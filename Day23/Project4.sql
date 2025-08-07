-- Step 1: Create and use database
CREATE DATABASE IF NOT EXISTS LibraryDB;
USE LibraryDB;

-- Step 2: Create tables

-- Books table
CREATE TABLE books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    isbn VARCHAR(20) NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(100),
    stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0)
);

-- Members table
CREATE TABLE members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE
);

-- Loans table
CREATE TABLE loans (
    loan_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT NOT NULL,
    book_id INT NOT NULL,
    loan_date DATE NOT NULL DEFAULT CURDATE(),
    return_date DATE DEFAULT NULL,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    -- CHECK constraint: max 3 active loans per member (return_date IS NULL means active loan)
    CONSTRAINT chk_max_active_loans CHECK (
        (
            SELECT COUNT(*) FROM loans l2
            WHERE l2.member_id = member_id AND l2.return_date IS NULL
        ) <= 3
    )
);

-- Step 3: Insert sample data

INSERT INTO books (isbn, title, author, stock) VALUES
('978-0140449136', 'The Odyssey', 'Homer', 5),
('978-0261103573', 'The Lord of the Rings', 'J.R.R. Tolkien', 3),
('978-0439139601', 'Harry Potter and the Goblet of Fire', 'J.K. Rowling', 4);

INSERT INTO members (name, email) VALUES
('Alice Smith', 'alice@example.com'),
('Bob Johnson', 'bob@example.com'),
('Carol Lee', 'carol@example.com');

-- Step 4: Procedure to loan a book with transaction & stock check

DELIMITER //
CREATE PROCEDURE loan_book(
    IN p_member_id INT,
    IN p_book_id INT
)
BEGIN
    DECLARE current_stock INT;
    DECLARE active_loans INT;

    -- Start transaction
    START TRANSACTION;

    -- Check current stock
    SELECT stock INTO current_stock FROM books WHERE book_id = p_book_id FOR UPDATE;

    IF current_stock <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book out of stock';
    END IF;

    -- Check active loans for member
    SELECT COUNT(*) INTO active_loans FROM loans WHERE member_id = p_member_id AND return_date IS NULL FOR UPDATE;

    IF active_loans >= 3 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Member has reached max active loans (3)';
    END IF;

    -- Insert loan record
    INSERT INTO loans (member_id, book_id) VALUES (p_member_id, p_book_id);

    -- Update stock
    UPDATE books SET stock = stock - 1 WHERE book_id = p_book_id;

    COMMIT;
END //
DELIMITER ;

-- Step 5: Procedure to return a book (delete loan or update return_date and increase stock)

DELIMITER //
CREATE PROCEDURE return_book(
    IN p_loan_id INT
)
BEGIN
    DECLARE v_book_id INT;

    START TRANSACTION;

    -- Find book id for this loan
    SELECT book_id INTO v_book_id FROM loans WHERE loan_id = p_loan_id;

    -- Update loan return_date
    UPDATE loans SET return_date = CURDATE() WHERE loan_id = p_loan_id;

    -- Increase stock
    UPDATE books SET stock = stock + 1 WHERE book_id = v_book_id;

    COMMIT;
END //
DELIMITER ;

-- Step 6: Temporarily disable CHECK constraint for bulk update (MySQL does not support disabling CHECK constraints directly)
-- Workaround: Drop and recreate constraint (simulate disabling)

-- Drop CHECK constraint (replace 'chk_max_active_loans' with your actual constraint name if needed)
ALTER TABLE loans DROP CHECK chk_max_active_loans;

-- Perform your bulk updates here (e.g. mass loan insertions)
-- Example bulk insert (dangerous if unchecked)
INSERT INTO loans (member_id, book_id, loan_date) VALUES (1, 3, CURDATE()), (1, 2, CURDATE());

-- Recreate the CHECK constraint
ALTER TABLE loans ADD CONSTRAINT chk_max_active_loans CHECK (
    (
        SELECT COUNT(*) FROM loans l2
        WHERE l2.member_id = member_id AND l2.return_date IS NULL
    ) <= 3
);

-- Step 7: Sample usage of loan_book procedure

-- Loan book id 1 (The Odyssey) to member 1 (Alice)
CALL loan_book(1, 1);

-- Loan book id 2 (LOTR) to member 1 (Alice)
CALL loan_book(1, 2);

-- Loan book id 3 (Harry Potter) to member 1 (Alice)
CALL loan_book(1, 3);

-- Attempt 4th loan to same member (should fail)
 CALL loan_book(1, 1); -- Uncomment to test error

-- Step 8: Returning a book

-- Suppose loan_id 1 is to be returned
CALL return_book(1);

-- Step 9: Check current loans and book stocks

SELECT * FROM books;
SELECT * FROM members;
SELECT * FROM loans;


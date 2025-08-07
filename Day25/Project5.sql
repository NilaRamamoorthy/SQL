-- Step 1: Create database and use it
CREATE DATABASE IF NOT EXISTS LibraryManagement;
USE LibraryManagement;

-- Step 2: Create normalized tables

-- Suppliers (e.g., book vendors)
CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_name VARCHAR(255) NOT NULL
);

-- Books table with supplier and purchase cost info
CREATE TABLE books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255),
    total_copies INT NOT NULL,
    available_copies INT NOT NULL,
    purchase_price DECIMAL(10,2),
    supplier_id INT,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

-- Members who borrow books
CREATE TABLE members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    member_name VARCHAR(255) NOT NULL,
    membership_date DATE NOT NULL
);

-- Issued books table
CREATE TABLE issued_books (
    issue_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT NOT NULL,
    book_id INT NOT NULL,
    issue_date DATE NOT NULL ,
    due_date DATE,
    return_date DATE,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

-- Step 3: View for members to see book availability (hide cost and supplier)
CREATE OR REPLACE VIEW view_book_availability AS
SELECT book_id, title, author, available_copies
FROM books;

-- Step 4: Function to calculate due date (e.g., 14 days after issue_date)
DELIMITER //
CREATE FUNCTION get_due_date(p_issue_date DATE) RETURNS DATE
DETERMINISTIC
BEGIN
    RETURN DATE_ADD(p_issue_date, INTERVAL 14 DAY);
END //
DELIMITER ;

-- Step 5: Procedure to issue a book to a member
DELIMITER //
CREATE PROCEDURE issue_book(
    IN p_member_id INT,
    IN p_book_id INT,
    OUT p_issue_id INT
)
BEGIN
    DECLARE v_available INT;

    -- Check availability
    SELECT available_copies INTO v_available FROM books WHERE book_id = p_book_id;
    IF v_available <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book not available for issuing';
    END IF;

    -- Insert issue record
    INSERT INTO issued_books(member_id, book_id, issue_date, due_date)
    VALUES (p_member_id, p_book_id, CURRENT_DATE, get_due_date(CURRENT_DATE));

    SET p_issue_id = LAST_INSERT_ID();

    -- Update availability in books table
    UPDATE books SET available_copies = available_copies - 1 WHERE book_id = p_book_id;
END //
DELIMITER ;

-- Step 6: Trigger after issuing book to update availability (redundant here, but per requirement)
DELIMITER //
CREATE TRIGGER after_issue
AFTER INSERT ON issued_books
FOR EACH ROW
BEGIN
    UPDATE books SET available_copies = available_copies - 1
    WHERE book_id = NEW.book_id AND available_copies > 0;
END //
DELIMITER ;

-- Step 7: Insert sample data

INSERT INTO suppliers (supplier_name) VALUES 
('Global Books Ltd.'),
('City Book Distributors');

INSERT INTO books (title, author, total_copies, available_copies, purchase_price, supplier_id) VALUES
('The Great Gatsby', 'F. Scott Fitzgerald', 5, 5, 15.00, 1),
('1984', 'George Orwell', 8, 8, 12.50, 2),
('To Kill a Mockingbird', 'Harper Lee', 7, 7, 14.00, 1);

INSERT INTO members (member_name, membership_date) VALUES
('John Doe', '2023-01-15'),
('Jane Smith', '2024-03-22');


 CALL issue_book(1, 2, @issue_id);
 SELECT @issue_id;


SELECT * FROM view_book_availability;

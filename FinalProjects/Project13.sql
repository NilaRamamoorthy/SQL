-- 1. Create Database
CREATE DATABASE library_management_system;
USE library_management_system;

-- 2. Create Tables

-- Books table
CREATE TABLE books (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(100) NOT NULL
);

-- Members table
CREATE TABLE members (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Borrows table
CREATE TABLE borrows (
    id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT NOT NULL,
    book_id INT NOT NULL,
    borrow_date DATE NOT NULL,
    return_date DATE,
    FOREIGN KEY (member_id) REFERENCES members(id),
    FOREIGN KEY (book_id) REFERENCES books(id)
);

-- 3. Insert Sample Data

-- Books
INSERT INTO books (title, author) VALUES
('The Great Gatsby', 'F. Scott Fitzgerald'),
('1984', 'George Orwell'),
('To Kill a Mockingbird', 'Harper Lee'),
('Pride and Prejudice', 'Jane Austen');

-- Members
INSERT INTO members (name) VALUES
('Alice Brown'),
('Bob Carter'),
('Charlie Davis');

-- Borrows
INSERT INTO borrows (member_id, book_id, borrow_date, return_date) VALUES
(1, 1, '2025-07-25', '2025-08-02'), -- Returned
(2, 2, '2025-07-30', NULL),         -- Not returned
(3, 3, '2025-08-01', '2025-08-06'), -- Returned
(1, 4, '2025-08-03', NULL);         -- Not returned

-- 4. Query: Join to get borrow details
SELECT 
    b.id AS borrow_id,
    m.name AS member_name,
    bk.title AS book_title,
    b.borrow_date,
    b.return_date,
    CASE 
        WHEN b.return_date IS NULL THEN 'Not Returned'
        ELSE 'Returned'
    END AS status
FROM borrows b
JOIN members m ON b.member_id = m.id
JOIN books bk ON b.book_id = bk.id
ORDER BY b.borrow_date;

-- 5. Query: Fine calculation (Assume fine = $2 per day after 7 days)
SELECT 
    m.name AS member_name,
    bk.title AS book_title,
    b.borrow_date,
    COALESCE(b.return_date, CURDATE()) AS actual_return_date,
    GREATEST(DATEDIFF(COALESCE(b.return_date, CURDATE()), b.borrow_date) - 7, 0) AS overdue_days,
    GREATEST(DATEDIFF(COALESCE(b.return_date, CURDATE()), b.borrow_date) - 7, 0) * 2 AS fine_amount
FROM borrows b
JOIN members m ON b.member_id = m.id
JOIN books bk ON b.book_id = bk.id
ORDER BY fine_amount DESC;

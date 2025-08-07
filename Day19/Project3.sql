--  Create and use database
DROP DATABASE IF EXISTS library_db;
CREATE DATABASE library_db;
USE library_db;

-- Create books table
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    author VARCHAR(100),
    total_copies INT DEFAULT 1
);

--  Create members table
CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100)
);

--  Create borrowings table
CREATE TABLE borrowings (
    borrow_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT,
    book_id INT,
    borrow_date DATE,
    due_date DATE,
    return_date DATE,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

--  Insert members
INSERT INTO members (name, email) VALUES
('Alice', 'alice@email.com'),
('Bob', 'bob@email.com'),
('Charlie', 'charlie@email.com'),
('Diana', 'diana@email.com'),
('Eve', 'eve@email.com'),
('Frank', 'frank@email.com'),
('Grace', 'grace@email.com'),
('Henry', 'henry@email.com'),
('Ivy', 'ivy@email.com'),
('Jack', 'jack@email.com');

--  Insert books
INSERT INTO books (title, author, total_copies) VALUES
('1984', 'George Orwell', 5),
('To Kill a Mockingbird', 'Harper Lee', 3),
('The Great Gatsby', 'F. Scott Fitzgerald', 4),
('Moby Dick', 'Herman Melville', 2),
('The Hobbit', 'J.R.R. Tolkien', 6),
('War and Peace', 'Leo Tolstoy', 2),
('Pride and Prejudice', 'Jane Austen', 5),
('Hamlet', 'William Shakespeare', 3),
('The Catcher in the Rye', 'J.D. Salinger', 4),
('Ulysses', 'James Joyce', 1);

--  Insert borrowings
INSERT INTO borrowings (member_id, book_id, borrow_date, due_date, return_date) VALUES
(1, 1, '2025-07-01', '2025-07-10', NULL),
(2, 2, '2025-07-03', '2025-07-12', '2025-07-10'),
(3, 3, '2025-07-05', '2025-07-15', NULL),
(4, 1, '2025-07-07', '2025-07-17', NULL),
(5, 5, '2025-07-09', '2025-07-19', '2025-07-18');

--  Queries:
-- 1. Books borrowed by a member
SELECT m.name, b.title, br.borrow_date
FROM borrowings br
JOIN members m ON br.member_id = m.member_id
JOIN books b ON br.book_id = b.book_id
WHERE m.name = 'Alice';

-- 2. Overdue books
SELECT m.name, b.title, br.due_date
FROM borrowings br
JOIN members m ON br.member_id = m.member_id
JOIN books b ON br.book_id = b.book_id
WHERE br.return_date IS NULL AND br.due_date < CURDATE();

-- 3. Most borrowed books
SELECT b.title, COUNT(*) AS borrow_count
FROM borrowings br
JOIN books b ON br.book_id = b.book_id
GROUP BY br.book_id
ORDER BY borrow_count DESC
LIMIT 5;

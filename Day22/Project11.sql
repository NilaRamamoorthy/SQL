-- 1. Create Database and Use
CREATE DATABASE IF NOT EXISTS library_circulation;
USE library_circulation;

-- 2. Create Tables

CREATE TABLE books (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255),
    genre VARCHAR(100)
);

CREATE TABLE members (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255)
);

CREATE TABLE loans (
    id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT,
    member_id INT,
    loan_date DATE,
    FOREIGN KEY (book_id) REFERENCES books(id),
    FOREIGN KEY (member_id) REFERENCES members(id)
);

CREATE TABLE returns (
    id INT PRIMARY KEY AUTO_INCREMENT,
    loan_id INT,
    return_date DATE,
    FOREIGN KEY (loan_id) REFERENCES loans(id)
);

-- 3. Insert Sample Data

INSERT INTO books (title, genre) VALUES
('The Great Gatsby', 'Fiction'),
('A Brief History of Time', 'Non-Fiction'),
('1984', 'Fiction'),
('Sapiens', 'Non-Fiction'),
('To Kill a Mockingbird', 'Fiction');

INSERT INTO members (name) VALUES
('Alice'),
('Bob'),
('Charlie'),
('David');

INSERT INTO loans (book_id, member_id, loan_date) VALUES
(1, 1, CURDATE() - INTERVAL 10 DAY),
(2, 1, CURDATE() - INTERVAL 30 DAY),
(3, 2, CURDATE() - INTERVAL 20 DAY),
(4, 3, CURDATE() - INTERVAL 100 DAY),
(5, 4, CURDATE() - INTERVAL 5 DAY),
(1, 2, CURDATE() - INTERVAL 60 DAY),
(2, 3, CURDATE() - INTERVAL 15 DAY);

INSERT INTO returns (loan_id, return_date) VALUES
(1, CURDATE() - INTERVAL 2 DAY),
(2, CURDATE() - INTERVAL 15 DAY),
(3, CURDATE() - INTERVAL 5 DAY),
(4, CURDATE() - INTERVAL 80 DAY);

-- 4a. Subquery to find books borrowed more than average times

SELECT 
    b.id, b.title,
    COUNT(l.id) AS borrow_count
FROM books b
JOIN loans l ON b.id = l.book_id
GROUP BY b.id, b.title
HAVING borrow_count > (
    SELECT AVG(book_borrow_count) FROM (
        SELECT COUNT(*) AS book_borrow_count FROM loans GROUP BY book_id
    ) AS avg_borrows
);

-- 4b. CASE to classify members based on total borrowings

SELECT 
    m.id, m.name,
    COUNT(l.id) AS total_borrows,
    CASE 
        WHEN COUNT(l.id) > 5 THEN 'Frequent Borrower'
        WHEN COUNT(l.id) BETWEEN 2 AND 5 THEN 'Occasional Borrower'
        ELSE 'Rare Borrower'
    END AS borrower_type
FROM members m
LEFT JOIN loans l ON m.id = l.member_id
GROUP BY m.id, m.name;

-- 4c. JOIN + GROUP BY to show most borrowed genres

SELECT 
    b.genre,
    COUNT(l.id) AS borrow_count
FROM books b
JOIN loans l ON b.id = l.book_id
GROUP BY b.genre
ORDER BY borrow_count DESC;

-- 4d. UNION to show active (borrowed in last 90 days) and inactive borrowers

SELECT DISTINCT
    m.id, m.name, 'Active' AS status
FROM members m
JOIN loans l ON m.id = l.member_id
WHERE l.loan_date >= CURDATE() - INTERVAL 90 DAY

UNION

SELECT DISTINCT
    m.id, m.name, 'Inactive' AS status
FROM members m
WHERE m.id NOT IN (
    SELECT DISTINCT member_id FROM loans WHERE loan_date >= CURDATE() - INTERVAL 90 DAY
);

-- 4e. INTERSECT for members who borrowed both Fiction and Non-Fiction

SELECT member_id FROM loans l
JOIN books b ON l.book_id = b.id
WHERE b.genre = 'Fiction'

INTERSECT

SELECT member_id FROM loans l
JOIN books b ON l.book_id = b.id
WHERE b.genre = 'Non-Fiction';

-- 4f. Date-based filtering for loans in the past 90 days

SELECT 
    l.id, l.book_id, b.title, l.member_id, m.name, l.loan_date
FROM loans l
JOIN books b ON l.book_id = b.id
JOIN members m ON l.member_id = m.id
WHERE l.loan_date >= CURDATE() - INTERVAL 90 DAY;

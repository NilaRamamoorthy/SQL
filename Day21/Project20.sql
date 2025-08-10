-- 1. Create Database
CREATE DATABASE public_library;
USE public_library;

-- 2. Create Tables

CREATE TABLE members (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE books (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255)
);

CREATE TABLE checkouts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT NOT NULL,
    book_id INT NOT NULL,
    checkout_date DATE NOT NULL,
    return_date DATE,
    FOREIGN KEY (member_id) REFERENCES members(id),
    FOREIGN KEY (book_id) REFERENCES books(id)
);

CREATE TABLE fines (
    id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    fine_date DATE NOT NULL,
    FOREIGN KEY (member_id) REFERENCES members(id)
);

-- 3. Insert Sample Data

INSERT INTO members (name) VALUES
('Alice'),
('Bob'),
('Charlie'),
('Diana'),
('Eve');

INSERT INTO books (title, author) VALUES
('The Great Gatsby', 'F. Scott Fitzgerald'),
('1984', 'George Orwell'),
('To Kill a Mockingbird', 'Harper Lee'),
('Pride and Prejudice', 'Jane Austen'),
('Moby-Dick', 'Herman Melville');

INSERT INTO checkouts (member_id, book_id, checkout_date, return_date) VALUES
(1, 1, '2025-01-10', '2025-01-20'),
(2, 1, '2025-01-22', '2025-02-01'),
(1, 2, '2025-02-10', '2025-02-20'),
(3, 2, '2025-02-25', NULL),
(4, 3, '2025-03-05', '2025-03-15'),
(1, 3, '2025-03-20', NULL),
(5, 4, '2025-03-25', NULL),
(2, 4, '2025-04-01', '2025-04-10'),
(3, 5, '2025-04-05', '2025-04-15'),
(1, 5, '2025-04-20', NULL),
(1, 1, '2025-05-01', NULL),
(2, 2, '2025-05-05', NULL),
(4, 1, '2025-05-10', NULL),
(5, 2, '2025-05-15', NULL),
(3, 3, '2025-05-20', NULL),
(5, 3, '2025-05-25', NULL),
(2, 5, '2025-05-30', NULL),
(4, 4, '2025-06-01', NULL),
(1, 2, '2025-06-05', NULL);

INSERT INTO fines (member_id, amount, fine_date) VALUES
(1, 600, '2025-01-30'),
(2, 450, '2025-02-15'),
(3, 700, '2025-03-20'),
(4, 200, '2025-04-10'),
(5, 800, '2025-05-05');

-- 4. Queries

-- a) Count books issued per member
SELECT 
    m.id AS member_id,
    m.name AS member_name,
    COUNT(c.id) AS books_issued
FROM members m
LEFT JOIN checkouts c ON m.id = c.member_id
GROUP BY m.id, m.name;

-- b) Members with fines over ₹500
SELECT 
    m.id AS member_id,
    m.name AS member_name,
    SUM(f.amount) AS total_fines
FROM members m
JOIN fines f ON m.id = f.member_id
GROUP BY m.id, m.name
HAVING total_fines > 500;

-- c) Books with more than 5 checkouts
SELECT 
    b.id AS book_id,
    b.title,
    COUNT(c.id) AS checkout_count
FROM books b
JOIN checkouts c ON b.id = c.book_id
GROUP BY b.id, b.title
HAVING checkout_count > 5;

-- d) INNER JOIN: checkouts ↔ members ↔ books (detailed checkout info)
SELECT 
    c.id AS checkout_id,
    m.name AS member_name,
    b.title AS book_title,
    c.checkout_date,
    c.return_date
FROM checkouts c
JOIN members m ON c.member_id = m.id
JOIN books b ON c.book_id = b.id
ORDER BY c.checkout_date;

-- e) LEFT JOIN: books ↔ checkouts (all books with their checkout counts)
SELECT 
    b.id AS book_id,
    b.title,
    COUNT(c.id) AS checkout_count
FROM books b
LEFT JOIN checkouts c ON b.id = c.book_id
GROUP BY b.id, b.title;

-- f) SELF JOIN: members who borrowed the same books
SELECT DISTINCT
    m1.id AS member1_id,
    m1.name AS member1_name,
    m2.id AS member2_id,
    m2.name AS member2_name,
    b.title AS book_title
FROM checkouts c1
JOIN checkouts c2 ON c1.book_id = c2.book_id AND c1.member_id < c2.member_id
JOIN members m1 ON c1.member_id = m1.id
JOIN members m2 ON c2.member_id = m2.id
JOIN books b ON c1.book_id = b.id
ORDER BY book_title, member1_name, member2_name;

-- 1. Create Database
CREATE DATABASE bookstore_analytics;
USE bookstore_analytics;

-- 2. Create Tables

CREATE TABLE authors (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE books (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    author_id INT NOT NULL,
    genre VARCHAR(100),
    rating DECIMAL(2,1), -- e.g., 4.6
    FOREIGN KEY (author_id) REFERENCES authors(id)
);

CREATE TABLE customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE sales (
    id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT NOT NULL,
    customer_id INT NOT NULL,
    sale_date DATE NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    FOREIGN KEY (book_id) REFERENCES books(id),
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

-- 3. Insert Sample Data

INSERT INTO authors (name) VALUES
('J.K. Rowling'),
('George R.R. Martin'),
('Agatha Christie'),
('J.R.R. Tolkien');

INSERT INTO books (title, author_id, genre, rating) VALUES
('Harry Potter and the Sorcerer''s Stone', 1, 'Fantasy', 4.8),
('A Game of Thrones', 2, 'Fantasy', 4.7),
('Murder on the Orient Express', 3, 'Mystery', 4.6),
('The Hobbit', 4, 'Fantasy', 4.9),
('The Silmarillion', 4, 'Fantasy', 4.2),
('Death on the Nile', 3, 'Mystery', 4.5);

INSERT INTO customers (name) VALUES
('Alice'),
('Bob'),
('Charlie'),
('Diana'),
('Eve');

INSERT INTO sales (book_id, customer_id, sale_date, quantity) VALUES
(1, 1, '2025-07-01', 10),
(2, 2, '2025-07-02', 20),
(3, 3, '2025-07-03', 5),
(1, 4, '2025-07-04', 15),
(4, 5, '2025-07-05', 50),
(4, 1, '2025-07-06', 60),
(2, 3, '2025-07-07', 30),
(6, 2, '2025-07-08', 7),
(1, 5, '2025-07-09', 5),
(5, 1, '2025-07-10', 12),
(3, 4, '2025-07-11', 8);

-- 4. Queries

-- a) Top-selling authors (GROUP BY author, SUM quantities)
SELECT
    a.id,
    a.name,
    SUM(s.quantity) AS total_sold
FROM authors a
JOIN books b ON a.id = b.author_id
JOIN sales s ON b.id = s.book_id
GROUP BY a.id, a.name
ORDER BY total_sold DESC;

-- b) Books with rating > 4.5 and sold more than 100 times
SELECT
    b.id,
    b.title,
    b.rating,
    SUM(s.quantity) AS total_sold
FROM books b
JOIN sales s ON b.id = s.book_id
GROUP BY b.id, b.title, b.rating
HAVING b.rating > 4.5 AND total_sold > 100;

-- c) Customers with more than 5 purchases (HAVING)
SELECT
    c.id,
    c.name,
    COUNT(s.id) AS purchase_count
FROM customers c
JOIN sales s ON c.id = s.customer_id
GROUP BY c.id, c.name
HAVING purchase_count > 5;

-- d) INNER JOIN books ↔ sales ↔ customers (show sales details)
SELECT
    b.title,
    c.name AS customer_name,
    s.sale_date,
    s.quantity
FROM sales s
JOIN books b ON s.book_id = b.id
JOIN customers c ON s.customer_id = c.id;

-- e) FULL OUTER JOIN authors ↔ books (list all authors and their books, including authors without books and books without authors)
-- MySQL does not support FULL OUTER JOIN directly; emulate using UNION of LEFT and RIGHT JOIN

-- Left join authors to books
SELECT
    a.id AS author_id,
    a.name AS author_name,
    b.id AS book_id,
    b.title AS book_title
FROM authors a
LEFT JOIN books b ON a.id = b.author_id

UNION

-- Right join authors to books (books without authors, if any)
SELECT
    a.id AS author_id,
    a.name AS author_name,
    b.id AS book_id,
    b.title AS book_title
FROM authors a
RIGHT JOIN books b ON a.id = b.author_id
WHERE a.id IS NULL;

-- f) SELF JOIN on books with the same genre
SELECT
    b1.id AS book1_id,
    b1.title AS book1_title,
    b2.id AS book2_id,
    b2.title AS book2_title,
    b1.genre
FROM books b1
JOIN books b2 ON b1.genre = b2.genre AND b1.id < b2.id
ORDER BY b1.genre, b1.title, b2.title;

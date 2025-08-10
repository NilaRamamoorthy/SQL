-- 1. Create Database and Use
CREATE DATABASE IF NOT EXISTS bookstore;
USE bookstore;

-- 2. Create Tables

CREATE TABLE authors (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE books (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    genre VARCHAR(100),
    author_id INT,
    format ENUM('Physical', 'eBook') NOT NULL,
    price DECIMAL(10, 2),
    FOREIGN KEY (author_id) REFERENCES authors(id)
);

CREATE TABLE customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    email VARCHAR(255)
);

CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    book_id INT,
    quantity INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (book_id) REFERENCES books(id)
);

-- 3. Insert Sample Data

INSERT INTO authors (name) VALUES
('J.K. Rowling'),
('George R.R. Martin'),
('Agatha Christie');

INSERT INTO books (title, genre, author_id, format, price) VALUES
('Harry Potter and the Sorcerer''s Stone', 'Fantasy', 1, 'Physical', 15.00),
('Harry Potter and the Sorcerer''s Stone', 'Fantasy', 1, 'eBook', 8.00),
('A Game of Thrones', 'Fantasy', 2, 'Physical', 20.00),
('A Game of Thrones', 'Fantasy', 2, 'eBook', 10.00),
('Murder on the Orient Express', 'Mystery', 3, 'Physical', 12.00);

INSERT INTO customers (name, email) VALUES
('Alice', 'alice@example.com'),
('Bob', 'bob@example.com');

INSERT INTO orders (customer_id, book_id, quantity, order_date) VALUES
(1, 1, 2, '2025-07-01'),
(1, 3, 1, '2025-07-03'),
(2, 4, 3, '2025-07-05'),
(2, 5, 1, '2025-06-20');

-- 4. Retrieve books, filter by genre (e.g., Fantasy)

SELECT DISTINCT
    b.id, b.title, b.genre, a.name AS author_name, b.format, b.price
FROM books b
JOIN authors a ON b.author_id = a.id
WHERE b.genre = 'Fantasy';

-- 5. Total and average sales per author

SELECT
    a.name AS author_name,
    SUM(o.quantity * b.price) AS total_sales,
    AVG(o.quantity * b.price) AS average_sale
FROM orders o
JOIN books b ON o.book_id = b.id
JOIN authors a ON b.author_id = a.id
GROUP BY a.id, a.name;

-- 6. Filter duplicate books using DISTINCT on title + author

SELECT DISTINCT
    b.title,
    a.name AS author_name
FROM books b
JOIN authors a ON b.author_id = a.id;

-- 7. Filter orders between two dates

SELECT
    o.id, c.name AS customer_name, b.title, o.quantity, o.order_date
FROM orders o
JOIN customers c ON o.customer_id = c.id
JOIN books b ON o.book_id = b.id
WHERE o.order_date BETWEEN '2025-07-01' AND '2025-07-31';

-- 8. Subquery in WHERE to find books never sold

SELECT
    b.id, b.title
FROM books b
WHERE b.id NOT IN (
    SELECT DISTINCT book_id FROM orders
);

-- 9. CASE WHEN to classify sales performance per book

SELECT
    b.title,
    SUM(o.quantity * b.price) AS revenue,
    CASE
        WHEN SUM(o.quantity * b.price) < 100 THEN 'Low'
        WHEN SUM(o.quantity * b.price) BETWEEN 100 AND 500 THEN 'Medium'
        ELSE 'High'
    END AS sales_performance
FROM books b
LEFT JOIN orders o ON b.id = o.book_id
GROUP BY b.id, b.title
ORDER BY revenue DESC;

-- 10. Sort books by revenue and author name

SELECT
    b.title,
    a.name AS author_name,
    SUM(o.quantity * b.price) AS revenue
FROM books b
JOIN authors a ON b.author_id = a.id
LEFT JOIN orders o ON b.id = o.book_id
GROUP BY b.id, a.name
ORDER BY revenue DESC, author_name ASC;

-- 11. UNION to merge physical and eBook sales summaries

SELECT
    'Physical' AS format,
    SUM(o.quantity * b.price) AS total_revenue,
    COUNT(DISTINCT o.id) AS total_orders
FROM books b
JOIN orders o ON b.id = o.book_id
WHERE b.format = 'Physical'

UNION ALL

SELECT
    'eBook' AS format,
    SUM(o.quantity * b.price) AS total_revenue,
    COUNT(DISTINCT o.id) AS total_orders
FROM books b
JOIN orders o ON b.id = o.book_id
WHERE b.format = 'eBook';

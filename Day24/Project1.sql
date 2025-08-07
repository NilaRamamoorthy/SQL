-- Step 1: Create normalized tables (3NF)
CREATE DATABASE OnlineBookstore;
USE OnlineBookstore;

-- Authors
CREATE TABLE authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

-- Genres
CREATE TABLE genres (
    genre_id INT PRIMARY KEY AUTO_INCREMENT,
    genre_name VARCHAR(100) NOT NULL UNIQUE
);

-- Publishers
CREATE TABLE publishers (
    publisher_id INT PRIMARY KEY AUTO_INCREMENT,
    publisher_name VARCHAR(255) NOT NULL UNIQUE
);

-- Books
CREATE TABLE books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    author_id INT NOT NULL,
    genre_id INT NOT NULL,
    publisher_id INT NOT NULL,
    price DECIMAL(10,2),
    FOREIGN KEY (author_id) REFERENCES authors(author_id),
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id),
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id)
);

-- Sales
CREATE TABLE sales (
    sale_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT NOT NULL,
    sale_date DATE NOT NULL,
    quantity INT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

-- Step 2: Create Indexes
CREATE INDEX idx_books_title ON books(title);
CREATE INDEX idx_books_author ON books(author_id);

-- Step 3: Sample Data Insertion

-- Authors
INSERT INTO authors (name) VALUES
('George Orwell'),
('Jane Austen'),
('J.K. Rowling'),
('Stephen King'),
('Agatha Christie');

-- Genres
INSERT INTO genres (genre_name) VALUES
('Fiction'),
('Fantasy'),
('Mystery'),
('Horror'),
('Romance');

-- Publishers
INSERT INTO publishers (publisher_name) VALUES
('Penguin Random House'),
('HarperCollins'),
('Bloomsbury'),
('Macmillan'),
('Simon & Schuster');

-- Books
INSERT INTO books (title, author_id, genre_id, publisher_id, price) VALUES
('1984', 1, 1, 1, 15.99),
('Pride and Prejudice', 2, 5, 2, 12.50),
('Harry Potter and the Sorcerer\'s Stone', 3, 2, 3, 20.00),
('The Shining', 4, 4, 4, 18.75),
('Murder on the Orient Express', 5, 3, 5, 14.99),
('Harry Potter and the Chamber of Secrets', 3, 2, 3, 21.00);

-- Sales
INSERT INTO sales (book_id, sale_date, quantity, total_amount) VALUES
(1, '2025-07-01', 10, 159.90),
(2, '2025-07-02', 5, 62.50),
(3, '2025-07-03', 20, 400.00),
(4, '2025-07-04', 8, 150.00),
(5, '2025-07-05', 12, 179.88),
(6, '2025-07-06', 15, 315.00),
(3, '2025-08-01', 10, 200.00),
(6, '2025-08-03', 5, 105.00);

-- Step 4: JOIN books with publisher and genre
SELECT b.book_id, b.title,
       a.name AS author,
       p.publisher_name,
       g.genre_name
FROM books b
JOIN authors a ON b.author_id = a.author_id
JOIN publishers p ON b.publisher_id = p.publisher_id
JOIN genres g ON b.genre_id = g.genre_id;

-- Step 5: Create denormalized summary table for monthly book sales
CREATE TABLE monthly_book_sales AS
SELECT
    YEAR(s.sale_date) AS year,
    MONTH(s.sale_date) AS month,
    b.book_id,
    b.title,
    SUM(s.quantity) AS total_quantity_sold,
    SUM(s.total_amount) AS total_sales_amount
FROM sales s
JOIN books b ON s.book_id = b.book_id
GROUP BY YEAR(s.sale_date), MONTH(s.sale_date), b.book_id, b.title;

-- Index for reporting
CREATE INDEX idx_monthly_sales_month ON monthly_book_sales(year, month);

-- Step 6: Pagination for best-selling books
-- Top 10
SELECT book_id, title, total_sales_amount
FROM monthly_book_sales
ORDER BY total_sales_amount DESC
LIMIT 10 OFFSET 0;

-- Page 2
SELECT book_id, title, total_sales_amount
FROM monthly_book_sales
ORDER BY total_sales_amount DESC
LIMIT 10 OFFSET 10;

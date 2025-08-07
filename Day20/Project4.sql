-- 1. Create the database and use it
CREATE DATABASE book_store;
USE book_store;


-- Table: book_id, title, author, genre, price, published_year, stock

CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    genre VARCHAR(50),
    price DECIMAL(10, 2),
    published_year INT,
    stock INT 
);
-- Insert sample data into the 'books' table
INSERT INTO books (title, author, genre, price, published_year, stock) VALUES
('To Kill a Mockingbird', 'Harper Lee', 'Fiction', 12.99, 1960, 100),
('1984', 'George Orwell', 'Dystopian', 9.99, 1949, 150),
('The Great Gatsby', 'F. Scott Fitzgerald', 'Classic', 8.99, 1925, 200),
('Pride and Prejudice', 'Jane Austen', 'Romance', 7.99, 1813, 120),
('The Catcher in the Rye', 'J.D. Salinger', 'Coming-of-age', 10.99, 1951, 80);

-- -- 1. Get all fiction books priced under 500, showing title, author, and price
SELECT title, author, price
FROM books
WHERE genre = 'Fiction' AND price < 500
ORDER BY published_year DESC, title ASC;

-- 2. List all distinct genres
SELECT DISTINCT genre
FROM books;

-- 3. Find titles that start with 'The'
SELECT title, author, price
FROM books
WHERE title LIKE 'The%'
ORDER BY published_year DESC, title ASC;

-- 4. Filter books published between 2010 and 2023
SELECT title, author, price
FROM books
WHERE published_year BETWEEN 2010 AND 2023
ORDER BY published_year DESC, title ASC;

-- 5. Identify books with NULL stock values
SELECT title, author, price
FROM books
WHERE stock IS NULL
ORDER BY published_year DESC, title ASC;

--  Sort by published_year DESC, then title ASC.
SELECT title, author, price,published_year
FROM books
ORDER BY published_year DESC, title ASC;
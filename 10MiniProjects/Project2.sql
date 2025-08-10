-- 1. Create Database and Use
CREATE DATABASE IF NOT EXISTS movie_rental;
USE movie_rental;

-- 2. Create Tables

CREATE TABLE genres (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE movies (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    genre_id INT,
    price DECIMAL(10,2),
    FOREIGN KEY (genre_id) REFERENCES genres(id)
);

CREATE TABLE customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255)
);

CREATE TABLE rentals (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    movie_id INT,
    rental_date DATE,
    return_date DATE,
    rental_fee DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (movie_id) REFERENCES movies(id)
);

CREATE TABLE purchases (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    movie_id INT,
    purchase_date DATE,
    purchase_price DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (movie_id) REFERENCES movies(id)
);

-- 3. Insert Sample Data

INSERT INTO genres (name) VALUES
('Action'), ('Comedy'), ('Drama');

INSERT INTO movies (title, genre_id, price) VALUES
('Avengers: Endgame', 1, 3.99),
('The Dark Knight', 1, 2.99),
('Superbad', 2, 1.99),
('The Hangover', 2, 2.49),
('The Shawshank Redemption', 3, 3.49);

INSERT INTO customers (name, email) VALUES
('John Doe', 'john@example.com'),
('Jane Smith', 'jane@example.com');

INSERT INTO rentals (customer_id, movie_id, rental_date, return_date, rental_fee) VALUES
(1, 1, '2025-07-01', '2025-07-05', 3.99),
(1, 2, '2025-07-02', NULL, 2.99),  -- unreturned
(2, 3, '2025-07-03', '2025-07-04', 1.99),
(2, 4, '2025-07-04', '2025-07-10', 2.49),
(2, 5, '2025-07-05', '2025-07-06', 3.49);

INSERT INTO purchases (customer_id, movie_id, purchase_date, purchase_price) VALUES
(1, 1, '2025-06-15', 19.99),
(2, 5, '2025-06-20', 14.99);

-- 4. Use LIKE to search movies by partial title (e.g., 'Dark')

SELECT id, title FROM movies WHERE title LIKE '%Dark%';

-- 5. Aggregate revenue per genre (sum rental_fee + purchase_price)

SELECT 
    g.name AS genre,
    COALESCE(SUM(r.rental_fee), 0) + COALESCE(SUM(p.purchase_price), 0) AS total_revenue
FROM genres g
LEFT JOIN movies m ON m.genre_id = g.id
LEFT JOIN rentals r ON r.movie_id = m.id
LEFT JOIN purchases p ON p.movie_id = m.id
GROUP BY g.id, g.name;

-- 6. Find unreturned movies (return_date IS NULL)

SELECT 
    r.id, c.name AS customer_name, m.title, r.rental_date
FROM rentals r
JOIN customers c ON r.customer_id = c.id
JOIN movies m ON r.movie_id = m.id
WHERE r.return_date IS NULL;

-- 7. Use CASE to label late returns (assuming due 7 days after rental_date)

SELECT
    r.id,
    c.name AS customer_name,
    m.title,
    r.rental_date,
    r.return_date,
    CASE
        WHEN r.return_date IS NULL THEN 'Not Returned'
        WHEN DATEDIFF(r.return_date, r.rental_date) > 7 THEN 'Late'
        ELSE 'On Time'
    END AS return_status
FROM rentals r
JOIN customers c ON r.customer_id = c.id
JOIN movies m ON r.movie_id = m.id;

-- 8. Subquery to find top 3 rented movies per genre

SELECT genre_name, movie_title, rental_count FROM (
    SELECT
        g.name AS genre_name,
        m.title AS movie_title,
        COUNT(r.id) AS rental_count,
        ROW_NUMBER() OVER (PARTITION BY g.id ORDER BY COUNT(r.id) DESC) AS rn
    FROM rentals r
    JOIN movies m ON r.movie_id = m.id
    JOIN genres g ON m.genre_id = g.id
    GROUP BY g.id, g.name, m.id, m.title
) AS ranked
WHERE rn <= 3;

-- 9. Combine rental and purchase data using UNION ALL

SELECT
    customer_id,
    movie_id,
    rental_date AS activity_date,
    rental_fee AS amount,
    'Rental' AS activity_type
FROM rentals

UNION ALL

SELECT
    customer_id,
    movie_id,
    purchase_date AS activity_date,
    purchase_price AS amount,
    'Purchase' AS activity_type
FROM purchases

ORDER BY activity_date DESC;

-- 10. JOIN to fetch full customer and rental info

SELECT
    r.id AS rental_id,
    c.name AS customer_name,
    m.title AS movie_title,
    r.rental_date,
    r.return_date,
    r.rental_fee
FROM rentals r
JOIN customers c ON r.customer_id = c.id
JOIN movies m ON r.movie_id = m.id
ORDER BY r.rental_date DESC;

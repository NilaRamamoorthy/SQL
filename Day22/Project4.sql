-- 1. Create Database and Use
CREATE DATABASE IF NOT EXISTS movie_booking_analytics;
USE movie_booking_analytics;

-- 2. Create Tables
CREATE TABLE movies (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255)
);

CREATE TABLE customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255)
);

CREATE TABLE theatres (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    location VARCHAR(255)
);

CREATE TABLE bookings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    movie_id INT,
    customer_id INT,
    theatre_id INT,
    booking_time DATETIME,
    FOREIGN KEY (movie_id) REFERENCES movies(id),
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (theatre_id) REFERENCES theatres(id)
);

-- 3. Insert Sample Data

INSERT INTO movies (title) VALUES
('Avengers'),
('Batman'),
('Spiderman'),
('Joker');

INSERT INTO customers (name) VALUES
('Alice'),
('Bob'),
('Charlie'),
('David'),
('Eva');

INSERT INTO theatres (name, location) VALUES
('Cinema One', 'Downtown'),
('Cinema Two', 'Uptown');

INSERT INTO bookings (movie_id, customer_id, theatre_id, booking_time) VALUES
(1, 1, 1, '2025-07-01 09:30:00'),  -- Avengers, Alice
(1, 2, 1, '2025-07-02 13:00:00'),  -- Avengers, Bob
(2, 2, 1, '2025-07-02 15:30:00'),  -- Batman, Bob
(2, 3, 2, '2025-07-03 18:00:00'),  -- Batman, Charlie
(3, 4, 2, '2025-07-04 20:00:00'),  -- Spiderman, David
(1, 5, 1, '2025-07-05 11:00:00'),  -- Avengers, Eva
(2, 5, 1, '2025-07-05 19:00:00'),  -- Batman, Eva
(4, 1, 2, '2025-07-06 14:00:00');  -- Joker, Alice

-- 4a. Subquery: Movies with bookings above average number of bookings
SELECT 
    m.id,
    m.title,
    COUNT(b.id) AS total_bookings
FROM movies m
JOIN bookings b ON m.id = b.movie_id
GROUP BY m.id, m.title
HAVING total_bookings > (
    SELECT AVG(movie_count) FROM (
        SELECT COUNT(*) AS movie_count
        FROM bookings
        GROUP BY movie_id
    ) AS avg_table
);

-- 4b. JOIN bookings ↔ movies ↔ customers
SELECT 
    b.id AS booking_id,
    m.title AS movie_title,
    c.name AS customer_name,
    b.booking_time
FROM bookings b
JOIN movies m ON b.movie_id = m.id
JOIN customers c ON b.customer_id = c.id;

-- 4c. CASE to classify booking times as Morning, Afternoon, Evening
SELECT 
    b.id,
    m.title,
    c.name,
    b.booking_time,
    CASE 
        WHEN HOUR(b.booking_time) BETWEEN 5 AND 11 THEN 'Morning'
        WHEN HOUR(b.booking_time) BETWEEN 12 AND 16 THEN 'Afternoon'
        WHEN HOUR(b.booking_time) BETWEEN 17 AND 21 THEN 'Evening'
        ELSE 'Night'
    END AS time_of_day
FROM bookings b
JOIN movies m ON b.movie_id = m.id
JOIN customers c ON b.customer_id = c.id;

-- 4d. INTERSECT to find customers who watched both "Avengers" and "Batman"
-- MySQL doesn't support INTERSECT directly, so emulate with INNER JOIN between two subqueries

SELECT DISTINCT customer_id
FROM bookings
WHERE movie_id = (SELECT id FROM movies WHERE title = 'Avengers')
AND customer_id IN (
    SELECT customer_id
    FROM bookings
    WHERE movie_id = (SELECT id FROM movies WHERE title = 'Batman')
);

-- 4e. UNION ALL to combine weekend and weekday ticket sales
-- Assuming WEEKDAY() 0=Monday ... 6=Sunday

SELECT 
    b.id, m.title, c.name, b.booking_time, 'Weekday' AS day_type
FROM bookings b
JOIN movies m ON b.movie_id = m.id
JOIN customers c ON b.customer_id = c.id
WHERE WEEKDAY(b.booking_time) BETWEEN 0 AND 4

UNION ALL

SELECT 
    b.id, m.title, c.name, b.booking_time, 'Weekend' AS day_type
FROM bookings b
JOIN movies m ON b.movie_id = m.id
JOIN customers c ON b.customer_id = c.id
WHERE WEEKDAY(b.booking_time) IN (5,6);

-- 4f. Correlated subquery: Find customer who booked the most in each theatre
SELECT 
    t.id AS theatre_id,
    t.name AS theatre_name,
    (
        SELECT c.name
        FROM customers c
        JOIN bookings b ON c.id = b.customer_id
        WHERE b.theatre_id = t.id
        GROUP BY c.id, c.name
        ORDER BY COUNT(b.id) DESC
        LIMIT 1
    ) AS top_customer
FROM theatres t;

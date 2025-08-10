-- 1. Create Database
CREATE DATABASE IF NOT EXISTS cinema_analytics;
USE cinema_analytics;

-- 2. OLTP Tables

CREATE TABLE theaters (
    theater_id INT PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(50),
    total_seats INT
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    city VARCHAR(50)
);

CREATE TABLE movies (
    movie_id INT PRIMARY KEY,
    title VARCHAR(255),
    genre VARCHAR(50),
    duration_minutes INT
);

CREATE TABLE shows (
    show_id INT PRIMARY KEY,
    movie_id INT,
    theater_id INT,
    show_time DATETIME,
    ticket_price DECIMAL(10,2),  -- price in USD by default
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id),
    FOREIGN KEY (theater_id) REFERENCES theaters(theater_id)
);

CREATE TABLE bookings (
    booking_id INT PRIMARY KEY,
    show_id INT,
    customer_id INT,
    seats_booked INT,
    booking_time DATETIME,
    currency CHAR(3) DEFAULT 'USD', -- currency code for price paid
    price_paid DECIMAL(10,2), -- amount paid in the specified currency
    FOREIGN KEY (show_id) REFERENCES shows(show_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 3. Star Schema Warehouse Tables

CREATE TABLE dim_movie (
    movie_id INT PRIMARY KEY,
    title VARCHAR(255),
    genre VARCHAR(50),
    duration_minutes INT
);

CREATE TABLE dim_time (
    time_id INT PRIMARY KEY AUTO_INCREMENT,
    show_date DATE,
    show_hour INT,
    show_minute INT,
    day_of_week VARCHAR(10),
    month VARCHAR(20),
    year INT
);

CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    city VARCHAR(50)
);

CREATE TABLE fact_bookings (
    fact_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT,
    movie_id INT,
    customer_id INT,
    theater_id INT,
    time_id INT,
    seats_booked INT,
    price_usd DECIMAL(10,2),
    FOREIGN KEY (movie_id) REFERENCES dim_movie(movie_id),
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    FOREIGN KEY (time_id) REFERENCES dim_time(time_id)
);

-- 4. Insert Sample Data for OLTP tables

INSERT INTO theaters VALUES
(1, 'Grand Cinema', 'New York', 150),
(2, 'Cineplex', 'Los Angeles', 200),
(3, 'Movie Palace', 'Chicago', 120);

INSERT INTO customers VALUES
(101, 'Alice Johnson', 'alice@example.com', 'New York'),
(102, 'Bob Smith', 'bob@example.com', 'Los Angeles'),
(103, 'Carol Davis', 'carol@example.com', 'Chicago');

INSERT INTO movies VALUES
(201, 'Avengers: Endgame', 'Action', 181),
(202, 'The Notebook', 'Romance', 123),
(203, 'Inception', 'Sci-Fi', 148);

INSERT INTO shows VALUES
(301, 201, 1, '2025-08-10 19:00:00', 15.00),
(302, 201, 2, '2025-08-10 20:00:00', 16.00),
(303, 202, 1, '2025-08-10 18:00:00', 12.00),
(304, 203, 3, '2025-08-11 21:00:00', 14.00);

INSERT INTO bookings VALUES
(401, 301, 101, 2, '2025-08-01 10:30:00', 'USD', 30.00),
(402, 301, 102, 1, '2025-08-02 12:00:00', 'USD', 15.00),
(403, 302, 103, 3, '2025-08-03 14:00:00', 'USD', 48.00),
(404, 303, 101, 1, '2025-08-04 16:00:00', 'USD', 12.00),
(405, 304, 102, 2, '2025-08-05 18:00:00', 'USD', 28.00);

-- 5. ETL: Load dimension tables

INSERT INTO dim_movie SELECT * FROM movies;

INSERT INTO dim_customer SELECT * FROM customers;

-- Populate dim_time from shows

INSERT INTO dim_time (show_date, show_hour, show_minute, day_of_week, month, year)
SELECT
    DATE(show_time),
    HOUR(show_time),
    MINUTE(show_time),
    DAYNAME(show_time),
    MONTHNAME(show_time),
    YEAR(show_time)
FROM shows;

-- Create a helper to link show_time to time_id in dim_time
-- We'll assume show_time in shows matches one row in dim_time exactly.

-- 6. ETL: Load fact_bookings with currency standardization to USD
-- For this example, assume all prices are USD so conversion is 1:1.
-- If there were other currencies, you'd apply a conversion factor here.

INSERT INTO fact_bookings (booking_id, movie_id, customer_id, theater_id, time_id, seats_booked, price_usd)
SELECT
    b.booking_id,
    s.movie_id,
    b.customer_id,
    s.theater_id,
    dt.time_id,
    b.seats_booked,
    b.price_paid -- Assuming USD for simplicity
FROM bookings b
JOIN shows s ON b.show_id = s.show_id
JOIN dim_time dt ON DATE(s.show_time) = dt.show_date AND HOUR(s.show_time) = dt.show_hour AND MINUTE(s.show_time) = dt.show_minute;

-- 7. OLAP Queries

-- a) Occupancy rate by movie (seats booked / total seats)

SELECT 
    m.title,
    SUM(f.seats_booked) AS total_seats_booked,
    SUM(t.total_seats) AS total_seats_available,
    ROUND(SUM(f.seats_booked) * 100.0 / SUM(t.total_seats), 2) AS occupancy_rate_percent
FROM fact_bookings f
JOIN dim_movie m ON f.movie_id = m.movie_id
JOIN theaters t ON f.theater_id = t.theater_id
GROUP BY m.title
ORDER BY occupancy_rate_percent DESC;

-- b) Genre-based trend analysis (total seats booked by genre, monthly)

SELECT 
    m.genre,
    dt.month,
    dt.year,
    SUM(f.seats_booked) AS total_seats_booked
FROM fact_bookings f
JOIN dim_movie m ON f.movie_id = m.movie_id
JOIN dim_time dt ON f.time_id = dt.time_id
GROUP BY m.genre, dt.month, dt.year
ORDER BY dt.year, dt.month, m.genre;

-- c) Compare real-time OLTP check-ins with OLAP historical insights
-- Example: Count bookings in OLTP for a specific date vs OLAP fact table

-- OLTP count for 2025-08-10
SELECT COUNT(*) AS oltp_bookings_count
FROM bookings b
JOIN shows s ON b.show_id = s.show_id
WHERE DATE(s.show_time) = '2025-08-10';

-- OLAP count for 2025-08-10
SELECT COUNT(*) AS olap_bookings_count
FROM fact_bookings f
JOIN dim_time dt ON f.time_id = dt.time_id
WHERE dt.show_date = '2025-08-10';


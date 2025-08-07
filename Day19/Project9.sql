-- Create database and use
DROP DATABASE IF EXISTS cinema_db;
CREATE DATABASE cinema_db;
USE cinema_db;

-- Create tables
CREATE TABLE movies (
  movie_id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(100) NOT NULL,
  duration_minutes INT NOT NULL
);

CREATE TABLE screens (
  screen_id INT AUTO_INCREMENT PRIMARY KEY,
  screen_name VARCHAR(50) NOT NULL,
  capacity INT NOT NULL
);

CREATE TABLE customers (
  customer_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE
);

CREATE TABLE bookings (
  booking_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  movie_id INT NOT NULL,
  screen_id INT NOT NULL,
  show_time DATETIME NOT NULL,
  seats_booked INT NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  FOREIGN KEY (movie_id) REFERENCES movies(movie_id),
  FOREIGN KEY (screen_id) REFERENCES screens(screen_id)
);

-- Insert sample data
INSERT INTO movies (title, duration_minutes) VALUES
('Space Adventure', 120),
('Romantic Mystery', 105),
('Comedy Nights', 90),
('Action Heroes', 130),
('Sci‑Fi Saga', 150);

INSERT INTO screens (screen_name, capacity) VALUES
('Screen A', 100),
('Screen B', 80),
('Screen C', 120);

INSERT INTO customers (name, email) VALUES
('Alice','a@example.com'),
('Bob','b@example.com'),
('Charlie','c@example.com'),
('Diana','d@example.com'),
('Eve','e@example.com'),
('Frank','f@example.com'),
('Grace','g@example.com'),
('Henry','h@example.com');

INSERT INTO bookings (customer_id, movie_id, screen_id, show_time, seats_booked) VALUES
(1,1,1,'2025-08-01 17:00:00',2),
(2,1,1,'2025-08-01 17:00:00',4),
(3,2,2,'2025-08-01 19:00:00',3),
(4,3,2,'2025-08-01 20:00:00',1),
(5,1,1,'2025-08-02 17:00:00',5),
(6,4,3,'2025-08-02 21:00:00',2),
(7,5,3,'2025-08-02 21:00:00',3),
(8,2,2,'2025-08-03 19:00:00',2),
(1,3,2,'2025-08-03 20:00:00',4),
(2,4,3,'2025-08-03 21:00:00',1),
(3,5,3,'2025-08-04 21:00:00',2),
(4,2,2,'2025-08-04 19:00:00',3),
(5,3,1,'2025-08-04 20:00:00',2),
(6,1,1,'2025-08-04 17:00:00',1),
(7,4,3,'2025-08-05 21:00:00',2);

-- Queries

-- 1. Booked seats per show (per movie + show_time + screen)
SELECT m.title, b.show_time, s.screen_name, SUM(b.seats_booked) AS seats_total
FROM bookings b
JOIN movies m ON m.movie_id = b.movie_id
JOIN screens s ON s.screen_id = b.screen_id
GROUP BY b.movie_id, b.show_time, b.screen_id
ORDER BY b.show_time;

-- 2. Top 3 most watched movies
SELECT m.title, SUM(b.seats_booked) AS total_seats
FROM bookings b
JOIN movies m ON m.movie_id = b.movie_id
GROUP BY b.movie_id
ORDER BY total_seats DESC
LIMIT 3;

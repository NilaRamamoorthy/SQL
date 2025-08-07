-- Create the database
CREATE DATABASE IF NOT EXISTS flights;
USE flights;

-- Create the flights table
CREATE TABLE flights (
  flight_id INT AUTO_INCREMENT PRIMARY KEY,
  flight_number VARCHAR(10) NOT NULL,
  origin VARCHAR(50) NOT NULL,
  destination VARCHAR(50) NOT NULL,
  status VARCHAR(20),
  departure_time DATETIME NOT NULL
);

-- Insert sample data
INSERT INTO flights (flight_number, origin, destination, status, departure_time) VALUES
('AI202', 'Delhi', 'Chennai', 'On Time',  '2025-08-06 10:00:00'),
('AI203', 'Mumbai', 'Chennai', 'Delayed', '2025-08-06 12:00:00'),
('AI204', 'Delhi', 'Mumbai',  'On Time',  '2025-08-06 14:00:00'),
('AI205', 'Chennai', 'Delhi', 'Cancelled','2025-08-06 16:00:00'),
('AI206', 'Mumbai', 'Delhi',  'On Time',  '2025-08-06 18:00:00'),
('BA123', 'Kolkata', 'Chennai', NULL,       '2025-08-06 09:00:00'),
('GA999AI', 'Goa', 'Mumbai',   'On Time',  '2025-08-06 20:00:00');

-- Queries based on requirements

-- 1. Flights going to Chennai or Mumbai
SELECT flight_number, origin, destination
FROM flights
WHERE destination IN ('Chennai', 'Mumbai')
ORDER BY departure_time ASC;

-- 2. Flights whose flight_number ends with 'AI'
SELECT flight_number, origin, destination
FROM flights
WHERE flight_number LIKE '%AI'
ORDER BY departure_time ASC;

-- 3. Flights departing within a specific day (e.g., 2025‑08‑06)
SELECT flight_number, origin, destination
FROM flights
WHERE departure_time BETWEEN '2025-08-06 00:00:00' AND '2025-08-06 23:59:59'
ORDER BY departure_time ASC;

-- 4. Flights with NULL status
SELECT flight_number, origin, destination
FROM flights
WHERE status IS NULL
ORDER BY departure_time ASC;

-- 5. List all unique destinations
SELECT DISTINCT destination
FROM flights
ORDER BY destination ASC;

-- Create database and use it
CREATE DATABASE IF NOT EXISTS bus_route_db;
USE bus_route_db;

-- Create routes table
CREATE TABLE routes (
  route_id INT AUTO_INCREMENT PRIMARY KEY,
  bus_no VARCHAR(20) NOT NULL,
  origin VARCHAR(50) NOT NULL,
  destination VARCHAR(50) NOT NULL,
  departure DATETIME NOT NULL,
  arrival DATETIME NOT NULL,
  status VARCHAR(20)
);

-- Insert sample data
INSERT INTO routes (bus_no, origin, destination, departure, arrival, status) VALUES
('TN25AB999', 'Coimbatore', 'Madurai', '2025-08-04 08:00:00', '2025-08-04 11:00:00', 'On Time'),
('TN25AB123', 'Chennai',    'Madurai', '2025-08-05 09:00:00', '2025-08-05 14:00:00', NULL),
('TN25AB789', 'Coimbatore', 'Tiruppur', '2025-08-06 07:30:00', '2025-08-06 10:30:00', 'Delayed'),
('TN25AB456', 'Coimbatore', 'Salem',    '2025-08-03 06:30:00', '2025-08-03 10:00:00', 'On Time'),
('TN25AB999AI','Coimbatore','Maduripur', '2025-08-06 12:00:00', '2025-08-06 15:00:00', 'On Time');

-- 1. Buses that go from Coimbatore to Madurai — show bus_no, departure, arrival
SELECT bus_no, departure, arrival
FROM routes
WHERE origin = 'Coimbatore'
  AND destination = 'Madurai'
ORDER BY departure ASC;

-- 2. Destinations ending with “pur” using LIKE
SELECT bus_no, origin, destination
FROM routes
WHERE destination LIKE '%pur'
ORDER BY departure ASC;

-- 3. Routes with status IS NULL
SELECT bus_no, origin, destination, departure
FROM routes
WHERE status IS NULL
ORDER BY departure ASC;

-- 4. List distinct service origins or destinations (e.g. distinct destinations)
SELECT DISTINCT destination
FROM routes
ORDER BY destination ASC;

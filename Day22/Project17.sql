-- 1. Create Database and Use
CREATE DATABASE IF NOT EXISTS ride_sharing_app;
USE ride_sharing_app;

-- 2. Create Tables

CREATE TABLE drivers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    city VARCHAR(100)
);

CREATE TABLE riders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    city VARCHAR(100)
);

CREATE TABLE rides (
    id INT PRIMARY KEY AUTO_INCREMENT,
    driver_id INT,
    rider_id INT,
    ride_type ENUM('Shared', 'Premium', 'Economy'),
    start_time DATETIME,
    end_time DATETIME,
    status ENUM('Completed', 'Cancelled'),
    city VARCHAR(100),
    FOREIGN KEY (driver_id) REFERENCES drivers(id),
    FOREIGN KEY (rider_id) REFERENCES riders(id)
);

CREATE TABLE payments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ride_id INT,
    amount DECIMAL(10,2),
    payment_time DATETIME,
    FOREIGN KEY (ride_id) REFERENCES rides(id)
);

-- 3. Insert Sample Data

INSERT INTO drivers (name, city) VALUES
('Alice', 'New York'),
('Bob', 'San Francisco'),
('Charlie', 'New York');

INSERT INTO riders (name, city) VALUES
('Eve', 'New York'),
('Mallory', 'San Francisco'),
('Trent', 'New York'),
('Oscar', 'San Francisco');

INSERT INTO rides (driver_id, rider_id, ride_type, start_time, end_time, status, city) VALUES
(1, 1, 'Shared', '2025-08-10 08:00:00', '2025-08-10 08:30:00', 'Completed', 'New York'),
(1, 3, 'Premium', '2025-08-10 09:00:00', '2025-08-10 09:45:00', 'Completed', 'New York'),
(2, 2, 'Economy', '2025-08-10 18:00:00', '2025-08-10 18:20:00', 'Cancelled', 'San Francisco'),
(3, 1, 'Shared', '2025-08-10 19:00:00', '2025-08-10 19:40:00', 'Completed', 'New York'),
(2, 4, 'Premium', '2025-08-10 20:00:00', '2025-08-10 20:30:00', 'Completed', 'San Francisco'),
(3, 3, 'Economy', '2025-08-10 07:30:00', '2025-08-10 08:00:00', 'Completed', 'New York');

INSERT INTO payments (ride_id, amount, payment_time) VALUES
(1, 15.50, '2025-08-10 08:30:00'),
(2, 40.00, '2025-08-10 09:45:00'),
(4, 12.00, '2025-08-10 19:40:00'),
(5, 30.00, '2025-08-10 20:30:00'),
(6, 10.00, '2025-08-10 08:00:00');

-- 4. Query: Subquery to find average ride duration per driver (in minutes)

SELECT 
    d.id AS driver_id,
    d.name AS driver_name,
    AVG(TIMESTAMPDIFF(MINUTE, r.start_time, r.end_time)) AS avg_ride_duration_minutes
FROM drivers d
JOIN rides r ON d.id = r.driver_id
WHERE r.status = 'Completed'
GROUP BY d.id, d.name;

-- 5. Query: Correlated subquery to get rider with most rides per city

SELECT 
    r.city,
    r.name AS rider_name,
    (
        SELECT COUNT(*)
        FROM rides ri
        WHERE ri.rider_id = r.id
    ) AS ride_count
FROM riders r
WHERE
    (
        SELECT COUNT(*)
        FROM rides ri
        WHERE ri.rider_id = r.id
    ) = (
        SELECT MAX(sub_count) FROM (
            SELECT rider_id, COUNT(*) AS sub_count 
            FROM rides 
            WHERE city = r.city
            GROUP BY rider_id
        ) AS city_rides
    );

-- 6. Query: CASE to classify ride types

SELECT
    id,
    ride_type,
    CASE 
        WHEN ride_type = 'Shared' THEN 'Shared'
        WHEN ride_type = 'Premium' THEN 'Premium'
        WHEN ride_type = 'Economy' THEN 'Economy'
        ELSE 'Other'
    END AS ride_classification
FROM rides;

-- 7. Query: UNION for completed and cancelled rides

SELECT * FROM rides WHERE status = 'Completed'
UNION ALL
SELECT * FROM rides WHERE status = 'Cancelled';

-- 8. Query: JOIN + GROUP BY for city-wise earnings

SELECT 
    r.city,
    SUM(p.amount) AS total_earnings
FROM rides r
JOIN payments p ON r.id = p.ride_id
GROUP BY r.city;

-- 9. Query: Date range filter for peak hours (e.g., 7AM to 10AM)

SELECT 
    r.id,
    r.driver_id,
    r.rider_id,
    r.start_time,
    r.end_time,
    r.status
FROM rides r
WHERE TIME(r.start_time) BETWEEN '07:00:00' AND '10:00:00';

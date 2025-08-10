-- 1. Create Database
CREATE DATABASE flight_booking;
USE flight_booking;

-- 2. Create Tables

CREATE TABLE airlines (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE flights (
    id INT PRIMARY KEY AUTO_INCREMENT,
    airline_id INT NOT NULL,
    flight_number VARCHAR(20) NOT NULL,
    route VARCHAR(100) NOT NULL,  -- e.g., "NYC-LAX"
    capacity INT NOT NULL,
    FOREIGN KEY (airline_id) REFERENCES airlines(id)
);

CREATE TABLE passengers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE bookings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    flight_id INT NOT NULL,
    passenger_id INT NOT NULL,
    booking_date DATE NOT NULL,
    FOREIGN KEY (flight_id) REFERENCES flights(id),
    FOREIGN KEY (passenger_id) REFERENCES passengers(id)
);

-- 3. Insert Sample Data

INSERT INTO airlines (name) VALUES
('Air Alpha'),
('Beta Airlines'),
('Gamma Flights');

INSERT INTO flights (airline_id, flight_number, route, capacity) VALUES
(1, 'AA101', 'NYC-LAX', 200),
(1, 'AA102', 'NYC-SFO', 180),
(2, 'BA201', 'LAX-CHI', 150),
(2, 'BA202', 'CHI-MIA', 170),
(3, 'GF301', 'MIA-NYC', 160);

INSERT INTO passengers (name) VALUES
('John Doe'),
('Jane Smith'),
('Alice Johnson'),
('Bob Brown'),
('Charlie Davis');

INSERT INTO bookings (flight_id, passenger_id, booking_date) VALUES
(1, 1, '2025-07-01'),
(1, 2, '2025-07-02'),
(1, 3, '2025-07-03'),
(2, 1, '2025-07-04'),
(2, 4, '2025-07-05'),
(3, 2, '2025-07-06'),
(3, 3, '2025-07-07'),
(3, 5, '2025-07-08'),
(4, 1, '2025-07-09'),
(4, 2, '2025-07-10'),
(5, 4, '2025-07-11'),
(5, 5, '2025-07-12'),
(1, 5, '2025-07-13'),
(2, 3, '2025-07-14');

-- 4. Queries

-- a) Total bookings per airline
SELECT
    a.id AS airline_id,
    a.name AS airline_name,
    COUNT(b.id) AS total_bookings
FROM airlines a
LEFT JOIN flights f ON a.id = f.airline_id
LEFT JOIN bookings b ON f.id = b.flight_id
GROUP BY a.id, a.name;

-- b) Most frequent flyers (passengers with most bookings)
SELECT
    p.id AS passenger_id,
    p.name AS passenger_name,
    COUNT(b.id) AS bookings_count
FROM passengers p
JOIN bookings b ON p.id = b.passenger_id
GROUP BY p.id, p.name
ORDER BY bookings_count DESC;

-- c) Flights with avg occupancy > 80% (based on bookings / capacity)
SELECT
    f.id AS flight_id,
    f.flight_number,
    f.route,
    f.capacity,
    COUNT(b.id) AS bookings_count,
    ROUND((COUNT(b.id) / f.capacity) * 100, 2) AS occupancy_percentage
FROM flights f
LEFT JOIN bookings b ON f.id = b.flight_id
GROUP BY f.id, f.flight_number, f.route, f.capacity
HAVING occupancy_percentage > 80;

-- d) INNER JOIN bookings ↔ flights ↔ passengers (booking details)
SELECT
    b.id AS booking_id,
    p.name AS passenger_name,
    f.flight_number,
    f.route,
    a.name AS airline_name,
    b.booking_date
FROM bookings b
JOIN flights f ON b.flight_id = f.id
JOIN passengers p ON b.passenger_id = p.id
JOIN airlines a ON f.airline_id = a.id
ORDER BY b.booking_date;

-- e) RIGHT JOIN airlines ↔ flights (all airlines including those with no flights)
SELECT
    a.id AS airline_id,
    a.name AS airline_name,
    f.id AS flight_id,
    f.flight_number
FROM flights f
RIGHT JOIN airlines a ON f.airline_id = a.id
ORDER BY a.id;

-- f) SELF JOIN passengers who flew same routes (passenger pairs with at least one common flight route)
SELECT DISTINCT
    p1.id AS passenger1_id,
    p1.name AS passenger1_name,
    p2.id AS passenger2_id,
    p2.name AS passenger2_name,
    f.route
FROM bookings b1
JOIN bookings b2 ON b1.flight_id = b2.flight_id AND b1.passenger_id < b2.passenger_id
JOIN passengers p1 ON b1.passenger_id = p1.id
JOIN passengers p2 ON b2.passenger_id = p2.id
JOIN flights f ON b1.flight_id = f.id
ORDER BY f.route, passenger1_id, passenger2_id;

-- 1. Create Database
CREATE DATABASE IF NOT EXISTS airline_analytics;
USE airline_analytics;

-- 2. OLTP Tables

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE aircrafts (
    aircraft_id INT PRIMARY KEY,
    model VARCHAR(50),
    carrier VARCHAR(100)
);

CREATE TABLE routes (
    route_id INT PRIMARY KEY,
    origin VARCHAR(50),
    destination VARCHAR(50),
    distance_km INT
);

CREATE TABLE flights (
    flight_id INT PRIMARY KEY,
    route_id INT,
    aircraft_id INT,
    scheduled_departure DATETIME,
    scheduled_arrival DATETIME,
    actual_departure DATETIME,
    actual_arrival DATETIME,
    FOREIGN KEY (route_id) REFERENCES routes(route_id),
    FOREIGN KEY (aircraft_id) REFERENCES aircrafts(aircraft_id)
);

CREATE TABLE bookings (
    booking_id INT PRIMARY KEY,
    flight_id INT,
    customer_id INT,
    booking_date DATETIME,
    seat VARCHAR(10),
    FOREIGN KEY (flight_id) REFERENCES flights(flight_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 3. Warehouse Star Schema Tables

CREATE TABLE dim_route (
    route_id INT PRIMARY KEY,
    origin VARCHAR(50),
    destination VARCHAR(50),
    distance_km INT
);

CREATE TABLE dim_aircraft (
    aircraft_id INT PRIMARY KEY,
    model VARCHAR(50),
    carrier VARCHAR(100)
);

CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE fact_flights (
    fact_id INT PRIMARY KEY AUTO_INCREMENT,
    flight_id INT,
    route_id INT,
    aircraft_id INT,
    customer_id INT,
    scheduled_departure DATETIME,
    scheduled_arrival DATETIME,
    actual_departure DATETIME,
    actual_arrival DATETIME,
    flight_duration_minutes INT,
    delay_minutes INT,
    booking_date DATETIME
);

-- 4. Sample Data Insertions

INSERT INTO customers VALUES
(1, 'Alice Johnson', 'alice@example.com'),
(2, 'Bob Smith', 'bob@example.com'),
(3, 'Carol Lee', 'carol@example.com');

INSERT INTO aircrafts VALUES
(1, 'Boeing 737', 'AirwaysX'),
(2, 'Airbus A320', 'FlyHigh'),
(3, 'Boeing 777', 'AirwaysX');

INSERT INTO routes VALUES
(1, 'New York', 'Los Angeles', 3935),
(2, 'Chicago', 'Miami', 1920),
(3, 'Dallas', 'Seattle', 2760);

INSERT INTO flights VALUES
(101, 1, 1, '2025-08-10 08:00:00', '2025-08-10 11:00:00', '2025-08-10 08:10:00', '2025-08-10 11:05:00'),
(102, 2, 2, '2025-08-10 09:00:00', '2025-08-10 12:00:00', '2025-08-10 09:00:00', '2025-08-10 12:10:00'),
(103, 3, 3, '2025-08-10 07:30:00', '2025-08-10 10:30:00', '2025-08-10 07:40:00', '2025-08-10 10:20:00');

INSERT INTO bookings VALUES
(201, 101, 1, '2025-07-01 10:00:00', '12A'),
(202, 101, 2, '2025-07-02 11:30:00', '12B'),
(203, 102, 3, '2025-07-05 15:00:00', '14C');

-- 5. ETL: Load dim tables

INSERT INTO dim_route SELECT * FROM routes;
INSERT INTO dim_aircraft SELECT * FROM aircrafts;
INSERT INTO dim_customer SELECT * FROM customers;

-- 6. ETL: Load fact table with calculated flight_duration and delay in minutes

INSERT INTO fact_flights
(flight_id, route_id, aircraft_id, customer_id, scheduled_departure, scheduled_arrival,
 actual_departure, actual_arrival, flight_duration_minutes, delay_minutes, booking_date)
SELECT
    f.flight_id,
    f.route_id,
    f.aircraft_id,
    b.customer_id,
    f.scheduled_departure,
    f.scheduled_arrival,
    f.actual_departure,
    f.actual_arrival,
    TIMESTAMPDIFF(MINUTE, f.actual_departure, f.actual_arrival) AS flight_duration_minutes,
    GREATEST(TIMESTAMPDIFF(MINUTE, f.scheduled_departure, f.actual_departure), 0) AS delay_minutes,
    b.booking_date
FROM flights f
JOIN bookings b ON f.flight_id = b.flight_id;

-- 7. OLAP Queries

-- a) Average delay by route (origin → destination)
SELECT
    r.origin,
    r.destination,
    AVG(f.delay_minutes) AS avg_delay_minutes,
    COUNT(f.fact_id) AS total_flights
FROM fact_flights f
JOIN dim_route r ON f.route_id = r.route_id
GROUP BY r.origin, r.destination
ORDER BY avg_delay_minutes DESC;

-- b) Carrier ranking by average delay and flight count
SELECT
    a.carrier,
    AVG(f.delay_minutes) AS avg_delay_minutes,
    COUNT(f.fact_id) AS total_flights
FROM fact_flights f
JOIN dim_aircraft a ON f.aircraft_id = a.aircraft_id
GROUP BY a.carrier
ORDER BY avg_delay_minutes, total_flights DESC;

-- c) Flights with delays over 15 minutes
SELECT
    f.flight_id,
    r.origin,
    r.destination,
    a.model,
    a.carrier,
    f.delay_minutes
FROM fact_flights f
JOIN dim_route r ON f.route_id = r.route_id
JOIN dim_aircraft a ON f.aircraft_id = a.aircraft_id
WHERE f.delay_minutes > 15
ORDER BY f.delay_minutes DESC;

-- d) Compare OLTP system (detailed flights) vs Warehouse (aggregated delays)
-- Example: OLTP raw data: detailed flight times
SELECT
    flight_id, scheduled_departure, actual_departure, scheduled_arrival, actual_arrival
FROM flights
ORDER BY flight_id;

-- Warehouse summary example:
SELECT
    origin, destination, AVG(delay_minutes) AS avg_delay
FROM fact_flights f
JOIN dim_route r ON f.route_id = r.route_id
GROUP BY origin, destination;


-- 1. Create Database
CREATE DATABASE IF NOT EXISTS hotel_management;
USE hotel_management;

-- 2. OLTP Tables

CREATE TABLE rooms (
    room_id INT PRIMARY KEY,
    room_number VARCHAR(10),
    room_type_id INT
);

CREATE TABLE room_types (
    room_type_id INT PRIMARY KEY,
    type_name VARCHAR(50),
    base_rate DECIMAL(10,2)
);

CREATE TABLE guests (
    guest_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE services (
    service_id INT PRIMARY KEY,
    service_name VARCHAR(100),
    service_cost DECIMAL(10,2)
);

CREATE TABLE bookings (
    booking_id INT PRIMARY KEY,
    guest_id INT,
    room_id INT,
    check_in DATETIME,
    check_out DATETIME,
    service_id INT,
    service_qty INT DEFAULT 0,
    FOREIGN KEY (guest_id) REFERENCES guests(guest_id),
    FOREIGN KEY (room_id) REFERENCES rooms(room_id),
    FOREIGN KEY (service_id) REFERENCES services(service_id)
);

-- 3. Snowflake Schema Warehouse Tables

CREATE TABLE dim_room_type (
    room_type_id INT PRIMARY KEY,
    type_name VARCHAR(50),
    base_rate DECIMAL(10,2)
);

CREATE TABLE dim_room (
    room_id INT PRIMARY KEY,
    room_number VARCHAR(10),
    room_type_id INT,
    FOREIGN KEY (room_type_id) REFERENCES dim_room_type(room_type_id)
);

CREATE TABLE dim_guest (
    guest_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE dim_service (
    service_id INT PRIMARY KEY,
    service_name VARCHAR(100),
    service_cost DECIMAL(10,2)
);

CREATE TABLE dim_time (
    time_id INT PRIMARY KEY AUTO_INCREMENT,
    date DATE,
    day_of_week VARCHAR(10),
    month VARCHAR(20),
    year INT,
    season VARCHAR(10) -- e.g., Winter, Spring, Summer, Fall
);

CREATE TABLE fact_bookings (
    fact_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT,
    guest_id INT,
    room_id INT,
    room_type_id INT,
    service_id INT,
    time_id INT,
    stay_duration_days INT,
    room_revenue DECIMAL(10,2),
    service_revenue DECIMAL(10,2),
    total_revenue DECIMAL(10,2),
    FOREIGN KEY (guest_id) REFERENCES dim_guest(guest_id),
    FOREIGN KEY (room_id) REFERENCES dim_room(room_id),
    FOREIGN KEY (room_type_id) REFERENCES dim_room_type(room_type_id),
    FOREIGN KEY (service_id) REFERENCES dim_service(service_id),
    FOREIGN KEY (time_id) REFERENCES dim_time(time_id)
);

-- 4. Insert Sample Data into OLTP Tables

INSERT INTO room_types VALUES
(1, 'Economy', 100.00),
(2, 'Deluxe', 180.00),
(3, 'Suite', 300.00);

INSERT INTO rooms VALUES
(101, '101', 1),
(102, '102', 1),
(201, '201', 2),
(202, '202', 2),
(301, '301', 3);

INSERT INTO guests VALUES
(1001, 'Alice Johnson', 'alice@example.com'),
(1002, 'Bob Smith', 'bob@example.com'),
(1003, 'Carol White', 'carol@example.com');

INSERT INTO services VALUES
(1, 'Breakfast', 15.00),
(2, 'Spa', 50.00),
(3, 'Airport Pickup', 30.00);

INSERT INTO bookings VALUES
(5001, 1001, 101, '2025-08-01 14:00:00', '2025-08-05 12:00:00', 1, 4),
(5002, 1002, 201, '2025-08-02 15:00:00', '2025-08-04 11:00:00', 2, 1),
(5003, 1003, 301, '2025-08-03 13:00:00', '2025-08-10 10:00:00', NULL, 0);

-- 5. ETL: Load dimension tables from OLTP

INSERT INTO dim_room_type SELECT * FROM room_types;
INSERT INTO dim_room SELECT * FROM rooms;
INSERT INTO dim_guest SELECT * FROM guests;
INSERT INTO dim_service SELECT * FROM services;

-- Insert distinct booking dates and season info into dim_time

INSERT INTO dim_time (date, day_of_week, month, year, season)
SELECT DISTINCT
    DATE(check_in),
    DAYNAME(check_in),
    MONTHNAME(check_in),
    YEAR(check_in),
    CASE
        WHEN MONTH(check_in) IN (12,1,2) THEN 'Winter'
        WHEN MONTH(check_in) IN (3,4,5) THEN 'Spring'
        WHEN MONTH(check_in) IN (6,7,8) THEN 'Summer'
        WHEN MONTH(check_in) IN (9,10,11) THEN 'Fall'
        ELSE 'Unknown'
    END
FROM bookings;

-- 6. ETL: Load fact_bookings with calculated stay duration and revenues

INSERT INTO fact_bookings (booking_id, guest_id, room_id, room_type_id, service_id, time_id, stay_duration_days, room_revenue, service_revenue, total_revenue)
SELECT
    b.booking_id,
    b.guest_id,
    b.room_id,
    r.room_type_id,
    b.service_id,
    dt.time_id,
    DATEDIFF(DATE(b.check_out), DATE(b.check_in)) AS stay_duration_days,
    (DATEDIFF(DATE(b.check_out), DATE(b.check_in)) * rt.base_rate) AS room_revenue,
    COALESCE(b.service_qty * s.service_cost, 0) AS service_revenue,
    (DATEDIFF(DATE(b.check_out), DATE(b.check_in)) * rt.base_rate) + COALESCE(b.service_qty * s.service_cost, 0) AS total_revenue
FROM bookings b
JOIN dim_room r ON b.room_id = r.room_id
JOIN dim_room_type rt ON r.room_type_id = rt.room_type_id
LEFT JOIN dim_service s ON b.service_id = s.service_id
JOIN dim_time dt ON DATE(b.check_in) = dt.date;

-- 7. OLAP Queries

-- a) Occupancy by season (count of bookings per season)

SELECT
    dt.season,
    COUNT(f.fact_id) AS total_bookings,
    SUM(f.stay_duration_days) AS total_room_nights
FROM fact_bookings f
JOIN dim_time dt ON f.time_id = dt.time_id
GROUP BY dt.season
ORDER BY total_bookings DESC;

-- b) Room type profitability (total revenue per room type)

SELECT
    rt.type_name,
    COUNT(f.fact_id) AS bookings_count,
    SUM(f.room_revenue) AS total_room_revenue,
    SUM(f.service_revenue) AS total_service_revenue,
    SUM(f.total_revenue) AS total_revenue
FROM fact_bookings f
JOIN dim_room_type rt ON f.room_type_id = rt.room_type_id
GROUP BY rt.type_name
ORDER BY total_revenue DESC;

-- c) Average stay duration per room type

SELECT
    rt.type_name,
    AVG(f.stay_duration_days) AS avg_stay_days
FROM fact_bookings f
JOIN dim_room_type rt ON f.room_type_id = rt.room_type_id
GROUP BY rt.type_name;


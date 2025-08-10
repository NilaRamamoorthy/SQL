-- 1. Create Database
CREATE DATABASE IF NOT EXISTS logistics_reporting;
USE logistics_reporting;

-- 2. OLTP Tables

CREATE TABLE vehicles (
    vehicle_id INT PRIMARY KEY,
    vehicle_type VARCHAR(50),
    license_plate VARCHAR(20)
);

CREATE TABLE drivers (
    driver_id INT PRIMARY KEY,
    name VARCHAR(100),
    license_number VARCHAR(50)
);

CREATE TABLE routes (
    route_id INT PRIMARY KEY,
    start_location VARCHAR(100),
    end_location VARCHAR(100),
    distance_km DECIMAL(6,2)
);

CREATE TABLE deliveries (
    delivery_id INT PRIMARY KEY,
    vehicle_id INT,
    driver_id INT,
    route_id INT,
    delivery_start DATETIME,
    delivery_end DATETIME,
    fuel_used_liters DECIMAL(6,2),
    gps_start_lat DECIMAL(9,6),
    gps_start_long DECIMAL(9,6),
    gps_end_lat DECIMAL(9,6),
    gps_end_long DECIMAL(9,6),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id),
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id),
    FOREIGN KEY (route_id) REFERENCES routes(route_id)
);

-- 3. Star Schema Warehouse Tables

CREATE TABLE dim_vehicle (
    vehicle_id INT PRIMARY KEY,
    vehicle_type VARCHAR(50),
    license_plate VARCHAR(20)
);

CREATE TABLE dim_driver (
    driver_id INT PRIMARY KEY,
    name VARCHAR(100),
    license_number VARCHAR(50)
);

CREATE TABLE dim_route (
    route_id INT PRIMARY KEY,
    start_location VARCHAR(100),
    end_location VARCHAR(100),
    distance_km DECIMAL(6,2)
);

CREATE TABLE dim_time (
    time_id INT PRIMARY KEY AUTO_INCREMENT,
    delivery_date DATE,
    delivery_start_hour INT,
    delivery_end_hour INT,
    day_of_week VARCHAR(10),
    month VARCHAR(20),
    year INT
);

CREATE TABLE fact_deliveries (
    fact_id INT PRIMARY KEY AUTO_INCREMENT,
    delivery_id INT,
    vehicle_id INT,
    driver_id INT,
    route_id INT,
    time_id INT,
    fuel_used_liters DECIMAL(6,2),
    delivery_duration_minutes INT,
    FOREIGN KEY (vehicle_id) REFERENCES dim_vehicle(vehicle_id),
    FOREIGN KEY (driver_id) REFERENCES dim_driver(driver_id),
    FOREIGN KEY (route_id) REFERENCES dim_route(route_id),
    FOREIGN KEY (time_id) REFERENCES dim_time(time_id)
);

-- 4. Insert Sample Data into OLTP Tables

INSERT INTO vehicles VALUES
(1, 'Truck', 'ABC-1234'),
(2, 'Van', 'XYZ-5678'),
(3, 'Trailer', 'LMN-9012');

INSERT INTO drivers VALUES
(101, 'John Doe', 'D-123456'),
(102, 'Jane Smith', 'D-654321'),
(103, 'Alice Brown', 'D-112233');

INSERT INTO routes VALUES
(201, 'Warehouse A', 'Store X', 120.5),
(202, 'Warehouse B', 'Store Y', 85.0),
(203, 'Warehouse A', 'Store Z', 150.75);

INSERT INTO deliveries VALUES
(301, 1, 101, 201, '2025-08-01 08:00:00', '2025-08-01 12:30:00', 45.5, 40.712776, -74.005974, 40.678178, -73.944158),
(302, 2, 102, 202, '2025-08-02 09:00:00', '2025-08-02 11:15:00', 20.0, 34.052235, -118.243683, 34.040713, -118.246769),
(303, 3, 103, 203, '2025-08-03 07:45:00', '2025-08-03 13:00:00', 55.3, 40.712776, -74.005974, 40.789142, -73.134960);

-- 5. ETL: Load dimension tables from OLTP

INSERT INTO dim_vehicle SELECT * FROM vehicles;

INSERT INTO dim_driver SELECT * FROM drivers;

INSERT INTO dim_route SELECT * FROM routes;

-- Insert distinct delivery dates and time info into dim_time

INSERT INTO dim_time (delivery_date, delivery_start_hour, delivery_end_hour, day_of_week, month, year)
SELECT DISTINCT
    DATE(delivery_start),
    HOUR(delivery_start),
    HOUR(delivery_end),
    DAYNAME(delivery_start),
    MONTHNAME(delivery_start),
    YEAR(delivery_start)
FROM deliveries;

-- 6. ETL: Load fact_deliveries with duration calculation and cleaned GPS

INSERT INTO fact_deliveries (delivery_id, vehicle_id, driver_id, route_id, time_id, fuel_used_liters, delivery_duration_minutes)
SELECT
    d.delivery_id,
    d.vehicle_id,
    d.driver_id,
    d.route_id,
    dt.time_id,
    d.fuel_used_liters,
    TIMESTAMPDIFF(MINUTE, d.delivery_start, d.delivery_end) AS delivery_duration_minutes
FROM deliveries d
JOIN dim_time dt ON DATE(d.delivery_start) = dt.delivery_date AND HOUR(d.delivery_start) = dt.delivery_start_hour AND HOUR(d.delivery_end) = dt.delivery_end_hour;

-- 7. OLAP Queries

-- a) Fuel usage per vehicle type

SELECT
    v.vehicle_type,
    SUM(f.fuel_used_liters) AS total_fuel_used,
    AVG(f.fuel_used_liters) AS avg_fuel_per_delivery
FROM fact_deliveries f
JOIN dim_vehicle v ON f.vehicle_id = v.vehicle_id
GROUP BY v.vehicle_type
ORDER BY total_fuel_used DESC;

-- b) Driver performance: total deliveries and avg delivery duration

SELECT
    dr.name,
    COUNT(f.fact_id) AS total_deliveries,
    AVG(f.delivery_duration_minutes) AS avg_delivery_duration_minutes
FROM fact_deliveries f
JOIN dim_driver dr ON f.driver_id = dr.driver_id
GROUP BY dr.name
ORDER BY total_deliveries DESC;

-- c) Route utilization and distance vs fuel efficiency

SELECT
    r.start_location,
    r.end_location,
    r.distance_km,
    SUM(f.fuel_used_liters) AS total_fuel_used,
    ROUND(r.distance_km / NULLIF(SUM(f.fuel_used_liters), 0), 2) AS km_per_liter
FROM fact_deliveries f
JOIN dim_route r ON f.route_id = r.route_id
GROUP BY r.route_id
ORDER BY km_per_liter DESC;


-- 1. Create Database
CREATE DATABASE IF NOT EXISTS food_delivery_reporting;
USE food_delivery_reporting;

-- 2. OLTP Tables

CREATE TABLE drivers (
    driver_id INT PRIMARY KEY,
    driver_name VARCHAR(100),
    region VARCHAR(100)
);

CREATE TABLE restaurants (
    restaurant_id INT PRIMARY KEY,
    restaurant_name VARCHAR(255),
    category VARCHAR(100), -- e.g., Fast Food, Italian
    location_id INT
);

CREATE TABLE locations (
    location_id INT PRIMARY KEY,
    city VARCHAR(100),
    region VARCHAR(100),
    zipcode VARCHAR(20)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(255),
    location_id INT,
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    restaurant_id INT,
    driver_id INT,
    order_placed DATETIME,
    order_delivered DATETIME,
    total_cost DECIMAL(8,2),
    delivery_fee DECIMAL(6,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id),
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
);

-- 3. Warehouse Snowflake Schema Tables

CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(255),
    location_id INT
);

CREATE TABLE dim_location (
    location_id INT PRIMARY KEY,
    city VARCHAR(100),
    region VARCHAR(100),
    zipcode VARCHAR(20)
);

CREATE TABLE dim_restaurant (
    restaurant_id INT PRIMARY KEY,
    restaurant_name VARCHAR(255),
    category VARCHAR(100),
    location_id INT
);

CREATE TABLE dim_driver (
    driver_id INT PRIMARY KEY,
    driver_name VARCHAR(100),
    region VARCHAR(100)
);

CREATE TABLE fact_order_delivery (
    fact_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    customer_id INT,
    restaurant_id INT,
    driver_id INT,
    location_id INT,
    order_placed DATETIME,
    order_delivered DATETIME,
    delivery_duration_minutes INT,
    food_cost DECIMAL(8,2),
    delivery_fee DECIMAL(6,2),
    total_cost DECIMAL(8,2)
);

-- 4. Sample Data Insertions

INSERT INTO locations VALUES
(1, 'Mumbai', 'West', '400001'),
(2, 'Pune', 'West', '411001'),
(3, 'Delhi', 'North', '110001');

INSERT INTO customers VALUES
(1, 'Ravi Kumar', 1),
(2, 'Anita Sharma', 2),
(3, 'Sunil Mehta', 3);

INSERT INTO drivers VALUES
(1, 'Rajesh Singh', 'West'),
(2, 'Manish Patel', 'West'),
(3, 'Vikram Gupta', 'North');

INSERT INTO restaurants VALUES
(1, 'Spicy Indian', 'Indian', 1),
(2, 'Pizza Delight', 'Italian', 2),
(3, 'Burger Hub', 'Fast Food', 3);

INSERT INTO orders VALUES
(1001, 1, 1, 1, '2025-08-01 12:00:00', '2025-08-01 12:35:00', 500.00, 50.00),
(1002, 2, 2, 2, '2025-08-01 13:15:00', '2025-08-01 13:50:00', 750.00, 60.00),
(1003, 3, 3, 3, '2025-08-01 18:00:00', '2025-08-01 18:40:00', 300.00, 40.00);

-- 5. ETL Process (simulate insert into warehouse fact and dims)

-- Insert dims
INSERT INTO dim_location SELECT * FROM locations;
INSERT INTO dim_customer SELECT * FROM customers;
INSERT INTO dim_driver SELECT * FROM drivers;
INSERT INTO dim_restaurant SELECT * FROM restaurants;

-- Insert fact with calculated delivery duration and food cost
INSERT INTO fact_order_delivery
(order_id, customer_id, restaurant_id, driver_id, location_id,
 order_placed, order_delivered, delivery_duration_minutes, food_cost, delivery_fee, total_cost)
SELECT
    o.order_id,
    o.customer_id,
    o.restaurant_id,
    o.driver_id,
    c.location_id,
    o.order_placed,
    o.order_delivered,
    TIMESTAMPDIFF(MINUTE, o.order_placed, o.order_delivered) AS delivery_duration_minutes,
    o.total_cost - o.delivery_fee AS food_cost,
    o.delivery_fee,
    o.total_cost
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;

-- 6. OLAP Queries

-- a) Average delivery time by region
SELECT
    l.region,
    AVG(f.delivery_duration_minutes) AS avg_delivery_time_minutes,
    COUNT(f.fact_id) AS total_deliveries
FROM fact_order_delivery f
JOIN dim_location l ON f.location_id = l.location_id
GROUP BY l.region
ORDER BY avg_delivery_time_minutes;

-- b) Food category trends: total orders and revenue by category
SELECT
    r.category,
    COUNT(f.fact_id) AS total_orders,
    SUM(f.food_cost) AS total_food_revenue
FROM fact_order_delivery f
JOIN dim_restaurant r ON f.restaurant_id = r.restaurant_id
GROUP BY r.category
ORDER BY total_orders DESC;

-- c) City-wise KPIs: total orders, avg delivery fee
SELECT
    l.city,
    COUNT(f.fact_id) AS total_orders,
    AVG(f.delivery_fee) AS avg_delivery_fee
FROM fact_order_delivery f
JOIN dim_location l ON f.location_id = l.location_id
GROUP BY l.city;

-- d) Vendor-wise KPIs: driver deliveries and avg delivery duration
SELECT
    d.driver_name,
    COUNT(f.fact_id) AS deliveries_completed,
    AVG(f.delivery_duration_minutes) AS avg_delivery_time
FROM fact_order_delivery f
JOIN dim_driver d ON f.driver_id = d.driver_id
GROUP BY d.driver_name
ORDER BY deliveries_completed DESC;

-- 1. Create Database and Use It
CREATE DATABASE IF NOT EXISTS ecommerce_warehouse;
USE ecommerce_warehouse;

-- 2. Create Dimension Tables (Normalized for Snowflake Schema)

-- Customer dimension normalized into Customer and Location
CREATE TABLE dim_location (
    location_id INT PRIMARY KEY,
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100)
);

CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(255),
    email VARCHAR(255),
    location_id INT,
    gender CHAR(1),
    age INT,
    loyalty_status VARCHAR(50),
    FOREIGN KEY (location_id) REFERENCES dim_location(location_id)
);

-- Product dimension normalized into Product and Category
CREATE TABLE dim_category (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100),
    department VARCHAR(100)
);

CREATE TABLE dim_product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    category_id INT,
    brand VARCHAR(100),
    price DECIMAL(10,2),
    FOREIGN KEY (category_id) REFERENCES dim_category(category_id)
);

-- Time dimension for orders
CREATE TABLE dim_time (
    time_id INT PRIMARY KEY,
    order_date DATE,
    day INT,
    month INT,
    quarter INT,
    year INT,
    day_of_week VARCHAR(10),
    is_weekend BOOLEAN
);

-- 3. Create Fact Table
CREATE TABLE fact_orders (
    order_id BIGINT PRIMARY KEY,
    time_id INT,
    customer_id INT,
    product_id INT,
    quantity INT,
    total_amount DECIMAL(15,2),
    FOREIGN KEY (time_id) REFERENCES dim_time(time_id),
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id)
);

-- 4. Insert Sample Data

-- dim_location
INSERT INTO dim_location VALUES
(1, 'New York', 'NY', 'USA'),
(2, 'San Francisco', 'CA', 'USA'),
(3, 'Chicago', 'IL', 'USA');

-- dim_customer
INSERT INTO dim_customer VALUES
(101, 'Alice Johnson', 'alice@example.com', 1, 'F', 30, 'Gold'),
(102, 'Bob Smith', 'bob@example.com', 2, 'M', 45, 'Silver'),
(103, 'Carol Lee', 'carol@example.com', 3, 'F', 28, 'Bronze');

-- dim_category
INSERT INTO dim_category VALUES
(1, 'Electronics', 'Technology'),
(2, 'Furniture', 'Home'),
(3, 'Books', 'Media');

-- dim_product
INSERT INTO dim_product VALUES
(1001, 'Laptop Pro 15"', 1, 'TechBrand', 1500.00),
(1002, 'Wireless Mouse', 1, 'ClickTech', 25.00),
(1003, 'Office Chair', 2, 'ComfortCo', 200.00),
(1004, 'Programming Book', 3, 'EduPress', 50.00);

-- dim_time (sample dates)
INSERT INTO dim_time VALUES
(1, '2025-01-01', 1, 1, 1, 2025, 'Wednesday', TRUE),
(2, '2025-01-02', 2, 1, 1, 2025, 'Thursday', FALSE),
(3, '2025-01-03', 3, 1, 1, 2025, 'Friday', FALSE),
(4, '2025-01-04', 4, 1, 1, 2025, 'Saturday', TRUE),
(5, '2025-01-05', 5, 1, 1, 2025, 'Sunday', TRUE);

-- fact_orders
INSERT INTO fact_orders VALUES
(5001, 1, 101, 1001, 1, 1500.00),
(5002, 1, 102, 1002, 2, 50.00),
(5003, 2, 103, 1003, 1, 200.00),
(5004, 3, 101, 1004, 3, 150.00),
(5005, 4, 102, 1001, 1, 1500.00),
(5006, 5, 103, 1002, 5, 125.00);

-- 5. Sample OLAP Queries

-- a) Top-selling products by total quantity sold
SELECT 
    p.product_name,
    SUM(f.quantity) AS total_units_sold,
    SUM(f.total_amount) AS total_revenue
FROM fact_orders f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_units_sold DESC;

-- b) Seasonal sales trend: total revenue by month
SELECT 
    t.year,
    t.month,
    SUM(f.total_amount) AS monthly_revenue
FROM fact_orders f
JOIN dim_time t ON f.time_id = t.time_id
GROUP BY t.year, t.month
ORDER BY t.year, t.month;

-- c) Drill-down: Revenue by product category then by brand
SELECT 
    c.category_name,
    p.brand,
    SUM(f.total_amount) AS revenue
FROM fact_orders f
JOIN dim_product p ON f.product_id = p.product_id
JOIN dim_category c ON p.category_id = c.category_id
GROUP BY c.category_name, p.brand
ORDER BY c.category_name, revenue DESC;

-- d) Roll-up: Total revenue by category
SELECT 
    c.category_name,
    SUM(f.total_amount) AS total_revenue
FROM fact_orders f
JOIN dim_product p ON f.product_id = p.product_id
JOIN dim_category c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY total_revenue DESC;


-- 1. Create Database and Use It
CREATE DATABASE IF NOT EXISTS retail_sales_analysis;
USE retail_sales_analysis;

-- 2. Create Dimension Tables

CREATE TABLE dim_time (
    time_id INT PRIMARY KEY,
    date DATE NOT NULL,
    day INT,
    month INT,
    quarter INT,
    year INT,
    day_of_week VARCHAR(10),
    is_weekend BOOLEAN
);

CREATE TABLE dim_store (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    region VARCHAR(100)
);

CREATE TABLE dim_product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    category VARCHAR(100),
    brand VARCHAR(100),
    price DECIMAL(10,2)
);

CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(255),
    gender CHAR(1),
    age INT,
    loyalty_status VARCHAR(50)
);

-- 3. Create Fact Table

CREATE TABLE fact_sales (
    sale_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    time_id INT,
    store_id INT,
    product_id INT,
    customer_id INT,
    units_sold INT,
    total_sales DECIMAL(15,2),
    FOREIGN KEY (time_id) REFERENCES dim_time(time_id),
    FOREIGN KEY (store_id) REFERENCES dim_store(store_id),
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id),
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id)
);

-- 4. Insert Sample Data

-- dim_time (for first 5 days of Jan 2025)
INSERT INTO dim_time VALUES
(1, '2025-01-01', 1, 1, 1, 2025, 'Wednesday', TRUE),
(2, '2025-01-02', 2, 1, 1, 2025, 'Thursday', FALSE),
(3, '2025-01-03', 3, 1, 1, 2025, 'Friday', FALSE),
(4, '2025-01-04', 4, 1, 1, 2025, 'Saturday', TRUE),
(5, '2025-01-05', 5, 1, 1, 2025, 'Sunday', TRUE);

-- dim_store
INSERT INTO dim_store VALUES
(1, 'Downtown Store', 'New York', 'NY', 'East'),
(2, 'Uptown Store', 'New York', 'NY', 'East'),
(3, 'Midtown Store', 'Chicago', 'IL', 'Midwest');

-- dim_product
INSERT INTO dim_product VALUES
(1, 'Laptop Pro 15"', 'Electronics', 'TechBrand', 1500.00),
(2, 'Wireless Mouse', 'Electronics', 'ClickTech', 25.00),
(3, 'Office Chair', 'Furniture', 'ComfortCo', 200.00),
(4, 'Coffee Maker', 'Appliances', 'BrewMaster', 80.00);

-- dim_customer
INSERT INTO dim_customer VALUES
(1, 'Alice Johnson', 'F', 30, 'Gold'),
(2, 'Bob Smith', 'M', 45, 'Silver'),
(3, 'Carol Lee', 'F', 28, 'Bronze'),
(4, 'David Kim', 'M', 35, 'Gold');

-- fact_sales
INSERT INTO fact_sales (time_id, store_id, product_id, customer_id, units_sold, total_sales) VALUES
(1, 1, 1, 1, 1, 1500.00),
(1, 1, 2, 2, 2, 50.00),
(2, 2, 3, 3, 1, 200.00),
(3, 3, 4, 4, 3, 240.00),
(4, 2, 1, 1, 2, 3000.00),
(5, 1, 3, 2, 1, 200.00),
(5, 3, 2, 4, 5, 125.00);

-- 5. Sample OLAP Queries

-- Daily Sales
-- SELECT t.date, SUM(f.total_sales) AS daily_sales
-- FROM fact_sales f JOIN dim_time t ON f.time_id = t.time_id
-- GROUP BY t.date
-- ORDER BY t.date;

-- Monthly Sales
-- SELECT t.year, t.month, SUM(f.total_sales) AS monthly_sales
-- FROM fact_sales f JOIN dim_time t ON f.time_id = t.time_id
-- GROUP BY t.year, t.month
-- ORDER BY t.year, t.month;

-- Quarterly Sales
-- SELECT t.year, t.quarter, SUM(f.total_sales) AS quarterly_sales
-- FROM fact_sales f JOIN dim_time t ON f.time_id = t.time_id
-- GROUP BY t.year, t.quarter
-- ORDER BY t.year, t.quarter;


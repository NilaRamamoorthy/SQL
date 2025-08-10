-- 1. Create sample tables
CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100)
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    sale_date DATE,
    quantity INT,
    sale_amount DECIMAL(10,2),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 2. Insert sample data
INSERT INTO products (product_id, product_name) VALUES
(1, 'Smartphone'),
(2, 'Laptop'),
(3, 'Headphones'),
(4, 'Camera'),
(5, 'Smartwatch');

INSERT INTO sales (product_id, sale_date, quantity, sale_amount) VALUES
(1, '2025-07-01', 10, 5000),
(1, '2025-07-02', 5, 2500),
(2, '2025-07-01', 8, 8000),
(2, '2025-07-05', 3, 3000),
(3, '2025-07-03', 20, 2000),
(4, '2025-07-10', 7, 3500),
(5, '2025-07-02', 15, 4500),
(1, '2025-07-08', 12, 6000),
(3, '2025-07-15', 5, 500),
(4, '2025-07-16', 10, 5000),
(5, '2025-07-18', 20, 6000),
(2, '2025-07-20', 10, 10000),
(1, '2025-07-22', 8, 4000);

-- 3. Query: Weekly sales with rankings

WITH weekly_sales AS (
    SELECT
        product_id,
        YEARWEEK(sale_date, 1) AS year_week,
        SUM(quantity) AS total_quantity,
        SUM(sale_amount) AS total_sales
    FROM sales
    GROUP BY product_id, year_week
),
weekly_rankings AS (
    SELECT
        ws.*,
        RANK() OVER (PARTITION BY ws.year_week ORDER BY ws.total_sales DESC) AS sales_rank,
        DENSE_RANK() OVER (PARTITION BY ws.year_week ORDER BY ws.total_sales DESC) AS dense_sales_rank
    FROM weekly_sales ws
),
weekly_rank_with_lag AS (
    SELECT
        wr.*,
        LAG(wr.sales_rank) OVER (PARTITION BY wr.product_id ORDER BY wr.year_week) AS prev_week_rank
    FROM weekly_rankings wr
)

SELECT
    p.product_name,
    wrwl.year_week,
    wrwl.total_quantity,
    wrwl.total_sales,
    wrwl.sales_rank,
    wrwl.dense_sales_rank,
    wrwl.prev_week_rank,
    CASE 
        WHEN wrwl.prev_week_rank IS NULL THEN 'New'
        WHEN wrwl.sales_rank < wrwl.prev_week_rank THEN 'Up'
        WHEN wrwl.sales_rank > wrwl.prev_week_rank THEN 'Down'
        ELSE 'Same'
    END AS movement
FROM weekly_rank_with_lag wrwl
JOIN products p ON p.product_id = wrwl.product_id
ORDER BY wrwl.year_week DESC, wrwl.sales_rank;

-- 4. Query: Monthly sales with rankings (similar approach)

WITH monthly_sales AS (
    SELECT
        product_id,
        DATE_FORMAT(sale_date, '%Y-%m') AS year_month,
        SUM(quantity) AS total_quantity,
        SUM(sale_amount) AS total_sales
    FROM sales
    GROUP BY product_id, year_month
),
monthly_rankings AS (
    SELECT
        ms.*,
        RANK() OVER (PARTITION BY ms.year_month ORDER BY ms.total_sales DESC) AS sales_rank,
        DENSE_RANK() OVER (PARTITION BY ms.year_month ORDER BY ms.total_sales DESC) AS dense_sales_rank
    FROM monthly_sales ms
),
monthly_rank_with_lag AS (
    SELECT
        mr.*,
        LAG(mr.sales_rank) OVER (PARTITION BY mr.product_id ORDER BY mr.year_month) AS prev_month_rank
    FROM monthly_rankings mr
)

SELECT
    p.product_name,
    mrwl.year_month,
    mrwl.total_quantity,
    mrwl.total_sales,
    mrwl.sales_rank,
    mrwl.dense_sales_rank,
    mrwl.prev_month_rank,
    CASE 
        WHEN mrwl.prev_month_rank IS NULL THEN 'New'
        WHEN mrwl.sales_rank < mrwl.prev_month_rank THEN 'Up'
        WHEN mrwl.sales_rank > mrwl.prev_month_rank THEN 'Down'
        ELSE 'Same'
    END AS movement
FROM monthly_rank_with_lag mrwl
JOIN products p ON p.product_id = mrwl.product_id
ORDER BY mrwl.year_month DESC, mrwl.sales_rank;

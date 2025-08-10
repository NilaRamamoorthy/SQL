-- 1. Create Database & Use
CREATE DATABASE IF NOT EXISTS sales_performance;
USE sales_performance;

-- 2. Create Tables

CREATE TABLE locations (
    location_id INT PRIMARY KEY,
    name VARCHAR(100),
    parent_id INT NULL,
    location_type ENUM('Region', 'State', 'City'),
    FOREIGN KEY (parent_id) REFERENCES locations(location_id)
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY AUTO_INCREMENT,
    location_id INT,
    sale_amount DECIMAL(10, 2),
    sale_date DATE,
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

-- 3. Insert Sample Location Data (Regions > States > Cities)

INSERT INTO locations (location_id, name, parent_id, location_type) VALUES
(1, 'North Region', NULL, 'Region'),
(2, 'South Region', NULL, 'Region'),

(10, 'North State A', 1, 'State'),
(11, 'North State B', 1, 'State'),
(20, 'South State A', 2, 'State'),

(100, 'North City 1', 10, 'City'),
(101, 'North City 2', 10, 'City'),
(110, 'North City 3', 11, 'City'),
(200, 'South City 1', 20, 'City'),
(201, 'South City 2', 20, 'City');

-- 4. Insert Sample Sales Data (random dates and amounts)

INSERT INTO sales (location_id, sale_amount, sale_date) VALUES
(100, 5000, '2025-07-01'),
(100, 3000, '2025-07-02'),
(101, 7000, '2025-07-02'),
(110, 2000, '2025-07-05'),
(200, 8000, '2025-07-06'),
(201, 12000, '2025-07-07'),
(100, 6000, '2025-07-08'),
(101, 4000, '2025-07-09'),
(110, 3000, '2025-07-10'),
(200, 9000, '2025-07-11'),
(201, 15000, '2025-07-12'),
(100, 7000, '2025-07-13'),
(101, 5000, '2025-07-14');

-- 5. Recursive CTE to expand Location Hierarchy and get full path

WITH RECURSIVE location_hierarchy AS (
    SELECT 
        location_id, 
        name, 
        parent_id, 
        location_type,
        CAST(name AS CHAR(255)) AS full_path,
        1 AS level
    FROM locations
    WHERE parent_id IS NULL

    UNION ALL

    SELECT 
        l.location_id, 
        l.name, 
        l.parent_id, 
        l.location_type,
        CONCAT(h.full_path, ' > ', l.name),
        h.level + 1
    FROM locations l
    INNER JOIN location_hierarchy h ON l.parent_id = h.location_id
),

-- 6. Aggregate Weekly Sales

weekly_sales AS (
    SELECT 
        l.location_id,
        l.full_path,
        YEARWEEK(s.sale_date, 1) AS year_week,  -- ISO week format
        SUM(s.sale_amount) AS total_sales
    FROM sales s
    JOIN location_hierarchy l ON s.location_id = l.location_id
    GROUP BY l.location_id, l.full_path, year_week
),

-- 7. Aggregate Monthly Sales

monthly_sales AS (
    SELECT
        l.location_id,
        l.full_path,
        YEAR(s.sale_date) AS sale_year,
        MONTH(s.sale_date) AS sale_month,
        SUM(s.sale_amount) AS total_sales
    FROM sales s
    JOIN location_hierarchy l ON s.location_id = l.location_id
    GROUP BY l.location_id, l.full_path, sale_year, sale_month
),

-- 8. Ranking Regions by Sales This Week (latest week)

latest_week AS (
    SELECT MAX(year_week) AS max_week FROM weekly_sales
),

weekly_ranked AS (
    SELECT 
        ws.location_id,
        ws.full_path,
        ws.year_week,
        ws.total_sales,
        RANK() OVER (ORDER BY ws.total_sales DESC) AS sales_rank,
        DENSE_RANK() OVER (ORDER BY ws.total_sales DESC) AS dense_sales_rank,
        LAG(ws.total_sales) OVER (ORDER BY ws.year_week) AS last_week_sales
    FROM weekly_sales ws
    JOIN latest_week lw ON ws.year_week = lw.max_week
),

-- 9. Flag top performers: top 3 ranks as 'Top', else 'Other'

flagged_regions AS (
    SELECT
        location_id,
        full_path,
        year_week,
        total_sales,
        sales_rank,
        dense_sales_rank,
        last_week_sales,
        CASE 
            WHEN sales_rank <= 3 THEN 'Top Performer'
            ELSE 'Other'
        END AS performance_flag,
        -- Revenue growth compared to last week
        CASE 
            WHEN last_week_sales IS NULL THEN NULL
            WHEN total_sales > last_week_sales THEN 'Growth'
            WHEN total_sales < last_week_sales THEN 'Decline'
            ELSE 'Stable'
        END AS sales_trend
    FROM weekly_ranked
)

-- 10. Final Select

SELECT 
    location_id,
    full_path,
    year_week,
    total_sales,
    sales_rank,
    dense_sales_rank,
    last_week_sales,
    performance_flag,
    sales_trend
FROM flagged_regions
ORDER BY sales_rank;


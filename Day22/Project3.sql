-- 1. Create Database and Use
CREATE DATABASE IF NOT EXISTS retail_sales;
USE retail_sales;

-- 2. Create Tables
CREATE TABLE IF NOT EXISTS stores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    region VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS employees (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    store_id INT,
    FOREIGN KEY (store_id) REFERENCES stores(id)
);

CREATE TABLE IF NOT EXISTS sales (
    id INT PRIMARY KEY AUTO_INCREMENT,
    store_id INT,
    product_id INT,
    employee_id INT,
    sale_type ENUM('online', 'offline'),
    quantity INT,
    price DECIMAL(10,2),
    sale_date DATE,
    FOREIGN KEY (store_id) REFERENCES stores(id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (employee_id) REFERENCES employees(id)
);

-- 3. Insert Sample Data
INSERT INTO stores (name, region) VALUES
('Store A', 'North'),
('Store B', 'South'),
('Store C', 'North'),
('Store D', 'East');

INSERT INTO products (name) VALUES
('Product X'), ('Product Y'), ('Product Z');

INSERT INTO employees (name, store_id) VALUES
('Alice', 1),
('Bob', 1),
('Charlie', 2),
('David', 3),
('Eve', 4);

INSERT INTO sales (store_id, product_id, employee_id, sale_type, quantity, price, sale_date) VALUES
(1, 1, 1, 'offline', 10, 100.00, '2025-07-01'),
(1, 2, 2, 'online', 5, 200.00, '2025-07-03'),
(2, 1, 3, 'offline', 20, 100.00, '2025-07-02'),
(3, 3, 4, 'online', 15, 150.00, '2025-07-05'),
(4, 2, 5, 'offline', 8, 200.00, '2025-07-04'),
(1, 1, 1, 'online', 7, 100.00, '2025-06-30'),
(2, 3, 3, 'online', 10, 150.00, '2025-07-10'),
(3, 2, 4, 'offline', 6, 200.00, '2025-07-11');

-- 4a. Store revenue and % of total revenue
SELECT 
    s.id,
    s.name AS store_name,
    SUM(sa.quantity * sa.price) AS store_revenue,
    ROUND(
        SUM(sa.quantity * sa.price) / 
        (SELECT SUM(quantity * price) FROM sales) * 100, 2
    ) AS revenue_percentage_of_total
FROM stores s
JOIN sales sa ON s.id = sa.store_id
GROUP BY s.id, s.name;

-- 4b. Top performer per region (employee with highest sales)
SELECT
    st.region,
    e.name AS top_performer,
    emp_sales.total_sales
FROM stores st
JOIN employees e ON e.store_id = st.id
JOIN (
    SELECT employee_id, SUM(quantity * price) AS total_sales
    FROM sales
    GROUP BY employee_id
) emp_sales ON emp_sales.employee_id = e.id
WHERE emp_sales.total_sales = (
    SELECT MAX(sales_sum) FROM (
        SELECT SUM(quantity * price) AS sales_sum
        FROM sales sa2
        JOIN employees e2 ON sa2.employee_id = e2.id
        JOIN stores st2 ON e2.store_id = st2.id
        WHERE st2.region = st.region
        GROUP BY sa2.employee_id
    ) AS region_sales
);

-- 4c. UNION online and offline sales
SELECT 'offline' AS sale_type, store_id, product_id, quantity, price, sale_date FROM sales WHERE sale_type = 'offline'
UNION ALL
SELECT 'online' AS sale_type, store_id, product_id, quantity, price, sale_date FROM sales WHERE sale_type = 'online';

-- 4d. Categorize products by total revenue
SELECT 
    p.id,
    p.name,
    SUM(sa.quantity * sa.price) AS total_revenue,
    CASE
        WHEN SUM(sa.quantity * sa.price) > 2000 THEN 'Top Seller'
        WHEN SUM(sa.quantity * sa.price) BETWEEN 1000 AND 2000 THEN 'Medium'
        ELSE 'Low'
    END AS sales_category
FROM products p
JOIN sales sa ON p.id = sa.product_id
GROUP BY p.id, p.name;

-- 4e. Monthly sales trends (total revenue per month)
SELECT 
    YEAR(sale_date) AS sale_year,
    MONTH(sale_date) AS sale_month,
    SUM(quantity * price) AS monthly_revenue
FROM sales
GROUP BY sale_year, sale_month
ORDER BY sale_year, sale_month;

-- 4f. Store-level performance with employees count, total quantity and revenue
SELECT 
    st.id,
    st.name AS store_name,
    COUNT(DISTINCT e.id) AS total_employees,
    SUM(sa.quantity) AS total_quantity_sold,
    SUM(sa.quantity * sa.price) AS total_revenue
FROM stores st
LEFT JOIN employees e ON e.store_id = st.id
LEFT JOIN sales sa ON sa.store_id = st.id
GROUP BY st.id, st.name;

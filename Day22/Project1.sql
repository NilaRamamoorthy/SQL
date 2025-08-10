-- 1. Create Database
CREATE DATABASE ecommerce_dashboard;
USE ecommerce_dashboard;

-- 2. Create Tables

CREATE TABLE customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    created_at DATE NOT NULL
);

CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL
);

CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE order_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE reviews (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    review_text TEXT,
    review_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- 3. Insert Sample Data

INSERT INTO customers (name, created_at) VALUES
('Alice', '2024-11-10'),
('Bob', '2025-01-15'),
('Charlie', '2023-07-20'),
('Diana', '2025-02-05'),
('Eve', '2022-12-25');

INSERT INTO products (name, price) VALUES
('Laptop', 75000),
('Smartphone', 35000),
('Headphones', 5000),
('Monitor', 15000),
('Keyboard', 2000);

INSERT INTO orders (customer_id, order_date) VALUES
(1, '2025-01-10'),
(1, '2025-03-05'),
(2, '2025-02-20'),
(3, '2024-12-15'),
(4, '2025-04-10'),
(5, '2023-11-25');

INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 1, 1),  -- Alice: Laptop
(1, 3, 2),  -- Alice: 2 Headphones
(2, 2, 1),  -- Alice: Smartphone
(3, 4, 1),  -- Bob: Monitor
(4, 5, 3),  -- Charlie: 3 Keyboards
(5, 1, 1),  -- Diana: Laptop
(6, 3, 1);  -- Eve: Headphones

INSERT INTO reviews (customer_id, product_id, review_text, review_date) VALUES
(1, 1, 'Great laptop!', '2025-01-15'),
(2, 4, 'Good monitor.', '2025-02-25'),
(3, 5, 'Love the keyboard.', '2024-12-20'),
(4, 1, 'Laptop works well.', '2025-04-15');

-- 4. Queries

-- a) Subquery in SELECT: Calculate each customer's average order value (current year)
SELECT 
    c.id AS customer_id,
    c.name,
    (
        SELECT AVG(order_total) FROM (
            SELECT 
                o.id,
                SUM(oi.quantity * p.price) AS order_total
            FROM orders o
            JOIN order_items oi ON o.id = oi.order_id
            JOIN products p ON oi.product_id = p.id
            WHERE o.customer_id = c.id
              AND YEAR(o.order_date) = YEAR(CURDATE())
            GROUP BY o.id
        ) AS order_totals
    ) AS avg_order_value
FROM customers c;

-- b) Subquery in FROM: Total revenue per product
SELECT
    p.id AS product_id,
    p.name,
    product_revenue.total_revenue
FROM products p
JOIN (
    SELECT 
        oi.product_id,
        SUM(oi.quantity * p2.price) AS total_revenue
    FROM order_items oi
    JOIN products p2 ON oi.product_id = p2.id
    GROUP BY oi.product_id
) AS product_revenue ON p.id = product_revenue.product_id;

-- c) Correlated subquery: Find customers with orders above their own average order value
SELECT DISTINCT
    c.id,
    c.name,
    o.id AS order_id,
    order_total
FROM customers c
JOIN orders o ON c.id = o.customer_id
JOIN (
    SELECT 
        o2.id,
        SUM(oi.quantity * p.price) AS order_total
    FROM orders o2
    JOIN order_items oi ON o2.id = oi.order_id
    JOIN products p ON oi.product_id = p.id
    WHERE YEAR(o2.order_date) = YEAR(CURDATE())
    GROUP BY o2.id
) AS order_sums ON order_sums.id = o.id
WHERE order_total > (
    SELECT AVG(order_total) FROM (
        SELECT 
            o3.id,
            SUM(oi2.quantity * p2.price) AS order_total
        FROM orders o3
        JOIN order_items oi2 ON o3.id = oi2.order_id
        JOIN products p2 ON oi2.product_id = p2.id
        WHERE o3.customer_id = c.id AND YEAR(o3.order_date) = YEAR(CURDATE())
        GROUP BY o3.id
    ) AS customer_orders
);

-- d) UNION: Combine old and new customers (Assuming old = created before 2024, new >= 2024)
SELECT id, name, 'Old Customer' AS customer_type FROM customers WHERE created_at < '2024-01-01'
UNION
SELECT id, name, 'New Customer' AS customer_type FROM customers WHERE created_at >= '2024-01-01';

-- e) INTERSECT: Customers who placed orders and submitted reviews (MySQL doesn't support INTERSECT, so use INNER JOIN)
SELECT DISTINCT
    c.id,
    c.name
FROM customers c
JOIN orders o ON c.id = o.customer_id
JOIN reviews r ON c.id = r.customer_id;

-- f) CASE: Categorize customers based on total spending this year
SELECT 
    c.id,
    c.name,
    COALESCE(SUM(oi.quantity * p.price), 0) AS total_spent,
    CASE 
        WHEN COALESCE(SUM(oi.quantity * p.price), 0) > 50000 THEN 'High Spender'
        WHEN COALESCE(SUM(oi.quantity * p.price), 0) BETWEEN 20000 AND 50000 THEN 'Medium Spender'
        ELSE 'Low Spender'
    END AS customer_category
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id AND YEAR(o.order_date) = YEAR(CURDATE())
LEFT JOIN order_items oi ON o.id = oi.order_id
LEFT JOIN products p ON oi.product_id = p.id
GROUP BY c.id, c.name;

-- g) Filter orders in the current year using DATE() and YEAR()
SELECT
    o.id AS order_id,
    c.name AS customer_name,
    o.order_date,
    SUM(oi.quantity * p.price) AS order_total
FROM orders o
JOIN customers c ON o.customer_id = c.id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id
WHERE YEAR(o.order_date) = YEAR(CURDATE())
GROUP BY o.id, c.name, o.order_date;

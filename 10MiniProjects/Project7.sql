-- 1. Create Database and Use
CREATE DATABASE IF NOT EXISTS gadget_store;
USE gadget_store;

-- 2. Create Tables

CREATE TABLE categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    category_id INT,
    price DECIMAL(10,2),
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

CREATE TABLE customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255)
);

CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    product_id INT,
    order_date DATE,
    quantity INT,
    total_price DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- 3. Insert Sample Data

INSERT INTO categories (name) VALUES
('Smartphones'),
('Accessories'),
('Laptops'),
('Tablets');

INSERT INTO products (name, category_id, price) VALUES
('iPhone 14', 1, 70000),
('Samsung Charger', 2, 1500),
('MacBook Air', 3, 120000),
('iPad Pro', 4, 90000),
('Wireless Earbuds', 2, 5000),
('Dell Laptop', 3, 70000);

INSERT INTO customers (name, location) VALUES
('Alice', 'New York'),
('Bob', 'California'),
('Charlie', 'Texas'),
('Diana', 'New York'),
('Ethan', 'Florida');

INSERT INTO orders (customer_id, product_id, order_date, quantity, total_price) VALUES
(1, 1, '2025-07-01', 1, 70000),
(2, 2, '2025-07-03', 2, 3000),
(1, 5, '2025-07-05', 1, 5000),
(3, 3, '2025-07-07', 1, 120000),
(4, 6, '2025-07-09', 1, 70000),
(5, 1, '2025-07-11', 1, 70000),
(2, 5, '2025-07-12', 3, 15000);

-- 4. Query: Use DISTINCT to get unique customer locations

SELECT DISTINCT location
FROM customers;

-- 5. Query: Use BETWEEN to filter high-value orders (e.g., between ₹50,000 and ₹1,50,000)

SELECT *
FROM orders
WHERE total_price BETWEEN 50000 AND 150000;

-- 6. Query: Subquery in WHERE to find customers who never ordered accessories

SELECT id, name FROM customers c
WHERE id NOT IN (
    SELECT DISTINCT customer_id
    FROM orders o
    JOIN products p ON o.product_id = p.id
    JOIN categories cat ON p.category_id = cat.id
    WHERE cat.name = 'Accessories'
);

-- 7. Query: Use MAX() and MIN() for order value analytics

SELECT
    MAX(total_price) AS max_order_value,
    MIN(total_price) AS min_order_value,
    AVG(total_price) AS avg_order_value
FROM orders;

-- 8. Query: Use JOINs for full product category mapping

SELECT
    p.id AS product_id,
    p.name AS product_name,
    c.name AS category_name,
    p.price
FROM products p
LEFT JOIN categories c ON p.category_id = c.id
ORDER BY c.name, p.name;

-- 9. Query: Sort by most purchased products (SUM of quantity)

SELECT
    p.name,
    SUM(o.quantity) AS total_quantity_sold
FROM orders o
JOIN products p ON o.product_id = p.id
GROUP BY p.id, p.name
ORDER BY total_quantity_sold DESC;

-- 10. Query: CASE to label customers as "VIP" or "Regular" based on total spend

SELECT
    c.id,
    c.name,
    SUM(o.total_price) AS total_spent,
    CASE
        WHEN SUM(o.total_price) > 100000 THEN 'VIP'
        ELSE 'Regular'
    END AS customer_status
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name
ORDER BY total_spent DESC;

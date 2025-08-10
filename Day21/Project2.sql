-- 1. Create Database
CREATE DATABASE online_retail;
USE online_retail;

-- 2. Create Tables

CREATE TABLE customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
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
    quantity INT NOT NULL CHECK (quantity > 0),
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- 3. Insert Sample Data

INSERT INTO customers (name) VALUES
('Alice'),
('Bob'),
('Charlie'),
('Diana');

INSERT INTO products (name, price) VALUES
('Laptop', 1200.00),
('Smartphone', 800.00),
('Headphones', 150.00),
('Monitor', 300.00),
('Keyboard', 100.00);

INSERT INTO orders (customer_id, order_date) VALUES
(1, '2025-07-01'),
(1, '2025-07-15'),
(2, '2025-07-20'),
(3, '2025-07-22');

INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 1, 1),  -- Alice buys 1 Laptop
(1, 3, 2),  -- Alice buys 2 Headphones
(2, 2, 1),  -- Alice buys 1 Smartphone
(3, 3, 5),  -- Bob buys 5 Headphones
(3, 5, 10), -- Bob buys 10 Keyboards
(4, 4, 1);  -- Charlie buys 1 Monitor

-- 4. Queries

-- a) Total amount spent per customer
SELECT 
    c.name AS customer_name,
    IFNULL(SUM(p.price * oi.quantity), 0) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
LEFT JOIN order_items oi ON o.id = oi.order_id
LEFT JOIN products p ON oi.product_id = p.id
GROUP BY c.id, c.name;

-- b) Products sold count and total revenue per product
SELECT
    p.name AS product_name,
    SUM(oi.quantity) AS total_sold,
    SUM(p.price * oi.quantity) AS total_revenue
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.id, p.name;

-- c) Group sales by product with total revenue > 10,000
SELECT
    p.name AS product_name,
    SUM(p.price * oi.quantity) AS total_revenue
FROM products p
JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.id, p.name
HAVING total_revenue > 10000;

-- d) INNER JOIN orders ↔ order_items ↔ products (example: show order details)
SELECT 
    o.id AS order_id,
    c.name AS customer_name,
    p.name AS product_name,
    oi.quantity,
    p.price,
    (p.price * oi.quantity) AS item_total
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id
JOIN customers c ON o.customer_id = c.id;

-- e) LEFT JOIN to show customers without orders
SELECT 
    c.name AS customer_name,
    COUNT(o.id) AS order_count
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name
HAVING order_count = 0;

-- f) RIGHT JOIN to show products never sold
SELECT 
    p.name AS product_name,
    IFNULL(SUM(oi.quantity), 0) AS total_sold
FROM order_items oi
RIGHT JOIN products p ON oi.product_id = p.id
GROUP BY p.id, p.name
HAVING total_sold = 0;

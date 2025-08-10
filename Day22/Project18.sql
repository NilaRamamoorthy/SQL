-- 1. Create Database and Use
CREATE DATABASE IF NOT EXISTS warehouse_management;
USE warehouse_management;

-- 2. Create Tables

CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    reorder_level INT -- threshold to reorder stock
);

CREATE TABLE inventory (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    quantity INT,
    location ENUM('Online', 'Offline'),
    expiry_date DATE,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE suppliers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255)
);

CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    supplier_id INT,
    order_date DATE,
    delivery_date DATE,
    expected_delivery_date DATE,
    status ENUM('Pending', 'Delivered', 'Delayed'),
    quantity INT,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
);

-- 3. Insert Sample Data

INSERT INTO products (name, reorder_level) VALUES
('Widget A', 50),
('Widget B', 30),
('Gadget C', 20);

INSERT INTO inventory (product_id, quantity, location, expiry_date) VALUES
(1, 40, 'Online', '2025-12-01'),
(1, 20, 'Offline', '2025-11-15'),
(2, 25, 'Online', '2025-09-30'),
(3, 10, 'Offline', '2025-08-20');

INSERT INTO suppliers (name) VALUES
('Supplier X'),
('Supplier Y'),
('Supplier Z');

INSERT INTO orders (product_id, supplier_id, order_date, delivery_date, expected_delivery_date, status, quantity) VALUES
(1, 1, '2025-07-01', '2025-07-05', '2025-07-05', 'Delivered', 100),
(2, 2, '2025-07-10', '2025-07-20', '2025-07-18', 'Delayed', 50),
(3, 3, '2025-07-15', NULL, '2025-07-25', 'Pending', 30),
(1, 1, '2025-08-01', '2025-08-02', '2025-08-02', 'Delivered', 60);

-- 4. Query: Subquery in WHERE to show products below reorder level (based on total inventory quantity)

SELECT 
    p.id,
    p.name,
    p.reorder_level,
    (SELECT SUM(i.quantity) FROM inventory i WHERE i.product_id = p.id) AS total_quantity
FROM products p
WHERE (SELECT SUM(i.quantity) FROM inventory i WHERE i.product_id = p.id) < p.reorder_level;

-- 5. Query: CASE to categorize products as Fast, Medium, Slow moving based on total quantity (example thresholds)

SELECT 
    p.id,
    p.name,
    SUM(i.quantity) AS total_quantity,
    CASE 
        WHEN SUM(i.quantity) < 20 THEN 'Fast Moving'
        WHEN SUM(i.quantity) BETWEEN 20 AND 50 THEN 'Medium Moving'
        ELSE 'Slow Moving'
    END AS movement_category
FROM products p
JOIN inventory i ON p.id = i.product_id
GROUP BY p.id, p.name;

-- 6. Query: Correlated subquery to get supplier with least delayed deliveries

SELECT 
    s.id,
    s.name,
    (
        SELECT COUNT(*)
        FROM orders o
        WHERE o.supplier_id = s.id AND o.status = 'Delayed'
    ) AS delayed_deliveries
FROM suppliers s
ORDER BY delayed_deliveries ASC
LIMIT 1;

-- 7. Query: JOIN + GROUP BY for fulfillment rate by supplier

-- Fulfillment Rate = Delivered Orders / Total Orders per supplier

SELECT 
    s.id,
    s.name,
    COUNT(o.id) AS total_orders,
    SUM(CASE WHEN o.status = 'Delivered' THEN 1 ELSE 0 END) AS delivered_orders,
    ROUND(SUM(CASE WHEN o.status = 'Delivered' THEN 1 ELSE 0 END) / COUNT(o.id) * 100, 2) AS fulfillment_rate_percent
FROM suppliers s
LEFT JOIN orders o ON s.id = o.supplier_id
GROUP BY s.id, s.name;

-- 8. Query: UNION ALL for online and offline stock

SELECT 
    'Online' AS stock_location,
    product_id,
    SUM(quantity) AS total_quantity
FROM inventory
WHERE location = 'Online'
GROUP BY product_id

UNION ALL

SELECT 
    'Offline' AS stock_location,
    product_id,
    SUM(quantity) AS total_quantity
FROM inventory
WHERE location = 'Offline'
GROUP BY product_id;

-- 9. Query: Date filtering for expiry tracking (products expiring within next 30 days)

SELECT 
    p.id,
    p.name,
    i.expiry_date,
    DATEDIFF(i.expiry_date, CURDATE()) AS days_until_expiry
FROM inventory i
JOIN products p ON i.product_id = p.id
WHERE i.expiry_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY)
ORDER BY i.expiry_date ASC;

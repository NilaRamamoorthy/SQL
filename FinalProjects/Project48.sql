-- 1. Create Database
CREATE DATABASE inventory_expiry;
USE inventory_expiry;

-- 2. Create Tables

-- Product catalog
CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

-- Batches of products with expiry dates
CREATE TABLE batches (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity >= 0),
    expiry_date DATE NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- 3. Insert Sample Data

INSERT INTO products (name) VALUES
('Milk 1L'),
('Yogurt 500g'),
('Orange Juice 1L');

INSERT INTO batches (product_id, quantity, expiry_date) VALUES
(1, 50, '2025-08-01'),
(1, 30, '2025-08-15'),
(2, 20, '2025-07-30'),
(3, 40, '2025-09-05');

-- 4. Query: Expired stock alerts (past expiry date)
SELECT p.name AS product_name, b.quantity, b.expiry_date
FROM batches b
JOIN products p ON b.product_id = p.id
WHERE b.expiry_date < CURDATE();

-- 5. Query: Remaining stock per product (non-expired)
SELECT p.id, p.name, SUM(b.quantity) AS total_quantity
FROM products p
LEFT JOIN batches b 
    ON p.id = b.product_id 
    AND b.expiry_date >= CURDATE()
GROUP BY p.id, p.name;

-- 6. Query: Next batch to expire for each product
SELECT p.name AS product_name, MIN(b.expiry_date) AS next_expiry
FROM products p
JOIN batches b ON p.id = b.product_id
WHERE b.expiry_date >= CURDATE()
GROUP BY p.name;

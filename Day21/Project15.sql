-- 1. Create Database
CREATE DATABASE online_marketplace;
USE online_marketplace;

-- 2. Create Tables

CREATE TABLE sellers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL
);

CREATE TABLE buyers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    seller_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (seller_id) REFERENCES sellers(id)
);

CREATE TABLE purchases (
    id INT PRIMARY KEY AUTO_INCREMENT,
    buyer_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    purchase_date DATE NOT NULL,
    FOREIGN KEY (buyer_id) REFERENCES buyers(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- 3. Insert Sample Data

INSERT INTO sellers (name, city) VALUES
('Seller A', 'Mumbai'),
('Seller B', 'Delhi'),
('Seller C', 'Mumbai'),
('Seller D', 'Bangalore');

INSERT INTO buyers (name) VALUES
('Buyer 1'),
('Buyer 2'),
('Buyer 3'),
('Buyer 4');

INSERT INTO products (seller_id, name, price) VALUES
(1, 'Product 1', 1500.00),
(1, 'Product 2', 2500.00),
(2, 'Product 3', 3500.00),
(3, 'Product 4', 4500.00),
(4, 'Product 5', 5500.00);

INSERT INTO purchases (buyer_id, product_id, quantity, purchase_date) VALUES
(1, 1, 10, '2025-08-01'),
(2, 2, 20, '2025-08-02'),
(3, 3, 5, '2025-08-03'),
(4, 4, 15, '2025-08-04'),
(1, 5, 8, '2025-08-05'),
(2, 1, 7, '2025-08-06'),
(3, 2, 3, '2025-08-07'),
(4, 3, 12, '2025-08-08'),
(1, 4, 9, '2025-08-09');

-- 4. Queries

-- a) Revenue generated per seller (SUM)
SELECT 
    s.id,
    s.name AS seller_name,
    ROUND(SUM(p.price * pu.quantity), 2) AS total_revenue
FROM sellers s
JOIN products p ON s.id = p.seller_id
JOIN purchases pu ON p.id = pu.product_id
GROUP BY s.id, s.name
ORDER BY total_revenue DESC;

-- b) Most purchased products (COUNT total quantity sold)
SELECT 
    p.id,
    p.name AS product_name,
    SUM(pu.quantity) AS total_quantity_sold
FROM products p
JOIN purchases pu ON p.id = pu.product_id
GROUP BY p.id, p.name
ORDER BY total_quantity_sold DESC;

-- c) Sellers with revenue > ₹1,00,000
SELECT 
    s.id,
    s.name AS seller_name,
    ROUND(SUM(p.price * pu.quantity), 2) AS total_revenue
FROM sellers s
JOIN products p ON s.id = p.seller_id
JOIN purchases pu ON p.id = pu.product_id
GROUP BY s.id, s.name
HAVING total_revenue > 100000;

-- d) INNER JOIN purchases ↔ products ↔ sellers (show purchase details)
SELECT
    pu.id AS purchase_id,
    b.name AS buyer_name,
    p.name AS product_name,
    s.name AS seller_name,
    pu.quantity,
    pu.purchase_date,
    ROUND(p.price * pu.quantity, 2) AS total_price
FROM purchases pu
JOIN products p ON pu.product_id = p.id
JOIN sellers s ON p.seller_id = s.id
JOIN buyers b ON pu.buyer_id = b.id
ORDER BY pu.purchase_date;

-- e) LEFT JOIN sellers ↔ products (list sellers and their products, including sellers without products)
SELECT
    s.id AS seller_id,
    s.name AS seller_name,
    p.id AS product_id,
    p.name AS product_name
FROM sellers s
LEFT JOIN products p ON s.id = p.seller_id
ORDER BY s.id, p.id;

-- f) SELF JOIN sellers from the same city (pairs of sellers in the same city)
SELECT
    s1.id AS seller1_id,
    s1.name AS seller1_name,
    s2.id AS seller2_id,
    s2.name AS seller2_name,
    s1.city
FROM sellers s1
JOIN sellers s2 ON s1.city = s2.city AND s1.id < s2.id
ORDER BY s1.city, s1.id, s2.id;

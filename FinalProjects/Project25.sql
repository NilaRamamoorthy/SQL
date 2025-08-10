-- 1. Create Database
CREATE DATABASE product_wishlist_system;
USE product_wishlist_system;

-- 2. Create Tables

-- Users Table
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Products Table
CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Wishlist Table (Many-to-Many)
CREATE TABLE wishlist (
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    PRIMARY KEY (user_id, product_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- 3. Insert Sample Data

-- Users
INSERT INTO users (name) VALUES
('Alice'),
('Bob'),
('Charlie');

-- Products
INSERT INTO products (name) VALUES
('Laptop'),
('Smartphone'),
('Headphones'),
('Camera');

-- Wishlist Entries
INSERT INTO wishlist (user_id, product_id) VALUES
(1, 1), -- Alice → Laptop
(1, 2), -- Alice → Smartphone
(2, 1), -- Bob → Laptop
(2, 3), -- Bob → Headphones
(3, 1), -- Charlie → Laptop
(3, 4); -- Charlie → Camera

-- 4. Query: Get wishlist of a specific user
SELECT 
    u.name AS user_name,
    p.name AS product_name
FROM wishlist w
JOIN users u ON w.user_id = u.id
JOIN products p ON w.product_id = p.id
WHERE u.name = 'Alice';

-- 5. Query: Get most popular products in wishlists
SELECT 
    p.name AS product_name,
    COUNT(*) AS wishlist_count
FROM wishlist w
JOIN products p ON w.product_id = p.id
GROUP BY p.name
ORDER BY wishlist_count DESC;

-- 6. Query: Get users who have a specific product in their wishlist
SELECT 
    u.name AS user_name
FROM wishlist w
JOIN users u ON w.user_id = u.id
JOIN products p ON w.product_id = p.id
WHERE p.name = 'Laptop';

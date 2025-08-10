-- 1. Create Database
CREATE DATABASE product_reviews;
USE product_reviews;

-- 2. Create Tables

-- Users table
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Products table
CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Reviews table
CREATE TABLE reviews (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    product_id INT,
    rating DECIMAL(2,1) CHECK (rating >= 1 AND rating <= 5),
    review TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    UNIQUE (user_id, product_id) -- Prevent duplicate review from same user for same product
);

-- 3. Insert Sample Data

-- Users
INSERT INTO users (name) VALUES
('Alice'),
('Bob'),
('Charlie'),
('Diana');

-- Products
INSERT INTO products (name) VALUES
('Laptop'),
('Smartphone'),
('Headphones'),
('Smartwatch');

-- Reviews
INSERT INTO reviews (user_id, product_id, rating, review) VALUES
(1, 1, 4.5, 'Great performance and battery life.'),
(2, 1, 4.0, 'Solid laptop, worth the price.'),
(3, 2, 5.0, 'Excellent smartphone with amazing camera.'),
(1, 3, 3.5, 'Decent sound quality but not the best.'),
(4, 2, 4.8, 'Loving the phone so far, great features.'),
(2, 4, 4.2, 'Stylish and functional smartwatch.');

-- 4. Query: Average Ratings per Product
SELECT 
    p.id,
    p.name,
    ROUND(AVG(r.rating), 2) AS avg_rating,
    COUNT(r.id) AS total_reviews
FROM products p
LEFT JOIN reviews r ON p.id = r.product_id
GROUP BY p.id, p.name;

-- 5. Query: Top-Rated Products (rating >= 4.5)
SELECT 
    p.id,
    p.name,
    ROUND(AVG(r.rating), 2) AS avg_rating
FROM products p
JOIN reviews r ON p.id = r.product_id
GROUP BY p.id, p.name
HAVING AVG(r.rating) >= 4.5
ORDER BY avg_rating DESC;

-- 6. Query: Prevent duplicate review test
-- INSERT INTO reviews (user_id, product_id, rating, review)
-- VALUES (1, 1, 5.0, 'Review again');

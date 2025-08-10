
-- 1. CREATE DATABASE AND SELECT IT

CREATE DATABASE ecommerce_catalog;
USE ecommerce_catalog;

-- 3. CREATE TABLES
-- Categories table
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Brands table
CREATE TABLE brands (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Products table
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL,
    image_url VARCHAR(255),
    category_id INT,
    brand_id INT,
    FOREIGN KEY (category_id) REFERENCES categories(id),
    FOREIGN KEY (brand_id) REFERENCES brands(id),
    INDEX idx_category (category_id),
    INDEX idx_brand (brand_id),
    INDEX idx_price (price)
);


-- 4. INSERT SAMPLE DATA


-- Insert categories
INSERT INTO categories (name) VALUES
('Electronics'),
('Apparel'),
('Home & Kitchen'),
('Books'),
('Sports');

-- Insert brands
INSERT INTO brands (name) VALUES
('Apple'),
('Nike'),
('Samsung'),
('Sony'),
('Adidas');

-- Insert products
INSERT INTO products (name, description, price, stock, image_url, category_id, brand_id) VALUES
('iPhone 14', 'Latest Apple smartphone', 999.99, 25, 'https://example.com/iphone14.jpg', 1, 1),
('Nike Air Max', 'Comfortable running shoes', 129.99, 50, 'https://example.com/nikeairmax.jpg', 2, 2),
('Samsung Galaxy S22', 'Flagship Samsung phone', 899.99, 30, 'https://example.com/galaxys22.jpg', 1, 3),
('Sony WH-1000XM5', 'Noise-cancelling headphones', 349.99, 15, 'https://example.com/sonyheadphones.jpg', 1, 4),
('Adidas T-Shirt', 'Cotton sports t-shirt', 39.99, 100, 'https://example.com/adidastshirt.jpg', 2, 5),
('Blender', 'High-speed kitchen blender', 59.99, 20, 'https://example.com/blender.jpg', 3, 4),
('The Great Gatsby', 'Classic novel by F. Scott Fitzgerald', 14.99, 80, 'https://example.com/gatsby.jpg', 4, 4),
('Football', 'Official size 5 football', 29.99, 60, 'https://example.com/football.jpg', 5, 5),
('Apple Watch Series 8', 'Smartwatch with health features', 399.99, 10, 'https://example.com/applewatch.jpg', 1, 1),
('Nike Shorts', 'Lightweight training shorts', 49.99, 70, 'https://example.com/nikeshorts.jpg', 2, 2);



-- 1. Get all products with their brand and category
SELECT 
    p.id, p.name, p.price, p.stock, p.image_url,
    c.name AS category,
    b.name AS brand
FROM products p
JOIN categories c ON p.category_id = c.id
JOIN brands b ON p.brand_id = b.id;

-- 2. Filter products by a specific category (e.g., 'Electronics')
SELECT * FROM products
WHERE category_id = (SELECT id FROM categories WHERE name = 'Electronics');

-- 3. Filter products by a specific brand (e.g., 'Nike')
SELECT * FROM products
WHERE brand_id = (SELECT id FROM brands WHERE name = 'Nike');

-- 4. Filter products within a price range (e.g., $100 to $500)
SELECT * FROM products
WHERE price BETWEEN 100 AND 500;

-- 5. Filter products by category AND brand
SELECT * FROM products
WHERE category_id = (SELECT id FROM categories WHERE name = 'Apparel')
  AND brand_id = (SELECT id FROM brands WHERE name = 'Adidas');

-- 6. Get all products sorted by price (ascending)
SELECT * FROM products
ORDER BY price ASC;

-- 7. Search products by name (case-insensitive, partial match)
SELECT * FROM products
WHERE LOWER(name) LIKE '%watch%';

-- 8. Get all in-stock products
SELECT * FROM products
WHERE stock > 0;

-- 9. Count of products per category
SELECT c.name AS category, COUNT(p.id) AS product_count
FROM products p
JOIN categories c ON p.category_id = c.id
GROUP BY c.id;

-- 10. Count of products per brand
SELECT b.name AS brand, COUNT(p.id) AS product_count
FROM products p
JOIN brands b ON p.brand_id = b.id
GROUP BY b.id;

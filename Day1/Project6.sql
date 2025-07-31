DROP DATABASE IF EXISTS ecommerce_db;
CREATE DATABASE ecommerce_db;
USE ecommerce_db;

CREATE TABLE brands (
  brand_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE categories (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE products (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  brand_id INT NOT NULL,
  category_id INT NOT NULL,
  price DECIMAL(9,2) NOT NULL,
  stock INT DEFAULT 0,
  FOREIGN KEY (brand_id) REFERENCES brands(brand_id),
  FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(100) NOT NULL UNIQUE,
  email VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE favorites (
  user_id INT,
  product_id INT,
  PRIMARY KEY (user_id, product_id),
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO brands (name) VALUES
('BrandA'), ('BrandB'), ('BrandC');

INSERT INTO categories (name) VALUES
('Electronics'), ('Clothing'), ('Kitchen');

INSERT INTO products (name, brand_id, category_id, price, stock) VALUES
('Smartphone', 1, 1, 299.99, 50),
('Laptop', 1, 1, 799.50, 30),
('T-shirt', 2, 2, 19.99, 200),
('Jeans', 2, 2, 49.99, 150),
('Blender', 3, 3, 69.99, 40),
('Toaster', 3, 3, 39.99, 60),
('Headphones', 1, 1, 99.99, 80),
('Jacket', 2, 2, 89.99, 120);

INSERT INTO users (username, email) VALUES
('alice', 'alice@example.com'),
('bob', 'bob@example.com'),
('carol', 'carol@example.com');

INSERT INTO favorites (user_id, product_id) VALUES
(1,1),(1,3),(2,1),(2,4),(2,1),(3,5),(3,1);

-- Queries:
-- products by category
SELECT c.name AS category, p.name, p.price, p.stock
FROM products p
JOIN categories c ON p.category_id = c.category_id
WHERE c.name = 'Electronics';

-- products by brand
SELECT b.name AS brand, p.name, p.price
FROM products p
JOIN brands b ON p.brand_id = b.brand_id
WHERE b.name = 'BrandA';

-- most favorited products
SELECT p.name, COUNT(f.user_id) AS fav_count
FROM favorites f
JOIN products p ON f.product_id = p.product_id
GROUP BY f.product_id
ORDER BY fav_count DESC
LIMIT 3;
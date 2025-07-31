--  1. Drop and create database
DROP DATABASE IF EXISTS grocery_store;
CREATE DATABASE grocery_store;
USE grocery_store;

-- 2. Create Categories Table
CREATE TABLE categories (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(50) NOT NULL UNIQUE
);

--  3. Create Suppliers Table
CREATE TABLE suppliers (
  supplier_id INT AUTO_INCREMENT PRIMARY KEY,
  supplier_name VARCHAR(100) NOT NULL UNIQUE,
  contact_email VARCHAR(100)
);

--  4. Create Products Table
CREATE TABLE products (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  product_name VARCHAR(100) NOT NULL UNIQUE,
  category_id INT NOT NULL,
  supplier_id INT NOT NULL,
  price DECIMAL(8, 2) NOT NULL,
  stock INT DEFAULT 0,
  is_discontinued BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (category_id) REFERENCES categories(category_id),
  FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

--  5. Insert Categories
INSERT INTO categories (category_name) VALUES
('Fruits'), ('Vegetables'), ('Dairy'), ('Snacks'), ('Beverages');

-- 6. Insert Suppliers
INSERT INTO suppliers (supplier_name, contact_email) VALUES
('Fresh Farms Co.', 'fresh@farms.com'),
('GreenLeaf Distributors', 'contact@greenleaf.com'),
('DairyLand', 'support@dairyland.com'),
('SnackNation', 'sales@snacknation.com'),
('DrinkWell Ltd.', 'hello@drinkwell.com');

--  7. Insert Products (20+)
INSERT INTO products (product_name, category_id, supplier_id, price, stock) VALUES
('Apple', 1, 1, 2.50, 100),
('Banana', 1, 1, 1.20, 150),
('Orange', 1, 1, 2.00, 80),
('Carrot', 2, 2, 1.10, 200),
('Broccoli', 2, 2, 2.30, 75),
('Spinach', 2, 2, 1.80, 90),
('Milk', 3, 3, 3.00, 60),
('Cheese', 3, 3, 4.50, 40),
('Yogurt', 3, 3, 2.75, 50),
('Potato Chips', 4, 4, 1.99, 120),
('Popcorn', 4, 4, 1.50, 100),
('Granola Bar', 4, 4, 0.99, 200),
('Cola', 5, 5, 1.25, 300),
('Orange Juice', 5, 5, 2.50, 150),
('Mineral Water', 5, 5, 0.99, 500),
('Lettuce', 2, 2, 1.25, 60),
('Grapes', 1, 1, 3.50, 70),
('Butter', 3, 3, 3.80, 55),
('Energy Drink', 5, 5, 2.99, 130),
('Trail Mix', 4, 4, 2.25, 90),
('Cucumber', 2, 2, 1.10, 85);

--  8. Update Stock Example (e.g., add 50 to Apple)
UPDATE products
SET stock = stock + 50
WHERE product_name = 'Apple';

-- 9. Delete Discontinued Products
-- First, mark some as discontinued:
UPDATE products
SET is_discontinued = TRUE
WHERE product_name IN ('Popcorn', 'Grapes');

-- Now delete those:
DELETE FROM products
WHERE is_discontinued = TRUE;

--  10. Group Products by Category and Count
SELECT c.category_name, COUNT(p.product_id) AS product_count
FROM products p
JOIN categories c ON p.category_id = c.category_id
GROUP BY p.category_id;

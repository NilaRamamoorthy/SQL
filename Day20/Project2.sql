-- 1. Create database and switch to it
CREATE DATABASE product_catalog;
USE product_catalog;

-- 2. Create products table
CREATE TABLE products (
  product_id   INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name         VARCHAR(100) NOT NULL,
  category     VARCHAR(50) NOT NULL,
  price        DECIMAL(10,2) NOT NULL CHECK (price >= 0),
  stock        INT NOT NULL CHECK (stock >= 0),
  supplier     VARCHAR(100) NOT NULL,
  description  TEXT
);

-- 3. Insert 20 sample products
INSERT INTO products (name, category, price, stock, supplier, description) VALUES
('Wireless Mouse',        'Electronics', 25.99, 150, 'Global Supplies Inc.',  'Ergonomic wireless mouse'),
('USB-C Charger',         'Electronics', 19.50, 200, 'ChargePlus Ltd.',       'Fast USB-C wall charger'),
('Bluetooth Speaker',     'Audio',        45.00,  80, 'SoundWave',             'Portable Bluetooth speaker'),
('Noise‑Cancelling Headphones','Audio', 129.99, 50, 'SoundWave',             'Over-ear noise‑cancelling'),
('Office Chair',          'Furniture',   149.00,  40, 'FurniCo',               'Ergonomic office chair'),
('Standing Desk',         'Furniture',   299.00,  20, 'FurniCo',               'Adjustable height desk'),
('Desk Lamp LED',         'Lighting',     35.00, 120, 'BrightLight',           'LED desk lamp with dimmer'),
('Floor Lamp',            'Lighting',     89.99,  45, 'BrightLight',           'Modern floor lamp'),
('Running Shoes',         'Apparel',      60.00, 100, 'ActiveGear',            'Lightweight running shoes'),
('Yoga Mat',              'Fitness',      25.00, 250, 'FitPros',               'Non-slip yoga mat'),
('Dumbbell Set 10‑50 lbs','Fitness',     199.00,  30, 'FitPros',               'Adjustable dumbbell set'),
('Water Bottle 1L',       'Fitness',      12.50, 300, 'HydroPlus',             'Stainless steel bottle'),
('Smartwatch Pro',        'Electronics', 199.99, 75, 'TechNova',              'Waterproof smartwatch'),
('Tablet 10‑inch',        'Electronics', 249.00, 60, 'TechNova',              '10‑inch Android tablet'),
('Coffee Maker',          'Appliances',   79.99, 80, 'HomeBrew Co.',          '12‑cup programmable coffee maker'),
('Blender 700W',          'Appliances',   99.95, 60, 'HomeBrew Co.',          'High‑power kitchen blender'),
('Air Fryer 5L',          'Appliances',  129.00, 50, 'KitchenMaster',         'Digital 5‑liter air fryer'),
('Baking Sheet Set',      'Kitchen',      29.99, 200, 'KitchenMaster',         'Non‑stick baking sheets (3‑pc)'),
('Chef Knife 8‑inch',     'Kitchen',      49.00, 120, 'SharpEdge Tools',       'Premium stainless chef knife'),
('Cutting Board Bamboo',  'Kitchen',      19.95, 150, 'SharpEdge Tools',       'Eco‑friendly bamboo board');

SELECT * FROM products;

--  List all products with price between 100 and 1000.
SELECT name,category,price FROM products WHERE price BETWEEN 100 AND 1000;

--  Select only name, category, and price.
SELECT name,category,price FROM products;

--  Use LIKE to find products with “phone” in the name.
SELECT name,category,price FROM products WHERE category='Phone';

--  Retrieve items with NULL description.
SELECT name, description FROM products WHERE description IS NULL;

-- Use DISTINCT to list all suppliers.
SELECT DISTINCT supplier FROM products;

-- Filter products where stock is 0 OR price > 5000.
SELECT name,price,stock FROM products WHERE stock=0 OR price>5000;

-- Sort by category, then price DESC
SELECT name, category FROM products ORDER BY category;

SELECT name, category,price FROM products ORDER BY price DESC;

-- Step 1: Create Database and Switch Context
CREATE DATABASE ECommerceCatalog;
USE ECommerceCatalog;

-- Step 2: Normalize Tables (3NF Design)
CREATE TABLE categories (
  category_id INT PRIMARY KEY AUTO_INCREMENT,
  category_name VARCHAR(100) NOT NULL
);

CREATE TABLE suppliers (
  supplier_id INT PRIMARY KEY AUTO_INCREMENT,
  supplier_name VARCHAR(255) NOT NULL
);

CREATE TABLE products (
  product_id INT PRIMARY KEY AUTO_INCREMENT,
  product_name VARCHAR(255) NOT NULL,
  category_id INT NOT NULL,
  supplier_id INT NOT NULL,
  price DECIMAL(10,2),
  FOREIGN KEY (category_id) REFERENCES categories(category_id),
  FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

CREATE TABLE inventory (
  inventory_id INT PRIMARY KEY AUTO_INCREMENT,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE orders (
  order_id INT PRIMARY KEY AUTO_INCREMENT,
  order_date DATE NOT NULL,
  customer_name VARCHAR(255),
  total_amount DECIMAL(10,2)
);

CREATE TABLE order_items (
  order_item_id INT PRIMARY KEY AUTO_INCREMENT,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  unit_price DECIMAL(10,2),
  FOREIGN KEY (order_id) REFERENCES orders(order_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Step 3: Denormalized Reporting Table
CREATE TABLE product_sales_summary (
  product_id INT,
  product_name VARCHAR(255),
  total_quantity_sold INT,
  total_sales_amount DECIMAL(15,2),
  PRIMARY KEY (product_id)
);

-- Step 4: Sample Data Insertion

INSERT INTO categories (category_name) VALUES
('Electronics'),
('Apparel'),
('Home Goods');

INSERT INTO suppliers (supplier_name) VALUES
('Acme Corp'),
('Global Supplies'),
('Techtronics');

INSERT INTO products (product_name, category_id, supplier_id, price) VALUES
('Smartphone X', 1, 3, 999.99),
('Laptop Pro', 1, 3, 1299.99),
('Wireless Headphones', 1, 1, 199.99),
('Men''s T-Shirt', 2, 2, 29.99),
('Blender 5000', 3, 1, 89.99);

INSERT INTO inventory (product_id, quantity) VALUES
(1, 100),
(2, 50),
(3, 200),
(4, 300),
(5, 75);

INSERT INTO orders (order_date, customer_name, total_amount) VALUES
('2025-07-01', 'John Doe', 1199.98),
('2025-07-02', 'Jane Smith', 1619.98),
('2025-07-03', 'Emily Davis', 29.99);

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 999.99),
(1, 4, 2, 29.99),
(2, 2, 1, 1299.99),
(2, 3, 1, 199.99),
(3, 4, 1, 29.99);

-- Step 5: Indexes for Performance
CREATE INDEX idx_products_name ON products (product_name);
CREATE INDEX idx_products_category ON products (category_id);
CREATE INDEX idx_products_supplier ON products (supplier_id);

-- Now you can run EXPLAIN, subqueries, pagination, summary inserts, etc.

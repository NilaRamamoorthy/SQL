-- Step 1: Create the Database
CREATE DATABASE ecommerce_db;
USE ecommerce_db;

-- Step 2: Create Tables (Star Schema)

-- Customers Table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    address TEXT
);

-- Products Table
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10, 2),
    stock INT
);

-- Orders Table
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Order Details Table
CREATE TABLE order_details (
    order_detail_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Payments Table
CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    amount DECIMAL(10, 2),
    payment_date DATE,
    payment_method VARCHAR(50),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Shipments Table
CREATE TABLE shipments (
    shipment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    shipment_date DATE,
    delivery_date DATE,
    status VARCHAR(50),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Step 3: Insert Sample Data (20+ Records)

-- Customers
INSERT INTO customers (name, email, phone, address) VALUES
('Alice Sharma', 'alice@gmail.com', '9876543210', 'Delhi'),
('Bob Singh', 'bob@gmail.com', '9123456780', 'Mumbai'),
('Carol Patel', 'carol@gmail.com', '9234567810', 'Bangalore'),
('David Rao', 'david@gmail.com', '9345678910', 'Chennai'),
('Eva Das', 'eva@gmail.com', '9456789120', 'Hyderabad');

-- Products
INSERT INTO products (name, category, price, stock) VALUES
('Laptop', 'Electronics', 75000, 20),
('Smartphone', 'Electronics', 25000, 40),
('Shoes', 'Fashion', 2000, 100),
('Washing Machine', 'Home Appliances', 35000, 15),
('Backpack', 'Accessories', 1200, 50);

-- Orders
INSERT INTO orders (customer_id, order_date) VALUES
(1, '2025-08-01'), (2, '2025-08-02'), (1, '2025-08-03'),
(3, '2025-08-04'), (4, '2025-08-05'), (5, '2025-08-06'),
(2, '2025-08-07'), (3, '2025-08-08');

-- Order Details
INSERT INTO order_details (order_id, product_id, quantity) VALUES
(1, 1, 1), (1, 5, 2), (2, 2, 1),
(3, 3, 3), (4, 4, 1), (5, 5, 2),
(6, 1, 1), (7, 3, 2), (8, 2, 1);

-- Payments
INSERT INTO payments (order_id, amount, payment_date, payment_method) VALUES
(1, 77400, '2025-08-01', 'Credit Card'),
(2, 25000, '2025-08-02', 'UPI'),
(3, 6000, '2025-08-03', 'Net Banking'),
(4, 35000, '2025-08-04', 'Cash on Delivery'),
(5, 2400, '2025-08-05', 'UPI'),
(6, 75000, '2025-08-06', 'Credit Card'),
(7, 4000, '2025-08-07', 'Debit Card'),
(8, 25000, '2025-08-08', 'Net Banking');

-- Shipments
INSERT INTO shipments (order_id, shipment_date, delivery_date, status) VALUES
(1, '2025-08-01', '2025-08-03', 'Delivered'),
(2, '2025-08-02', '2025-08-05', 'Delivered'),
(3, '2025-08-03', '2025-08-06', 'Delivered'),
(4, '2025-08-04', '2025-08-07', 'Shipped'),
(5, '2025-08-05', NULL, 'Pending'),
(6, '2025-08-06', '2025-08-08', 'Delivered'),
(7, '2025-08-07', '2025-08-10', 'Delivered'),
(8, '2025-08-08', NULL, 'Shipped');

-- Step 4: Advanced SQL Queries (BI Reports)

-- 1. Retrieve Customer Purchase History
SELECT 
    c.name AS customer_name,
    o.order_id,
    o.order_date,
    p.name AS product_name,
    od.quantity,
    pay.amount
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
JOIN payments pay ON o.order_id = pay.order_id
ORDER BY c.name, o.order_date;

-- 2. Identify Best-Selling Products
SELECT 
    p.name AS product_name,
    SUM(od.quantity) AS total_units_sold
FROM order_details od
JOIN products p ON od.product_id = p.product_id
GROUP BY p.name
ORDER BY total_units_sold DESC
LIMIT 5;

-- 3. Monthly Sales Report Using Window Functions
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    SUM(pay.amount) AS total_monthly_sales,
    RANK() OVER (ORDER BY SUM(pay.amount) DESC) AS sales_rank
FROM orders o
JOIN payments pay ON o.order_id = pay.order_id
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m');

-- 4. Customers with the Most Orders
SELECT 
    c.name AS customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id
ORDER BY total_orders DESC
LIMIT 3;

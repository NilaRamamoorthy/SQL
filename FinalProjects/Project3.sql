
CREATE DATABASE IF NOT EXISTS order_system;
USE order_system;

-- 2. CREATE TABLES


-- Users table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE
);

-- Products table
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL,
    image_url VARCHAR(255)
);

-- Orders table
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    status ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Order Items table
CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL, -- store product price at time of purchase
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- 4. INSERT SAMPLE DATA


-- Users
INSERT INTO users (name, email) VALUES
('Alice', 'alice@example.com'),
('Bob', 'bob@example.com');

-- Products
INSERT INTO products (name, description, price, stock, image_url) VALUES
('Laptop', 'High performance laptop', 1200.00, 10, 'https://example.com/laptop.jpg'),
('Headphones', 'Noise-cancelling headphones', 150.00, 20, 'https://example.com/headphones.jpg'),
('Book', 'Interesting novel', 25.00, 100, 'https://example.com/book.jpg');

-- Orders
INSERT INTO orders (user_id, status) VALUES
(1, 'Pending'), -- Alice
(2, 'Processing'); -- Bob

-- Order Items
INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
(1, 1, 1, 1200.00), -- Alice bought 1 Laptop
(1, 3, 2, 25.00),   -- Alice bought 2 Books
(2, 2, 1, 150.00);  -- Bob bought 1 Headphone


-- 1. Get full order history for a user (Alice)
SELECT 
    o.id AS order_id,
    o.created_at,
    o.status,
    p.name AS product,
    oi.quantity,
    oi.price,
    (oi.quantity * oi.price) AS total_item_price
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id
WHERE o.user_id = 1
ORDER BY o.created_at DESC;

-- 2. Get total amount per order
SELECT 
    o.id AS order_id,
    u.name AS user,
    o.status,
    o.created_at,
    SUM(oi.quantity * oi.price) AS total_order_value
FROM orders o
JOIN users u ON o.user_id = u.id
JOIN order_items oi ON o.id = oi.order_id
GROUP BY o.id, u.name, o.status, o.created_at
ORDER BY o.created_at DESC;

-- 3. Count orders by status
SELECT 
    status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY status;

-- 4. Update order status (e.g., mark Alice's order as Shipped)
UPDATE orders
SET status = 'Shipped'
WHERE id = 1;

-- 5. Create a new order using a transaction (example template)

START TRANSACTION;

INSERT INTO orders (user_id, status) VALUES (1, 'Pending');
SET @last_order_id = LAST_INSERT_ID();

INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
(@last_order_id, 2, 1, 150.00),
(@last_order_id, 3, 3, 25.00);

COMMIT;

-- 6. Get product sales totals
SELECT 
    p.name AS product,
    SUM(oi.quantity) AS total_units_sold,
    SUM(oi.quantity * oi.price) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.id
GROUP BY p.id
ORDER BY total_revenue DESC;

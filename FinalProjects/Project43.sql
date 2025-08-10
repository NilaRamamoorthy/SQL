-- 1. Create Database
CREATE DATABASE product_return_mgmt;
USE product_return_mgmt;

-- 2. Create Tables

-- Orders table
CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    product_id INT NOT NULL
);

-- Returns table
CREATE TABLE returns (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    reason VARCHAR(255) NOT NULL,
    status ENUM('Pending', 'Approved', 'Rejected') NOT NULL DEFAULT 'Pending',
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

-- 3. Insert Sample Data

INSERT INTO orders (user_id, product_id) VALUES
(1, 101),
(2, 102),
(3, 103),
(4, 104);

INSERT INTO returns (order_id, reason, status) VALUES
(1, 'Damaged item', 'Pending'),
(2, 'Wrong product delivered', 'Approved'),
(3, 'Size mismatch', 'Rejected');

-- 4. Query: JOIN orders with returns
SELECT 
    o.id AS order_id,
    o.user_id,
    o.product_id,
    r.reason,
    r.status
FROM orders o
LEFT JOIN returns r ON o.id = r.order_id;

-- 5. Query: Return status report (count per status)
SELECT 
    status,
    COUNT(*) AS total_returns
FROM returns
GROUP BY status;

-- 1. Create Database and Use
CREATE DATABASE IF NOT EXISTS shopping_analysis;
USE shopping_analysis;

-- 2. Create Tables

CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255)
);

CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL
);

CREATE TABLE carts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    created_at DATETIME NOT NULL,
    status ENUM('Completed', 'Abandoned') NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE cart_items (
    cart_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    PRIMARY KEY (cart_id, product_id),
    FOREIGN KEY (cart_id) REFERENCES carts(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    cart_id INT,
    order_date DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (cart_id) REFERENCES carts(id)
);

CREATE TABLE order_items (
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- 3. Insert Sample Data

INSERT INTO users (name, email) VALUES
('Alice', 'alice@example.com'),
('Bob', 'bob@example.com'),
('Charlie', 'charlie@example.com');

INSERT INTO products (name, price) VALUES
('Laptop', 70000),
('Headphones', 1500),
('Smartphone', 25000),
('Mouse', 800);

-- Alice's carts
INSERT INTO carts (user_id, created_at, status) VALUES
(1, NOW() - INTERVAL 10 DAY, 'Completed'),
(1, NOW() - INTERVAL 6 DAY, 'Abandoned'),
(1, NOW() - INTERVAL 4 DAY, 'Abandoned'),
(1, NOW() - INTERVAL 2 DAY, 'Abandoned');

-- Bob's carts
INSERT INTO carts (user_id, created_at, status) VALUES
(2, NOW() - INTERVAL 8 DAY, 'Completed'),
(2, NOW() - INTERVAL 5 DAY, 'Completed');

-- Charlie's carts
INSERT INTO carts (user_id, created_at, status) VALUES
(3, NOW() - INTERVAL 9 DAY, 'Abandoned'),
(3, NOW() - INTERVAL 3 DAY, 'Abandoned');

-- Cart Items
INSERT INTO cart_items (cart_id, product_id, quantity) VALUES
(1, 1, 1), -- Alice's completed cart: Laptop
(2, 2, 1), -- Alice abandoned cart: Headphones
(3, 3, 1), -- Alice abandoned cart: Smartphone
(4, 2, 2), -- Alice abandoned cart: Headphones
(5, 3, 1), -- Bob completed cart: Smartphone
(6, 4, 1), -- Bob completed cart: Mouse
(7, 1, 1), -- Charlie abandoned cart: Laptop
(8, 4, 2); -- Charlie abandoned cart: Mouse

-- Orders
INSERT INTO orders (user_id, cart_id, order_date) VALUES
(1, 1, NOW() - INTERVAL 9 DAY),
(2, 5, NOW() - INTERVAL 7 DAY),
(2, 6, NOW() - INTERVAL 4 DAY);

-- Order Items
INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 1, 1),
(2, 3, 1),
(3, 4, 1);

-- 4. Query: Subquery to find users who abandoned carts more than 3 times

SELECT u.id, u.name, COUNT(c.id) AS abandoned_cart_count
FROM users u
JOIN carts c ON u.id = c.user_id
WHERE c.status = 'Abandoned'
AND c.created_at >= NOW() - INTERVAL 7 DAY
GROUP BY u.id, u.name
HAVING COUNT(c.id) > 3;

-- 5. Query: CASE to label cart status (already a status column, but to show usage)

SELECT
    c.id,
    u.name AS user_name,
    CASE
        WHEN c.status = 'Completed' THEN 'Completed'
        ELSE 'Abandoned'
    END AS cart_status,
    c.created_at
FROM carts c
JOIN users u ON c.user_id = u.id;

-- 6. Query: UNION for items added to cart and items actually purchased

-- Items added to carts
SELECT
    u.id AS user_id,
    u.name AS user_name,
    p.id AS product_id,
    p.name AS product_name,
    'Added to Cart' AS action,
    ci.quantity,
    c.created_at AS action_date
FROM users u
JOIN carts c ON u.id = c.user_id
JOIN cart_items ci ON c.id = ci.cart_id
JOIN products p ON ci.product_id = p.id

UNION ALL

-- Items purchased
SELECT
    u.id AS user_id,
    u.name AS user_name,
    p.id AS product_id,
    p.name AS product_name,
    'Purchased' AS action,
    oi.quantity,
    o.order_date AS action_date
FROM users u
JOIN orders o ON u.id = o.user_id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id;

-- 7. Query: Correlated subquery to find most abandoned product per user

SELECT 
    u.id,
    u.name,
    (
        SELECT p.name
        FROM cart_items ci
        JOIN carts c ON ci.cart_id = c.id
        JOIN products p ON ci.product_id = p.id
        WHERE c.user_id = u.id AND c.status = 'Abandoned'
        GROUP BY p.id, p.name
        ORDER BY COUNT(*) DESC
        LIMIT 1
    ) AS most_abandoned_product
FROM users u;

-- 8. Query: Date filtering for abandonments in the last week

SELECT 
    c.id,
    u.name AS user_name,
    c.created_at,
    c.status
FROM carts c
JOIN users u ON c.user_id = u.id
WHERE c.status = 'Abandoned'
AND c.created_at >= NOW() - INTERVAL 7 DAY;

-- 9. Query: JOIN + GROUP BY to see cart conversion rate (ratio of completed carts to total carts per user)

SELECT 
    u.id,
    u.name,
    COUNT(c.id) AS total_carts,
    SUM(CASE WHEN c.status = 'Completed' THEN 1 ELSE 0 END) AS completed_carts,
    ROUND(SUM(CASE WHEN c.status = 'Completed' THEN 1 ELSE 0 END) / COUNT(c.id) * 100, 2) AS conversion_rate_percent
FROM users u
JOIN carts c ON u.id = c.user_id
GROUP BY u.id, u.name;

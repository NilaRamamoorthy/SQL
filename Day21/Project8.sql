-- 1. Create Database
CREATE DATABASE food_delivery;
USE food_delivery;

-- 2. Create Tables

CREATE TABLE restaurants (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL
);

CREATE TABLE delivery_agents (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    restaurant_id INT NOT NULL,
    delivery_agent_id INT,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id),
    FOREIGN KEY (delivery_agent_id) REFERENCES delivery_agents(id)
);

CREATE TABLE order_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    item_name VARCHAR(255) NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id)
);

-- 3. Insert Sample Data

INSERT INTO restaurants (name, location) VALUES
('Spicy Grill', 'Downtown'),
('Sushi House', 'Uptown'),
('Pizza Palace', 'Downtown'),
('Burger Barn', 'Midtown');

INSERT INTO delivery_agents (name) VALUES
('Alice'),
('Bob'),
('Charlie');

INSERT INTO orders (restaurant_id, delivery_agent_id, order_date) VALUES
(1, 1, '2025-07-01 10:00:00'),
(1, 2, '2025-07-02 11:00:00'),
(2, 1, '2025-07-03 12:00:00'),
(3, NULL, '2025-07-04 13:00:00'),
(3, 3, '2025-07-05 14:00:00'),
(4, 2, '2025-07-06 15:00:00'),
(1, 1, '2025-07-07 16:00:00');

INSERT INTO order_items (order_id, item_name, quantity, price) VALUES
(1, 'Chicken Curry', 2, 250.00),
(1, 'Naan Bread', 4, 50.00),
(2, 'Grilled Fish', 1, 500.00),
(3, 'Sushi Roll', 3, 300.00),
(4, 'Pepperoni Pizza', 1, 600.00),
(5, 'Veggie Pizza', 2, 450.00),
(6, 'Cheeseburger', 1, 350.00),
(7, 'Spicy Wings', 5, 200.00);

-- 4. Queries

-- a) Total orders per restaurant
SELECT
    r.id,
    r.name,
    COUNT(o.id) AS total_orders
FROM restaurants r
LEFT JOIN orders o ON r.id = o.restaurant_id
GROUP BY r.id, r.name;

-- b) Sum of order values per delivery agent
SELECT
    da.id,
    da.name,
    COALESCE(SUM(oi.price * oi.quantity), 0) AS total_revenue
FROM delivery_agents da
LEFT JOIN orders o ON da.id = o.delivery_agent_id
LEFT JOIN order_items oi ON o.id = oi.order_id
GROUP BY da.id, da.name;

-- c) Restaurants with revenue > 50000 (HAVING)
SELECT
    r.id,
    r.name,
    SUM(oi.price * oi.quantity) AS total_revenue
FROM restaurants r
JOIN orders o ON r.id = o.restaurant_id
JOIN order_items oi ON o.id = oi.order_id
GROUP BY r.id, r.name
HAVING total_revenue > 50000;

-- d) INNER JOIN: restaurants ↔ orders (all orders with restaurant info)
SELECT
    o.id AS order_id,
    r.name AS restaurant_name,
    o.order_date
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.id;

-- e) LEFT JOIN: delivery agents ↔ orders (all agents with their orders)
SELECT
    da.id AS agent_id,
    da.name AS agent_name,
    o.id AS order_id,
    o.order_date
FROM delivery_agents da
LEFT JOIN orders o ON da.id = o.delivery_agent_id;

-- f) SELF JOIN to find restaurants in the same location
SELECT
    r1.id AS restaurant1_id,
    r1.name AS restaurant1_name,
    r2.id AS restaurant2_id,
    r2.name AS restaurant2_name,
    r1.location
FROM restaurants r1
JOIN restaurants r2 ON r1.location = r2.location AND r1.id < r2.id
ORDER BY r1.location, r1.name;

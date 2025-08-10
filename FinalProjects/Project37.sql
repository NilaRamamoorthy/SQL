-- 1. Create Database
CREATE DATABASE food_delivery_tracker;
USE food_delivery_tracker;

-- 2. Create Tables

-- Orders
CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    restaurant_id INT NOT NULL,
    user_id INT NOT NULL,
    placed_at DATETIME NOT NULL,
    delivered_at DATETIME NULL
);

-- Delivery agents
CREATE TABLE delivery_agents (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Deliveries
CREATE TABLE deliveries (
    order_id INT NOT NULL,
    agent_id INT NOT NULL,
    PRIMARY KEY (order_id, agent_id),
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (agent_id) REFERENCES delivery_agents(id) ON DELETE CASCADE
);

-- 3. Insert Sample Data

-- Delivery Agents
INSERT INTO delivery_agents (name) VALUES
('John Miller'),
('Sara Khan'),
('David Chen');

-- Orders
INSERT INTO orders (restaurant_id, user_id, placed_at, delivered_at) VALUES
(1, 101, '2025-08-01 12:00:00', '2025-08-01 12:30:00'),
(2, 102, '2025-08-01 12:15:00', '2025-08-01 12:50:00'),
(1, 103, '2025-08-02 13:00:00', '2025-08-02 13:25:00'),
(3, 104, '2025-08-02 13:10:00', NULL),
(2, 105, '2025-08-03 18:00:00', '2025-08-03 18:40:00');

-- Deliveries
INSERT INTO deliveries (order_id, agent_id) VALUES
(1, 1),
(2, 2),
(3, 1),
(4, 3),
(5, 2);

-- 4. Query: Average delivery time (in minutes)
SELECT 
    AVG(TIMESTAMPDIFF(MINUTE, placed_at, delivered_at)) AS avg_delivery_minutes
FROM orders
WHERE delivered_at IS NOT NULL;

-- 5. Query: Delivery count per agent
SELECT 
    da.name AS agent_name,
    COUNT(d.order_id) AS deliveries_made
FROM delivery_agents da
LEFT JOIN deliveries d ON da.id = d.agent_id
GROUP BY da.id
ORDER BY deliveries_made DESC;

-- 6. Query: Late deliveries (> 40 minutes)
SELECT 
    o.id AS order_id,
    da.name AS agent_name,
    TIMESTAMPDIFF(MINUTE, placed_at, delivered_at) AS delivery_time
FROM orders o
JOIN deliveries d ON o.id = d.order_id
JOIN delivery_agents da ON d.agent_id = da.id
WHERE delivered_at IS NOT NULL
  AND TIMESTAMPDIFF(MINUTE, placed_at, delivered_at) > 40;

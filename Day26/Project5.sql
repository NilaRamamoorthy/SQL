-- 1. Create Database and Use
CREATE DATABASE IF NOT EXISTS customer_journey;
USE customer_journey;

-- 2. Create Tables

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATETIME,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_stages (
    stage_id INT PRIMARY KEY,
    stage_name VARCHAR(50),
    next_stage_id INT NULL,
    FOREIGN KEY (next_stage_id) REFERENCES order_stages(stage_id)
);

CREATE TABLE order_events (
    event_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    stage_id INT,
    event_time DATETIME,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (stage_id) REFERENCES order_stages(stage_id)
);

-- 3. Insert Sample Data

INSERT INTO customers (customer_id, name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie');

INSERT INTO orders (order_id, customer_id, order_date) VALUES
(1001, 1, '2025-08-01 10:00:00'),
(1002, 1, '2025-08-05 12:00:00'),
(1003, 2, '2025-08-03 09:30:00');

INSERT INTO order_stages (stage_id, stage_name, next_stage_id) VALUES
(1, 'Order Placed', 2),
(2, 'Processing', 3),
(3, 'Shipped', 4),
(4, 'Delivered', NULL);

INSERT INTO order_events (order_id, stage_id, event_time) VALUES
(1001, 1, '2025-08-01 10:00:00'),
(1001, 2, '2025-08-01 14:00:00'),
(1001, 3, '2025-08-02 08:00:00'),
(1001, 4, '2025-08-03 16:00:00'),

(1002, 1, '2025-08-05 12:00:00'),
(1002, 2, '2025-08-06 09:00:00'),

(1003, 1, '2025-08-03 09:30:00'),
(1003, 2, '2025-08-03 15:00:00'),
(1003, 3, '2025-08-04 10:00:00');

-- 4. Recursive CTE for order stage hierarchy (optional - shows order from start to end)

WITH RECURSIVE stage_hierarchy AS (
    SELECT stage_id, stage_name, next_stage_id, 1 AS level
    FROM order_stages
    WHERE stage_id = 1
    
    UNION ALL
    
    SELECT os.stage_id, os.stage_name, os.next_stage_id, sh.level + 1
    FROM order_stages os
    JOIN stage_hierarchy sh ON os.stage_id = sh.next_stage_id
)
SELECT * FROM stage_hierarchy ORDER BY level;

-- 5. Use ROW_NUMBER() to order events per customer and order

WITH ordered_events AS (
    SELECT
        c.customer_id,
        c.name AS customer_name,
        o.order_id,
        oe.stage_id,
        os.stage_name,
        oe.event_time,
        ROW_NUMBER() OVER (PARTITION BY c.customer_id, o.order_id ORDER BY oe.event_time) AS event_seq,
        LAG(oe.event_time) OVER (PARTITION BY c.customer_id, o.order_id ORDER BY oe.event_time) AS prev_event_time
    FROM order_events oe
    JOIN orders o ON oe.order_id = o.order_id
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN order_stages os ON oe.stage_id = os.stage_id
)

SELECT
    customer_id,
    customer_name,
    order_id,
    event_seq,
    stage_name,
    event_time,
    prev_event_time,
    TIMESTAMPDIFF(MINUTE, prev_event_time, event_time) AS minutes_since_prev_event
FROM ordered_events
ORDER BY customer_id, order_id, event_seq;

-- 6. Rank customers by total number of order events (frequency)

WITH customer_event_counts AS (
    SELECT
        c.customer_id,
        c.name,
        COUNT(oe.event_id) AS total_events
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    LEFT JOIN order_events oe ON o.order_id = oe.order_id
    GROUP BY c.customer_id, c.name
)

SELECT
    customer_id,
    name,
    total_events,
    RANK() OVER (ORDER BY total_events DESC) AS frequency_rank
FROM customer_event_counts
ORDER BY frequency_rank;

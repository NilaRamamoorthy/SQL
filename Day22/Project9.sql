-- 1. Create Database and Use
CREATE DATABASE IF NOT EXISTS food_ordering_insights;
USE food_ordering_insights;

-- 2. Create Tables

CREATE TABLE restaurants (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    area VARCHAR(255)
);

CREATE TABLE customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    area VARCHAR(255)
);

CREATE TABLE dishes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    restaurant_id INT,
    name VARCHAR(255),
    price DECIMAL(10,2),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id)
);

CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    dish_id INT,
    order_type ENUM('Delivery', 'Pickup'),
    delivery_date DATE,
    quantity INT DEFAULT 1,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (dish_id) REFERENCES dishes(id)
);

-- 3. Insert Sample Data

INSERT INTO restaurants (name, area) VALUES
('Tasty Bites', 'Downtown'),
('Food Palace', 'Uptown'),
('Green Eatery', 'Downtown');

INSERT INTO customers (name, area) VALUES
('Alice', 'Downtown'),
('Bob', 'Uptown'),
('Charlie', 'Downtown'),
('David', 'Midtown');

INSERT INTO dishes (restaurant_id, name, price) VALUES
(1, 'Burger', 5.50),
(1, 'Fries', 2.00),
(2, 'Pizza', 8.00),
(3, 'Salad', 6.00);

INSERT INTO orders (customer_id, dish_id, order_type, delivery_date, quantity) VALUES
(1, 1, 'Delivery', '2025-08-01', 2),
(1, 2, 'Pickup', '2025-08-01', 1),
(2, 3, 'Delivery', '2025-08-02', 3),
(3, 4, 'Pickup', '2025-08-03', 1),
(4, 1, 'Delivery', '2025-08-04', 1),
(2, 2, 'Delivery', '2025-08-05', 4),
(3, 3, 'Pickup', '2025-08-06', 2);

-- 4a. SELECT subquery to show dish popularity percentage

SELECT 
    d.name AS dish_name,
    SUM(o.quantity) AS total_ordered,
    (SUM(o.quantity) * 100.0 / (SELECT SUM(quantity) FROM orders)) AS popularity_percentage
FROM dishes d
LEFT JOIN orders o ON d.id = o.dish_id
GROUP BY d.id, d.name;

-- 4b. FROM subquery to calculate order volume by area

SELECT
    area,
    SUM(total_orders) AS total_order_volume
FROM (
    SELECT
        c.area,
        COUNT(o.id) AS total_orders
    FROM customers c
    LEFT JOIN orders o ON c.id = o.customer_id
    GROUP BY c.area, c.id
) AS sub
GROUP BY area;

-- 4c. CASE to bucket customers based on total orders

SELECT
    c.id,
    c.name,
    COUNT(o.id) AS total_orders,
    CASE 
        WHEN COUNT(o.id) > 5 THEN 'High'
        WHEN COUNT(o.id) BETWEEN 3 AND 5 THEN 'Medium'
        ELSE 'Low'
    END AS order_bucket
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name;

-- 4d. Correlated subquery to get customer with highest order in each area

SELECT DISTINCT
    c.area,
    (SELECT c2.name
     FROM customers c2
     JOIN orders o2 ON c2.id = o2.customer_id
     WHERE c2.area = c.area
     GROUP BY c2.id
     ORDER BY COUNT(o2.id) DESC
     LIMIT 1) AS top_customer
FROM customers c;

-- 4e. UNION ALL to compare delivery and pickup orders

SELECT 
    'Delivery' AS order_type,
    COUNT(*) AS total_orders,
    SUM(quantity) AS total_quantity
FROM orders
WHERE order_type = 'Delivery'

UNION ALL

SELECT 
    'Pickup' AS order_type,
    COUNT(*) AS total_orders,
    SUM(quantity) AS total_quantity
FROM orders
WHERE order_type = 'Pickup';

-- 4f. Group orders by delivery date using date functions

SELECT 
    delivery_date,
    COUNT(*) AS orders_count,
    SUM(quantity) AS total_quantity
FROM orders
GROUP BY delivery_date
ORDER BY delivery_date;

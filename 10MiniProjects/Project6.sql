-- 1. Create Database and Use
CREATE DATABASE IF NOT EXISTS restaurant_management;
USE restaurant_management;

-- 2. Create Tables

CREATE TABLE customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    first_order_date DATE
);

CREATE TABLE staff (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    role VARCHAR(50) -- e.g., waiter, chef
);

CREATE TABLE menu_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL
);

CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    staff_id INT,        -- waiter/waitress who handled the order
    order_type ENUM('Dine-in', 'Delivery'),
    order_date DATE,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (staff_id) REFERENCES staff(id)
);

CREATE TABLE order_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    menu_item_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (menu_item_id) REFERENCES menu_items(id)
);

-- 3. Insert Sample Data

INSERT INTO customers (name, first_order_date) VALUES
('John Doe', '2025-01-01'),
('Jane Smith', '2025-06-10'),
('Alice Brown', '2025-05-05'),
('Bob Johnson', '2025-06-15');

INSERT INTO staff (name, role) VALUES
('Michael', 'Waiter'),
('Sarah', 'Waiter'),
('Tom', 'Chef');

INSERT INTO menu_items (name, price) VALUES
('Margherita Pizza', 250.00),
('Pepperoni Pizza', 350.00),
('Pasta Alfredo', 300.00),
('Caesar Salad', 150.00);

INSERT INTO orders (customer_id, staff_id, order_type, order_date, total_amount) VALUES
(1, 1, 'Dine-in', '2025-07-01', 600.00),
(2, 2, 'Delivery', '2025-07-02', 350.00),
(1, 1, 'Delivery', '2025-07-03', 250.00),
(3, 2, 'Dine-in', '2025-07-04', 450.00),
(4, 1, 'Delivery', '2025-07-05', 150.00),
(2, 2, 'Dine-in', '2025-07-06', 700.00);

INSERT INTO order_items (order_id, menu_item_id, quantity) VALUES
(1, 1, 1),
(1, 3, 1),
(2, 2, 1),
(3, 1, 1),
(4, 4, 3),
(5, 4, 1),
(6, 2, 2);

-- 4. Query: INNER JOIN to list full orders with customer and waiter info

SELECT 
    o.id AS order_id,
    c.name AS customer_name,
    s.name AS waiter_name,
    o.order_type,
    o.order_date,
    o.total_amount
FROM orders o
INNER JOIN customers c ON o.customer_id = c.id
INNER JOIN staff s ON o.staff_id = s.id
ORDER BY o.order_date;

-- 5. Query: Find pizza menu items using LIKE '%Pizza%'

SELECT 
    id,
    name,
    price
FROM menu_items
WHERE name LIKE '%Pizza%';

-- 6. Query: Total orders per staff (waiter)

SELECT 
    s.name AS staff_name,
    COUNT(o.id) AS total_orders
FROM staff s
LEFT JOIN orders o ON s.id = o.staff_id
GROUP BY s.id, s.name
ORDER BY total_orders DESC;

-- 7. Query: List orders ordered by amount and customer name

SELECT 
    o.id AS order_id,
    c.name AS customer_name,
    o.total_amount,
    o.order_date
FROM orders o
JOIN customers c ON o.customer_id = c.id
ORDER BY o.total_amount DESC, c.name;

-- 8. Query: Categorize customers as New or Returning based on order count

SELECT
    c.id,
    c.name,
    CASE 
        WHEN order_count > 1 THEN 'Returning'
        ELSE 'New'
    END AS customer_category,
    order_count
FROM (
    SELECT 
        c.id,
        c.name,
        COUNT(o.id) AS order_count
    FROM customers c
    LEFT JOIN orders o ON c.id = o.customer_id
    GROUP BY c.id, c.name
) AS cust_orders;

-- 9. Query: Subquery to find customers who ordered more than 5 times

SELECT 
    c.id,
    c.name,
    COUNT(o.id) AS total_orders
FROM customers c
JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name
HAVING total_orders > 5;

-- 10. Query: Combine dine-in and delivery orders using UNION

SELECT 
    'Dine-in' AS order_mode,
    o.id AS order_id,
    c.name AS customer_name,
    o.order_date,
    o.total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.id
WHERE o.order_type = 'Dine-in'

UNION ALL

SELECT 
    'Delivery' AS order_mode,
    o.id AS order_id,
    c.name AS customer_name,
    o.order_date,
    o.total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.id
WHERE o.order_type = 'Delivery'
ORDER BY order_date;


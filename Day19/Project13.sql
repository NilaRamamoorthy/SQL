-- Drop and create database

CREATE DATABASE food_delivery;
USE food_delivery;

-- Tables
CREATE TABLE restaurants (
    restaurant_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255)
);

CREATE TABLE delivery_agents (
    agent_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20)
);

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    address VARCHAR(255)
);

CREATE TABLE menus (
    menu_id INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id INT NOT NULL,
    item_name VARCHAR(100) NOT NULL,
    price DECIMAL(7,2) NOT NULL,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    restaurant_id INT NOT NULL,
    agent_id INT,
    order_date DATETIME NOT NULL,
    delivery_status ENUM('Pending', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    total_amount DECIMAL(7,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id),
    FOREIGN KEY (agent_id) REFERENCES delivery_agents(agent_id)
);

-- Insert sample restaurants
INSERT INTO restaurants (name, address) VALUES
('Pizza Palace', '123 Main St'),
('Burger Bonanza', '456 Market Ave'),
('Sushi Central', '789 Elm St'),
('Taco Town', '321 Oak St'),
('Pasta Place', '654 Pine St');

-- Insert delivery agents
INSERT INTO delivery_agents (full_name, phone) VALUES
('John Rider', '555-1111'),
('Mary Wheels', '555-2222'),
('Paul Swift', '555-3333');

-- Insert customers
INSERT INTO customers (full_name, address) VALUES
('Alice Cooper', '10 Downing St'),
('Bob Marley', '42 Wallaby Way'),
('Cindy Crawford', '221B Baker St'),
('David Bowie', '1600 Pennsylvania Ave'),
('Eva Green', '742 Evergreen Terrace');

-- Insert menu items (at least 10 items spread across restaurants)
INSERT INTO menus (restaurant_id, item_name, price) VALUES
(1, 'Pepperoni Pizza', 12.99),
(1, 'Veggie Pizza', 11.99),
(2, 'Cheeseburger', 8.99),
(2, 'Veggie Burger', 7.99),
(3, 'California Roll', 9.99),
(3, 'Spicy Tuna Roll', 10.99),
(4, 'Beef Taco', 6.99),
(4, 'Chicken Taco', 6.99),
(5, 'Spaghetti Carbonara', 13.99),
(5, 'Fettuccine Alfredo', 12.99);

-- Insert orders (15 orders, link customers, restaurants, and agents)
INSERT INTO orders (customer_id, restaurant_id, agent_id, order_date, delivery_status, total_amount) VALUES
(1, 1, 1, '2025-07-01 12:00:00', 'Delivered', 12.99),
(2, 2, 2, '2025-07-01 12:30:00', 'Pending', 8.99),
(3, 3, 3, '2025-07-01 13:00:00', 'Delivered', 10.99),
(4, 1, 1, '2025-07-02 18:00:00', 'Cancelled', 11.99),
(5, 5, 2, '2025-07-02 19:00:00', 'Delivered', 12.99),
(1, 4, 3, '2025-07-03 11:00:00', 'Pending', 6.99),
(2, 3, 1, '2025-07-03 12:15:00', 'Delivered', 9.99),
(3, 2, 2, '2025-07-03 13:30:00', 'Pending', 7.99),
(4, 5, 3, '2025-07-04 14:45:00', 'Delivered', 13.99),
(5, 1, 1, '2025-07-04 15:00:00', 'Delivered', 11.99),
(1, 2, 2, '2025-07-05 16:30:00', 'Pending', 8.99),
(2, 3, 3, '2025-07-05 17:45:00', 'Delivered', 10.99),
(3, 4, 1, '2025-07-06 18:00:00', 'Cancelled', 6.99),
(4, 5, 2, '2025-07-06 19:15:00', 'Delivered', 12.99),
(5, 1, 3, '2025-07-07 20:30:00', 'Pending', 11.99);

-- Query 1: Pending deliveries
SELECT o.order_id, r.name AS restaurant, c.full_name AS customer, o.order_date, o.delivery_status
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.delivery_status = 'Pending';

-- Query 2: Total revenue by restaurant
SELECT r.name AS restaurant, SUM(o.total_amount) AS total_revenue
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
WHERE o.delivery_status = 'Delivered'
GROUP BY r.restaurant_id;

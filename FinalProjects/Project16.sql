-- 1. Create Database
CREATE DATABASE expense_tracker;
USE expense_tracker;

-- 2. Create Tables

-- Users
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Categories
CREATE TABLE categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Expenses
CREATE TABLE expenses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    category_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    date DATE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- 3. Insert Sample Data

-- Users
INSERT INTO users (name) VALUES
('Alice'),
('Bob'),
('Charlie');

-- Categories
INSERT INTO categories (name) VALUES
('Food'),
('Transport'),
('Entertainment'),
('Utilities');

-- Expenses
INSERT INTO expenses (user_id, category_id, amount, date) VALUES
(1, 1, 25.50, '2025-08-01'),
(1, 2, 15.00, '2025-08-02'),
(2, 1, 40.00, '2025-08-02'),
(2, 3, 60.00, '2025-08-05'),
(3, 4, 120.00, '2025-08-05'),
(1, 1, 30.00, '2025-07-30');

-- 4. Query: Aggregation by category
SELECT 
    c.name AS category_name,
    SUM(e.amount) AS total_spent
FROM expenses e
JOIN categories c ON e.category_id = c.id
GROUP BY c.name
ORDER BY total_spent DESC;

-- 5. Query: Monthly aggregation per user
SELECT 
    u.name AS user_name,
    DATE_FORMAT(e.date, '%Y-%m') AS month,
    SUM(e.amount) AS total_spent
FROM expenses e
JOIN users u ON e.user_id = u.id
GROUP BY u.name, DATE_FORMAT(e.date, '%Y-%m')
ORDER BY u.name, month;

-- 6. Query: Filter expenses by amount range
SELECT 
    u.name AS user_name,
    c.name AS category_name,
    e.amount,
    e.date
FROM expenses e
JOIN users u ON e.user_id = u.id
JOIN categories c ON e.category_id = c.id
WHERE e.amount BETWEEN 20 AND 50
ORDER BY e.amount DESC;

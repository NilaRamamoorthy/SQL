-- 1. Create Database
CREATE DATABASE bank_tracker;
USE bank_tracker;

-- 2. Create Tables

CREATE TABLE customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    city VARCHAR(255) NOT NULL
);

CREATE TABLE accounts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    account_number VARCHAR(50) UNIQUE NOT NULL,
    balance DECIMAL(15,2) DEFAULT 0,
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE transactions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    account_id INT NOT NULL,
    type ENUM('deposit', 'withdrawal') NOT NULL,
    amount DECIMAL(15,2) NOT NULL CHECK (amount > 0),
    transacted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(id)
);

-- 3. Insert Sample Data

INSERT INTO customers (name, city) VALUES
('Alice', 'Mumbai'),
('Bob', 'Delhi'),
('Charlie', 'Mumbai'),
('Diana', 'Chennai');

INSERT INTO accounts (customer_id, account_number, balance) VALUES
(1, 'ACC12345', 50000),
(2, 'ACC67890', 15000),
(3, 'ACC54321', 30000),
(4, 'ACC98765', 0);

INSERT INTO transactions (account_id, type, amount, transacted_at) VALUES
(1, 'deposit', 20000, '2025-07-01 10:00:00'),
(1, 'withdrawal', 5000, '2025-07-02 11:00:00'),
(1, 'withdrawal', 12000, '2025-07-10 15:30:00'),
(2, 'deposit', 15000, '2025-07-05 09:00:00'),
(3, 'deposit', 10000, '2025-07-07 14:00:00'),
(3, 'withdrawal', 2000, '2025-07-08 16:00:00');

-- 4. Queries

-- a) Total deposits and withdrawals per account
SELECT 
    a.account_number,
    SUM(CASE WHEN t.type = 'deposit' THEN t.amount ELSE 0 END) AS total_deposits,
    SUM(CASE WHEN t.type = 'withdrawal' THEN t.amount ELSE 0 END) AS total_withdrawals
FROM accounts a
LEFT JOIN transactions t ON a.id = t.account_id
GROUP BY a.id, a.account_number;

-- b) Highest and lowest transaction amounts per account
SELECT
    a.account_number,
    MAX(t.amount) AS highest_transaction,
    MIN(t.amount) AS lowest_transaction
FROM accounts a
LEFT JOIN transactions t ON a.id = t.account_id
GROUP BY a.id, a.account_number;

-- c) Filter accounts with total withdrawals > 10000
SELECT 
    a.account_number,
    SUM(CASE WHEN t.type = 'withdrawal' THEN t.amount ELSE 0 END) AS total_withdrawals
FROM accounts a
LEFT JOIN transactions t ON a.id = t.account_id
GROUP BY a.id, a.account_number
HAVING total_withdrawals > 10000;

-- d) INNER JOIN customers and accounts
SELECT
    c.name AS customer_name,
    c.city,
    a.account_number,
    a.balance
FROM customers c
JOIN accounts a ON c.id = a.customer_id;

-- e) LEFT JOIN to show accounts with no transactions
SELECT
    a.account_number,
    COUNT(t.id) AS transaction_count
FROM accounts a
LEFT JOIN transactions t ON a.id = t.account_id
GROUP BY a.id, a.account_number
HAVING transaction_count = 0;

-- f) SELF JOIN to find customers from the same city
SELECT 
    c1.id AS customer1_id,
    c1.name AS customer1_name,
    c2.id AS customer2_id,
    c2.name AS customer2_name,
    c1.city
FROM customers c1
JOIN customers c2 ON c1.city = c2.city AND c1.id < c2.id
ORDER BY c1.city, c1.name;

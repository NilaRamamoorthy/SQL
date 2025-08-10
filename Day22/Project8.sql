-- 1. Create Database and Use
CREATE DATABASE IF NOT EXISTS digital_wallet_monitor;
USE digital_wallet_monitor;

-- 2. Create Tables

CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    city VARCHAR(255)
);

CREATE TABLE accounts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    wallet_system VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE transactions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    account_id INT,
    transaction_type VARCHAR(20), -- e.g., 'Credit', 'Debit', 'Refund'
    amount DECIMAL(10, 2),
    transaction_date DATETIME,
    FOREIGN KEY (account_id) REFERENCES accounts(id)
);

-- 3. Insert Sample Data

INSERT INTO users (name, city) VALUES
('Alice', 'Mumbai'),
('Bob', 'Delhi'),
('Charlie', 'Mumbai'),
('David', 'Bangalore'),
('Eva', 'Delhi');

INSERT INTO accounts (user_id, wallet_system) VALUES
(1, 'WalletA'),
(1, 'WalletB'),
(2, 'WalletA'),
(3, 'WalletB'),
(4, 'WalletA'),
(5, 'WalletB');

INSERT INTO transactions (account_id, transaction_type, amount, transaction_date) VALUES
(1, 'Credit', 500.00, '2025-08-05 10:00:00'),
(1, 'Debit', 200.00, '2025-08-07 15:30:00'),
(2, 'Refund', 100.00, '2025-08-04 09:00:00'),
(3, 'Credit', 700.00, '2025-08-06 11:00:00'),
(4, 'Debit', 150.00, '2025-08-02 18:00:00'),
(5, 'Credit', 900.00, '2025-08-03 12:00:00'),
(5, 'Debit', 400.00, '2025-08-08 17:00:00');

-- 4a. Subquery: Average transaction value per user

SELECT 
    u.id AS user_id, 
    u.name, 
    (SELECT AVG(t.amount) 
     FROM transactions t 
     JOIN accounts a ON t.account_id = a.id 
     WHERE a.user_id = u.id) AS avg_transaction_value
FROM users u;

-- 4b. JOIN + GROUP BY to show transaction totals by city

SELECT 
    u.city,
    SUM(t.amount) AS total_transaction_amount
FROM users u
JOIN accounts a ON u.id = a.user_id
JOIN transactions t ON a.id = t.account_id
GROUP BY u.city;

-- 4c. CASE for transaction types

SELECT 
    id,
    account_id,
    amount,
    transaction_date,
    CASE
        WHEN transaction_type = 'Credit' THEN 'Credit'
        WHEN transaction_type = 'Debit' THEN 'Debit'
        WHEN transaction_type = 'Refund' THEN 'Refund'
        ELSE 'Other'
    END AS transaction_category
FROM transactions;

-- 4d. UNION to merge two different wallet systems transactions (simulate by selecting WalletA and WalletB separately)

SELECT 
    u.name,
    a.wallet_system,
    t.amount,
    t.transaction_date
FROM users u
JOIN accounts a ON u.id = a.user_id
JOIN transactions t ON a.id = t.account_id
WHERE a.wallet_system = 'WalletA'

UNION

SELECT 
    u.name,
    a.wallet_system,
    t.amount,
    t.transaction_date
FROM users u
JOIN accounts a ON u.id = a.user_id
JOIN transactions t ON a.id = t.account_id
WHERE a.wallet_system = 'WalletB';

-- 4e. INTERSECT to find users active on both WalletA and WalletB

SELECT DISTINCT user_id FROM accounts WHERE wallet_system = 'WalletA'

INTERSECT

SELECT DISTINCT user_id FROM accounts WHERE wallet_system = 'WalletB';

-- 4f. Date filtering for transactions made this week or month (Assuming current date is '2025-08-08')

-- Transactions in current week (Monday to Sunday)
SELECT *
FROM transactions t
WHERE YEARWEEK(DATE(t.transaction_date), 1) = YEARWEEK(CURDATE(), 1);

-- Transactions in current month
SELECT *
FROM transactions t
WHERE YEAR(t.transaction_date) = YEAR(CURDATE())
  AND MONTH(t.transaction_date) = MONTH(CURDATE());

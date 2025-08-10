-- 1. Create Database
CREATE DATABASE bank_transactions;
USE bank_transactions;

-- 2. Create Tables

-- Accounts Table
CREATE TABLE accounts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    balance DECIMAL(15,2) DEFAULT 0.00
);

-- Transactions Table
CREATE TABLE transactions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    account_id INT NOT NULL,
    type ENUM('deposit','withdrawal') NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(id)
);

-- 3. Insert Sample Data

-- Accounts
INSERT INTO accounts (user_id, balance) VALUES
(1, 1000.00),
(2, 500.00),
(3, 2000.00);

-- Transactions
INSERT INTO transactions (account_id, type, amount, timestamp) VALUES
(1, 'deposit', 500.00, '2025-08-01 10:00:00'),
(1, 'withdrawal', 200.00, '2025-08-02 12:00:00'),
(1, 'deposit', 100.00, '2025-08-03 09:30:00'),
(2, 'deposit', 300.00, '2025-08-01 15:00:00'),
(2, 'withdrawal', 100.00, '2025-08-04 14:00:00'),
(3, 'withdrawal', 500.00, '2025-08-02 11:15:00');

-- 4. Query: CTE to Calculate Current Balance from Transactions
WITH balance_calc AS (
    SELECT 
        a.id AS account_id,
        a.user_id,
        SUM(CASE WHEN t.type = 'deposit' THEN t.amount ELSE -t.amount END) AS transaction_sum
    FROM accounts a
    LEFT JOIN transactions t ON a.id = t.account_id
    GROUP BY a.id, a.user_id
)
SELECT 
    bc.account_id,
    bc.user_id,
    a.balance AS initial_balance,
    bc.transaction_sum,
    a.balance + IFNULL(bc.transaction_sum, 0) AS final_balance
FROM balance_calc bc
JOIN accounts a ON bc.account_id = a.id;

-- 5. Query: Transaction History for an Account
SELECT 
    t.id,
    t.account_id,
    t.type,
    t.amount,
    t.timestamp
FROM transactions t
WHERE t.account_id = 1
ORDER BY t.timestamp ASC;

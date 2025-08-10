-- 1. Create Database and Use
CREATE DATABASE IF NOT EXISTS bank_system;
USE bank_system;

-- 2. Create Tables

CREATE TABLE customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    city VARCHAR(100)
);

CREATE TABLE accounts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    account_type ENUM('savings', 'current') NOT NULL,
    balance DECIMAL(15,2) DEFAULT 0,
    opened_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE transactions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    account_id INT,
    transaction_type ENUM('deposit', 'withdrawal') NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    transaction_date DATE NOT NULL,
    FOREIGN KEY (account_id) REFERENCES accounts(id)
);

-- 3. Insert Sample Data

INSERT INTO customers (name, city) VALUES
('Alice', 'New York'),
('Bob', 'Los Angeles'),
('Charlie', 'Chicago'),
('Diana', 'Houston');

INSERT INTO accounts (customer_id, account_type, balance, opened_date) VALUES
(1, 'savings', 15000.00, '2022-01-15'),
(2, 'current', 8000.00, '2023-03-20'),
(3, 'savings', 0.00, '2023-07-10'),
(4, 'current', 12000.00, '2023-05-05'),
(4, 'savings', 2500.00, '2023-06-01');

INSERT INTO transactions (account_id, transaction_type, amount, transaction_date) VALUES
(1, 'deposit', 10000.00, '2023-07-01'),
(1, 'withdrawal', 2000.00, '2023-07-02'),
(2, 'deposit', 5000.00, '2023-07-01'),
(4, 'deposit', 12000.00, '2023-07-03'),
(4, 'withdrawal', 1000.00, '2023-07-04'),
(5, 'deposit', 2500.00, '2023-07-05');

-- 4. Query: Find accounts with no transactions (IS NULL with LEFT JOIN)

SELECT a.id AS account_id, c.name AS customer_name, a.account_type
FROM accounts a
LEFT JOIN transactions t ON a.id = t.account_id
JOIN customers c ON a.customer_id = c.id
WHERE t.id IS NULL;

-- 5. Query: INNER JOIN to combine accounts and customers info

SELECT c.id AS customer_id, c.name, c.city, a.id AS account_id, a.account_type, a.balance
FROM customers c
INNER JOIN accounts a ON c.id = a.customer_id
ORDER BY c.name;

-- 6. Query: SUM of deposits per customer

SELECT c.id AS customer_id, c.name, SUM(t.amount) AS total_deposits
FROM customers c
JOIN accounts a ON c.id = a.customer_id
JOIN transactions t ON a.id = t.account_id AND t.transaction_type = 'deposit'
GROUP BY c.id, c.name
ORDER BY total_deposits DESC;

-- 7. Query: CASE for risk-level classification based on account balance

SELECT a.id AS account_id, c.name AS customer_name, a.balance,
  CASE
    WHEN a.balance >= 10000 THEN 'Low Risk'
    WHEN a.balance BETWEEN 5000 AND 9999.99 THEN 'Medium Risk'
    ELSE 'High Risk'
  END AS risk_level
FROM accounts a
JOIN customers c ON a.customer_id = c.id;

-- 8. Query: Subquery in FROM to compute daily balance changes per account

SELECT daily.account_id, daily.transaction_date,
       SUM(daily.amount_change) AS daily_balance_change
FROM (
    SELECT
        t.account_id,
        t.transaction_date,
        CASE
            WHEN t.transaction_type = 'deposit' THEN t.amount
            ELSE -t.amount
        END AS amount_change
    FROM transactions t
) AS daily
GROUP BY daily.account_id, daily.transaction_date
ORDER BY daily.account_id, daily.transaction_date;

-- 9. Query: UNION ALL to combine savings and current account statements (transaction details)

SELECT c.name AS customer_name, a.account_type, t.transaction_type, t.amount, t.transaction_date
FROM customers c
JOIN accounts a ON c.id = a.customer_id
JOIN transactions t ON a.id = t.account_id
WHERE a.account_type = 'savings'

UNION ALL

SELECT c.name AS customer_name, a.account_type, t.transaction_type, t.amount, t.transaction_date
FROM customers c
JOIN accounts a ON c.id = a.customer_id
JOIN transactions t ON a.id = t.account_id
WHERE a.account_type = 'current'

ORDER BY customer_name, transaction_date;

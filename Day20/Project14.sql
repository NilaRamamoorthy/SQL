-- 1. Create database and switch to it
CREATE DATABASE IF NOT EXISTS digital_wallet_db;
USE digital_wallet_db;

-- 2. Create the transactions table
CREATE TABLE transactions (
  txn_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  txn_type VARCHAR(50) NOT NULL,
  txn_date DATETIME NOT NULL,
  status VARCHAR(20)
);

-- 3. Insert sample data
INSERT INTO transactions (user_id, amount, txn_type, txn_date, status) VALUES
(101, 150.00, 'Mobile Recharge', '2025-08-01 10:30:00', 'Completed'),
(102, 500.00, 'Data Recharge', '2025-08-02 14:45:00', NULL),
(103, 200.00, 'Mobile Recharge', '2025-08-03 09:00:00', 'Failed'),
(104, 1200.00, 'Bill Payment', '2025-08-04 16:20:00', 'Completed'),
(105, 800.00, 'Data Recharge', '2025-08-05 11:15:00', 'Completed'),
(106, 50.00, 'Mobile Recharge', '2025-08-06 13:00:00', 'Completed');

-- 4. Query: Transactions between ₹100 and ₹1000, showing user_id, amount, txn_type
SELECT user_id, amount, txn_type
FROM transactions
WHERE amount BETWEEN 100 AND 1000
ORDER BY txn_date DESC;

-- 5. Query: Transactions where txn_type contains 'recharge'
SELECT user_id, amount, txn_type
FROM transactions
WHERE txn_type LIKE '%recharge%'
ORDER BY txn_date DESC;

-- 6. Query: Transactions with NULL status
SELECT user_id, amount, txn_type
FROM transactions
WHERE status IS NULL
ORDER BY txn_date DESC;

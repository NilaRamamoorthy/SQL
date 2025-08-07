-- Step 1: Create Database
CREATE DATABASE IF NOT EXISTS BankingSystem;
USE BankingSystem;

-- Step 2: Create Normalized Tables

-- Customers
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

-- Accounts
CREATE TABLE accounts (
    account_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    account_number VARCHAR(20) NOT NULL UNIQUE,
    balance DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    fraud_flag BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Transactions
CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    from_account INT,
    to_account INT,
    amount DECIMAL(12,2) NOT NULL,
    transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (from_account) REFERENCES accounts(account_id),
    FOREIGN KEY (to_account) REFERENCES accounts(account_id)
);

-- Step 3: Insert Sample Data

INSERT INTO customers (name, email) VALUES
('Alice', 'alice@bank.com'),
('Bob', 'bob@bank.com'),
('Charlie', 'charlie@bank.com');

INSERT INTO accounts (customer_id, account_number, balance, fraud_flag) VALUES
(1, 'ACC1001', 5000.00, FALSE),
(2, 'ACC1002', 3000.00, FALSE),
(3, 'ACC1003', 10000.00, TRUE); -- flagged for fraud (hidden from view)

-- Step 4: View - Abstracted Account Summary for Tellers

CREATE OR REPLACE VIEW view_account_summary AS
SELECT
    a.account_id,
    c.name AS customer_name,
    a.account_number,
    a.balance
FROM accounts a
JOIN customers c ON a.customer_id = c.customer_id
WHERE a.fraud_flag = FALSE;

-- Step 5: Stored Procedure - Transfer Funds

DELIMITER //
CREATE PROCEDURE transfer_funds(
    IN p_from_account INT,
    IN p_to_account INT,
    IN p_amount DECIMAL(12,2)
)
BEGIN
    DECLARE from_balance DECIMAL(12,2);

    -- Check from account balance
    SELECT balance INTO from_balance FROM accounts WHERE account_id = p_from_account;

    IF from_balance < p_amount THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient balance';
    ELSE
        -- Deduct from sender
        UPDATE accounts
        SET balance = balance - p_amount
        WHERE account_id = p_from_account;

        -- Add to receiver
        UPDATE accounts
        SET balance = balance + p_amount
        WHERE account_id = p_to_account;

        -- Log transaction
        INSERT INTO transactions (from_account, to_account, amount)
        VALUES (p_from_account, p_to_account, p_amount);
    END IF;
END //
DELIMITER ;

-- Step 6: Function - Get Transaction Count for Account

DELIMITER //
CREATE FUNCTION get_transaction_count(p_account_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE txn_count INT;

    SELECT COUNT(*) INTO txn_count
    FROM transactions
    WHERE from_account = p_account_id OR to_account = p_account_id;

    RETURN txn_count;
END //
DELIMITER ;

-- Step 7: Trigger - Prevent Overdraft Before Transfer

DELIMITER //
CREATE TRIGGER before_transfer
BEFORE INSERT ON transactions
FOR EACH ROW
BEGIN
    DECLARE from_bal DECIMAL(12,2);

    IF NEW.from_account IS NOT NULL THEN
        SELECT balance INTO from_bal FROM accounts WHERE account_id = NEW.from_account;

        IF from_bal < NEW.amount THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Overdraft not allowed';
        END IF;
    END IF;
END //
DELIMITER ;

-- Step 8: Access Restriction for Tellers (Notes)
-- Example: Abstracted access using a restricted MySQL user

-- CREATE USER 'teller'@'%' IDENTIFIED BY 'securepass';
-- GRANT SELECT ON BankingSystem.view_account_summary TO 'teller'@'%';
-- REVOKE ALL ON BankingSystem.* FROM 'teller'@'%';

-- Step 9: Sample Usage

--  Check view (for frontend or teller dashboard)
SELECT * FROM view_account_summary;

-- Perform valid fund transfer (from Alice to Bob)
CALL transfer_funds(1, 2, 1000.00);

-- Check transaction count for Alice
SELECT get_transaction_count(1) AS transactions_for_alice;

-- Try overdraft (will fail)
-- CALL transfer_funds(2, 1, 10000.00); -- Error: Insufficient balance

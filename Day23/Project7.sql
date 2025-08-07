-- Step 1: Create and use database
CREATE DATABASE IF NOT EXISTS BankingDB;
USE BankingDB;

-- Step 2: Create tables

-- Customers table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE
);

-- Accounts table
CREATE TABLE accounts (
    account_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    balance DECIMAL(15,2) NOT NULL CHECK (balance >= 0),
    status ENUM('open','closed') DEFAULT 'open',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Transactions table
CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    account_id INT NOT NULL,
    transaction_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(15,2) NOT NULL,
    transaction_type ENUM('debit', 'credit') NOT NULL,
    description VARCHAR(255),
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

-- Step 3: Insert sample data

INSERT INTO customers (name, email) VALUES
('Alice Johnson', 'alice@example.com'),
('Bob Smith', 'bob@example.com');

INSERT INTO accounts (customer_id, balance, status) VALUES
(1, 1000.00, 'open'),
(2, 500.00, 'open');

INSERT INTO transactions (account_id, amount, transaction_type, description) VALUES
(1, 1000.00, 'credit', 'Initial deposit'),
(2, 500.00, 'credit', 'Initial deposit');

-- Step 4: Update balance after transactions (trigger or manual)

-- Let's add a trigger to update account balance after insert on transactions

DELIMITER //
CREATE TRIGGER trg_update_balance_after_transaction
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    IF NEW.transaction_type = 'debit' THEN
        UPDATE accounts SET balance = balance - NEW.amount WHERE account_id = NEW.account_id;
    ELSEIF NEW.transaction_type = 'credit' THEN
        UPDATE accounts SET balance = balance + NEW.amount WHERE account_id = NEW.account_id;
    END IF;
END //
DELIMITER ;

-- Step 5: Delete closed accounts

-- Example: Delete accounts with status 'closed' and no balance (0)

DELETE FROM accounts WHERE status = 'closed' AND balance = 0;

-- Step 6: Drop a foreign key to restructure (example dropping FK on transactions.account_id)

-- First find FK name:
-- SHOW CREATE TABLE transactions;

ALTER TABLE transactions DROP FOREIGN KEY transactions_ibfk_1;  -- use your actual FK name from above

-- Step 7: Transaction to transfer money with rollback if debit or credit fails

DELIMITER //
CREATE PROCEDURE transfer_funds(
    IN from_account INT,
    IN to_account INT,
    IN amount DECIMAL(15,2)
)
BEGIN
    DECLARE insufficient_funds CONDITION FOR SQLSTATE '45000';
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transfer failed, transaction rolled back';
    END;

    START TRANSACTION;

    -- Check sufficient balance
    IF (SELECT balance FROM accounts WHERE account_id = from_account) < amount THEN
        SIGNAL insufficient_funds SET MESSAGE_TEXT = 'Insufficient funds in source account';
    END IF;

    -- Debit source account
    INSERT INTO transactions (account_id, amount, transaction_type, description)
    VALUES (from_account, amount, 'debit', CONCAT('Transfer to account ', to_account));

    -- Credit destination account
    INSERT INTO transactions (account_id, amount, transaction_type, description)
    VALUES (to_account, amount, 'credit', CONCAT('Transfer from account ', from_account));

    COMMIT;
END //
DELIMITER ;

-- Step 8: Demonstrate isolation by simulating concurrent transfers
-- This must be run in separate sessions/clients simultaneously, example:

-- Session 1:
-- SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- START TRANSACTION;
-- CALL transfer_funds(1, 2, 100);
-- -- do NOT commit yet, wait for session 2

-- Session 2:
-- SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- START TRANSACTION;
-- CALL transfer_funds(1, 2, 950);
-- -- This will wait/block or fail due to isolation level and balance checks

-- Session 1:
COMMIT;

-- Session 2:
COMMIT; -- or rollback

-- Step 9: Sample usage queries

-- Check balances
SELECT account_id, balance FROM accounts;

-- Make a transfer
CALL transfer_funds(1, 2, 200);

-- Check transactions
SELECT * FROM transactions ORDER BY transaction_date DESC;

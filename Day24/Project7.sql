-- Step 1: Create Database and Use It
CREATE DATABASE BankingTransactionSystem;
USE BankingTransactionSystem;

-- Step 2: Create normalized tables (3NF)

-- Branches
CREATE TABLE branches (
    branch_id INT PRIMARY KEY AUTO_INCREMENT,
    branch_name VARCHAR(255) NOT NULL,
    branch_address VARCHAR(255)
);

-- Customers
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20)
);

-- Accounts
CREATE TABLE accounts (
    account_id INT PRIMARY KEY AUTO_INCREMENT,
    account_no VARCHAR(20) NOT NULL UNIQUE,
    customer_id INT NOT NULL,
    branch_id INT NOT NULL,
    account_type VARCHAR(50),
    opening_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);

-- Transactions
CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    account_id INT NOT NULL,
    transaction_date DATETIME NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    transaction_type ENUM('deposit', 'withdrawal', 'transfer') NOT NULL,
    description VARCHAR(255),
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);


-- Insert sample data 

-- Branches
INSERT INTO branches (branch_name, branch_address) VALUES
('Downtown Branch', '123 Main St'),
('Uptown Branch', '456 High St');

-- Customers
INSERT INTO customers (first_name, last_name, email, phone) VALUES
('John', 'Doe', 'john.doe@example.com', '555-1234'),
('Jane', 'Smith', 'jane.smith@example.com', '555-5678'),
('Bob', 'Johnson', 'bob.johnson@example.com', '555-8765');

-- Accounts
INSERT INTO accounts (account_no, customer_id, branch_id, account_type, opening_date) VALUES
('ACC123456', 1, 1, 'Checking', '2023-01-01'),
('ACC654321', 2, 2, 'Savings', '2023-02-15'),
('ACC112233', 3, 1, 'Checking', '2023-03-20');

-- Transactions
INSERT INTO transactions (account_id, transaction_date, amount, transaction_type, description) VALUES
(1, '2025-07-01 09:00:00', 1000.00, 'deposit', 'Initial deposit'),
(1, '2025-07-05 14:30:00', -200.00, 'withdrawal', 'ATM withdrawal'),
(1, '2025-07-10 10:00:00', 500.00, 'deposit', 'Paycheck'),
(1, '2025-07-15 12:00:00', -100.00, 'withdrawal', 'Groceries'),
(2, '2025-07-02 10:00:00', 1500.00, 'deposit', 'Initial deposit'),
(2, '2025-07-10 11:30:00', -300.00, 'withdrawal', 'Car repair'),
(3, '2025-07-03 08:00:00', 2000.00, 'deposit', 'Initial deposit'),
(3, '2025-07-12 15:00:00', -500.00, 'withdrawal', 'Rent payment');


-- Step 3: Create Indexes for performance
CREATE INDEX idx_account_no ON accounts(account_no);
CREATE INDEX idx_transaction_date ON transactions(transaction_date);
CREATE INDEX idx_branch_id ON accounts(branch_id);

-- Step 4: EXPLAIN query for slow account balance check (example)
EXPLAIN
SELECT account_no, SUM(amount) AS balance
FROM accounts a
JOIN transactions t ON a.account_id = t.account_id
WHERE account_no = 'ACC123456'
GROUP BY account_no;

-- Step 5: Subquery to calculate running balance for a specific account
-- Replace 'ACC123456' with the desired account number
SELECT
    t.transaction_id,
    t.transaction_date,
    t.amount,
    t.transaction_type,
    (SELECT SUM(amount)
     FROM transactions t2
     WHERE t2.account_id = t.account_id
       AND t2.transaction_date <= t.transaction_date) AS running_balance
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
WHERE a.account_no = 'ACC123456'
ORDER BY t.transaction_date ASC;

-- Step 6: Create denormalized statement view (summary of transactions per account)
CREATE VIEW account_statement_view AS
SELECT
    a.account_no,
    c.first_name,
    c.last_name,
    b.branch_name,
    t.transaction_id,
    t.transaction_date,
    t.amount,
    t.transaction_type,
    t.description
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
JOIN branches b ON a.branch_id = b.branch_id;

-- Step 7: Query to display latest 10 transactions for an account
-- Replace 'ACC123456' with desired account_no
SELECT *
FROM account_statement_view
WHERE account_no = 'ACC123456'
ORDER BY transaction_date DESC
LIMIT 10;

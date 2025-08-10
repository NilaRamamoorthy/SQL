
CREATE DATABASE IF NOT EXISTS SubscriptionDB;
USE SubscriptionDB;

-- Step 1: Create tables

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE plans (
    plan_id INT PRIMARY KEY AUTO_INCREMENT,
    plan_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    CHECK (start_date < end_date)
);

CREATE TABLE subscriptions (
    subscription_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    plan_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    renewal_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (plan_id) REFERENCES plans(plan_id) ON DELETE CASCADE,
    CHECK (start_date < end_date)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    subscription_id INT NOT NULL,
    payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10,2) NOT NULL,
    status ENUM('Pending', 'Completed', 'Failed') DEFAULT 'Pending',
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(subscription_id) ON DELETE CASCADE
);

-- Step 2: Insert sample data

INSERT INTO users (username, email) VALUES
('alice', 'alice@example.com'),
('bob', 'bob@example.com');

INSERT INTO plans (plan_name, price, start_date, end_date) VALUES
('Basic Plan', 9.99, '2025-01-01', '2026-01-01'),
('Premium Plan', 19.99, '2025-01-01', '2026-01-01');

INSERT INTO subscriptions (user_id, plan_id, start_date, end_date, renewal_date) VALUES
(1, 1, '2025-02-01', '2026-02-01', '2026-01-31'),
(2, 2, '2025-03-01', '2026-03-01', '2026-02-28');

INSERT INTO payments (subscription_id, amount, status) VALUES
(1, 9.99, 'Completed'),
(2, 19.99, 'Completed');

-- Step 3: Update renewal dates using SAVEPOINT and transaction

START TRANSACTION;

SAVEPOINT before_renewal_update;

-- Simulate renewal date update (example: extend by one year)
UPDATE subscriptions
SET renewal_date = DATE_ADD(renewal_date, INTERVAL 1 YEAR)
WHERE subscription_id = 1;

-- Check for a condition to simulate failure, e.g. invalid date or business rule violation
-- For demonstration, assume no failure; otherwise ROLLBACK TO SAVEPOINT before_renewal_update;

-- Commit transaction to ensure durability before connection loss
COMMIT;

-- Step 4: Delete expired plans (plans with end_date before today)

DELETE FROM plans WHERE end_date < CURDATE();

-- Step 5: Select final state for verification

SELECT * FROM users;
SELECT * FROM plans;
SELECT * FROM subscriptions;
SELECT * FROM payments;

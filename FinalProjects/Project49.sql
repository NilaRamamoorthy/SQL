-- 1. Create Database
CREATE DATABASE payment_subscription;
USE payment_subscription;

-- 2. Create Tables

CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

-- renewal_cycle = number of months between renewals
CREATE TABLE subscriptions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    plan_name VARCHAR(255) NOT NULL,
    start_date DATE NOT NULL,
    renewal_cycle INT NOT NULL CHECK (renewal_cycle > 0),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 3. Insert Sample Data

INSERT INTO users (name) VALUES
('Alice'),
('Bob'),
('Charlie');

INSERT INTO subscriptions (user_id, plan_name, start_date, renewal_cycle) VALUES
(1, 'Premium Plan', '2025-01-15', 1),   -- Monthly
(2, 'Standard Plan', '2024-12-01', 3),  -- Quarterly
(3, 'Basic Plan', '2024-08-10', 12);    -- Yearly

-- 4. Query: Calculate next renewal date
SELECT 
    s.id,
    u.name AS user_name,
    s.plan_name,
    s.start_date,
    s.renewal_cycle,
    DATE_ADD(s.start_date, INTERVAL CEIL(TIMESTAMPDIFF(MONTH, s.start_date, CURDATE()) / s.renewal_cycle) * s.renewal_cycle MONTH) AS next_renewal
FROM subscriptions s
JOIN users u ON s.user_id = u.id;

-- 5. Query: Expired subscriptions (next_renewal < today)
SELECT 
    u.name AS user_name,
    s.plan_name,
    s.start_date,
    s.renewal_cycle,
    DATE_ADD(s.start_date, INTERVAL CEIL(TIMESTAMPDIFF(MONTH, s.start_date, CURDATE()) / s.renewal_cycle) * s.renewal_cycle MONTH) AS next_renewal
FROM subscriptions s
JOIN users u ON s.user_id = u.id
HAVING next_renewal < CURDATE();

-- 6. Query: Subscriptions renewing in the next 7 days
SELECT 
    u.name AS user_name,
    s.plan_name,
    DATE_ADD(s.start_date, INTERVAL CEIL(TIMESTAMPDIFF(MONTH, s.start_date, CURDATE()) / s.renewal_cycle) * s.renewal_cycle MONTH) AS next_renewal
FROM subscriptions s
JOIN users u ON s.user_id = u.id
HAVING next_renewal BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY);

-- 1. Create Database and Use
CREATE DATABASE IF NOT EXISTS saas_analytics;
USE saas_analytics;

-- 2. Create Tables

CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    signup_date DATE
);

CREATE TABLE plans (
    id INT PRIMARY KEY AUTO_INCREMENT,
    plan_name VARCHAR(100),
    price DECIMAL(10,2),
    is_free_tier BOOLEAN DEFAULT FALSE
);

CREATE TABLE subscriptions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    plan_id INT,
    start_date DATE,
    renewal_date DATE,
    status ENUM('active', 'inactive', 'trial'),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (plan_id) REFERENCES plans(id)
);

CREATE TABLE payments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    subscription_id INT,
    amount DECIMAL(10,2),
    payment_date DATE,
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(id)
);

-- 3. Insert Sample Data

INSERT INTO users (name, signup_date) VALUES
('Alice', '2024-01-15'),
('Bob', '2024-06-10'),
('Charlie', '2024-08-20'),
('David', '2024-02-28'),
('Eve', '2024-07-05');

INSERT INTO plans (plan_name, price, is_free_tier) VALUES
('Basic', 0.00, TRUE),
('Pro', 29.99, FALSE),
('Enterprise', 99.99, FALSE);

INSERT INTO subscriptions (user_id, plan_id, start_date, renewal_date, status) VALUES
(1, 2, '2024-01-15', '2025-01-15', 'active'),
(2, 3, '2024-06-10', '2025-06-10', 'trial'),
(3, 1, '2024-08-20', '2024-09-20', 'inactive'),
(4, 2, '2024-02-28', '2025-02-28', 'active'),
(5, 1, '2024-07-05', '2024-08-05', 'trial');

INSERT INTO payments (subscription_id, amount, payment_date) VALUES
(1, 29.99, '2024-01-15'),
(2, 99.99, '2024-06-10'),
(4, 29.99, '2024-02-28');

-- 4a. Subquery in FROM to calculate plan-wise average revenue

SELECT 
    p.plan_name,
    AVG(plan_revenue) AS avg_revenue_per_plan
FROM (
    SELECT 
        s.plan_id,
        SUM(payments.amount) AS plan_revenue
    FROM subscriptions s
    LEFT JOIN payments ON s.id = payments.subscription_id
    GROUP BY s.id, s.plan_id
) AS plan_totals
JOIN plans p ON plan_totals.plan_id = p.id
GROUP BY p.plan_name;

-- 4b. CASE to show user activity status

SELECT 
    u.id,
    u.name,
    s.status,
    CASE 
        WHEN s.status = 'active' THEN 'Active'
        WHEN s.status = 'trial' THEN 'Trial'
        ELSE 'Inactive'
    END AS user_activity
FROM users u
LEFT JOIN subscriptions s ON u.id = s.user_id;

-- 4c. UNION to merge paid and free-tier users

SELECT u.id, u.name, 'Paid User' AS user_type
FROM users u
JOIN subscriptions s ON u.id = s.user_id
JOIN plans p ON s.plan_id = p.id
WHERE p.is_free_tier = FALSE

UNION

SELECT u.id, u.name, 'Free-tier User' AS user_type
FROM users u
JOIN subscriptions s ON u.id = s.user_id
JOIN plans p ON s.plan_id = p.id
WHERE p.is_free_tier = TRUE;

-- 4d. JOIN + GROUP BY for monthly revenue trends

SELECT 
    YEAR(p.payment_date) AS year,
    MONTH(p.payment_date) AS month,
    SUM(p.amount) AS total_revenue
FROM payments p
GROUP BY year, month
ORDER BY year, month;

-- 4e. Correlated subquery to find longest-subscribed users

SELECT 
    u.id,
    u.name,
    s.start_date,
    s.renewal_date,
    DATEDIFF(s.renewal_date, s.start_date) AS subscription_duration_days
FROM users u
JOIN subscriptions s ON u.id = s.user_id
WHERE DATEDIFF(s.renewal_date, s.start_date) = (
    SELECT MAX(DATEDIFF(s2.renewal_date, s2.start_date))
    FROM subscriptions s2
    WHERE s2.user_id = u.id
);

-- 4f. Date filtering for renewal reminders (next 7 days)

SELECT 
    u.id,
    u.name,
    s.renewal_date,
    DATEDIFF(s.renewal_date, CURDATE()) AS days_until_renewal
FROM users u
JOIN subscriptions s ON u.id = s.user_id
WHERE s.renewal_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)
ORDER BY s.renewal_date;

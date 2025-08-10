-- 1. Create Database and Use
CREATE DATABASE IF NOT EXISTS loan_tracker;
USE loan_tracker;

-- 2. Create Tables

CREATE TABLE customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255)
);

CREATE TABLE loan_types (
    id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(100)
);

CREATE TABLE loans (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    loan_type_id INT,
    principal DECIMAL(15,2),
    interest_rate DECIMAL(5,2),
    start_date DATE,
    due_date DATE,
    status VARCHAR(20), -- e.g., 'active', 'closed'
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (loan_type_id) REFERENCES loan_types(id)
);

CREATE TABLE payments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    loan_id INT,
    payment_date DATE,
    amount DECIMAL(15,2),
    FOREIGN KEY (loan_id) REFERENCES loans(id)
);

-- 3. Insert Sample Data

INSERT INTO customers (name) VALUES
('Alice'),
('Bob'),
('Charlie');

INSERT INTO loan_types (type_name) VALUES
('Home Loan'),
('Car Loan'),
('Personal Loan');

INSERT INTO loans (customer_id, loan_type_id, principal, interest_rate, start_date, due_date, status) VALUES
(1, 1, 500000, 6.5, '2024-01-01', '2026-01-01', 'active'),
(2, 2, 200000, 7.0, '2023-06-15', '2025-06-15', 'closed'),
(3, 3, 100000, 10.0, '2024-03-01', '2025-03-01', 'active'),
(1, 2, 150000, 7.5, '2023-07-01', '2024-07-01', 'closed');

INSERT INTO payments (loan_id, payment_date, amount) VALUES
(1, '2024-02-01', 20000),
(1, '2024-03-01', 25000),
(1, '2024-04-01', 30000),
(2, '2023-07-01', 50000),
(2, '2023-08-01', 70000),
(2, '2023-09-01', 80000),
(3, '2024-04-15', 30000),
(3, '2024-05-15', 20000),
(4, '2023-08-15', 75000),
(4, '2023-09-15', 75000);

-- 4a. Subquery in SELECT to calculate outstanding loan balance (principal - total payments)
SELECT
    l.id AS loan_id,
    c.name AS customer_name,
    lt.type_name,
    l.principal,
    IFNULL((
        SELECT SUM(p.amount) FROM payments p WHERE p.loan_id = l.id
    ), 0) AS total_paid,
    (l.principal - IFNULL((
        SELECT SUM(p.amount) FROM payments p WHERE p.loan_id = l.id
    ), 0)) AS outstanding_balance
FROM loans l
JOIN customers c ON l.customer_id = c.id
JOIN loan_types lt ON l.loan_type_id = lt.id;

-- 4b. JOIN + GROUP BY to calculate total repayments per loan type
SELECT
    lt.type_name,
    SUM(p.amount) AS total_repayments
FROM loan_types lt
LEFT JOIN loans l ON lt.id = l.loan_type_id
LEFT JOIN payments p ON l.id = p.loan_id
GROUP BY lt.id, lt.type_name;

-- 4c. CASE to categorize loans as "Closed", "On Track", "Delayed"
-- Assume "Delayed" if current date > due_date and outstanding_balance > 0

SELECT
    l.id AS loan_id,
    c.name AS customer_name,
    lt.type_name,
    l.due_date,
    (l.principal - IFNULL((
        SELECT SUM(p.amount) FROM payments p WHERE p.loan_id = l.id
    ), 0)) AS outstanding_balance,
    CASE
        WHEN l.status = 'closed' THEN 'Closed'
        WHEN CURDATE() > l.due_date AND (l.principal - IFNULL((
            SELECT SUM(p.amount) FROM payments p WHERE p.loan_id = l.id
        ), 0)) > 0 THEN 'Delayed'
        ELSE 'On Track'
    END AS loan_status
FROM loans l
JOIN customers c ON l.customer_id = c.id
JOIN loan_types lt ON l.loan_type_id = lt.id;

-- 4d. UNION ALL to combine active and closed loans (already in table with status, but explicit UNION ALL)

SELECT
    'Active' AS loan_category,
    l.id,
    c.name,
    lt.type_name,
    l.principal,
    l.status
FROM loans l
JOIN customers c ON l.customer_id = c.id
JOIN loan_types lt ON l.loan_type_id = lt.id
WHERE l.status = 'active'

UNION ALL

SELECT
    'Closed' AS loan_category,
    l.id,
    c.name,
    lt.type_name,
    l.principal,
    l.status
FROM loans l
JOIN customers c ON l.customer_id = c.id
JOIN loan_types lt ON l.loan_type_id = lt.id
WHERE l.status = 'closed';

-- 4e. Correlated subquery to find customers whose payments are above their own loan average

SELECT DISTINCT
    c.id AS customer_id,
    c.name AS customer_name
FROM customers c
JOIN loans l ON c.id = l.customer_id
JOIN payments p ON l.id = p.loan_id
WHERE p.amount > (
    SELECT AVG(p2.amount)
    FROM loans l2
    JOIN payments p2 ON l2.id = p2.loan_id
    WHERE l2.customer_id = c.id
);

-- 4f. Use DATEDIFF to calculate delay in payments (difference between payment_date and due_date)

SELECT
    p.id AS payment_id,
    c.name AS customer_name,
    l.id AS loan_id,
    l.due_date,
    p.payment_date,
    DATEDIFF(p.payment_date, l.due_date) AS days_delayed
FROM payments p
JOIN loans l ON p.loan_id = l.id
JOIN customers c ON l.customer_id = c.id
ORDER BY days_delayed DESC;

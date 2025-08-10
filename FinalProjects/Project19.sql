-- 1. Create Database
CREATE DATABASE loan_tracker;
USE loan_tracker;

-- 2. Create Tables

-- Loans Table
CREATE TABLE loans (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    principal DECIMAL(15,2) NOT NULL,
    interest_rate DECIMAL(5,2) NOT NULL, -- annual interest %
    start_date DATE NOT NULL,
    tenure_months INT NOT NULL
);

-- Payments Table
CREATE TABLE payments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    loan_id INT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    paid_on DATE NOT NULL,
    FOREIGN KEY (loan_id) REFERENCES loans(id)
);

-- 3. Insert Sample Data

-- Loans
INSERT INTO loans (user_id, principal, interest_rate, start_date, tenure_months) VALUES
(1, 100000, 12.00, '2025-01-01', 12),
(2, 50000, 10.00, '2025-03-15', 10),
(3, 75000, 11.50, '2025-02-10', 15);

-- Payments
INSERT INTO payments (loan_id, amount, paid_on) VALUES
(1, 9000, '2025-02-01'),
(1, 9000, '2025-03-01'),
(1, 9000, '2025-04-01'),
(2, 5500, '2025-04-01'),
(2, 5500, '2025-05-01'),
(3, 7000, '2025-03-01');

-- 4. Query: Total Paid vs Total Due (with interest calculation)
SELECT 
    l.id AS loan_id,
    l.user_id,
    l.principal,
    l.interest_rate,
    l.tenure_months,
    ROUND(l.principal * (1 + (l.interest_rate/100) * (l.tenure_months/12)), 2) AS total_due,
    IFNULL(SUM(p.amount), 0) AS total_paid,
    ROUND(ROUND(l.principal * (1 + (l.interest_rate/100) * (l.tenure_months/12)), 2) - IFNULL(SUM(p.amount), 0), 2) AS balance_remaining
FROM loans l
LEFT JOIN payments p ON l.id = p.loan_id
GROUP BY l.id, l.user_id, l.principal, l.interest_rate, l.tenure_months;

-- 5. Query: EMI Due Dates and Overdue Status
WITH due_dates AS (
    SELECT 
        l.id AS loan_id,
        l.start_date,
        l.tenure_months,
        ADDDATE(l.start_date, INTERVAL n MONTH) AS due_date
    FROM loans l
    JOIN (
        SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
        UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
        UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11
    ) nums
    ON nums.n < l.tenure_months
)
SELECT 
    d.loan_id,
    d.due_date,
    CASE 
        WHEN d.due_date < CURDATE() THEN 'OVERDUE'
        ELSE 'UPCOMING'
    END AS status
FROM due_dates d
ORDER BY d.loan_id, d.due_date;

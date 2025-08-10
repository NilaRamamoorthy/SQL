-- 1. Create Database
CREATE DATABASE IF NOT EXISTS bank_analytics;
USE bank_analytics;

-- 2. OLTP Tables

CREATE TABLE branches (
    branch_id INT PRIMARY KEY,
    branch_name VARCHAR(100),
    city VARCHAR(50)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    branch_id INT,
    city VARCHAR(50),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);

CREATE TABLE loans (
    loan_id INT PRIMARY KEY,
    customer_id INT,
    loan_type VARCHAR(50),
    principal_amount DECIMAL(15,2),
    loan_status VARCHAR(20), -- e.g., 'Active', 'Closed', 'Defaulted'
    start_date DATE,
    end_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    loan_id INT,
    payment_date DATE,
    amount DECIMAL(15,2),
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
);

-- 3. Warehouse Snowflake Schema Tables

CREATE TABLE dim_branch (
    branch_id INT PRIMARY KEY,
    branch_name VARCHAR(100),
    city VARCHAR(50)
);

CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    branch_id INT,
    city VARCHAR(50)
);

CREATE TABLE dim_loan_type (
    loan_type VARCHAR(50) PRIMARY KEY,
    description VARCHAR(255)
);

CREATE TABLE fact_loan_repayment (
    fact_id INT PRIMARY KEY AUTO_INCREMENT,
    loan_id INT,
    customer_id INT,
    branch_id INT,
    loan_type VARCHAR(50),
    principal_amount DECIMAL(15,2),
    loan_status VARCHAR(20),
    start_date DATE,
    end_date DATE,
    payment_date DATE,
    payment_amount DECIMAL(15,2),
    cumulative_paid DECIMAL(15,2),
    remaining_balance DECIMAL(15,2),
    is_default BOOLEAN
);

-- 4. Sample Data Insertion

INSERT INTO branches VALUES
(1, 'Downtown Branch', 'New York'),
(2, 'Uptown Branch', 'Chicago'),
(3, 'Central Branch', 'Los Angeles');

INSERT INTO customers VALUES
(101, 'John Doe', 1, 'New York'),
(102, 'Jane Smith', 2, 'Chicago'),
(103, 'Mike Brown', 3, 'Los Angeles');

INSERT INTO loans VALUES
(1001, 101, 'Home Loan', 500000, 'Active', '2023-01-15', '2043-01-15'),
(1002, 102, 'Car Loan', 30000, 'Defaulted', '2022-05-10', '2027-05-10'),
(1003, 103, 'Personal Loan', 15000, 'Closed', '2020-07-01', '2023-07-01');

INSERT INTO payments VALUES
(1, 1001, '2023-02-15', 2000),
(2, 1001, '2023-03-15', 2000),
(3, 1002, '2022-06-10', 3000),
(4, 1002, '2022-07-10', 3000),
(5, 1003, '2020-08-01', 5000),
(6, 1003, '2020-09-01', 5000),
(7, 1003, '2020-10-01', 5000);

-- 5. ETL: Load dim tables

INSERT INTO dim_branch SELECT * FROM branches;
INSERT INTO dim_customer SELECT * FROM customers;

INSERT INTO dim_loan_type VALUES
('Home Loan', 'Loan for buying a house'),
('Car Loan', 'Loan for purchasing a car'),
('Personal Loan', 'Unsecured personal loan');

-- 6. ETL: Load fact_loan_repayment with cumulative payments and default flag

INSERT INTO fact_loan_repayment
(loan_id, customer_id, branch_id, loan_type, principal_amount, loan_status, start_date, end_date,
 payment_date, payment_amount, cumulative_paid, remaining_balance, is_default)
SELECT
    l.loan_id,
    l.customer_id,
    c.branch_id,
    l.loan_type,
    l.principal_amount,
    l.loan_status,
    l.start_date,
    l.end_date,
    p.payment_date,
    p.amount,
    (
      SELECT SUM(amount)
      FROM payments p2
      WHERE p2.loan_id = l.loan_id
        AND p2.payment_date <= p.payment_date
    ) AS cumulative_paid,
    l.principal_amount - (
      SELECT SUM(amount)
      FROM payments p3
      WHERE p3.loan_id = l.loan_id
        AND p3.payment_date <= p.payment_date
    ) AS remaining_balance,
    CASE WHEN l.loan_status = 'Defaulted' THEN TRUE ELSE FALSE END AS is_default
FROM loans l
JOIN payments p ON l.loan_id = p.loan_id
JOIN customers c ON l.customer_id = c.customer_id
ORDER BY l.loan_id, p.payment_date;

-- 7. OLAP Queries

-- a) Default rate by branch

SELECT
    b.branch_name,
    b.city,
    COUNT(DISTINCT f.loan_id) AS total_loans,
    SUM(CASE WHEN f.is_default THEN 1 ELSE 0 END) AS defaulted_loans,
    ROUND(SUM(CASE WHEN f.is_default THEN 1 ELSE 0 END) * 100.0 / COUNT(DISTINCT f.loan_id), 2) AS default_rate_percent
FROM fact_loan_repayment f
JOIN dim_branch b ON f.branch_id = b.branch_id
GROUP BY b.branch_name, b.city
ORDER BY default_rate_percent DESC;

-- b) Loan product performance: total principal and number of loans, average repayment

SELECT
    lt.loan_type,
    COUNT(DISTINCT f.loan_id) AS num_loans,
    SUM(f.principal_amount) AS total_principal,
    ROUND(AVG(f.cumulative_paid), 2) AS avg_repayment
FROM fact_loan_repayment f
JOIN dim_loan_type lt ON f.loan_type = lt.loan_type
GROUP BY lt.loan_type
ORDER BY total_principal DESC;

-- c) Loans with remaining balance over 0 (active or defaulted loans)

SELECT
    f.loan_id,
    c.customer_name,
    b.branch_name,
    f.loan_type,
    f.principal_amount,
    f.remaining_balance,
    f.loan_status
FROM fact_loan_repayment f
JOIN dim_customer c ON f.customer_id = c.customer_id
JOIN dim_branch b ON f.branch_id = b.branch_id
WHERE f.remaining_balance > 0
GROUP BY f.loan_id, c.customer_name, b.branch_name, f.loan_type, f.principal_amount, f.remaining_balance, f.loan_status
ORDER BY f.remaining_balance DESC;

-- d) Repayment history of a specific loan (example loan_id = 1001)

SELECT
    payment_date,
    payment_amount,
    cumulative_paid,
    remaining_balance
FROM fact_loan_repayment
WHERE loan_id = 1001
ORDER BY payment_date;


-- Create database
CREATE DATABASE IF NOT EXISTS loan_db;
USE loan_db;

-- Create tables

CREATE TABLE borrowers (
    borrower_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    contact VARCHAR(50)
);

CREATE TABLE loan_types (
    loan_type_id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL,
    interest_rate DECIMAL(5,2) NOT NULL -- e.g., 7.50 for 7.5%
);

CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    borrower_id INT NOT NULL,
    loan_type_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    disbursement_date DATE NOT NULL,
    due_date DATE NOT NULL,
    FOREIGN KEY (borrower_id) REFERENCES borrowers(borrower_id),
    FOREIGN KEY (loan_type_id) REFERENCES loan_types(loan_type_id)
);

CREATE TABLE repayments (
    repayment_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL,
    repayment_date DATE NOT NULL,
    amount_paid DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
);

-- Insert sample data

INSERT INTO borrowers (full_name, contact) VALUES
('John Doe', '123-456-7890'),
('Jane Smith', '987-654-3210'),
('Alice Brown', '555-123-4567');

INSERT INTO loan_types (type_name, interest_rate) VALUES
('Home Loan', 6.50),
('Car Loan', 7.25),
('Personal Loan', 10.00);

INSERT INTO loans (borrower_id, loan_type_id, amount, disbursement_date, due_date) VALUES
(1, 1, 50000, '2024-01-15', '2029-01-15'),
(2, 2, 15000, '2023-06-10', '2026-06-10'),
(3, 3, 8000, '2024-03-05', '2025-03-05');

INSERT INTO repayments (loan_id, repayment_date, amount_paid) VALUES
(1, '2024-02-15', 1000),
(1, '2024-03-15', 1000),
(2, '2023-07-10', 500),
(3, '2024-04-05', 800),
(3, '2024-05-05', 800);

-- Query 1: Total amount repaid per borrower

SELECT b.borrower_id, b.full_name,
       COALESCE(SUM(r.amount_paid), 0) AS total_repaid
FROM borrowers b
LEFT JOIN loans l ON b.borrower_id = l.borrower_id
LEFT JOIN repayments r ON l.loan_id = r.loan_id
GROUP BY b.borrower_id, b.full_name
ORDER BY total_repaid DESC;

-- Query 2: Upcoming repayment schedule (next repayments due within next 30 days)

SELECT b.full_name, l.loan_id, l.due_date,
       COALESCE(SUM(r.amount_paid), 0) AS total_repaid,
       l.amount AS loan_amount,
       (l.amount - COALESCE(SUM(r.amount_paid), 0)) AS balance_due
FROM loans l
JOIN borrowers b ON l.borrower_id = b.borrower_id
LEFT JOIN repayments r ON l.loan_id = r.loan_id
WHERE l.due_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY)
GROUP BY l.loan_id, b.full_name, l.due_date, l.amount
ORDER BY l.due_date;


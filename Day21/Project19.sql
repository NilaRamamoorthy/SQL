-- 1. Create Database
CREATE DATABASE loan_analysis;
USE loan_analysis;

-- 2. Create Tables

CREATE TABLE officers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE clients (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL
);

CREATE TABLE loans (
    id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT NOT NULL,
    officer_id INT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    issued_date DATE NOT NULL,
    FOREIGN KEY (client_id) REFERENCES clients(id),
    FOREIGN KEY (officer_id) REFERENCES officers(id)
);

CREATE TABLE repayments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    loan_id INT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    paid_on DATE NOT NULL,
    FOREIGN KEY (loan_id) REFERENCES loans(id)
);

-- 3. Insert Sample Data

INSERT INTO officers (name) VALUES
('Officer A'),
('Officer B'),
('Officer C');

INSERT INTO clients (name, city) VALUES
('Client 1', 'Mumbai'),
('Client 2', 'Delhi'),
('Client 3', 'Mumbai'),
('Client 4', 'Chennai'),
('Client 5', 'Delhi');

INSERT INTO loans (client_id, officer_id, amount, issued_date) VALUES
(1, 1, 500000, '2025-01-10'),
(2, 2, 300000, '2025-02-15'),
(3, 1, 150000, '2025-03-20'),
(4, 3, 250000, '2025-04-25'),
(5, 2, 400000, '2025-05-30'),
(1, 1, 200000, '2025-06-10'),
(3, 2, 350000, '2025-07-15');

INSERT INTO repayments (loan_id, amount, paid_on) VALUES
(1, 120000, '2025-02-10'),
(1, 150000, '2025-03-10'),
(2, 50000, '2025-03-15'),
(3, 110000, '2025-04-20'),
(4, 70000, '2025-05-25'),
(5, 90000, '2025-06-30'),
(6, 100000, '2025-07-10'),
(7, 120000, '2025-08-15');

-- 4. Queries

-- a) Total loans issued per officer
SELECT 
    o.id AS officer_id,
    o.name AS officer_name,
    COUNT(l.id) AS total_loans_issued
FROM officers o
LEFT JOIN loans l ON o.id = l.officer_id
GROUP BY o.id, o.name;

-- b) Clients with total repayment > ₹1,00,000
SELECT 
    c.id AS client_id,
    c.name AS client_name,
    SUM(r.amount) AS total_repaid
FROM clients c
JOIN loans l ON c.id = l.client_id
JOIN repayments r ON l.id = r.loan_id
GROUP BY c.id, c.name
HAVING total_repaid > 100000;

-- c) Officers approving more than 10 loans
SELECT
    o.id AS officer_id,
    o.name AS officer_name,
    COUNT(l.id) AS loans_approved
FROM officers o
JOIN loans l ON o.id = l.officer_id
GROUP BY o.id, o.name
HAVING loans_approved > 10;

-- d) INNER JOIN: clients ↔ loans ↔ officers (all loans with client and officer info)
SELECT
    l.id AS loan_id,
    c.name AS client_name,
    o.name AS officer_name,
    l.amount,
    l.issued_date
FROM loans l
JOIN clients c ON l.client_id = c.id
JOIN officers o ON l.officer_id = o.id
ORDER BY l.issued_date;

-- e) FULL OUTER JOIN loans ↔ repayments (MySQL workaround using UNION of LEFT and RIGHT JOIN)
SELECT
    l.id AS loan_id,
    l.amount AS loan_amount,
    r.amount AS repayment_amount,
    r.paid_on
FROM loans l
LEFT JOIN repayments r ON l.id = r.loan_id

UNION

SELECT
    l.id AS loan_id,
    l.amount AS loan_amount,
    r.amount AS repayment_amount,
    r.paid_on
FROM loans l
RIGHT JOIN repayments r ON l.id = r.loan_id
WHERE l.id IS NULL
ORDER BY loan_id, paid_on;

-- f) SELF JOIN clients from same city (excluding self)
SELECT 
    c1.id AS client1_id,
    c1.name AS client1_name,
    c2.id AS client2_id,
    c2.name AS client2_name,
    c1.city
FROM clients c1
JOIN clients c2 ON c1.city = c2.city AND c1.id < c2.id
ORDER BY c1.city, c1.id, c2.id;

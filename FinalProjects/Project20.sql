-- 1. Create Database
CREATE DATABASE salary_management;
USE salary_management;

-- 2. Create Tables

-- Employees Table
CREATE TABLE employees (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Salaries Table
CREATE TABLE salaries (
    emp_id INT NOT NULL,
    month DATE NOT NULL, -- store as first day of month for consistency
    base DECIMAL(10,2) NOT NULL,
    bonus DECIMAL(10,2) DEFAULT 0,
    FOREIGN KEY (emp_id) REFERENCES employees(id)
);

-- Deductions Table
CREATE TABLE deductions (
    emp_id INT NOT NULL,
    month DATE NOT NULL,
    reason VARCHAR(100),
    amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (emp_id) REFERENCES employees(id)
);

-- 3. Insert Sample Data

-- Employees
INSERT INTO employees (name) VALUES
('Alice Johnson'),
('Bob Smith'),
('Charlie Davis');

-- Salaries
INSERT INTO salaries (emp_id, month, base, bonus) VALUES
(1, '2025-01-01', 5000, 200),
(1, '2025-02-01', 5000, 500),
(2, '2025-01-01', 4500, 0),
(2, '2025-02-01', 4500, 300),
(3, '2025-01-01', 6000, 0);

-- Deductions
INSERT INTO deductions (emp_id, month, reason, amount) VALUES
(1, '2025-01-01', 'Late arrival', 100),
(1, '2025-02-01', 'Leave without pay', 300),
(2, '2025-01-01', 'Late arrival', 50),
(3, '2025-01-01', 'Loan repayment', 500);

-- 4. Query: Monthly Salary After Deductions
SELECT 
    e.id AS employee_id,
    e.name,
    s.month,
    s.base,
    s.bonus,
    IFNULL(SUM(d.amount), 0) AS total_deductions,
    (s.base + s.bonus - IFNULL(SUM(d.amount), 0)) AS net_salary
FROM employees e
JOIN salaries s ON e.id = s.emp_id
LEFT JOIN deductions d ON s.emp_id = d.emp_id AND s.month = d.month
GROUP BY e.id, e.name, s.month, s.base, s.bonus
ORDER BY s.month, e.name;

-- 5. Query: Conditional Bonus Logic (Example: bonus of 10% if base > 5000)
SELECT 
    e.id AS employee_id,
    e.name,
    s.month,
    s.base,
    CASE 
        WHEN s.base > 5000 THEN s.base * 0.10
        ELSE s.bonus
    END AS final_bonus,
    (s.base + 
        CASE WHEN s.base > 5000 THEN s.base * 0.10 ELSE s.bonus END 
        - IFNULL(SUM(d.amount), 0)
    ) AS net_salary_with_bonus_rule
FROM employees e
JOIN salaries s ON e.id = s.emp_id
LEFT JOIN deductions d ON s.emp_id = d.emp_id AND s.month = d.month
GROUP BY e.id, e.name, s.month, s.base, s.bonus
ORDER BY s.month, e.name;

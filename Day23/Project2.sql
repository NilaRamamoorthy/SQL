-- Step 1: Create and Use Database
CREATE DATABASE IF NOT EXISTS EmployeePayroll;
USE EmployeePayroll;

-- Step 2: Create Tables

-- Departments Table
CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL
);

-- Employees Table
CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    department_id INT NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Salaries Table
CREATE TABLE salaries (
    salary_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    pay_date DATE NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    CHECK (amount > 10000)
);

-- Step 3: Insert Sample Data

INSERT INTO departments (department_name) VALUES
('HR'), ('Engineering'), ('Finance');

INSERT INTO employees (name, email, department_id) VALUES
('Alice Smith', 'alice@example.com', 1),
('Bob Johnson', 'bob@example.com', 2),
('Carol White', 'carol@example.com', 3);

INSERT INTO salaries (employee_id, amount, pay_date) VALUES
(1, 20000, '2025-08-01'),
(2, 35000, '2025-08-01'),
(3, 30000, '2025-08-01');

-- Step 4: UPDATE Salary for Promotion
UPDATE salaries
SET amount = amount + 5000
WHERE employee_id = 2;

-- Step 5: DELETE Employee Who Resigned (Example: Alice)
DELETE FROM employees
WHERE employee_id = 1;

-- Step 6: Modify Constraint – email VARCHAR(100) instead of 150
-- First, drop UNIQUE index and modify column
ALTER TABLE employees DROP INDEX email;
ALTER TABLE employees MODIFY email VARCHAR(100);

-- Optionally, re-add UNIQUE constraint
ALTER TABLE employees ADD UNIQUE (email);

-- Step 7: Use Transaction for Bulk Bonus Insertion

START TRANSACTION;

SAVEPOINT before_bonus;

-- Attempting multiple bonus insertions
INSERT INTO salaries (employee_id, amount, pay_date) VALUES (2, 5000, '2025-08-10');

-- Simulate a failure (uncomment to test rollback):
INSERT INTO salaries (employee_id, amount, pay_date) VALUES (999, 7000, '2025-08-10');

-- If all okay:
COMMIT;

-- If error occurs:
ROLLBACK TO before_bonus;

-- Step 8: SELECT to Verify

-- View all employees
SELECT * FROM employees;

-- View all salaries
SELECT * FROM salaries;

-- View all departments
SELECT * FROM departments;

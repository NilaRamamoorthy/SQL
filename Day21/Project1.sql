-- 1. Create Database
CREATE DATABASE employee_management;
USE employee_management;

-- 2. Create Tables

CREATE TABLE departments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE employees (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    department_id INT,
    manager_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(id),
    FOREIGN KEY (manager_id) REFERENCES employees(id)
);

-- 3. Insert Sample Data

INSERT INTO departments (name) VALUES
('HR'),
('IT'),
('Sales'),
('Marketing');

INSERT INTO employees (name, salary, department_id, manager_id) VALUES
('Alice', 70000, 1, NULL),
('Bob', 85000, 2, NULL),
('Charlie', 60000, 2, 2),
('David', 55000, 2, 2),
('Eve', 50000, 3, NULL),
('Frank', 45000, 3, 5),
('Grace', 40000, 3, 5),
('Hank', 35000, 4, NULL),
('Ivy', 32000, NULL, NULL);  -- Employee without department

-- 4. Queries

-- a) Average salary per department
SELECT 
    d.name AS department,
    ROUND(AVG(e.salary), 2) AS avg_salary
FROM departments d
JOIN employees e ON d.id = e.department_id
GROUP BY d.name;

-- b) Count employees per department
SELECT 
    d.name AS department,
    COUNT(e.id) AS employee_count
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
GROUP BY d.name;

-- c) Departments with more than 5 employees
SELECT 
    d.name AS department,
    COUNT(e.id) AS employee_count
FROM departments d
JOIN employees e ON d.id = e.department_id
GROUP BY d.name
HAVING employee_count > 5;

-- d) INNER JOIN to show employees with their department names
SELECT 
    e.name AS employee_name,
    d.name AS department_name
FROM employees e
JOIN departments d ON e.department_id = d.id;

-- e) LEFT JOIN to find departments without employees
SELECT 
    d.name AS department_name,
    COUNT(e.id) AS employee_count
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
GROUP BY d.name
HAVING employee_count = 0;

-- f) SELF JOIN to show each employee with their manager's name (aliases e1, e2)
SELECT 
    e1.name AS employee_name,
    e2.name AS manager_name
FROM employees e1
LEFT JOIN employees e2 ON e1.manager_id = e2.id;

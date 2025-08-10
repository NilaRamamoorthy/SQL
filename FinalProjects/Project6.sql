-- 1. Create Database
CREATE DATABASE employee_timesheet;
USE employee_timesheet;

-- 2. Create Tables

-- Employees table
CREATE TABLE employees (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    dept VARCHAR(50) NOT NULL
);

-- Projects table
CREATE TABLE projects (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Timesheets table
CREATE TABLE timesheets (
    id INT PRIMARY KEY AUTO_INCREMENT,
    emp_id INT,
    project_id INT,
    hours DECIMAL(5,2) CHECK (hours >= 0),
    date DATE NOT NULL,
    FOREIGN KEY (emp_id) REFERENCES employees(id),
    FOREIGN KEY (project_id) REFERENCES projects(id)
);

-- 3. Insert Sample Data

-- Employees
INSERT INTO employees (name, dept) VALUES
('Alice', 'IT'),
('Bob', 'Marketing'),
('Charlie', 'Finance'),
('Diana', 'IT');

-- Projects
INSERT INTO projects (name) VALUES
('Website Redesign'),
('Social Media Campaign'),
('Budget Planning'),
('App Development');

-- Timesheets
INSERT INTO timesheets (emp_id, project_id, hours, date) VALUES
(1, 1, 5.0, '2025-08-05'),
(1, 4, 3.0, '2025-08-06'),
(2, 2, 6.0, '2025-08-05'),
(3, 3, 4.5, '2025-08-07'),
(4, 4, 7.0, '2025-08-06'),
(1, 1, 4.0, '2025-08-08'),
(2, 2, 5.5, '2025-08-09'),
(4, 4, 6.5, '2025-08-09');

-- 4. JOIN: Fetch Timesheet per Project
SELECT 
    t.id AS timesheet_id,
    e.name AS employee_name,
    p.name AS project_name,
    t.hours,
    t.date
FROM timesheets t
JOIN employees e ON t.emp_id = e.id
JOIN projects p ON t.project_id = p.id
ORDER BY t.date;

-- 5. GROUP BY: Total Hours per Employee/Project
SELECT 
    e.name AS employee_name,
    p.name AS project_name,
    SUM(t.hours) AS total_hours
FROM timesheets t
JOIN employees e ON t.emp_id = e.id
JOIN projects p ON t.project_id = p.id
GROUP BY e.name, p.name
ORDER BY e.name;

-- 6. Weekly Hours (Last 7 Days)
SELECT 
    e.name AS employee_name,
    SUM(t.hours) AS weekly_hours
FROM timesheets t
JOIN employees e ON t.emp_id = e.id
WHERE t.date >= CURDATE() - INTERVAL 7 DAY
GROUP BY e.name;

-- 7. Monthly Hours (Current Month)
SELECT 
    e.name AS employee_name,
    SUM(t.hours) AS monthly_hours
FROM timesheets t
JOIN employees e ON t.emp_id = e.id
WHERE MONTH(t.date) = MONTH(CURDATE())
  AND YEAR(t.date) = YEAR(CURDATE())
GROUP BY e.name;

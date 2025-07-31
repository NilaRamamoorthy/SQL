-- Create and use database
DROP DATABASE IF EXISTS company_hr;
CREATE DATABASE company_hr;
USE company_hr;

-- Create departments table
CREATE TABLE departments (
    dept_id INT AUTO_INCREMENT PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL UNIQUE
);

--  Create employees table
CREATE TABLE employees (
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_name VARCHAR(100) NOT NULL,
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

--  Create attendance table
CREATE TABLE attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT,
    att_date DATE,
    in_time TIME,
    out_time TIME,
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);

-- Insert departments
INSERT INTO departments (dept_name) VALUES
('HR'), ('IT'), ('Sales'), ('Marketing'), ('Finance');

--  Insert employees
INSERT INTO employees (emp_name, dept_id) VALUES
('Alice', 1), ('Bob', 2), ('Charlie', 3), ('Diana', 2), ('Eve', 4),
('Frank', 3), ('Grace', 1), ('Henry', 5), ('Ivy', 4), ('Jack', 5),
('Liam', 1), ('Mia', 2), ('Noah', 3), ('Olivia', 4), ('Paul', 5);

--  Insert attendance records (sample 30 records)
INSERT INTO attendance (emp_id, att_date, in_time, out_time) VALUES
(1, '2025-07-27', '09:00:00', '17:00:00'),
(2, '2025-07-27', '09:15:00', '17:10:00'),
(3, '2025-07-27', '09:05:00', '16:50:00'),
(4, '2025-07-27', '09:30:00', '17:30:00'),
(5, '2025-07-27', '09:00:00', '17:00:00'),
(6, '2025-07-28', '09:10:00', '17:20:00'),
(7, '2025-07-28', '08:55:00', '16:45:00'),
(8, '2025-07-28', '09:25:00', '17:10:00'),
(9, '2025-07-28', '09:00:00', '17:05:00'),
(10, '2025-07-28', '09:15:00', '17:00:00'),
(11, '2025-07-29', '09:05:00', '17:15:00'),
(12, '2025-07-29', '09:20:00', '17:25:00'),
(13, '2025-07-29', '09:00:00', '16:55:00'),
(14, '2025-07-29', '09:10:00', '17:00:00'),
(15, '2025-07-29', '09:30:00', '17:30:00'),
(1, '2025-07-28', '09:00:00', '17:00:00'),
(2, '2025-07-28', '09:10:00', '17:00:00'),
(3, '2025-07-28', '09:00:00', '17:00:00'),
(4, '2025-07-28', '09:05:00', '17:15:00'),
(5, '2025-07-28', '09:00:00', '17:10:00'),
(6, '2025-07-29', '09:15:00', '17:10:00'),
(7, '2025-07-29', '09:00:00', '17:05:00'),
(8, '2025-07-29', '09:10:00', '17:00:00'),
(9, '2025-07-29', '09:20:00', '17:25:00'),
(10, '2025-07-29', '09:30:00', '17:30:00'),
(11, '2025-07-30', '09:00:00', '17:00:00'),
(12, '2025-07-30', '09:00:00', '17:00:00'),
(13, '2025-07-30', '09:00:00', '17:00:00'),
(14, '2025-07-30', '09:00:00', '17:00:00'),
(15, '2025-07-30', '09:00:00', '17:00:00');

--  Calculate working hours per employee
SELECT 
  emp_id,
  att_date,
  TIMESTAMPDIFF(HOUR, in_time, out_time) AS hours_worked
FROM attendance;

--  Count present days per employee
SELECT 
  emp_id,
  COUNT(attendance_id) AS present_days
FROM attendance
GROUP BY emp_id;

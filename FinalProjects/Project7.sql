-- 1. Create Database
CREATE DATABASE leave_management;
USE leave_management;

-- 2. Create Tables

-- Employees table
CREATE TABLE employees (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Leave types table
CREATE TABLE leave_types (
    id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(50) NOT NULL
);

-- Leave requests table
CREATE TABLE leave_requests (
    id INT PRIMARY KEY AUTO_INCREMENT,
    emp_id INT,
    leave_type_id INT,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    status ENUM('Pending', 'Approved', 'Rejected') DEFAULT 'Pending',
    FOREIGN KEY (emp_id) REFERENCES employees(id),
    FOREIGN KEY (leave_type_id) REFERENCES leave_types(id),
    CHECK (from_date <= to_date)
);

-- 3. Insert Sample Data

-- Employees
INSERT INTO employees (name) VALUES
('Alice'),
('Bob'),
('Charlie'),
('Diana');

-- Leave Types
INSERT INTO leave_types (type_name) VALUES
('Sick Leave'),
('Casual Leave'),
('Earned Leave');

-- Leave Requests
INSERT INTO leave_requests (emp_id, leave_type_id, from_date, to_date, status) VALUES
(1, 1, '2025-08-05', '2025-08-07', 'Approved'),
(2, 2, '2025-08-08', '2025-08-09', 'Pending'),
(3, 3, '2025-08-10', '2025-08-12', 'Approved'),
(1, 2, '2025-08-15', '2025-08-16', 'Pending'),
(4, 1, '2025-08-18', '2025-08-18', 'Rejected');

-- 4. Query: Aggregate Leaves by Employee
SELECT 
    e.name AS employee_name,
    lt.type_name AS leave_type,
    COUNT(lr.id) AS total_leaves
FROM leave_requests lr
JOIN employees e ON lr.emp_id = e.id
JOIN leave_types lt ON lr.leave_type_id = lt.id
WHERE lr.status = 'Approved'
GROUP BY e.name, lt.type_name
ORDER BY e.name;

-- 5. Query: Detect Overlapping Leave Requests for an Employee
SELECT 
    a.id AS request_id_1,
    b.id AS request_id_2,
    a.emp_id,
    e.name AS employee_name,
    a.from_date, a.to_date,
    b.from_date, b.to_date
FROM leave_requests a
JOIN leave_requests b 
    ON a.emp_id = b.emp_id 
    AND a.id < b.id
    AND a.from_date <= b.to_date
    AND b.from_date <= a.to_date
JOIN employees e ON a.emp_id = e.id
ORDER BY a.emp_id;

-- 6. Query: Pending Approvals
SELECT 
    lr.id AS request_id,
    e.name AS employee_name,
    lt.type_name AS leave_type,
    lr.from_date,
    lr.to_date,
    lr.status
FROM leave_requests lr
JOIN employees e ON lr.emp_id = e.id
JOIN leave_types lt ON lr.leave_type_id = lt.id
WHERE lr.status = 'Pending';

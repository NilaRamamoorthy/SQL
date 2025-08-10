-- 1. Create Database
CREATE DATABASE complaint_management;
USE complaint_management;

-- 2. Create Tables

-- Departments handling complaints
CREATE TABLE departments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

-- Complaints submitted by the public
CREATE TABLE complaints (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    department_id INT NOT NULL,
    status ENUM('Open', 'In Progress', 'Resolved', 'Closed') NOT NULL DEFAULT 'Open',
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE CASCADE
);

-- Responses from staff to complaints
CREATE TABLE responses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    complaint_id INT NOT NULL,
    responder_id INT NOT NULL,
    message TEXT NOT NULL,
    FOREIGN KEY (complaint_id) REFERENCES complaints(id) ON DELETE CASCADE
);

-- 3. Insert Sample Data

INSERT INTO departments (name) VALUES
('Sanitation'),
('Water Supply'),
('Road Maintenance');

INSERT INTO complaints (title, department_id, status) VALUES
('Garbage not collected in Zone 5', 1, 'Open'),
('Water leakage in Sector 3', 2, 'In Progress'),
('Potholes near main market', 3, 'Resolved'),
('Overflowing drain in Sector 7', 1, 'Open');

INSERT INTO responses (complaint_id, responder_id, message) VALUES
(1, 101, 'Scheduled garbage truck for tomorrow morning'),
(2, 102, 'Leakage identified, repair in progress'),
(3, 103, 'Potholes filled, monitoring road condition');

-- 4. Query: Status summary (count per status)
SELECT status, COUNT(*) AS total
FROM complaints
GROUP BY status;

-- 5. Query: Department workload (count of open complaints per department)
SELECT d.id, d.name, COUNT(c.id) AS open_complaints
FROM departments d
LEFT JOIN complaints c ON d.id = c.department_id AND c.status != 'Closed'
GROUP BY d.id, d.name;

-- 6. Query: All responses for a given complaint
SELECT r.id, r.message
FROM responses r
JOIN complaints c ON r.complaint_id = c.id
WHERE c.id = 2;

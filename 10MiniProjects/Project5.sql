-- 1. Create Database and Use
CREATE DATABASE IF NOT EXISTS employee_performance;
USE employee_performance;

-- 2. Create Tables

CREATE TABLE departments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    dept_name VARCHAR(100) NOT NULL
);

CREATE TABLE employees (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    dept_id INT,
    manager_id INT,
    FOREIGN KEY (dept_id) REFERENCES departments(id),
    FOREIGN KEY (manager_id) REFERENCES employees(id)
);

CREATE TABLE reviews (
    id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT,
    review_date DATE,
    score DECIMAL(5,2),
    comments TEXT,
    completed_at DATETIME,
    FOREIGN KEY (employee_id) REFERENCES employees(id)
);

-- 3. Insert Sample Data

INSERT INTO departments (dept_name) VALUES
('Sales'),
('Engineering'),
('HR');

INSERT INTO employees (name, dept_id, manager_id) VALUES
('Alice', 1, NULL),
('Bob', 1, 1),
('Charlie', 2, NULL),
('David', 2, 3),
('Eva', 3, NULL);

INSERT INTO reviews (employee_id, review_date, score, comments, completed_at) VALUES
(1, '2025-01-10', 92.5, 'Excellent leadership', '2025-01-11 10:00:00'),
(2, '2025-01-15', 78.0, 'Good progress', '2025-01-16 12:00:00'),
(2, '2025-06-15', 82.0, 'Improved performance', '2025-06-16 09:00:00'),
(3, '2025-02-20', 88.0, 'Strong technical skills', NULL), -- not completed
(4, '2025-03-01', 70.0, 'Average performance', '2025-03-02 14:00:00'),
(5, '2025-01-25', 95.0, 'Outstanding HR initiatives', '2025-01-26 11:00:00');

-- 4. Query: SELF JOIN employees with their managers

SELECT
    e.id AS employee_id,
    e.name AS employee_name,
    m.name AS manager_name,
    d.dept_name
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id
LEFT JOIN departments d ON e.dept_id = d.id
ORDER BY e.id;

-- 5. Aggregate average review score per department

SELECT
    d.dept_name,
    AVG(r.score) AS avg_score
FROM reviews r
JOIN employees e ON r.employee_id = e.id
JOIN departments d ON e.dept_id = d.id
WHERE r.completed_at IS NOT NULL
GROUP BY d.dept_name;

-- 6. Use CASE to convert scores to ratings

SELECT
    e.name,
    d.dept_name,
    r.score,
    CASE
        WHEN r.score >= 90 THEN 'Excellent'
        WHEN r.score >= 75 THEN 'Good'
        WHEN r.score >= 60 THEN 'Average'
        ELSE 'Poor'
    END AS rating
FROM reviews r
JOIN employees e ON r.employee_id = e.id
JOIN departments d ON e.dept_id = d.id
WHERE r.completed_at IS NOT NULL
ORDER BY r.score DESC, d.dept_name;

-- 7. Subquery in SELECT to get latest review date per employee

SELECT
    e.name,
    d.dept_name,
    r.score,
    r.review_date,
    (SELECT MAX(r2.review_date) 
     FROM reviews r2 
     WHERE r2.employee_id = e.id AND r2.completed_at IS NOT NULL
    ) AS latest_review_date
FROM employees e
LEFT JOIN reviews r ON e.id = r.employee_id AND r.completed_at IS NOT NULL
JOIN departments d ON e.dept_id = d.id
ORDER BY r.score DESC, d.dept_name;

-- 8. Optional: Use ROW_NUMBER() to order reviews per employee (MySQL 8+)

WITH RankedReviews AS (
    SELECT
        r.id,
        r.employee_id,
        r.review_date,
        r.score,
        r.comments,
        ROW_NUMBER() OVER (PARTITION BY r.employee_id ORDER BY r.review_date DESC) AS rn
    FROM reviews r
    WHERE r.completed_at IS NOT NULL
)
SELECT
    rr.id,
    e.name,
    rr.review_date,
    rr.score,
    rr.comments,
    rr.rn
FROM RankedReviews rr
JOIN employees e ON rr.employee_id = e.id
WHERE rr.rn = 1 -- latest review per employee
ORDER BY rr.score DESC;


-- 1. Create Database and Use
CREATE DATABASE IF NOT EXISTS employee_promotion_tracker;
USE employee_promotion_tracker;

-- 2. Create Tables

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    name VARCHAR(100),
    manager_id INT NULL,
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

CREATE TABLE promotions (
    promotion_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT,
    promotion_date DATE,
    old_role VARCHAR(100),
    new_role VARCHAR(100),
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- 3. Insert Sample Data

INSERT INTO employees (employee_id, name, manager_id) VALUES
(1, 'Alice CEO', NULL),
(2, 'Bob Manager', 1),
(3, 'Carol Lead', 2),
(4, 'David Engineer', 3),
(5, 'Eva Engineer', 3);

INSERT INTO promotions (employee_id, promotion_date, old_role, new_role, old_salary, new_salary) VALUES
(2, '2022-01-01', 'Junior Manager', 'Manager', 60000, 80000),
(2, '2023-01-01', 'Manager', 'Senior Manager', 80000, 95000),
(3, '2021-06-01', 'Junior Lead', 'Lead', 50000, 70000),
(3, '2023-04-01', 'Lead', 'Senior Lead', 70000, 85000),
(4, '2022-05-15', 'Junior Engineer', 'Engineer', 40000, 60000),
(5, '2023-02-20', 'Junior Engineer', 'Engineer', 40000, 60000),
(5, '2024-01-15', 'Engineer', 'Senior Engineer', 60000, 75000);

-- 4. Queries

-- a) List promotions chronologically with ROW_NUMBER per employee
WITH PromotionChronology AS (
    SELECT 
        employee_id,
        promotion_date,
        old_role,
        new_role,
        old_salary,
        new_salary,
        ROW_NUMBER() OVER (PARTITION BY employee_id ORDER BY promotion_date) AS promotion_number
    FROM promotions
)
SELECT * FROM PromotionChronology
ORDER BY employee_id, promotion_number;

-- b) Compare previous and current roles/salaries using LEAD() to see next promotion's roles and salaries

WITH PromotionWithNext AS (
    SELECT
        employee_id,
        promotion_date,
        old_role,
        new_role,
        old_salary,
        new_salary,
        LEAD(old_role) OVER (PARTITION BY employee_id ORDER BY promotion_date) AS next_old_role,
        LEAD(new_role) OVER (PARTITION BY employee_id ORDER BY promotion_date) AS next_new_role,
        LEAD(old_salary) OVER (PARTITION BY employee_id ORDER BY promotion_date) AS next_old_salary,
        LEAD(new_salary) OVER (PARTITION BY employee_id ORDER BY promotion_date) AS next_new_salary
    FROM promotions
)
SELECT * FROM PromotionWithNext
ORDER BY employee_id, promotion_date;

-- c) Report showing time (days) between promotions

WITH PromotionDates AS (
    SELECT
        employee_id,
        promotion_date,
        LEAD(promotion_date) OVER (PARTITION BY employee_id ORDER BY promotion_date) AS next_promotion_date
    FROM promotions
)
SELECT
    employee_id,
    promotion_date,
    next_promotion_date,
    DATEDIFF(next_promotion_date, promotion_date) AS days_between_promotions
FROM PromotionDates
WHERE next_promotion_date IS NOT NULL
ORDER BY employee_id, promotion_date;

-- d) Recursive hierarchy: manager → employee chain

WITH RECURSIVE EmployeeHierarchy AS (
    SELECT 
        employee_id,
        name,
        manager_id,
        CAST(name AS CHAR(1000)) AS hierarchy_path,
        1 AS level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT 
        e.employee_id,
        e.name,
        e.manager_id,
        CONCAT(h.hierarchy_path, ' -> ', e.name),
        h.level + 1
    FROM employees e
    JOIN EmployeeHierarchy h ON e.manager_id = h.employee_id
)
SELECT * FROM EmployeeHierarchy
ORDER BY level, hierarchy_path;

-- e) RANK() to identify fastest-promoted employees (based on shortest avg days between promotions)

WITH PromotionIntervals AS (
    SELECT
        employee_id,
        promotion_date,
        LEAD(promotion_date) OVER (PARTITION BY employee_id ORDER BY promotion_date) AS next_promotion_date
    FROM promotions
),
PromotionDurations AS (
    SELECT
        employee_id,
        DATEDIFF(next_promotion_date, promotion_date) AS days_between_promotions
    FROM PromotionIntervals
    WHERE next_promotion_date IS NOT NULL
),
AvgPromotionTime AS (
    SELECT
        employee_id,
        AVG(days_between_promotions) AS avg_days_between_promotions
    FROM PromotionDurations
    GROUP BY employee_id
)
SELECT
    employee_id,
    avg_days_between_promotions,
    RANK() OVER (ORDER BY avg_days_between_promotions ASC) AS promotion_speed_rank
FROM AvgPromotionTime
ORDER BY promotion_speed_rank;


-- 1. Create database and use it
CREATE DATABASE IF NOT EXISTS organization_hierarchy;
USE organization_hierarchy;

-- 2. Create employee table with manager info and leadership history

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100),
    manager_id INT NULL,         -- employee's direct manager
    role VARCHAR(50),
    start_date DATE,
    end_date DATE NULL,
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

-- 3. Insert sample employee data (including some leadership changes)

INSERT INTO employees (employee_id, employee_name, manager_id, role, start_date, end_date) VALUES
(1, 'Alice', NULL, 'Director', '2019-01-01', NULL),
(2, 'Bob', 1, 'Manager', '2019-03-01', NULL),
(3, 'Charlie', 2, 'Team Lead', '2019-05-01', NULL),
(4, 'David', 3, 'Developer', '2020-01-01', NULL),
(5, 'Eve', 2, 'Team Lead', '2019-06-01', '2023-03-31'),  -- Eve left or role changed
(6, 'Frank', 2, 'Team Lead', '2023-04-01', NULL),        -- Frank replaced Eve
(7, 'Grace', 1, 'Manager', '2020-02-01', NULL),
(8, 'Hannah', 7, 'Team Lead', '2020-03-01', NULL),
(9, 'Ian', 8, 'Developer', '2021-07-01', NULL);

-- 4. Recursive CTE to generate full org chart (employee → manager → director)

WITH RECURSIVE org_chart AS (
    -- Base: Select top-level directors (no manager)
    SELECT
        employee_id,
        employee_name,
        manager_id,
        role,
        start_date,
        end_date,
        CAST(employee_name AS CHAR(1000)) AS path,
        0 AS level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive: join employees to their managers
    SELECT
        e.employee_id,
        e.employee_name,
        e.manager_id,
        e.role,
        e.start_date,
        e.end_date,
        CONCAT(oc.path, ' -> ', e.employee_name) AS path,
        oc.level + 1
    FROM employees e
    INNER JOIN org_chart oc ON e.manager_id = oc.employee_id
)

SELECT * FROM org_chart
ORDER BY path;

-- 5. Use ROW_NUMBER() to order direct reports under each manager by start_date

SELECT
    employee_id,
    employee_name,
    manager_id,
    role,
    start_date,
    ROW_NUMBER() OVER (PARTITION BY manager_id ORDER BY start_date) AS report_order
FROM employees
ORDER BY manager_id, report_order;

-- 6. Rank managers by number of direct subordinates

SELECT
    manager_id,
    e.employee_name AS manager_name,
    COUNT(emp.employee_id) AS subordinate_count,
    RANK() OVER (ORDER BY COUNT(emp.employee_id) DESC) AS manager_rank
FROM employees emp
JOIN employees e ON emp.manager_id = e.employee_id
GROUP BY manager_id, e.employee_name
ORDER BY subordinate_count DESC;

-- 7. Compare leadership changes using LAG() and LEAD() over start_date for each role

SELECT
    employee_id,
    employee_name,
    role,
    start_date,
    end_date,
    LAG(employee_name) OVER (PARTITION BY role ORDER BY start_date) AS previous_holder,
    LEAD(employee_name) OVER (PARTITION BY role ORDER BY start_date) AS next_holder
FROM employees
ORDER BY role, start_date;

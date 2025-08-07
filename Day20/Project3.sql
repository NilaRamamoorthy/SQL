-- 1. Create the database and use it
CREATE DATABASE employee_dir;
USE employee_dir;

-- 2. Create employees table
CREATE TABLE IF NOT EXISTS employees (
  emp_id       INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name         VARCHAR(100) NOT NULL,
  department   VARCHAR(50) NOT NULL,
  salary       DECIMAL(10,2) NOT NULL CHECK (salary BETWEEN 20000 AND 100000),
  email        VARCHAR(100),
  hire_date    DATE NOT NULL,
  manager_id   INT,
  FOREIGN KEY (manager_id) REFERENCES employees(emp_id)
);

-- 3. Insert 20 sample records
INSERT INTO employees (name, department, salary, email, hire_date, manager_id) VALUES
('Alice Johnson',     'HR',         45000.00, 'alice.j@company.com', '2015-03-10', NULL),
('Bob Smith',         'IT',         60000.00, 'bob.smith@company.com','2018-07-01', 1),
('Carol Taylor',      'Finance',    55000.00, NULL,                   '2016-11-20', 1),
('David Brown',       'IT',         72000.00, 'david.b@company.com', '2019-05-15', 2),
('Eva Green',         'HR',         50000.00, 'eva.green@company.com','2017-01-30', 1),
('Frank White',       'Sales',      62000.00, NULL,                   '2020-08-12', 4),
('Grace Black',       'Sales',      48000.00, 'grace.b@company.com',  '2018-12-05', 4),
('Henry Scott',       'Finance',    80000.00, 'henry.s@company.com',  '2014-09-22', NULL),
('Irene Adams',       'IT',         68000.00, NULL,                   '2021-04-03', 2),
('Jack Clark',        'Marketing',  53000.00, 'jack.c@company.com',   '2019-11-11', NULL),
('Karen Lewis',       'Marketing',  47000.00, 'karen.l@company.com',  '2020-02-28', 10),
('Larry Walker',      'Finance',    95000.00, 'larry.w@company.com',  '2013-06-14', 8),
('Monica Hall',       'HR',         38000.00, NULL,                   '2019-10-01', 1),
('Nathan Young',      'Sales',      72000.00, 'nathan.y@company.com', '2017-05-07', 4),
('Olivia King',       'IT',         61000.00, 'olivia.k@company.com', '2022-01-19', 2),
('Peter Wright',      'Marketing',  39000.00, NULL,                   '2018-03-27', 10),
('Quinn Mitchell',    'IT',         54000.00, 'quinn.m@company.com',  '2020-07-23', 2),
('Rachel Cooper',     'Finance',    88000.00, 'rachel.c@company.com', '2014-12-09', 8),
('Steve Hughes',      'Sales',      62000.00, NULL,                   '2021-09-15', 4),
('Tina Brooks',       'HR',         41000.00, 'tina.b@company.com',   '2023-02-01', 1);

-- Select employees with salary > 50,000 in Sales or Marketing.
SELECT name, department, salary FROM employees WHERE department IN('Sales','Marketing') AND salary>50000;

--  Show only name, salary, and department.
SELECT name,salary,department FROM employees;

--  List all unique departments.
SELECT DISTINCT department FROM employees;

--  Use LIKE to find employees with names ending in 'an'.
SELECT name,department FROM employees WHERE name LIKE '%an';

--  Identify employees with no manager (manager_id IS NULL).
SELECT name,department,manager_id FROM employees WHERE manager_id IS NULL;

--  Use BETWEEN for salaries between 40,000 and 80,000.
SELECT name, salary,department FROM employees WHERE salary BETWEEN 40000 AND 80000;

--  Sort by department ASC, salary DESC.
SELECT name, salary,department FROM employees ORDER BY department;
SELECT name, salary,department FROM employees ORDER BY salary DESC;

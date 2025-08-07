-- Create database and switch to it
CREATE DATABASE IF NOT EXISTS gym_members_db;
USE gym_members_db;

-- Create the members table
CREATE TABLE members (
  member_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  age INT,
  plan_type VARCHAR(50),
  start_date DATE,
  status VARCHAR(20)
);

-- Insert sample data
INSERT INTO members (name, age, plan_type, start_date, status) VALUES
('Sarah Connor',     28, 'Premium', '2025-07-01', 'Active'),
('Sam Smith',        35, 'Basic',   '2025-06-15', 'Active'),
('Steve Rogers',     42, 'Premium', '2025-05-20', 'Inactive'),
('Samantha Brown',   22, 'Standard','2025-07-10', NULL),
('Michael Jordan',   30, 'Premium', '2025-08-01', 'Active'),
('Susan Williams',   40, 'Basic',   '2025-07-05', 'Active');

-- 1. Retrieve active members aged between 20 and 40 (show name, age, plan_type)
SELECT name, age, plan_type
FROM members
WHERE status = 'Active'
  AND age BETWEEN 20 AND 40
ORDER BY age ASC, name ASC;

-- 2. List all distinct plan types
SELECT DISTINCT plan_type
FROM members
ORDER BY plan_type ASC;

-- 3. Use LIKE to find member names starting with 'S'
SELECT name, age, plan_type
FROM members
WHERE name LIKE 'S%'
ORDER BY age ASC, name ASC;

-- 4. Identify members with NULL status
SELECT name, age, plan_type
FROM members
WHERE status IS NULL
ORDER BY age ASC, name ASC;

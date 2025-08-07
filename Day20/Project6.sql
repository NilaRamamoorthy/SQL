-- Create database
CREATE DATABASE IF NOT EXISTS courses_db;
USE courses_db;

-- Create courses table
CREATE TABLE courses (
  course_id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  category VARCHAR(50),
  duration INT,          -- duration in hours
  price DECIMAL(10,2),
  instructor VARCHAR(100),
  status VARCHAR(20)
);

-- Insert sample data
INSERT INTO courses (title, category, duration, price, instructor, status) VALUES
('Data Structures in C', 'Tech', 20, 900.00, 'Alice Smith', 'Active'),
('Data Analysis with Python', 'Tech', 25, 1200.00, 'Bob Johnson', 'Active'),
('Business Fundamentals', 'Business', 15, 800.00, 'Carol Lee', 'Active'),
('Data Science Bootcamp', 'Tech', 30, 999.00, 'David Kim', 'Inactive'),
('Marketing 101', 'Business', 10, 500.00, NULL, 'Active'),
('Data Visualization', 'Tech', 18, 750.00, 'Eve Martinez', 'Active');

-- ➤ Queries based on requirements:

-- 1. Get active courses priced under ₹1000 (showing title, category, price)
SELECT title, category, price
FROM courses
WHERE status = 'Active'
  AND price < 1000
ORDER BY price DESC, duration ASC;

-- 2. List all distinct instructors
SELECT DISTINCT instructor
FROM courses
ORDER BY instructor;

-- 3. Find courses starting with "Data"
SELECT title, category, price
FROM courses
WHERE title LIKE 'Data%'
ORDER BY price DESC, duration ASC;

-- 4. Filter courses in category 'Tech' or 'Business'
SELECT title, category, price
FROM courses
WHERE category IN ('Tech', 'Business')
ORDER BY price DESC, duration ASC;

-- 5. Identify courses with NULL instructor
SELECT title, category, price
FROM courses
WHERE instructor IS NULL
ORDER BY price DESC, duration ASC;

-- 1. Create Database
CREATE DATABASE course_enrollment_system;
USE course_enrollment_system;

-- 2. Create Tables

-- Courses table
CREATE TABLE courses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(150) NOT NULL,
    instructor VARCHAR(100) NOT NULL
);

-- Students table
CREATE TABLE students (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL
);

-- Enrollments table (Many-to-Many relationship)
CREATE TABLE enrollments (
    course_id INT,
    student_id INT,
    enroll_date DATE NOT NULL,
    PRIMARY KEY (course_id, student_id),
    FOREIGN KEY (course_id) REFERENCES courses(id),
    FOREIGN KEY (student_id) REFERENCES students(id)
);

-- 3. Insert Sample Data

-- Courses
INSERT INTO courses (title, instructor) VALUES
('Database Systems', 'Dr. Smith'),
('Web Development', 'Prof. Johnson'),
('Data Science Fundamentals', 'Dr. Lee');

-- Students
INSERT INTO students (name, email) VALUES
('Alice Brown', 'alice@example.com'),
('Bob Carter', 'bob@example.com'),
('Charlie Davis', 'charlie@example.com'),
('Diana Evans', 'diana@example.com');

-- Enrollments
INSERT INTO enrollments (course_id, student_id, enroll_date) VALUES
(1, 1, '2025-08-01'),
(1, 2, '2025-08-02'),
(2, 1, '2025-08-03'),
(2, 3, '2025-08-04'),
(3, 2, '2025-08-05'),
(3, 4, '2025-08-06');

-- 4. Query: Get all students per course
SELECT 
    c.title AS course_title,
    s.name AS student_name,
    s.email,
    e.enroll_date
FROM enrollments e
JOIN courses c ON e.course_id = c.id
JOIN students s ON e.student_id = s.id
ORDER BY c.title, s.name;

-- 5. Query: Count of students per course
SELECT 
    c.title AS course_title,
    COUNT(e.student_id) AS total_students
FROM courses c
LEFT JOIN enrollments e ON c.id = e.course_id
GROUP BY c.title
ORDER BY total_students DESC;

-- 6. Query: Get courses a specific student is enrolled in (Example: Alice)
SELECT 
    s.name AS student_name,
    c.title AS course_title,
    c.instructor,
    e.enroll_date
FROM enrollments e
JOIN students s ON e.student_id = s.id
JOIN courses c ON e.course_id = c.id
WHERE s.name = 'Alice Brown'
ORDER BY e.enroll_date;

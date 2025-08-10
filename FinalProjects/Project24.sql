-- 1. Create Database
CREATE DATABASE attendance_tracker;
USE attendance_tracker;

-- 2. Create Tables

-- Students Table
CREATE TABLE students (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Courses Table
CREATE TABLE courses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Attendance Table
CREATE TABLE attendance (
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    date DATE NOT NULL,
    status ENUM('Present', 'Absent', 'Late') NOT NULL,
    PRIMARY KEY (student_id, course_id, date),
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

-- 3. Insert Sample Data

-- Students
INSERT INTO students (name) VALUES
('Alice'),
('Bob'),
('Charlie');

-- Courses
INSERT INTO courses (name) VALUES
('Mathematics'),
('Physics');

-- Attendance Records
INSERT INTO attendance (student_id, course_id, date, status) VALUES
(1, 1, '2025-08-01', 'Present'),
(2, 1, '2025-08-01', 'Absent'),
(3, 1, '2025-08-01', 'Late'),
(1, 2, '2025-08-01', 'Present'),
(2, 2, '2025-08-01', 'Present'),
(3, 2, '2025-08-01', 'Absent'),
(1, 1, '2025-08-02', 'Absent'),
(2, 1, '2025-08-02', 'Present'),
(3, 1, '2025-08-02', 'Present');

-- 4. Query: Get attendance summary per student per course
SELECT 
    s.name AS student_name,
    c.name AS course_name,
    SUM(status = 'Present') AS total_present,
    SUM(status = 'Absent') AS total_absent,
    SUM(status = 'Late') AS total_late
FROM attendance a
JOIN students s ON a.student_id = s.id
JOIN courses c ON a.course_id = c.id
GROUP BY s.name, c.name;

-- 5. Query: Get attendance for a specific date
SELECT 
    s.name AS student_name,
    c.name AS course_name,
    a.status
FROM attendance a
JOIN students s ON a.student_id = s.id
JOIN courses c ON a.course_id = c.id
WHERE a.date = '2025-08-01';

-- 6. Query: Get attendance percentage per student
SELECT 
    s.name AS student_name,
    CONCAT(ROUND(SUM(status = 'Present') / COUNT(*) * 100, 2), '%') AS attendance_percentage
FROM attendance a
JOIN students s ON a.student_id = s.id
GROUP BY s.name;

-- 1. Create Database and Use
CREATE DATABASE IF NOT EXISTS university_dashboard;
USE university_dashboard;

-- 2. Create Tables

CREATE TABLE departments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE students (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(id)
);

CREATE TABLE courses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(50) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(id)
);

CREATE TABLE enrollments (
    student_id INT,
    course_id INT,
    grade INT, -- numerical grade 0-100
    status VARCHAR(20), -- 'enrolled', 'dropped', 'completed'
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES students(id),
    FOREIGN KEY (course_id) REFERENCES courses(id)
);

-- 3. Insert Sample Data

INSERT INTO departments (name) VALUES
('Computer Science'),
('Mathematics'),
('Physics');

INSERT INTO students (name, department_id) VALUES
('Alice', 1),
('Bob', 1),
('Charlie', 2),
('Diana', 3),
('Ethan', 1),
('Fiona', 2);

INSERT INTO courses (code, title, department_id) VALUES
('CS101', 'Intro to Python', 1),
('CS102', 'Database Systems', 1),
('CS103', 'SQL Fundamentals', 1),
('MATH201', 'Calculus I', 2),
('PHY101', 'Physics Basics', 3);

INSERT INTO enrollments (student_id, course_id, grade, status) VALUES
(1, 1, 85, 'completed'),
(1, 3, 78, 'completed'),
(2, 1, 40, 'completed'),
(3, 4, 90, 'completed'),
(4, 5, 65, 'dropped'),
(5, 1, NULL, 'enrolled'),
(6, 4, 55, 'completed'),
(2, 3, 82, 'completed'),
(5, 3, 60, 'completed');

-- 4. Query: Enrollment count per course (GROUP BY)

SELECT
    c.code,
    c.title,
    COUNT(e.student_id) AS enrollment_count
FROM courses c
LEFT JOIN enrollments e ON c.id = e.course_id AND e.status = 'enrolled'
GROUP BY c.id, c.code, c.title;

-- 5. Query: Subquery in FROM to find courses with highest dropout rate

SELECT course_id, dropout_count
FROM (
    SELECT
        course_id,
        COUNT(*) AS dropout_count
    FROM enrollments
    WHERE status = 'dropped'
    GROUP BY course_id
) AS dropout_counts
ORDER BY dropout_count DESC
LIMIT 3;

-- 6. Query: LEFT JOIN to find students not enrolled in any course

SELECT s.id, s.name
FROM students s
LEFT JOIN enrollments e ON s.id = e.student_id
WHERE e.student_id IS NULL;

-- 7. Query: Use CASE for pass/fail grade mapping (passing grade >= 50)

SELECT
    s.name,
    c.title,
    e.grade,
    CASE
        WHEN e.grade >= 50 THEN 'Pass'
        WHEN e.grade IS NULL THEN 'No Grade'
        ELSE 'Fail'
    END AS result
FROM enrollments e
JOIN students s ON e.student_id = s.id
JOIN courses c ON e.course_id = c.id;

-- 8. Query: Use IN to filter courses by a list of course codes

SELECT *
FROM courses
WHERE code IN ('CS101', 'CS103', 'MATH201');

-- 9. Query: Use INTERSECT to find students who completed both Python and SQL courses

-- Note: INTERSECT is not supported in MySQL, but available in PostgreSQL or SQL Server.
-- If using MySQL, simulate with INNER JOIN or EXISTS

-- Assuming PostgreSQL or SQL Server:

SELECT student_id
FROM enrollments e
JOIN courses c ON e.course_id = c.id
WHERE c.code = 'CS101' AND e.status = 'completed'

INTERSECT

SELECT student_id
FROM enrollments e
JOIN courses c ON e.course_id = c.id
WHERE c.code = 'CS103' AND e.status = 'completed';

-- If MySQL, simulate:

SELECT DISTINCT e1.student_id
FROM enrollments e1
JOIN courses c1 ON e1.course_id = c1.id
JOIN enrollments e2 ON e1.student_id = e2.student_id
JOIN courses c2 ON e2.course_id = c2.id
WHERE c1.code = 'CS101' AND e1.status = 'completed'
  AND c2.code = 'CS103' AND e2.status = 'completed';

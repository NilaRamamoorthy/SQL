-- 1. Create Database and Use
CREATE DATABASE IF NOT EXISTS online_course_platform;
USE online_course_platform;

-- 2. Create Tables

CREATE TABLE students (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE courses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(255) NOT NULL
);

CREATE TABLE enrollments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    course_id INT,
    FOREIGN KEY (student_id) REFERENCES students(id),
    FOREIGN KEY (course_id) REFERENCES courses(id)
);

CREATE TABLE grades (
    enrollment_id INT PRIMARY KEY,
    score DECIMAL(5,2),
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(id)
);

-- 3. Insert Sample Data

INSERT INTO students (name) VALUES
('Alice'),
('Bob'),
('Charlie'),
('David'),
('Eva');

INSERT INTO courses (course_name) VALUES
('Mathematics'),
('Physics'),
('Chemistry');

INSERT INTO enrollments (student_id, course_id) VALUES
(1, 1),
(2, 1),
(3, 1),
(4, 2),
(5, 2),
(1, 3),
(2, 3);

INSERT INTO grades (enrollment_id, score) VALUES
(1, 85),
(2, 78),
(3, 92),
(4, 65),
(5, 73),
(6, 88),
(7, 79);

-- 4. Query: Get list of students filtered by course name (e.g., 'Mathematics')

SELECT s.id, s.name
FROM students s
INNER JOIN enrollments e ON s.id = e.student_id
INNER JOIN courses c ON e.course_id = c.id
WHERE c.course_name = 'Mathematics';

-- 5. INNER JOIN to show enrolled students with their scores

SELECT
    s.name AS student_name,
    c.course_name,
    g.score
FROM students s
INNER JOIN enrollments e ON s.id = e.student_id
INNER JOIN courses c ON e.course_id = c.id
INNER JOIN grades g ON e.id = g.enrollment_id;

-- 6. CASE to assign grade categories based on score

SELECT
    s.name AS student_name,
    c.course_name,
    g.score,
    CASE
        WHEN g.score >= 85 THEN 'A'
        WHEN g.score >= 70 THEN 'B'
        ELSE 'C'
    END AS grade_category
FROM students s
INNER JOIN enrollments e ON s.id = e.student_id
INNER JOIN courses c ON e.course_id = c.id
INNER JOIN grades g ON e.id = g.enrollment_id;

-- 7. AVG() to get average marks per course

SELECT
    c.course_name,
    AVG(g.score) AS average_score
FROM courses c
INNER JOIN enrollments e ON c.id = e.course_id
INNER JOIN grades g ON e.id = g.enrollment_id
GROUP BY c.course_name;

-- 8. GROUP BY + HAVING to show only courses with more than 50 students

-- Note: For example purposes, using HAVING COUNT(*) > 0 (since sample data < 50)

SELECT
    c.course_name,
    COUNT(DISTINCT e.student_id) AS student_count
FROM courses c
INNER JOIN enrollments e ON c.id = e.course_id
GROUP BY c.course_name
HAVING COUNT(DISTINCT e.student_id) > 50;

-- 9. Use IN to get students enrolled in specific courses (e.g., Mathematics or Physics)

SELECT DISTINCT s.id, s.name
FROM students s
INNER JOIN enrollments e ON s.id = e.student_id
WHERE e.course_id IN (
    SELECT id FROM courses WHERE course_name IN ('Mathematics', 'Physics')
);

-- 10. Correlated subquery to get top student (highest score) in each course

SELECT
    c.course_name,
    s.name AS top_student,
    g.score AS top_score
FROM courses c
JOIN enrollments e ON c.id = e.course_id
JOIN grades g ON e.id = g.enrollment_id
JOIN students s ON e.student_id = s.id
WHERE g.score = (
    SELECT MAX(g2.score)
    FROM enrollments e2
    JOIN grades g2 ON e2.id = g2.enrollment_id
    WHERE e2.course_id = c.id
);

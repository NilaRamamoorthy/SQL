-- 1. Create Database and Use
CREATE DATABASE IF NOT EXISTS course_analytics;
USE course_analytics;

-- 2. Create Tables

CREATE TABLE courses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(255)
);

CREATE TABLE students (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student_name VARCHAR(255)
);

CREATE TABLE enrollments (
    student_id INT,
    course_id INT,
    enroll_date DATE,
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES students(id),
    FOREIGN KEY (course_id) REFERENCES courses(id)
);

CREATE TABLE completion (
    student_id INT,
    course_id INT,
    completion_date DATE,
    score INT,
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES students(id),
    FOREIGN KEY (course_id) REFERENCES courses(id)
);

-- 3. Insert Sample Data

INSERT INTO courses (course_name) VALUES
('SQL'),
('Python'),
('Java'),
('Data Science');

INSERT INTO students (student_name) VALUES
('Alice'),
('Bob'),
('Charlie'),
('David'),
('Eva'),
('Frank');

INSERT INTO enrollments (student_id, course_id, enroll_date) VALUES
(1, 1, '2024-01-10'),
(1, 2, '2024-01-10'),
(2, 1, '2024-01-15'),
(3, 2, '2024-02-01'),
(4, 3, '2024-01-20'),
(5, 1, '2024-01-25'),
(6, 2, '2024-02-15');

INSERT INTO completion (student_id, course_id, completion_date, score) VALUES
(1, 1, '2024-03-10', 85),
(1, 2, '2024-03-12', 90),
(2, 1, '2024-03-15', 70),
(3, 2, '2024-04-01', 60),
(5, 1, '2024-03-20', 50),
(6, 2, '2024-04-10', 75);

-- 4a. Subquery in FROM to get completion rate per course

SELECT
    c.course_name,
    comp_stats.completed_students,
    total_enrolled.total_students,
    ROUND((comp_stats.completed_students / total_enrolled.total_students) * 100, 2) AS completion_rate_percent
FROM
    courses c
    JOIN (
        SELECT course_id, COUNT(*) AS completed_students
        FROM completion
        GROUP BY course_id
    ) comp_stats ON c.id = comp_stats.course_id
    JOIN (
        SELECT course_id, COUNT(*) AS total_students
        FROM enrollments
        GROUP BY course_id
    ) total_enrolled ON c.id = total_enrolled.course_id;

-- 4b. INTERSECT to find students who completed both "SQL" and "Python"

SELECT student_id FROM completion
WHERE course_id = (SELECT id FROM courses WHERE course_name = 'SQL')

INTERSECT

SELECT student_id FROM completion
WHERE course_id = (SELECT id FROM courses WHERE course_name = 'Python');

-- 4c. UNION to list all students from two course batches ("SQL" and "Python")

SELECT DISTINCT s.id, s.student_name
FROM students s
JOIN enrollments e ON s.id = e.student_id
JOIN courses c ON e.course_id = c.id
WHERE c.course_name = 'SQL'

UNION

SELECT DISTINCT s.id, s.student_name
FROM students s
JOIN enrollments e ON s.id = e.student_id
JOIN courses c ON e.course_id = c.id
WHERE c.course_name = 'Python';

-- 4d. CASE for grading based on score thresholds

SELECT
    student_id,
    course_id,
    score,
    CASE
        WHEN score >= 85 THEN 'A'
        WHEN score >= 70 THEN 'B'
        WHEN score >= 50 THEN 'C'
        ELSE 'F'
    END AS grade
FROM completion;

-- 4e. Correlated subquery to find student with highest grade in each course

SELECT
    c.course_name,
    s.student_name,
    comp.score
FROM completion comp
JOIN students s ON comp.student_id = s.id
JOIN courses c ON comp.course_id = c.id
WHERE comp.score = (
    SELECT MAX(score)
    FROM completion
    WHERE course_id = comp.course_id
);

-- 4f. Use DATE functions to show completion trends over months (count completions per month)

SELECT
    DATE_FORMAT(completion_date, '%Y-%m') AS month,
    COUNT(*) AS completions
FROM completion
GROUP BY month
ORDER BY month;

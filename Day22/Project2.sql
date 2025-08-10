-- 1. Create Database
CREATE DATABASE university_results;
USE university_results;

-- 2. Create Tables

CREATE TABLE students (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    enrollment_date DATE NOT NULL
);

CREATE TABLE courses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE subjects (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    course_id INT NOT NULL,
    FOREIGN KEY (course_id) REFERENCES courses(id)
);

CREATE TABLE results (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    subject_id INT NOT NULL,
    exam_type ENUM('midterm', 'final') NOT NULL,
    score DECIMAL(5,2) NOT NULL,
    exam_date DATE NOT NULL,
    FOREIGN KEY (student_id) REFERENCES students(id),
    FOREIGN KEY (subject_id) REFERENCES subjects(id)
);

-- 3. Insert Sample Data

INSERT INTO courses (name) VALUES
('Computer Science'),
('Mathematics');

INSERT INTO subjects (name, course_id) VALUES
('Data Structures', 1),
('Algorithms', 1),
('Calculus', 2),
('Linear Algebra', 2);

INSERT INTO students (name, enrollment_date) VALUES
('Alice', '2024-08-15'),
('Bob', '2023-02-10'),
('Charlie', '2025-01-20'),
('Diana', '2024-05-30');

INSERT INTO results (student_id, subject_id, exam_type, score, exam_date) VALUES
(1, 1, 'midterm', 85, '2025-03-10'),
(1, 2, 'midterm', 78, '2025-03-10'),
(1, 1, 'final', 88, '2025-05-20'),
(1, 2, 'final', 90, '2025-05-20'),

(2, 1, 'midterm', 70, '2025-03-10'),
(2, 2, 'midterm', 75, '2025-03-10'),
(2, 3, 'midterm', 80, '2025-03-15'),
(2, 3, 'final', 82, '2025-05-22'),

(3, 3, 'midterm', 95, '2025-03-15'),
(3, 4, 'midterm', 88, '2025-03-15'),
(3, 3, 'final', 92, '2025-05-22'),

(4, 4, 'midterm', 60, '2025-03-15'),
(4, 4, 'final', 65, '2025-05-22');

-- 4. Queries

-- a) Subquery in WHERE: Students who scored above class average in a subject (example: Data Structures subject_id=1)
SELECT 
    s.id,
    s.name,
    r.score
FROM results r
JOIN students s ON r.student_id = s.id
WHERE r.subject_id = 1
  AND r.score > (
    SELECT AVG(score)
    FROM results
    WHERE subject_id = 1
  );

-- b) FROM subquery: Average marks per subject
SELECT
    sub.subject_id,
    sub.name AS subject_name,
    AVG(r.score) AS avg_score
FROM subjects sub
JOIN results r ON sub.id = r.subject_id
GROUP BY sub.subject_id, sub.name;

-- c) UNION ALL: Combine midterm and final results (showing student_id, subject_id, exam_type, score)
SELECT student_id, subject_id, exam_type, score FROM results WHERE exam_type = 'midterm'
UNION ALL
SELECT student_id, subject_id, exam_type, score FROM results WHERE exam_type = 'final';

-- d) CASE: Grade students based on score ranges (Example query for final exams)
SELECT 
    s.name AS student_name,
    sub.name AS subject_name,
    r.score,
    CASE
        WHEN r.score >= 90 THEN 'A'
        WHEN r.score >= 80 THEN 'B'
        WHEN r.score >= 70 THEN 'C'
        WHEN r.score >= 60 THEN 'D'
        ELSE 'F'
    END AS grade
FROM results r
JOIN students s ON r.student_id = s.id
JOIN subjects sub ON r.subject_id = sub.id
WHERE r.exam_type = 'final';

-- e) JOIN students ↔ results ↔ subjects with GROUP BY course level (average score per course)
SELECT 
    c.name AS course_name,
    AVG(r.score) AS avg_course_score
FROM results r
JOIN subjects sub ON r.subject_id = sub.id
JOIN courses c ON sub.course_id = c.id
GROUP BY c.id, c.name;

-- f) Use date functions: Students enrolled within last 1 year from today
SELECT
    id,
    name,
    enrollment_date
FROM students
WHERE enrollment_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

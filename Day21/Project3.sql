-- 1. Create Database
CREATE DATABASE university_enrollment;
USE university_enrollment;

-- 2. Create Tables

CREATE TABLE students (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE teachers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE courses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    teacher_id INT,
    FOREIGN KEY (teacher_id) REFERENCES teachers(id)
);

CREATE TABLE enrollments (
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    grade DECIMAL(5,2),
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES students(id),
    FOREIGN KEY (course_id) REFERENCES courses(id)
);

-- 3. Insert Sample Data

INSERT INTO students (name) VALUES
('Alice'),
('Bob'),
('Charlie'),
('Diana');

INSERT INTO teachers (name) VALUES
('Prof. Smith'),
('Dr. Johnson');

INSERT INTO courses (title, teacher_id) VALUES
('Mathematics', 1),
('Physics', 1),
('Chemistry', 2),
('Literature', 2);

INSERT INTO enrollments (student_id, course_id, grade) VALUES
(1, 1, 85.5),  -- Alice in Mathematics
(2, 1, 78.0),  -- Bob in Mathematics
(3, 2, 72.0),  -- Charlie in Physics
(1, 2, 80.0),  -- Alice in Physics
(4, 3, 90.0),  -- Diana in Chemistry
(2, 3, 88.5);  -- Bob in Chemistry

-- 4. Queries

-- a) Count enrollments per course
SELECT 
    c.title AS course_title,
    COUNT(e.student_id) AS enrollment_count
FROM courses c
LEFT JOIN enrollments e ON c.id = e.course_id
GROUP BY c.id, c.title;

-- b) Average grade per course
SELECT 
    c.title AS course_title,
    ROUND(AVG(e.grade), 2) AS avg_grade
FROM courses c
JOIN enrollments e ON c.id = e.course_id
GROUP BY c.id, c.title;

-- c) Courses with avg grade > 75 (using HAVING)
SELECT 
    c.title AS course_title,
    ROUND(AVG(e.grade), 2) AS avg_grade
FROM courses c
JOIN enrollments e ON c.id = e.course_id
GROUP BY c.id, c.title
HAVING avg_grade > 75;

-- d) INNER JOIN students and their course grades
SELECT
    s.name AS student_name,
    c.title AS course_title,
    e.grade
FROM enrollments e
JOIN students s ON e.student_id = s.id
JOIN courses c ON e.course_id = c.id;

-- e) LEFT JOIN to list courses without enrollments
SELECT 
    c.title AS course_title,
    COUNT(e.student_id) AS enrollment_count
FROM courses c
LEFT JOIN enrollments e ON c.id = e.course_id
GROUP BY c.id, c.title
HAVING enrollment_count = 0;

-- f) SELF JOIN to show students with same course and grade (peer pairing)
SELECT 
    e1.student_id AS student1_id,
    s1.name AS student1_name,
    e2.student_id AS student2_id,
    s2.name AS student2_name,
    c.title AS course_title,
    e1.grade
FROM enrollments e1
JOIN enrollments e2 
    ON e1.course_id = e2.course_id 
    AND e1.grade = e2.grade
    AND e1.student_id < e2.student_id  -- avoid duplicates and self-pairs
JOIN students s1 ON e1.student_id = s1.id
JOIN students s2 ON e2.student_id = s2.id
JOIN courses c ON e1.course_id = c.id
ORDER BY c.title, e1.grade;

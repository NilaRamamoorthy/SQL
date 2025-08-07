-- Create database
CREATE DATABASE IF NOT EXISTS exam_db;
USE exam_db;

-- Create tables
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL
);

CREATE TABLE subjects (
    subject_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE teachers (
    teacher_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL
);

CREATE TABLE marks (
    mark_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    subject_id INT NOT NULL,
    teacher_id INT NOT NULL,
    marks_obtained INT NOT NULL CHECK (marks_obtained BETWEEN 0 AND 100),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id),
    FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id)
);

-- Insert sample students
INSERT INTO students (full_name) VALUES
('Alice Johnson'),
('Bob Smith'),
('Charlie Brown'),
('Diana Prince'),
('Ethan Hunt');

-- Insert sample subjects
INSERT INTO subjects (subject_name) VALUES
('Mathematics'),
('Physics'),
('Chemistry'),
('English'),
('History');

-- Insert sample teachers
INSERT INTO teachers (full_name) VALUES
('Mr. Anderson'),
('Ms. Baker'),
('Dr. Clark');

-- Insert sample marks (student_id, subject_id, teacher_id, marks_obtained)
INSERT INTO marks (student_id, subject_id, teacher_id, marks_obtained) VALUES
(1, 1, 1, 85),
(1, 2, 2, 90),
(1, 3, 3, 78),
(2, 1, 1, 88),
(2, 2, 2, 76),
(2, 3, 3, 84),
(3, 1, 1, 92),
(3, 2, 2, 89),
(3, 3, 3, 94),
(4, 1, 1, 70),
(4, 2, 2, 60),
(4, 3, 3, 75),
(5, 1, 1, 95),
(5, 2, 2, 85),
(5, 3, 3, 88);

-- Query 1: Calculate average marks for each student across all subjects
SELECT s.student_id, s.full_name,
       ROUND(AVG(m.marks_obtained), 2) AS average_marks
FROM students s
JOIN marks m ON s.student_id = m.student_id
GROUP BY s.student_id, s.full_name
ORDER BY average_marks DESC;

-- Query 2: Rank students by marks in a specific subject (e.g., Mathematics - subject_id=1)
SELECT s.student_id, s.full_name, m.marks_obtained,
       RANK() OVER (ORDER BY m.marks_obtained DESC) AS rank
FROM students s
JOIN marks m ON s.student_id = m.student_id
WHERE m.subject_id = 1
ORDER BY rank;

-- Query 3: Find top student(s) per subject
WITH ranked_marks AS (
    SELECT s.student_id, s.full_name, sub.subject_name, m.marks_obtained,
           RANK() OVER (PARTITION BY m.subject_id ORDER BY m.marks_obtained DESC) AS rank
    FROM students s
    JOIN marks m ON s.student_id = m.student_id
    JOIN subjects sub ON m.subject_id = sub.subject_id
)
SELECT subject_name, student_id, full_name, marks_obtained
FROM ranked_marks
WHERE rank = 1
ORDER BY subject_name;


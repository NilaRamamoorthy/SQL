-- 1. Create Database
CREATE DATABASE online_exam_system;
USE online_exam_system;

-- 2. Create Tables

-- Exams table
CREATE TABLE exams (
    id INT PRIMARY KEY AUTO_INCREMENT,
    course_id INT NOT NULL,
    date DATE NOT NULL
);

-- Questions table
CREATE TABLE questions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    exam_id INT NOT NULL,
    text VARCHAR(500) NOT NULL,
    correct_option CHAR(1) NOT NULL,
    FOREIGN KEY (exam_id) REFERENCES exams(id)
);

-- Students table (needed to track student names)
CREATE TABLE students (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Student Answers table
CREATE TABLE student_answers (
    student_id INT NOT NULL,
    question_id INT NOT NULL,
    selected_option CHAR(1) NOT NULL,
    PRIMARY KEY (student_id, question_id),
    FOREIGN KEY (student_id) REFERENCES students(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
);

-- 3. Insert Sample Data

-- Students
INSERT INTO students (name) VALUES
('Alice Brown'),
('Bob Carter');

-- Exams
INSERT INTO exams (course_id, date) VALUES
(101, '2025-08-01'),
(102, '2025-08-05');

-- Questions
INSERT INTO questions (exam_id, text, correct_option) VALUES
(1, 'What is the capital of France?', 'B'),
(1, '2 + 2 = ?', 'A'),
(2, 'HTML stands for?', 'C'),
(2, 'CSS is used for?', 'B');

-- Student Answers
INSERT INTO student_answers (student_id, question_id, selected_option) VALUES
(1, 1, 'B'), -- Correct
(1, 2, 'A'), -- Correct
(2, 1, 'C'), -- Wrong
(2, 2, 'A'), -- Correct
(1, 3, 'C'), -- Correct
(1, 4, 'B'), -- Correct
(2, 3, 'A'), -- Wrong
(2, 4, 'B'); -- Correct

-- 4. Query: Join exams with student answers
SELECT 
    s.name AS student_name,
    e.id AS exam_id,
    e.date AS exam_date,
    q.text AS question,
    sa.selected_option,
    q.correct_option,
    CASE 
        WHEN sa.selected_option = q.correct_option THEN 'Correct'
        ELSE 'Wrong'
    END AS result
FROM student_answers sa
JOIN students s ON sa.student_id = s.id
JOIN questions q ON sa.question_id = q.id
JOIN exams e ON q.exam_id = e.id
ORDER BY s.name, e.id, q.id;

-- 5. Query: Calculate score per student per exam
SELECT 
    s.name AS student_name,
    e.id AS exam_id,
    COUNT(CASE WHEN sa.selected_option = q.correct_option THEN 1 END) AS correct_answers,
    COUNT(q.id) AS total_questions,
    ROUND((COUNT(CASE WHEN sa.selected_option = q.correct_option THEN 1 END) / COUNT(q.id)) * 100, 2) AS score_percentage
FROM student_answers sa
JOIN students s ON sa.student_id = s.id
JOIN questions q ON sa.question_id = q.id
JOIN exams e ON q.exam_id = e.id
GROUP BY s.name, e.id
ORDER BY s.name, e.id;

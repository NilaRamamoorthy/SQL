-- 1. Create Database
CREATE DATABASE course_progress_tracker;
USE course_progress_tracker;

-- 2. Create Tables

-- Courses Table
CREATE TABLE courses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Lessons Table
CREATE TABLE lessons (
    id INT PRIMARY KEY AUTO_INCREMENT,
    course_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

-- Progress Table
CREATE TABLE progress (
    student_id INT NOT NULL,
    lesson_id INT NOT NULL,
    completed_at DATETIME,
    PRIMARY KEY (student_id, lesson_id),
    FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE
);

-- Students Table (optional, for clarity)
CREATE TABLE students (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- 3. Insert Sample Data

-- Courses
INSERT INTO courses (name) VALUES
('Web Development Bootcamp'),
('Data Science with Python');

-- Lessons
INSERT INTO lessons (course_id, title) VALUES
(1, 'HTML Basics'),
(1, 'CSS Fundamentals'),
(1, 'JavaScript Essentials'),
(2, 'Python Basics'),
(2, 'Data Analysis with Pandas'),
(2, 'Machine Learning Intro');

-- Students
INSERT INTO students (name) VALUES
('Alice Johnson'),
('Bob Smith'),
('Charlie Davis');

-- Progress
INSERT INTO progress (student_id, lesson_id, completed_at) VALUES
(1, 1, '2025-08-01 10:00:00'),
(1, 2, '2025-08-02 11:00:00'),
(1, 3, '2025-08-03 09:30:00'), -- Alice completed all lessons in course 1
(2, 1, '2025-08-01 14:00:00'),
(2, 2, NULL), -- Bob started but not completed lesson 2
(3, 4, '2025-08-05 12:15:00'); -- Charlie completed Python Basics

-- 4. Query: Calculate completion percentage per student per course
SELECT 
    s.name AS student_name,
    c.name AS course_name,
    COUNT(DISTINCT p.lesson_id) AS completed_lessons,
    COUNT(DISTINCT l.id) AS total_lessons,
    ROUND(
        (COUNT(DISTINCT p.lesson_id) / COUNT(DISTINCT l.id)) * 100, 2
    ) AS completion_percentage
FROM students s
JOIN progress p ON s.id = p.student_id AND p.completed_at IS NOT NULL
JOIN lessons l ON p.lesson_id = l.id
JOIN courses c ON l.course_id = c.id
GROUP BY s.id, c.id;

-- 5. Query: List incomplete lessons for a student (Example: Bob Smith)
SELECT 
    l.title AS lesson_title
FROM lessons l
JOIN courses c ON l.course_id = c.id
WHERE c.id = 1
  AND l.id NOT IN (
      SELECT lesson_id FROM progress p
      JOIN students s ON p.student_id = s.id
      WHERE s.name = 'Bob Smith' AND p.completed_at IS NOT NULL
  );

-- 6. Query: Students who completed all lessons in a course (Example: Web Development Bootcamp)
SELECT s.name
FROM students s
JOIN progress p ON s.id = p.student_id AND p.completed_at IS NOT NULL
JOIN lessons l ON p.lesson_id = l.id
WHERE l.course_id = 1
GROUP BY s.id
HAVING COUNT(DISTINCT p.lesson_id) = (SELECT COUNT(*) FROM lessons WHERE course_id = 1);

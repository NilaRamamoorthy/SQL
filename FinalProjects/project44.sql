-- 1. Create Database
CREATE DATABASE course_feedback_system;
USE course_feedback_system;

-- 2. Create Tables

-- Courses table
CREATE TABLE courses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL
);

-- Feedback table
CREATE TABLE feedback (
    id INT PRIMARY KEY AUTO_INCREMENT,
    course_id INT NOT NULL,
    user_id INT NOT NULL,
    rating DECIMAL(3,2) CHECK (rating >= 0 AND rating <= 5),
    comments TEXT,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

-- 3. Insert Sample Data

INSERT INTO courses (title) VALUES
('Introduction to SQL'),
('Python for Data Analysis'),
('Web Development Bootcamp');

INSERT INTO feedback (course_id, user_id, rating, comments) VALUES
(1, 101, 4.5, 'Very clear and well-structured.'),
(1, 102, 4.0, 'Good, but could use more exercises.'),
(2, 103, 5.0, 'Excellent and detailed explanations!'),
(3, 104, 3.8, 'Too fast-paced for beginners.'),
(3, 105, 4.2, 'Good coverage of topics.');

-- 4. Query: Average rating per course
SELECT 
    c.id AS course_id,
    c.title,
    ROUND(AVG(f.rating), 2) AS avg_rating
FROM courses c
LEFT JOIN feedback f ON c.id = f.course_id
GROUP BY c.id, c.title;

-- 5. Query: Feedback sentiment (simple positive/negative classification based on rating)
SELECT 
    CASE 
        WHEN rating >= 4 THEN 'Positive'
        WHEN rating >= 2 THEN 'Neutral'
        ELSE 'Negative'
    END AS sentiment,
    COUNT(*) AS total_feedbacks
FROM feedback
GROUP BY sentiment;

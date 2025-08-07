-- Step 1: Create Database and Use It
CREATE DATABASE OnlineLearningPlatform;
USE OnlineLearningPlatform;

-- Step 2: Create normalized tables (3NF)

-- Instructors
CREATE TABLE instructors (
    instructor_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE
);

-- Courses
CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(255) NOT NULL,
    instructor_id INT NOT NULL,
    FOREIGN KEY (instructor_id) REFERENCES instructors(instructor_id)
);

-- Users (students or learners)
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(255) UNIQUE,
    registered_date DATE
);

-- Enrollments (link users and courses)
CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

-- Completions (track course completion)
CREATE TABLE completions (
    completion_id INT PRIMARY KEY AUTO_INCREMENT,
    enrollment_id INT NOT NULL,
    completion_date DATE NOT NULL,
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id)
);

-- Insert sample data


-- Instructors
INSERT INTO instructors (name, email) VALUES
('Alice Johnson', 'alice.johnson@example.com'),
('Bob Smith', 'bob.smith@example.com'),
('Carol White', 'carol.white@example.com');

-- Courses
INSERT INTO courses (course_name, instructor_id) VALUES
('Intro to Python', 1),
('Advanced SQL', 2),
('Data Science Basics', 3),
('Web Development', 1),
('Machine Learning', 3);

-- Users
INSERT INTO users (username, email, registered_date) VALUES
('user1', 'user1@example.com', '2023-01-10'),
('user2', 'user2@example.com', '2023-02-15'),
('user3', 'user3@example.com', '2023-03-05'),
('user4', 'user4@example.com', '2023-04-20'),
('user5', 'user5@example.com', '2023-05-11'),
('user6', 'user6@example.com', '2023-06-01');

-- Enrollments
INSERT INTO enrollments (user_id, course_id, enrollment_date) VALUES
(1, 1, '2023-01-15'),
(1, 2, '2023-02-01'),
(1, 3, '2023-03-01'),
(1, 4, '2023-04-01'),
(2, 2, '2023-02-20'),
(2, 3, '2023-03-15'),
(3, 1, '2023-01-30'),
(3, 4, '2023-04-05'),
(4, 5, '2023-05-01'),
(5, 1, '2023-01-20'),
(5, 3, '2023-03-10'),
(6, 2, '2023-02-25');

-- Completions
INSERT INTO completions (enrollment_id, completion_date) VALUES
(1, '2023-02-15'),
(2, '2023-03-01'),
(3, '2023-04-01'),
(4, '2023-05-01'),
(5, '2023-03-25'),
(6, '2023-04-10'),
(7, '2023-02-20'),
(8, '2023-05-10'),
(9, '2023-06-15'),
(10, '2023-02-28'),
(11, '2023-04-15');


-- Step 3: Create indexes for performance
CREATE INDEX idx_courses_instructor ON courses(instructor_id);
CREATE INDEX idx_enrollments_course ON enrollments(course_id);
CREATE INDEX idx_enrollments_user ON enrollments(user_id);
CREATE INDEX idx_completions_date ON completions(completion_date);

-- Step 4: EXPLAIN query to analyze course completion report
EXPLAIN
SELECT
    c.course_id,
    c.course_name,
    COUNT(co.completion_id) AS completions_count
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
LEFT JOIN completions co ON e.enrollment_id = co.enrollment_id
GROUP BY c.course_id, c.course_name
ORDER BY completions_count DESC;

-- Step 5: Subquery to find users who completed more than 3 courses
SELECT u.user_id, u.username, COUNT(co.completion_id) AS completed_courses
FROM users u
JOIN enrollments e ON u.user_id = e.user_id
JOIN completions co ON e.enrollment_id = co.enrollment_id
GROUP BY u.user_id, u.username
HAVING COUNT(co.completion_id) > 3
ORDER BY completed_courses DESC;

-- Step 6: Create denormalized leaderboard table for course completions
CREATE TABLE course_completion_leaderboard (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(255),
    completions_count INT
);

-- Populate the leaderboard (refresh as needed)
INSERT INTO course_completion_leaderboard (course_id, course_name, completions_count)
SELECT
    c.course_id,
    c.course_name,
    COUNT(co.completion_id) AS completions_count
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
LEFT JOIN completions co ON e.enrollment_id = co.enrollment_id
GROUP BY c.course_id, c.course_name;

-- Step 7: Query to display top 5 trending courses using LIMIT
SELECT course_id, course_name, completions_count
FROM course_completion_leaderboard
ORDER BY completions_count DESC
LIMIT 5;


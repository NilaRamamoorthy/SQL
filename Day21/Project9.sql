-- 1. Create Database
CREATE DATABASE elearning_performance;
USE elearning_performance;

-- 2. Create Tables

CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE instructors (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE courses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    instructor_id INT NOT NULL,
    FOREIGN KEY (instructor_id) REFERENCES instructors(id)
);

CREATE TABLE enrollments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    course_id INT NOT NULL,
    completed BOOLEAN NOT NULL DEFAULT FALSE,
    enroll_date DATE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (course_id) REFERENCES courses(id)
);

-- 3. Insert Sample Data

INSERT INTO instructors (name) VALUES
('Alice Smith'),
('Bob Johnson');

INSERT INTO courses (title, instructor_id) VALUES
('Python Basics', 1),
('Advanced Java', 1),
('Data Science 101', 2),
('Web Development', 2),
('Machine Learning', 1);

INSERT INTO users (name) VALUES
('John Doe'),
('Jane Roe'),
('Sam Green'),
('Lucy Black'),
('Mark White'),
('Ella Brown');

INSERT INTO enrollments (user_id, course_id, completed, enroll_date) VALUES
(1, 1, TRUE, '2025-01-15'),
(2, 1, TRUE, '2025-01-20'),
(3, 1, FALSE, '2025-01-25'),
(4, 2, TRUE, '2025-02-01'),
(5, 2, FALSE, '2025-02-10'),
(6, 3, TRUE, '2025-02-15'),
(1, 3, TRUE, '2025-02-18'),
(2, 4, FALSE, '2025-03-01'),
(3, 4, TRUE, '2025-03-05'),
(4, 5, TRUE, '2025-03-10'),
(5, 5, TRUE, '2025-03-15');

-- 4. Queries

-- a) Total enrollments per course
SELECT
    c.id,
    c.title,
    COUNT(e.id) AS total_enrollments
FROM courses c
LEFT JOIN enrollments e ON c.id = e.course_id
GROUP BY c.id, c.title;

-- b) Average completion rate per instructor
SELECT
    i.id,
    i.name,
    ROUND(AVG(completion_rate) * 100, 2) AS avg_completion_percent
FROM instructors i
JOIN (
    SELECT
        c.instructor_id,
        c.id AS course_id,
        IFNULL(SUM(CASE WHEN e.completed THEN 1 ELSE 0 END) / COUNT(e.id), 0) AS completion_rate
    FROM courses c
    LEFT JOIN enrollments e ON c.id = e.course_id
    GROUP BY c.id, c.instructor_id
) course_completion ON i.id = course_completion.instructor_id
GROUP BY i.id, i.name;

-- c) Courses with more than 20 completions (HAVING)
SELECT
    c.id,
    c.title,
    COUNT(e.id) AS completions
FROM courses c
JOIN enrollments e ON c.id = e.course_id
WHERE e.completed = TRUE
GROUP BY c.id, c.title
HAVING completions > 20;

-- d) INNER JOIN users and courses (all enrollments with user and course info)
SELECT
    u.name AS user_name,
    c.title AS course_title,
    e.completed,
    e.enroll_date
FROM enrollments e
JOIN users u ON e.user_id = u.id
JOIN courses c ON e.course_id = c.id;

-- e) LEFT JOIN to list courses without enrollments
SELECT
    c.id,
    c.title,
    COUNT(e.id) AS enrollment_count
FROM courses c
LEFT JOIN enrollments e ON c.id = e.course_id
GROUP BY c.id, c.title
HAVING enrollment_count = 0;

-- f) SELF JOIN to compare users who completed the same course
SELECT
    e1.user_id AS user1_id,
    u1.name AS user1_name,
    e2.user_id AS user2_id,
    u2.name AS user2_name,
    e1.course_id,
    c.title AS course_title
FROM enrollments e1
JOIN enrollments e2 ON e1.course_id = e2.course_id AND e1.user_id < e2.user_id
JOIN users u1 ON e1.user_id = u1.id
JOIN users u2 ON e2.user_id = u2.id
JOIN courses c ON e1.course_id = c.id
WHERE e1.completed = TRUE AND e2.completed = TRUE
ORDER BY e1.course_id, e1.user_id, e2.user_id;

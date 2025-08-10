-- 1. Create database and use it
CREATE DATABASE IF NOT EXISTS course_curriculum;
USE course_curriculum;

-- 2. Create tables

CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100),
    course_type VARCHAR(20) -- 'Required' or 'Elective'
);

CREATE TABLE prerequisites (
    course_id INT,
    prereq_course_id INT,
    PRIMARY KEY(course_id, prereq_course_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    FOREIGN KEY (prereq_course_id) REFERENCES courses(course_id)
);

CREATE TABLE students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE student_progress (
    student_id INT,
    course_id INT,
    status VARCHAR(20), -- 'Completed', 'In Progress', 'Not Started'
    PRIMARY KEY(student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

-- 3. Insert sample data

INSERT INTO courses (course_id, course_name, course_type) VALUES
(1, 'Intro to Programming', 'Required'),
(2, 'Data Structures', 'Required'),
(3, 'Databases', 'Required'),
(4, 'Web Development', 'Elective'),
(5, 'Machine Learning', 'Elective'),
(6, 'Algorithms', 'Required');

INSERT INTO prerequisites (course_id, prereq_course_id) VALUES
(2, 1), -- Data Structures requires Intro to Programming
(3, 1), -- Databases requires Intro to Programming
(4, 2), -- Web Development requires Data Structures
(5, 3), -- Machine Learning requires Databases
(6, 2); -- Algorithms requires Data Structures

INSERT INTO students (student_id, name) VALUES
(101, 'Alice'),
(102, 'Bob');

INSERT INTO student_progress (student_id, course_id, status) VALUES
(101, 1, 'Completed'),
(101, 2, 'Completed'),
(101, 3, 'In Progress'),
(102, 1, 'Completed'),
(102, 4, 'In Progress');

-- 4. Recursive CTE to list full course paths (prerequisite chains)

WITH RECURSIVE course_paths AS (
    SELECT
        c.course_id,
        c.course_name,
        c.course_type,
        c.course_id AS start_course_id,
        c.course_name AS start_course_name,
        0 AS level,
        CAST(c.course_name AS CHAR(1000)) AS path
    FROM courses c
    WHERE c.course_id NOT IN (SELECT course_id FROM prerequisites) -- courses without prereqs

    UNION ALL

    SELECT
        c.course_id,
        c.course_name,
        c.course_type,
        cp.start_course_id,
        cp.start_course_name,
        cp.level + 1,
        CONCAT(cp.path, ' -> ', c.course_name)
    FROM prerequisites p
    JOIN courses c ON p.course_id = c.course_id
    JOIN course_paths cp ON p.prereq_course_id = cp.course_id
)

SELECT * FROM course_paths
ORDER BY start_course_id, level;

-- 5. Rank courses by Required vs Elective

SELECT
    course_id,
    course_name,
    course_type,
    RANK() OVER (ORDER BY CASE WHEN course_type = 'Required' THEN 1 ELSE 2 END) AS priority_rank
FROM courses
ORDER BY priority_rank, course_name;

-- 6. Suggest next recommended course using LEAD()

WITH ordered_courses AS (
    SELECT
        course_id,
        course_name,
        course_type,
        LEAD(course_name) OVER (ORDER BY course_id) AS next_course
    FROM courses
)

SELECT * FROM ordered_courses;

-- 7. Build CTE for each student's course progress summary

WITH student_course_progress AS (
    SELECT
        s.student_id,
        s.name AS student_name,
        c.course_id,
        c.course_name,
        sp.status
    FROM students s
    CROSS JOIN courses c
    LEFT JOIN student_progress sp ON s.student_id = sp.student_id AND c.course_id = sp.course_id
)

SELECT * FROM student_course_progress
ORDER BY student_id, course_id;

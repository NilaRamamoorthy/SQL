-- 1. Create Database
CREATE DATABASE IF NOT EXISTS university_performance;
USE university_performance;

-- 2. OLTP Tables

CREATE TABLE students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(255),
    department VARCHAR(100),
    batch_year INT
);

CREATE TABLE subjects (
    subject_id INT PRIMARY KEY,
    subject_name VARCHAR(255),
    department VARCHAR(100)
);

CREATE TABLE exams (
    exam_id INT PRIMARY KEY,
    subject_id INT,
    semester VARCHAR(10),
    exam_date DATE,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

-- Grades table stores inconsistent grade formats (e.g., numeric scores, letter grades, or GPA)
CREATE TABLE grades (
    grade_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    exam_id INT,
    grade VARCHAR(10), -- can be 'A', '85', '3.5' etc
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (exam_id) REFERENCES exams(exam_id)
);

-- 3. Star Schema Warehouse Tables

CREATE TABLE dim_student (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(255),
    department VARCHAR(100),
    batch_year INT
);

CREATE TABLE dim_subject (
    subject_id INT PRIMARY KEY,
    subject_name VARCHAR(255),
    department VARCHAR(100)
);

CREATE TABLE dim_time (
    time_id INT PRIMARY KEY AUTO_INCREMENT,
    exam_date DATE,
    semester VARCHAR(10),
    year INT,
    month INT,
    day INT
);

CREATE TABLE fact_scores (
    score_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    subject_id INT,
    time_id INT,
    score DECIMAL(5,2),  -- normalized numeric score 0-100
    pass_fail CHAR(1),   -- 'P' or 'F'
    FOREIGN KEY (student_id) REFERENCES dim_student(student_id),
    FOREIGN KEY (subject_id) REFERENCES dim_subject(subject_id),
    FOREIGN KEY (time_id) REFERENCES dim_time(time_id)
);

-- 4. Insert sample data into OLTP

INSERT INTO students VALUES
(1, 'Alice Johnson', 'Computer Science', 2023),
(2, 'Bob Lee', 'Computer Science', 2023),
(3, 'Carol Smith', 'Mathematics', 2022);

INSERT INTO subjects VALUES
(101, 'Databases', 'Computer Science'),
(102, 'Operating Systems', 'Computer Science'),
(201, 'Calculus', 'Mathematics');

INSERT INTO exams VALUES
(1001, 101, 'Fall', '2025-12-10'),
(1002, 102, 'Fall', '2025-12-12'),
(1003, 201, 'Fall', '2025-12-11');

-- Insert inconsistent grades (some numeric, some letter, some GPA scale)
INSERT INTO grades (student_id, exam_id, grade) VALUES
(1, 1001, 'A'),
(1, 1002, '85'),
(2, 1001, 'B'),
(2, 1002, '78'),
(3, 1003, '3.7'); -- Assuming GPA scale

-- 5. ETL: Normalize grades into numeric scores (0-100 scale)
-- Mapping for letter grades and GPA (example):
-- A=90, B=80, C=70, D=60, F=0
-- GPA scale: multiply by 25 (e.g., 3.7 * 25 = 92.5)

-- Create a helper function or use CASE in SELECT (since MySQL does not have functions easily here, use CASE in ETL)

-- First populate dimension tables

INSERT INTO dim_student
SELECT student_id, student_name, department, batch_year FROM students;

INSERT INTO dim_subject
SELECT subject_id, subject_name, department FROM subjects;

INSERT INTO dim_time (exam_date, semester, year, month, day)
SELECT DISTINCT
    exam_date,
    semester,
    YEAR(exam_date),
    MONTH(exam_date),
    DAY(exam_date)
FROM exams;

-- Get time_id for ETL step
-- Insert normalized scores into fact_scores

INSERT INTO fact_scores (student_id, subject_id, time_id, score, pass_fail)
SELECT
    g.student_id,
    e.subject_id,
    dt.time_id,
    CASE
        WHEN g.grade REGEXP '^[0-9]+$' THEN CAST(g.grade AS DECIMAL(5,2)) -- numeric score
        WHEN g.grade IN ('A','a') THEN 90
        WHEN g.grade IN ('B','b') THEN 80
        WHEN g.grade IN ('C','c') THEN 70
        WHEN g.grade IN ('D','d') THEN 60
        WHEN g.grade IN ('F','f') THEN 0
        WHEN g.grade REGEXP '^[0-9]*\\.?[0-9]+$' THEN CAST(g.grade AS DECIMAL(5,2)) * 25 -- GPA scale approx.
        ELSE NULL
    END AS normalized_score,
    CASE
        WHEN
            CASE
                WHEN g.grade REGEXP '^[0-9]+$' THEN CAST(g.grade AS DECIMAL(5,2))
                WHEN g.grade IN ('A','a') THEN 90
                WHEN g.grade IN ('B','b') THEN 80
                WHEN g.grade IN ('C','c') THEN 70
                WHEN g.grade IN ('D','d') THEN 60
                WHEN g.grade IN ('F','f') THEN 0
                WHEN g.grade REGEXP '^[0-9]*\\.?[0-9]+$' THEN CAST(g.grade AS DECIMAL(5,2)) * 25
                ELSE 0
            END >= 60 THEN 'P' ELSE 'F' END AS passfail_flag
FROM grades g
JOIN exams e ON g.exam_id = e.exam_id
JOIN dim_time dt ON e.exam_date = dt.exam_date;

-- 6. OLAP Queries

-- a) Average score by semester
SELECT
    dt.semester,
    AVG(fs.score) AS avg_score,
    COUNT(fs.score_id) AS num_scores
FROM fact_scores fs
JOIN dim_time dt ON fs.time_id = dt.time_id
GROUP BY dt.semester
ORDER BY dt.semester;

-- b) Subject-wise failure rate (percentage)
SELECT
    ds.subject_name,
    COUNT(CASE WHEN fs.pass_fail = 'F' THEN 1 END) * 100.0 / COUNT(fs.score_id) AS failure_rate_percent
FROM fact_scores fs
JOIN dim_subject ds ON fs.subject_id = ds.subject_id
GROUP BY ds.subject_name
ORDER BY failure_rate_percent DESC;

-- c) Slice/dice: Average score by department and batch_year
SELECT
    ds.department,
    dstudent.batch_year,
    AVG(fs.score) AS avg_score
FROM fact_scores fs
JOIN dim_subject ds ON fs.subject_id = ds.subject_id
JOIN dim_student dstudent ON fs.student_id = dstudent.student_id
GROUP BY ds.department, dstudent.batch_year
ORDER BY ds.department, dstudent.batch_year;

-- d) List students who failed any subject
SELECT DISTINCT
    dstudent.student_name,
    ds.subject_name,
    fs.score,
    fs.pass_fail
FROM fact_scores fs
JOIN dim_student dstudent ON fs.student_id = dstudent.student_id
JOIN dim_subject ds ON fs.subject_id = ds.subject_id
WHERE fs.pass_fail = 'F'
ORDER BY dstudent.student_name;


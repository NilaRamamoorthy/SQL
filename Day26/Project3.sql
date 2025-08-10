-- 1. Create Database & Use
CREATE DATABASE IF NOT EXISTS academic_performance;
USE academic_performance;

-- 2. Create Tables

CREATE TABLE students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE subjects (
    subject_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE semesters (
    semester_id INT PRIMARY KEY,
    name VARCHAR(50),
    start_date DATE,
    end_date DATE
);

CREATE TABLE grades (
    grade_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    subject_id INT,
    semester_id INT,
    marks INT,
    exam_date DATE,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id),
    FOREIGN KEY (semester_id) REFERENCES semesters(semester_id)
);

CREATE TABLE prerequisites (
    subject_id INT,
    prerequisite_id INT,
    PRIMARY KEY (subject_id, prerequisite_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id),
    FOREIGN KEY (prerequisite_id) REFERENCES subjects(subject_id)
);

-- 3. Insert Sample Data

INSERT INTO students (student_id, name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie');

INSERT INTO subjects (subject_id, name) VALUES
(101, 'Mathematics'),
(102, 'Physics'),
(103, 'Chemistry'),
(104, 'Computer Science');

INSERT INTO semesters (semester_id, name, start_date, end_date) VALUES
(1, 'Semester 1', '2024-01-01', '2024-06-30'),
(2, 'Semester 2', '2024-07-01', '2024-12-31'),
(3, 'Semester 3', '2025-01-01', '2025-06-30');

INSERT INTO grades (student_id, subject_id, semester_id, marks, exam_date) VALUES
(1, 101, 1, 85, '2024-03-15'),
(1, 102, 1, 78, '2024-03-16'),
(1, 103, 1, 90, '2024-03-17'),
(1, 101, 2, 88, '2024-09-15'),
(1, 102, 2, 82, '2024-09-16'),
(2, 101, 1, 92, '2024-03-15'),
(2, 103, 1, 75, '2024-03-17'),
(2, 104, 2, 80, '2024-09-18'),
(3, 101, 1, 70, '2024-03-15'),
(3, 102, 2, 77, '2024-09-16'),
(3, 103, 3, 85, '2025-03-20');

INSERT INTO prerequisites (subject_id, prerequisite_id) VALUES
(104, 101),  -- Computer Science requires Mathematics
(104, 102);  -- Computer Science requires Physics

-- 4. CTE: Subject-wise Topper (RANK)

WITH subject_toppers AS (
    SELECT
        subject_id,
        student_id,
        marks,
        RANK() OVER (PARTITION BY subject_id ORDER BY marks DESC) AS rank_in_subject
    FROM grades
)

SELECT 
    st.subject_id,
    s.name AS subject_name,
    st.student_id,
    st.marks,
    st.rank_in_subject,
    st2.name AS student_name
FROM subject_toppers st
JOIN students st2 ON st.student_id = st2.student_id
JOIN subjects s ON st.subject_id = s.subject_id
WHERE rank_in_subject = 1
ORDER BY subject_id;

-- 5. CTE: Exam Attempt Order (ROW_NUMBER)

WITH exam_attempts AS (
    SELECT
        student_id,
        subject_id,
        semester_id,
        marks,
        exam_date,
        ROW_NUMBER() OVER (PARTITION BY student_id, subject_id ORDER BY exam_date) AS attempt_order
    FROM grades
)

SELECT
    ea.student_id,
    st.name AS student_name,
    ea.subject_id,
    sbj.name AS subject_name,
    ea.semester_id,
    sm.name AS semester_name,
    ea.marks,
    ea.exam_date,
    ea.attempt_order
FROM exam_attempts ea
JOIN students st ON ea.student_id = st.student_id
JOIN subjects sbj ON ea.subject_id = sbj.subject_id
JOIN semesters sm ON ea.semester_id = sm.semester_id
ORDER BY ea.student_id, ea.subject_id, ea.attempt_order;

-- 6. CTE: Compare Marks between Semesters (LEAD, LAG)

WITH marks_with_prev_next AS (
    SELECT
        student_id,
        subject_id,
        semester_id,
        marks,
        LAG(marks) OVER (PARTITION BY student_id, subject_id ORDER BY semester_id) AS prev_marks,
        LEAD(marks) OVER (PARTITION BY student_id, subject_id ORDER BY semester_id) AS next_marks
    FROM grades
)

SELECT 
    m.student_id,
    st.name AS student_name,
    m.subject_id,
    sbj.name AS subject_name,
    m.semester_id,
    sm.name AS semester_name,
    m.marks,
    m.prev_marks,
    m.next_marks
FROM marks_with_prev_next m
JOIN students st ON m.student_id = st.student_id
JOIN subjects sbj ON m.subject_id = sbj.subject_id
JOIN semesters sm ON m.semester_id = sm.semester_id
ORDER BY m.student_id, m.subject_id, m.semester_id;

-- 7. CTEs for Subject-wise and Semester-wise Analysis

WITH subject_analysis AS (
    SELECT
        subject_id,
        AVG(marks) AS avg_marks,
        COUNT(DISTINCT student_id) AS students_count
    FROM grades
    GROUP BY subject_id
),
semester_analysis AS (
    SELECT
        semester_id,
        AVG(marks) AS avg_marks,
        COUNT(DISTINCT student_id) AS students_count
    FROM grades
    GROUP BY semester_id
)

SELECT 
    sa.subject_id,
    sbj.name AS subject_name,
    sa.avg_marks AS subject_avg,
    sa.students_count,
    sem.semester_id,
    sem.name AS semester_name,
    sem_analysis.avg_marks AS semester_avg,
    sem_analysis.students_count AS semester_students
FROM subject_analysis sa
JOIN subjects sbj ON sa.subject_id = sbj.subject_id
CROSS JOIN semesters sem
LEFT JOIN semester_analysis sem_analysis ON sem.semester_id = sem_analysis.semester_id
ORDER BY sa.subject_id, sem.semester_id;

-- 8. Recursive CTE to navigate course prerequisites

WITH RECURSIVE prereq_path (subject_id, prerequisite_id, path) AS (
    SELECT
        subject_id,
        prerequisite_id,
        CAST(CONCAT(subject_id, '->', prerequisite_id) AS CHAR(255)) AS path
    FROM prerequisites
    UNION ALL
    SELECT
        p.subject_id,
        pr.prerequisite_id,
        CONCAT(pr.path, '->', pr.prerequisite_id)
    FROM prerequisites pr
    INNER JOIN prereq_path p ON pr.subject_id = p.prerequisite_id
)

SELECT 
    subject_id,
    prerequisite_id,
    path
FROM prereq_path
ORDER BY subject_id, prerequisite_id;

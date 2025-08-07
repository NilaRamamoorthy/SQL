-- Step 1: Create Database and Activate It
CREATE DATABASE UniversityCourseReg;
USE UniversityCourseReg;

-- Step 2: Tables (3NF) — departments, faculty, students, courses, enrollments
CREATE TABLE departments (
  department_id INT PRIMARY KEY AUTO_INCREMENT,
  department_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE faculty (
  faculty_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  department_id INT NOT NULL,
  FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE TABLE students (
  student_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  enrollment_date DATE
);

CREATE TABLE courses (
  course_id INT PRIMARY KEY AUTO_INCREMENT,
  course_name VARCHAR(200) NOT NULL,
  department_id INT NOT NULL,
  faculty_id INT,
  FOREIGN KEY (department_id) REFERENCES departments(department_id),
  FOREIGN KEY (faculty_id) REFERENCES faculty(faculty_id)
);

CREATE TABLE enrollments (
  enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
  student_id INT NOT NULL,
  course_id INT NOT NULL,
  enrollment_date DATE,
  FOREIGN KEY (student_id) REFERENCES students(student_id),
  FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

-- Step 3: Sample Data Insertion
INSERT INTO departments (department_name) VALUES
('Computer Science'),
('Mathematics'),
('History');

INSERT INTO faculty (name, department_id) VALUES
('Dr. Alice Smith', 1),
('Prof. Bob Jones', 2),
('Dr. Carol Lee', 3);

INSERT INTO students (name, enrollment_date) VALUES
('Amanda Collins', '2025-01-10'),
('Aaron Patel', '2025-02-05'),
('Becky Nguyen', '2025-01-20'),
('Charles Kim', '2025-03-01'),
('David Zhang', '2025-02-15');

INSERT INTO courses (course_name, department_id, faculty_id) VALUES
('Intro to Programming',      1, 1),
('Data Structures',           1, 1),
('Calculus I',               2, 2),
('Linear Algebra',           2, 2),
('World History',            3, 3);

INSERT INTO enrollments (student_id, course_id, enrollment_date) VALUES
(1, 1, '2025-01-11'),
(1, 2, '2025-01-15'),
(1, 3, '2025-03-01'),
(2, 1, '2025-02-10'),
(2, 3, '2025-02-12'),
(2, 4, '2025-02-15'),
(2, 5, '2025-03-05'),
(3, 1, '2025-01-21'),
(3, 5, '2025-02-25'),
(4, 4, '2025-03-02'),
(5, 3, '2025-02-20'),
(5, 4, '2025-02-22'),
(5, 5, '2025-03-06');

-- Step 4: Create Indexes for Optimization
CREATE INDEX idx_students_id ON students(student_id);
CREATE INDEX idx_courses_id ON courses(course_id);
CREATE INDEX idx_faculty_id ON faculty(faculty_id);

-- Step 5: Analyze Joins for Reporting via EXPLAIN
EXPLAIN
SELECT s.student_id, s.name, c.course_id, c.course_name
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
WHERE s.name LIKE 'A%';

-- Step 6: Query: Students Enrolled in More Than 3 Courses
SELECT s.student_id, s.name, COUNT(*) AS num_courses
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
GROUP BY s.student_id, s.name
HAVING COUNT(*) > 3
ORDER BY num_courses DESC;

-- Step 7: Denormalized Summary View (Dashboard)
CREATE VIEW student_course_summary AS
SELECT
  s.student_id,
  s.name AS student_name,
  COUNT(e.course_id) AS total_courses,
  MAX(e.enrollment_date) AS last_enrollment_date
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
GROUP BY s.student_id, s.name;

-- Step 8: Retrieve Last 5 Courses for a Specific Student (Pagination)
-- Example for student_id = 2
SELECT c.course_id, c.course_name, e.enrollment_date
FROM enrollments e
JOIN courses c ON e.course_id = c.course_id
WHERE e.student_id = 2
ORDER BY e.enrollment_date DESC
LIMIT 5;

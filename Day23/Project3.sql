-- Step 1: Create and Use Database
CREATE DATABASE IF NOT EXISTS OnlineCourseReg;
USE OnlineCourseReg;

-- Step 2: Create Tables

-- Students Table
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

-- Courses Table
CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(100) NOT NULL,
    available_seats INT NOT NULL CHECK (available_seats >= 0)
);

-- Enrollments Table
CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    grade INT CHECK (grade BETWEEN 0 AND 100),
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

-- Step 3: Insert Sample Data

INSERT INTO students (name, email) VALUES
('Alice Smith', 'alice@example.com'),
('Bob Johnson', 'bob@example.com'),
('Carol Lee', 'carol@example.com');

INSERT INTO courses (course_name, available_seats) VALUES
('Mathematics', 3),
('Physics', 2),
('Computer Science', 2);

-- Step 4: Enroll Students (with FOREIGN KEY checks)
-- Also UPDATE course availability
START TRANSACTION;

INSERT INTO enrollments (student_id, course_id, grade)
VALUES (1, 1, 85);  -- Alice in Mathematics

UPDATE courses SET available_seats = available_seats - 1 WHERE course_id = 1;

COMMIT;

-- Step 5: Demonstrate ON DELETE CASCADE
-- DELETE student Bob (id = 2) → removes his enrollments
-- First enroll him:
INSERT INTO enrollments (student_id, course_id, grade) VALUES (2, 2, 78);
DELETE FROM students WHERE student_id = 2;

-- Step 6: Drop and Recreate CHECK Constraint (e.g. grading scale change)

-- 6a. Drop CHECK constraint (only in MySQL 8+ with named constraints)
-- MySQL does not support DROP CHECK by name pre-8.0.16. If using that version+:

-- First drop table if exists and recreate with named constraint
DROP TABLE IF EXISTS enrollments;

CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    grade INT,
    CONSTRAINT chk_grade CHECK (grade BETWEEN 0 AND 100),
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

-- 6b. Recreate with updated grading scale
-- Example: Change to allow grades from -1 (not yet graded) to 100
ALTER TABLE enrollments DROP CHECK chk_grade;
ALTER TABLE enrollments ADD CONSTRAINT chk_grade CHECK (grade BETWEEN -1 AND 100);

-- Step 7: Transaction for Bulk Enrollment (COMMIT / ROLLBACK)

START TRANSACTION;

-- Savepoint for partial rollback if needed
SAVEPOINT before_bulk_enroll;

-- Insert enrollments
INSERT INTO enrollments (student_id, course_id, grade) VALUES (1, 2, 90); -- Alice in Physics
INSERT INTO enrollments (student_id, course_id, grade) VALUES (3, 1, 88); -- Carol in Math

-- Update availability
UPDATE courses SET available_seats = available_seats - 1 WHERE course_id = 2;
UPDATE courses SET available_seats = available_seats - 1 WHERE course_id = 1;

-- Simulate an error (e.g. overbooking)
-- INSERT INTO enrollments (student_id, course_id, grade) VALUES (3, 1, 75); -- Uncomment for testing

-- Commit if all good
COMMIT;

-- If error occurs:
-- ROLLBACK TO before_bulk_enroll;

-- Step 8: Highlight Consistency - Partial Updates
-- Example of consistent transaction:
START TRANSACTION;

-- Update Carol's grade
UPDATE enrollments SET grade = 92 WHERE student_id = 3 AND course_id = 1;

-- Also increase available seats in error (simulate inconsistency)
UPDATE courses SET available_seats = available_seats + 1 WHERE course_id = 1;

-- Consistency rule: rollback if not all updates are correct
ROLLBACK;

-- Otherwise
COMMIT;

-- Step 9: View Final Data
SELECT * FROM students;
SELECT * FROM courses;
SELECT * FROM enrollments;


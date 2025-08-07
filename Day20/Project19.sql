-- Step 1: Create the Database
CREATE DATABASE SchoolSubjectEnrollment;

-- Step 2: Use the Database
USE SchoolSubjectEnrollment;

-- Step 3: Create the 'subject_enrollments' Table
CREATE TABLE subject_enrollments (
    enroll_id INT PRIMARY KEY AUTO_INCREMENT,
    student_name VARCHAR(100),
    subject VARCHAR(50),
    grade INT,
    status VARCHAR(50)
);

-- Step 4: Insert Sample Data
INSERT INTO subject_enrollments (student_name, subject, grade, status)
VALUES
    ('Rahul Verma', 'Math', 85, 'Active'),
    ('Ravi Kumar', 'English', 90, 'Active'),
    ('Priya Sharma', 'Science', 75, 'Inactive'),
    ('Rakesh Mehta', 'Math', 88, 'Active'),
    ('Rani Gupta', 'English', 95, 'Active'),
    ('Rajesh Singh', 'History', 80, 'Inactive'),
    ('Rita Patel', 'Math', 70, 'Active'),
    ('Ravi Shankar', 'English', 65, 'Active');

-- Step 5: Retrieve Students with Grades >= 80 in Math or English
SELECT * FROM subject_enrollments
WHERE (subject IN ('Math', 'English') AND grade >= 80)
ORDER BY grade DESC;

-- Step 6: LIKE Search on Student Name
SELECT * FROM subject_enrollments
WHERE student_name LIKE 'R%';

-- Step 7: Check for NULL Status
SELECT * FROM subject_enrollments
WHERE status IS NULL;

-- Step 8: List All Distinct Subjects
SELECT DISTINCT subject FROM subject_enrollments;

-- Step 9: Sort by Grade in Descending Order
SELECT * FROM subject_enrollments
ORDER BY grade DESC;

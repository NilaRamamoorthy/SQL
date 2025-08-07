-- 1. Create the database
CREATE DATABASE IF NOT EXISTS student_performance;
USE student_performance;

-- Create Table
CREATE TABLE students (
  student_id   INT NOT NULL AUTO_INCREMENT,
  name         VARCHAR(100) NOT NULL,
  grade        DECIMAL(5,2) NOT NULL,
  attendance   DECIMAL(5,2) NOT NULL,
  subject      VARCHAR(100) NOT NULL,
  email        VARCHAR(255),
  PRIMARY KEY (student_id)
);

-- 3. Insert 20 sample student records
INSERT INTO students (name, grade, attendance, subject, email) VALUES
('Alice Anderson',       91.50, 95.00, 'Math',     'alice.anderson@school.edu'),
('Aaron Bailey',         88.00, 92.50, 'Science',  NULL),
('Amelia Carter',        85.75, 98.00, 'Math',     'amelia.carter@university.edu'),
('Adrian Diaz',          79.00, 89.00, 'History',  'adrian.diaz@college.edu'),
('Ava Evans',            93.20, 96.50, 'Science',  'ava.evans@school.edu'),
('Abigail Foster',       82.10, 91.00, 'Math',     'abigail.foster@institute.edu'),
('Benjamin Green',       75.50, 88.00, 'Math',     'ben.green@school.edu'),
('Bianca Harris',        68.00, 85.00, 'Literature','bianca.harris@school.edu'),
('Christopher Ivan',     90.00, 94.00, 'Science',  'chris.ivan@college.edu'),
('Chloe Johnson',        87.25, 93.00, 'Math',     NULL),
('Daniel King',          92.75, 97.00, 'Science',  'daniel.king@university.edu'),
('Diana Lopez',          81.40, 90.50, 'History',  'diana.lopez@school.edu'),
('Ethan Martinez',       77.00, 89.50, 'Science',  'ethan.martinez@college.edu'),
('Emma Nelson',          83.60, 92.00, 'Math',     'emma.nelson@institute.edu'),
('Franklin Owens',       95.00, 98.50, 'Science',  'frank.owens@university.edu'),
('Fiona Patel',          78.20, 87.00, 'Math',     NULL),
('George Quinn',         89.90, 94.50, 'History',  'george.quinn@school.edu'),
('Hannah Roberts',       84.30, 91.50, 'Science',  'hannah.roberts@co-- llege.edu'),
('Isaac Smith',          86.00, 93.20, 'Math',     'isaac.smith@institution.edu'),
('Ivy Thompson',         80.50, 90.00, 'Literature','ivy.thompson@school.edu');
select * from students;

-- Retrieve students with grades above 80 and attendance > 90% 

SELECT name,grade,attendance from students 
where grade>80 AND attendance>90;

--  Show only names and grades.
SELECT name,grade from students;

-- Use DISTINCT to list all subjects offered.
select DISTINCT subject from students;

-- Filter students whose name starts with "A".
SELECT name,grade,subject FROM students where name LIKE 'A%';

-- Use IN for specific subjects (Math, Science).
SELECT name,grade,subject FROM students where subject IN ('Math','Science');

-- Find students with NULL email addresses.
SELECT name,email FROM students where email IS NULL;

-- Sort results by grade DESC, then name ASC.
SELECT name,grade FROM students ORDER BY grade DESC;
SELECT * FROM students ORDER BY name;
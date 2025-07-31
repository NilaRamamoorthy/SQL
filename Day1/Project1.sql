create database school_db;
USE school_db;
CREATE TABLE students (
  student_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100),
  age INT
);


CREATE TABLE teachers (
  teacher_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100),
  subject VARCHAR(100)
);


CREATE TABLE courses (
  course_id INT AUTO_INCREMENT PRIMARY KEY,
  course_name VARCHAR(100),
  teacher_id INT,
  FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id)
);

CREATE TABLE enrollments (
  enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT,
  course_id INT,
  FOREIGN KEY (student_id) REFERENCES students(student_id),
  FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

INSERT INTO students (name, age) VALUES
('Alice', 20), ('Bob', 21), ('Charlie', 22), ('David', 20), ('Eva', 23),
('Fiona', 21), ('George', 22), ('Hannah', 20), ('Ivy', 19), ('Jack', 21);

INSERT INTO teachers (name, subject) VALUES
('Mr. Smith', 'Math'),
('Mrs. Brown', 'English'),
('Dr. Green', 'Physics');

INSERT INTO courses (course_name, teacher_id) VALUES
('Algebra', 1),
('Literature', 2),
('Mechanics', 3);

INSERT INTO enrollments (student_id, course_id) VALUES
(1, 1), (2, 1), (3, 2), (4, 2), (5, 3),
(6, 1), (7, 3), (8, 2), (9, 3), (10, 1);


INSERT INTO students (name, age) VALUES ('Lara', 22);
INSERT INTO enrollments (student_id, course_id) VALUES (11, 2);
UPDATE teachers SET name = 'Mrs. Blue', subject = 'Literature & Writing'
WHERE teacher_id = 2;

SELECT c.course_name, s.name AS student_name
FROM enrollments e
JOIN students s ON s.student_id = e.student_id
JOIN courses c ON c.course_id = e.course_id
ORDER BY c.course_name;

SELECT c.course_name, COUNT(e.student_id) AS student_count
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id;

SELECT s.name AS student_without_enrollment
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
WHERE e.enrollment_id IS NULL;
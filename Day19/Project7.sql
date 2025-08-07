DROP DATABASE IF EXISTS course_portal;
CREATE DATABASE course_portal;
USE course_portal;

CREATE TABLE instructors (
  instructor_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  expertise VARCHAR(100)
);

CREATE TABLE courses (
  course_id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(150) NOT NULL,
  instructor_id INT,
  FOREIGN KEY (instructor_id) REFERENCES instructors(instructor_id)
);

CREATE TABLE students (
  student_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE
);

CREATE TABLE registrations (
  student_id INT,
  course_id INT,
  reg_date DATE NOT NULL,
  PRIMARY KEY (student_id, course_id),
  FOREIGN KEY (student_id) REFERENCES students(student_id),
  FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

INSERT INTO instructors (name, expertise) VALUES
('Dr. Allen', 'Data Science'),
('Ms. Baker', 'Web Development'),
('Mr. Clark', 'AI & ML');

INSERT INTO courses (title, instructor_id) VALUES
('Data Science 101', 1),
('Full Stack Web Dev', 2),
('Intro to Machine Learning', 3),
('Advanced Python', 1),
('Frontend Essentials', 2);

INSERT INTO students (name, email) VALUES
('Alice', 'a1@example.com'),
('Bob', 'b2@example.com'),
('Charlie', 'c3@example.com'),
('Diana', 'd4@example.com'),
('Eve', 'e5@example.com'),
('Frank', 'f6@example.com'),
('Grace', 'g7@example.com'),
('Henry', 'h8@example.com');

INSERT INTO registrations (student_id, course_id, reg_date) VALUES
(1,1,'2025-07-01'),
(2,1,'2025-07-02'),
(2,2,'2025-07-03'),
(3,2,'2025-07-04'),
(4,3,'2025-07-03'),
(5,3,'2025-07-05'),
(6,4,'2025-07-06'),
(7,4,'2025-07-07'),
(8,5,'2025-07-08'),
(1,2,'2025-07-09');

-- Queries:
-- count students per course
SELECT c.title, COUNT(r.student_id) AS student_count
FROM courses c
LEFT JOIN registrations r ON c.course_id = r.course_id
GROUP BY c.course_id;

-- list students not registered for any course
SELECT s.name
FROM students s
LEFT JOIN registrations r ON s.student_id = r.student_id
WHERE r.course_id IS NULL;
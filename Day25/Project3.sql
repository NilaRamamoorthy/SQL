-- Step 1: Create Database and Use It
CREATE DATABASE IF NOT EXISTS UniversityResults;
USE UniversityResults;

-- Step 2: Create normalized tables

CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    student_name VARCHAR(255) NOT NULL
);

CREATE TABLE subjects (
    subject_id INT PRIMARY KEY AUTO_INCREMENT,
    subject_name VARCHAR(255) NOT NULL
);

CREATE TABLE evaluators (
    evaluator_id INT PRIMARY KEY AUTO_INCREMENT,
    evaluator_name VARCHAR(255) NOT NULL
);

CREATE TABLE grades (
    grade_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    subject_id INT NOT NULL,
    marks DECIMAL(5,2) NOT NULL,
    evaluator_id INT NOT NULL,
    locked BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id),
    FOREIGN KEY (evaluator_id) REFERENCES evaluators(evaluator_id)
);

-- Audit log for grade updates
CREATE TABLE grade_audit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    grade_id INT NOT NULL,
    old_marks DECIMAL(5,2),
    new_marks DECIMAL(5,2),
    change_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(255),
    FOREIGN KEY (grade_id) REFERENCES grades(grade_id)
);

-- Step 3: Create view to show subject-wise marks hiding evaluator info
CREATE OR REPLACE VIEW view_student_grades AS
SELECT 
    g.grade_id,
    s.student_id,
    s.student_name,
    sub.subject_id,
    sub.subject_name,
    g.marks
FROM grades g
JOIN students s ON g.student_id = s.student_id
JOIN subjects sub ON g.subject_id = sub.subject_id;

-- Step 4: Stored procedure to update a student’s marks with audit log
DELIMITER //
CREATE PROCEDURE update_grade(
    IN p_grade_id INT,
    IN p_new_marks DECIMAL(5,2),
    IN p_changed_by VARCHAR(255)
)
BEGIN
    DECLARE v_old_marks DECIMAL(5,2);

    -- Check if the grade is locked (raise error if locked)
    IF EXISTS (SELECT 1 FROM grades WHERE grade_id = p_grade_id AND locked = TRUE) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Grade is locked and cannot be updated';
    END IF;

    -- Get current marks
    SELECT marks INTO v_old_marks FROM grades WHERE grade_id = p_grade_id;

    -- Update grade
    UPDATE grades SET marks = p_new_marks WHERE grade_id = p_grade_id;

    -- Insert audit log
    INSERT INTO grade_audit (grade_id, old_marks, new_marks, changed_by)
    VALUES (p_grade_id, v_old_marks, p_new_marks, p_changed_by);
END //
DELIMITER ;

-- Step 5: Function to calculate GPA for a student
DELIMITER //
CREATE FUNCTION calculate_gpa(p_student_id INT) RETURNS DECIMAL(3,2)
DETERMINISTIC
BEGIN
    DECLARE v_gpa DECIMAL(3,2);

    -- Assuming marks out of 100, GPA scale: 90-100=4.0, 80-89=3.0, 70-79=2.0, 60-69=1.0, <60=0
    SELECT
        IFNULL(ROUND(AVG(
            CASE
                WHEN marks >= 90 THEN 4.0
                WHEN marks >= 80 THEN 3.0
                WHEN marks >= 70 THEN 2.0
                WHEN marks >= 60 THEN 1.0
                ELSE 0
            END
        ), 2), 0)
    INTO v_gpa
    FROM grades
    WHERE student_id = p_student_id;

    RETURN v_gpa;
END //
DELIMITER ;

-- Step 6: Trigger before updating grades to prevent update if locked
DELIMITER //
CREATE TRIGGER before_update_grades
BEFORE UPDATE ON grades
FOR EACH ROW
BEGIN
    IF OLD.locked = TRUE THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot update locked grade';
    END IF;
END //
DELIMITER ;

-- Step 7: Abstraction: View for students to see only final marks (hide evaluator info)
CREATE OR REPLACE VIEW view_final_results AS
SELECT 
    s.student_id,
    s.student_name,
    sub.subject_name,
    g.marks
FROM grades g
JOIN students s ON g.student_id = s.student_id
JOIN subjects sub ON g.subject_id = sub.subject_id
WHERE g.locked = TRUE;


-- Sample Data 
INSERT INTO students (student_name) VALUES ('Alice'), ('Bob');
INSERT INTO subjects (subject_name) VALUES ('Mathematics'), ('Physics');
INSERT INTO evaluators (evaluator_name) VALUES ('Dr. Smith'), ('Prof. Jones');

INSERT INTO grades (student_id, subject_id, marks, evaluator_id, locked) VALUES
(1, 1, 95.0, 1, FALSE),
(1, 2, 88.0, 2, TRUE),
(2, 1, 72.5, 1, TRUE),
(2, 2, 60.0, 2, FALSE);


 CALL update_grade(1, 96.0, 'admin_user');


SELECT calculate_gpa(1) AS gpa;

CREATE DATABASE IF NOT EXISTS SchoolDB;
USE SchoolDB;

-- Step 1: Create tables

CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    dob DATE
);

CREATE TABLE subjects (
    subject_id INT PRIMARY KEY AUTO_INCREMENT,
    subject_name VARCHAR(100) NOT NULL,
    -- Initial CHECK on subject_name length (NOT NULL handled above)
    CHECK (subject_name <> '')
);

CREATE TABLE grades (
    grade_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    subject_id INT NOT NULL,
    grade INT NOT NULL CHECK (grade BETWEEN 0 AND 100),
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    UNIQUE (student_id, subject_id)  -- Prevent duplicate grades per subject per student
);

-- Step 2: Insert sample data

INSERT INTO students (name, dob) VALUES
('John Doe', '2005-04-12'),
('Jane Smith', '2006-09-30');

INSERT INTO subjects (subject_name) VALUES
('Mathematics'),
('Physics'),
('Chemistry');

INSERT INTO grades (student_id, subject_id, grade) VALUES
(1, 1, 85),
(1, 2, 90),
(2, 1, 75);

-- Step 3: Update grade when a retest occurs

UPDATE grades
SET grade = 95
WHERE student_id = 1 AND subject_id = 1;

-- Step 4: Delete failing grades on student withdrawal

-- Suppose student 2 withdraws
DELETE FROM students WHERE student_id = 2;
-- CASCADE will remove grades for student 2 automatically

-- Step 5: Modify constraint to expand grade scale (0-150)

-- MySQL doesn't allow direct modification of CHECK constraints easily.
-- So, we drop and recreate the table or use workaround.

-- First, drop the existing CHECK constraint by recreating the table:
-- 1. Rename old table
ALTER TABLE grades RENAME TO grades_old;

-- 2. Create new table with expanded CHECK (0-150)
CREATE TABLE grades (
    grade_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    subject_id INT NOT NULL,
    grade INT NOT NULL CHECK (grade BETWEEN 0 AND 150),
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    UNIQUE (student_id, subject_id)
);

-- 3. Copy data from old table to new (make sure all grades fit new range)
INSERT INTO grades (grade_id, student_id, subject_id, grade)
SELECT grade_id, student_id, subject_id, grade FROM grades_old;

-- 4. Drop old table
DROP TABLE grades_old;

-- Step 6: Use transaction to insert or update grades in batch with rollback

DELIMITER //
CREATE PROCEDURE batch_upsert_grades(
    IN student_ids TEXT,
    IN subject_ids TEXT,
    IN grades_list TEXT
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE i INT DEFAULT 1;
    DECLARE s_count INT;
    DECLARE stu_id INT;
    DECLARE sub_id INT;
    DECLARE grd INT;

    -- Assume input params are comma separated strings, e.g. '1,2,3'
    SET s_count = (LENGTH(student_ids) - LENGTH(REPLACE(student_ids, ',', ''))) + 1;

    START TRANSACTION;

    WHILE i <= s_count DO
        SET stu_id = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(student_ids, ',', i), ',', -1) AS UNSIGNED);
        SET sub_id = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(subject_ids, ',', i), ',', -1) AS UNSIGNED);
        SET grd = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(grades_list, ',', i), ',', -1) AS UNSIGNED);

        -- Validate grade within expanded range
        IF grd < 0 OR grd > 150 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = CONCAT('Invalid grade at position ', i);
        END IF;

        -- Try update first
        IF EXISTS (SELECT 1 FROM grades WHERE student_id = stu_id AND subject_id = sub_id) THEN
            UPDATE grades SET grade = grd WHERE student_id = stu_id AND subject_id = sub_id;
        ELSE
            INSERT INTO grades(student_id, subject_id, grade) VALUES (stu_id, sub_id, grd);
        END IF;

        SET i = i + 1;
    END WHILE;

    COMMIT;
END //
DELIMITER ;

-- Step 7: Sample call to batch_upsert_grades (update and insert in batch)

CALL batch_upsert_grades('1,2', '1,2', '100,120');

-- Check results
SELECT * FROM grades;


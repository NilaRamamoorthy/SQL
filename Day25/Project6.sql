
-- Step 1: Create Database and Use It
CREATE DATABASE IF NOT EXISTS GymAttendanceSystem;
USE GymAttendanceSystem;

-- Step 2: Create Tables (3NF Normalized)

-- Members Table
CREATE TABLE members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    contact_info VARCHAR(100),
    points INT DEFAULT 0
);

-- Trainers Table
CREATE TABLE trainers (
    trainer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Sessions Table
CREATE TABLE sessions (
    session_id INT PRIMARY KEY AUTO_INCREMENT,
    trainer_id INT NOT NULL,
    session_date DATE NOT NULL,
    session_type VARCHAR(50),
    FOREIGN KEY (trainer_id) REFERENCES trainers(trainer_id)
);

-- Attendance Table
CREATE TABLE attendance (
    attendance_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT NOT NULL,
    session_id INT NOT NULL,
    attendance_date DATE NOT NULL,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (session_id) REFERENCES sessions(session_id)
);

-- Step 3: Insert Sample Data

-- Members
INSERT INTO members (name, contact_info) VALUES
('Alice Johnson', 'alice@example.com'),
('Bob Smith', 'bob@example.com'),
('Charlie Lee', 'charlie@example.com');

-- Trainers
INSERT INTO trainers (name) VALUES
('Trainer A'),
('Trainer B');

-- Sessions
INSERT INTO sessions (trainer_id, session_date, session_type) VALUES
(1, '2025-08-01', 'Yoga'),
(2, '2025-08-02', 'Strength Training'),
(1, '2025-08-03', 'Pilates');

-- Step 4: Views

-- View for Trainers (Hide contact info)
CREATE OR REPLACE VIEW view_attendance_summary AS
SELECT
    a.attendance_id,
    m.member_id,
    m.name AS member_name,
    s.session_id,
    s.session_date,
    s.session_type
FROM attendance a
JOIN members m ON a.member_id = m.member_id
JOIN sessions s ON a.session_id = s.session_id;

-- Public view showing only active members with points
CREATE OR REPLACE VIEW view_active_members AS
SELECT
    member_id,
    name,
    points
FROM members
WHERE points > 0;

-- Step 5: Stored Procedure to Log Attendance
DELIMITER //
CREATE PROCEDURE log_attendance(IN p_member_id INT, IN p_session_id INT)
BEGIN
    INSERT INTO attendance (member_id, session_id)
    VALUES (p_member_id, p_session_id);
END //
DELIMITER ;

-- Step 6: Function to Get Monthly Visits for a Member
DELIMITER //
CREATE FUNCTION get_monthly_visits(p_member_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE visit_count INT;
    SELECT COUNT(*) INTO visit_count
    FROM attendance
    WHERE member_id = p_member_id
      AND MONTH(attendance_date) = MONTH(CURDATE())
      AND YEAR(attendance_date) = YEAR(CURDATE());
    RETURN visit_count;
END //
DELIMITER ;

-- Step 7: Trigger to Add Points on Attendance
DELIMITER //
CREATE TRIGGER after_attendance
AFTER INSERT ON attendance
FOR EACH ROW
BEGIN
    UPDATE members
    SET points = points + 10
    WHERE member_id = NEW.member_id;
END //
DELIMITER ;

-- Step 8: Sample Usage

-- Log attendance for Alice (member_id = 1) in Yoga session (session_id = 1)
CALL log_attendance(1, 1);

-- Log attendance for Bob (member_id = 2) in Strength Training session (session_id = 2)
CALL log_attendance(2, 2);

-- Log attendance for Alice again in Pilates (session_id = 3)
CALL log_attendance(1, 3);

-- Query: View Attendance Summary (trainer view)
SELECT * FROM view_attendance_summary;

-- Query: View Active Members (public dashboard)
SELECT * FROM view_active_members;

-- Query: Get Monthly Visits for Alice
SELECT get_monthly_visits(1) AS alice_visits;

-- Query: Check Points for Members
SELECT member_id, name, points FROM members;


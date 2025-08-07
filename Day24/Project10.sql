-- Step 1: Create Database and Use It
CREATE DATABASE GymManagement;
USE GymManagement;

-- Step 2: Normalized Tables (3NF)

-- Plans (membership plans)
CREATE TABLE plans (
    plan_id INT PRIMARY KEY AUTO_INCREMENT,
    plan_name VARCHAR(100) NOT NULL UNIQUE,
    price DECIMAL(10,2) NOT NULL,
    duration_months INT NOT NULL
);

-- Trainers
CREATE TABLE trainers (
    trainer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    specialty VARCHAR(100)
);

-- Members
CREATE TABLE members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    join_date DATE NOT NULL,
    plan_id INT NOT NULL,
    FOREIGN KEY (plan_id) REFERENCES plans(plan_id)
);

-- Sessions (attendance logs)
CREATE TABLE sessions (
    session_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT NOT NULL,
    trainer_id INT NOT NULL,
    session_date DATE NOT NULL,
    session_type VARCHAR(100),
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (trainer_id) REFERENCES trainers(trainer_id)
);

-- Payments
CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);



-- Insert Sample Data


-- Plans
INSERT INTO plans (plan_name, price, duration_months) VALUES
('Basic', 30.00, 1),
('Standard', 80.00, 3),
('Premium', 150.00, 6);

-- Trainers
INSERT INTO trainers (name, specialty) VALUES
('Alice Johnson', 'Strength Training'),
('Bob Smith', 'Yoga'),
('Carol White', 'Cardio'),
('David Lee', 'Pilates');

-- Members
INSERT INTO members (name, join_date, plan_id) VALUES
('John Doe', '2023-01-10', 1),
('Jane Roe', '2023-02-15', 2),
('Mike Miles', '2023-03-01', 3),
('Anna Bell', '2023-01-20', 1),
('Evan Scott', '2023-04-10', 2),
('Laura King', '2023-05-05', 3);

-- Sessions (member_id, trainer_id, session_date, session_type)
INSERT INTO sessions (member_id, trainer_id, session_date, session_type) VALUES
(1, 1, '2023-07-01', 'Strength'),
(1, 1, '2023-07-05', 'Strength'),
(2, 2, '2023-07-02', 'Yoga'),
(3, 3, '2023-07-03', 'Cardio'),
(3, 3, '2023-07-10', 'Cardio'),
(3, 1, '2023-07-15', 'Strength'),
(4, 4, '2023-07-08', 'Pilates'),
(5, 2, '2023-07-09', 'Yoga'),
(6, 1, '2023-07-10', 'Strength'),
(6, 1, '2023-07-12', 'Strength'),
(6, 3, '2023-07-15', 'Cardio');

-- Payments
INSERT INTO payments (member_id, payment_date, amount) VALUES
(1, '2023-01-10', 30.00),
(2, '2023-02-15', 80.00),
(3, '2023-03-01', 150.00),
(4, '2023-01-20', 30.00),
(5, '2023-04-10', 80.00),
(6, '2023-05-05', 150.00);

-- Step 3: Indexes for performance
CREATE INDEX idx_sessions_date ON sessions(session_date);
CREATE INDEX idx_sessions_member ON sessions(member_id);
CREATE INDEX idx_sessions_trainer ON sessions(trainer_id);

-- Step 4: EXPLAIN example to analyze trainer performance reports
EXPLAIN
SELECT t.trainer_id, t.name, COUNT(s.session_id) AS sessions_conducted
FROM trainers t
LEFT JOIN sessions s ON t.trainer_id = s.trainer_id
WHERE s.session_date BETWEEN '2023-07-01' AND '2023-07-31'
GROUP BY t.trainer_id, t.name
ORDER BY sessions_conducted DESC;

-- Step 5: Subquery to identify members with highest attendance
SELECT m.member_id, m.name, COUNT(s.session_id) AS attendance_count
FROM members m
JOIN sessions s ON m.member_id = s.member_id
GROUP BY m.member_id, m.name
HAVING attendance_count = (
    SELECT MAX(att_count) FROM (
        SELECT member_id, COUNT(session_id) AS att_count
        FROM sessions
        GROUP BY member_id
    ) AS sub
);

-- Step 6: Denormalized trainer-wise session summary
CREATE TABLE trainer_session_summary AS
SELECT
    t.trainer_id,
    t.name AS trainer_name,
    COUNT(s.session_id) AS total_sessions,
    COUNT(DISTINCT s.member_id) AS unique_members
FROM trainers t
LEFT JOIN sessions s ON t.trainer_id = s.trainer_id
GROUP BY t.trainer_id, t.name;

-- Step 7: Top 5 most consistent members by session count (LIMIT)
SELECT m.member_id, m.name, COUNT(s.session_id) AS session_count
FROM members m
JOIN sessions s ON m.member_id = s.member_id
GROUP BY m.member_id, m.name
ORDER BY session_count DESC
LIMIT 5;

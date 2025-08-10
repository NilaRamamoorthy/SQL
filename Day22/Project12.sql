-- 1. Create Database and Use
CREATE DATABASE IF NOT EXISTS gym_tracker;
USE gym_tracker;

-- 2. Create Tables

CREATE TABLE members (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    fitness_goal VARCHAR(255),
    membership_expiry DATE
);

CREATE TABLE trainers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255)
);

CREATE TABLE sessions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT,
    trainer_id INT,
    session_date DATE,
    completed_goal BOOLEAN,
    FOREIGN KEY (member_id) REFERENCES members(id),
    FOREIGN KEY (trainer_id) REFERENCES trainers(id)
);

CREATE TABLE payments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT,
    amount DECIMAL(10,2),
    payment_date DATE,
    FOREIGN KEY (member_id) REFERENCES members(id)
);

-- 3. Insert Sample Data

INSERT INTO members (name, fitness_goal, membership_expiry) VALUES
('Alice', 'Weight Loss', DATE_ADD(CURDATE(), INTERVAL 10 DAY)),
('Bob', 'Muscle Gain', DATE_SUB(CURDATE(), INTERVAL 5 DAY)),
('Charlie', 'Endurance', DATE_ADD(CURDATE(), INTERVAL 20 DAY)),
('David', 'Flexibility', DATE_SUB(CURDATE(), INTERVAL 1 MONTH));

INSERT INTO trainers (name) VALUES
('Trainer Mike'),
('Trainer Anna');

INSERT INTO sessions (member_id, trainer_id, session_date, completed_goal) VALUES
(1, 1, CURDATE() - INTERVAL 15 DAY, TRUE),
(1, 1, CURDATE() - INTERVAL 7 DAY, TRUE),
(2, 2, CURDATE() - INTERVAL 10 DAY, FALSE),
(3, 1, CURDATE() - INTERVAL 3 DAY, TRUE),
(3, 2, CURDATE() - INTERVAL 1 DAY, TRUE),
(4, 2, CURDATE() - INTERVAL 20 DAY, FALSE);

INSERT INTO payments (member_id, amount, payment_date) VALUES
(1, 100.00, CURDATE() - INTERVAL 30 DAY),
(2, 80.00, CURDATE() - INTERVAL 40 DAY),
(3, 120.00, CURDATE() - INTERVAL 10 DAY),
(4, 90.00, CURDATE() - INTERVAL 60 DAY);

-- 4a. Subquery to calculate average sessions per member

SELECT 
    AVG(session_count) AS avg_sessions_per_member
FROM (
    SELECT member_id, COUNT(*) AS session_count
    FROM sessions
    GROUP BY member_id
) AS session_counts;

-- 4b. CASE to bucket members by fitness goal completion (percentage of sessions with completed_goal = TRUE)

SELECT 
    m.id,
    m.name,
    COUNT(s.id) AS total_sessions,
    SUM(CASE WHEN s.completed_goal THEN 1 ELSE 0 END) AS completed_sessions,
    ROUND(100.0 * SUM(CASE WHEN s.completed_goal THEN 1 ELSE 0 END) / COUNT(s.id), 2) AS completion_percent,
    CASE
        WHEN COUNT(s.id) = 0 THEN 'No Sessions'
        WHEN ROUND(100.0 * SUM(CASE WHEN s.completed_goal THEN 1 ELSE 0 END) / COUNT(s.id), 2) >= 75 THEN 'High Completion'
        WHEN ROUND(100.0 * SUM(CASE WHEN s.completed_goal THEN 1 ELSE 0 END) / COUNT(s.id), 2) BETWEEN 40 AND 74 THEN 'Medium Completion'
        ELSE 'Low Completion'
    END AS completion_bucket
FROM members m
LEFT JOIN sessions s ON m.id = s.member_id
GROUP BY m.id, m.name;

-- 4c. Correlated subquery to find most active member per trainer (member with max sessions per trainer)

SELECT 
    t.id AS trainer_id,
    t.name AS trainer_name,
    (
        SELECT m.name
        FROM sessions s2
        JOIN members m ON s2.member_id = m.id
        WHERE s2.trainer_id = t.id
        GROUP BY s2.member_id
        ORDER BY COUNT(*) DESC
        LIMIT 1
    ) AS most_active_member
FROM trainers t;

-- 4d. JOIN + GROUP BY to show session count per trainer

SELECT 
    t.id,
    t.name,
    COUNT(s.id) AS session_count
FROM trainers t
LEFT JOIN sessions s ON t.id = s.trainer_id
GROUP BY t.id, t.name;

-- 4e. UNION ALL for expired and active memberships

SELECT 
    id, name, membership_expiry, 'Active' AS membership_status
FROM members
WHERE membership_expiry >= CURDATE()

UNION ALL

SELECT 
    id, name, membership_expiry, 'Expired' AS membership_status
FROM members
WHERE membership_expiry < CURDATE();

-- 4f. Date filter for memberships expiring this month

SELECT 
    id, name, membership_expiry
FROM members
WHERE YEAR(membership_expiry) = YEAR(CURDATE())
AND MONTH(membership_expiry) = MONTH(CURDATE());

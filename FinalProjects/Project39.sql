-- 1. Create Database
CREATE DATABASE fitness_tracker;
USE fitness_tracker;

-- 2. Create Tables

-- Users table
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Workouts table
CREATE TABLE workouts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL -- e.g., Cardio, Strength, Flexibility
);

-- Workout logs table
CREATE TABLE workout_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    workout_id INT NOT NULL,
    duration INT NOT NULL, -- in minutes
    log_date DATE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (workout_id) REFERENCES workouts(id) ON DELETE CASCADE
);

-- 3. Insert Sample Data

-- Users
INSERT INTO users (name) VALUES
('Alice Smith'),
('Bob Johnson'),
('Charlie Lee');

-- Workouts
INSERT INTO workouts (name, type) VALUES
('Running', 'Cardio'),
('Cycling', 'Cardio'),
('Push-ups', 'Strength'),
('Yoga', 'Flexibility');

-- Workout Logs
INSERT INTO workout_logs (user_id, workout_id, duration, log_date) VALUES
(1, 1, 30, '2025-08-04'),
(1, 3, 15, '2025-08-05'),
(2, 2, 45, '2025-08-05'),
(2, 4, 20, '2025-08-06'),
(3, 1, 25, '2025-08-06'),
(1, 2, 40, '2025-08-07'),
(3, 3, 30, '2025-08-07'),
(2, 1, 35, '2025-08-08');

-- 4. Query: Weekly summary per user
SELECT 
    u.name AS user_name,
    YEARWEEK(wl.log_date, 1) AS week_number,
    SUM(wl.duration) AS total_minutes
FROM workout_logs wl
JOIN users u ON wl.user_id = u.id
GROUP BY u.id, YEARWEEK(wl.log_date, 1)
ORDER BY u.name, week_number;

-- 5. Query: Workouts with type for each log
SELECT 
    wl.id AS log_id,
    u.name AS user_name,
    w.name AS workout_name,
    w.type AS workout_type,
    wl.duration,
    wl.log_date
FROM workout_logs wl
JOIN users u ON wl.user_id = u.id
JOIN workouts w ON wl.workout_id = w.id
ORDER BY wl.log_date DESC;

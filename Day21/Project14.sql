-- 1. Create Database
CREATE DATABASE fitness_tracker;
USE fitness_tracker;

-- 2. Create Tables

CREATE TABLE trainers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    trainer_id INT,
    goal VARCHAR(255),  -- user fitness goal description
    FOREIGN KEY (trainer_id) REFERENCES trainers(id)
);

CREATE TABLE workouts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    workout_date DATE NOT NULL,
    calories_burned INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE goals (
    id INT PRIMARY KEY AUTO_INCREMENT,
    goal_description VARCHAR(255) NOT NULL
);

-- 3. Insert Sample Data

INSERT INTO trainers (name) VALUES
('John Smith'),
('Emily Davis');

INSERT INTO users (name, trainer_id, goal) VALUES
('Alice', 1, 'Lose weight'),
('Bob', NULL, 'Build muscle'),
('Charlie', 1, 'Build muscle'),
('Diana', 2, 'Improve stamina'),
('Eve', NULL, 'Lose weight');

INSERT INTO workouts (user_id, workout_date, calories_burned) VALUES
(1, '2025-07-01', 300),
(1, '2025-07-03', 350),
(1, '2025-07-05', 400),
(2, '2025-07-02', 500),
(2, '2025-07-04', 450),
(2, '2025-07-06', 520),
(3, '2025-07-01', 480),
(3, '2025-07-03', 470),
(3, '2025-07-07', 500),
(4, '2025-07-02', 600),
(4, '2025-07-05', 620),
(5, '2025-07-01', 320),
(5, '2025-07-03', 330);

-- Add more workouts for user 1 to exceed 10 sessions
INSERT INTO workouts (user_id, workout_date, calories_burned) VALUES
(1, '2025-07-07', 370),
(1, '2025-07-09', 390),
(1, '2025-07-11', 410),
(1, '2025-07-13', 430),
(1, '2025-07-15', 420),
(1, '2025-07-17', 440),
(1, '2025-07-19', 450),
(1, '2025-07-21', 460);

-- 4. Queries

-- a) Average calories burned per workout
SELECT
    ROUND(AVG(calories_burned), 2) AS avg_calories_burned
FROM workouts;

-- b) Users with more than 10 workout sessions
SELECT
    u.id,
    u.name,
    COUNT(w.id) AS session_count
FROM users u
JOIN workouts w ON u.id = w.user_id
GROUP BY u.id, u.name
HAVING session_count > 10;

-- c) INNER JOIN users and workouts (show user workout details)
SELECT
    u.id AS user_id,
    u.name,
    w.workout_date,
    w.calories_burned
FROM users u
JOIN workouts w ON u.id = w.user_id
ORDER BY u.id, w.workout_date;

-- d) LEFT JOIN trainers and users (list users with their trainers, including those without a trainer)
SELECT
    u.id AS user_id,
    u.name AS user_name,
    t.name AS trainer_name
FROM users u
LEFT JOIN trainers t ON u.trainer_id = t.id
ORDER BY u.id;

-- e) SELF JOIN to group users with similar goals
SELECT
    u1.id AS user1_id,
    u1.name AS user1_name,
    u2.id AS user2_id,
    u2.name AS user2_name,
    u1.goal
FROM users u1
JOIN users u2 ON u1.goal = u2.goal AND u1.id < u2.id
ORDER BY u1.goal, u1.id, u2.id;

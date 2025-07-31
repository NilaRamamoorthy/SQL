-- Create and use the database
DROP DATABASE IF EXISTS gym_db;
CREATE DATABASE gym_db;
USE gym_db;

-- Create plans table
CREATE TABLE plans (
    plan_id INT AUTO_INCREMENT PRIMARY KEY,
    plan_name VARCHAR(100) NOT NULL,
    duration_months INT NOT NULL,
    price DECIMAL(10,2) NOT NULL
);

-- Create trainers table
CREATE TABLE trainers (
    trainer_id INT AUTO_INCREMENT PRIMARY KEY,
    trainer_name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100)
);

-- Create members table
CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    member_name VARCHAR(100) NOT NULL,
    join_date DATE NOT NULL
);

-- Create subscriptions table
CREATE TABLE subscriptions (
    subscription_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT,
    plan_id INT,
    trainer_id INT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (plan_id) REFERENCES plans(plan_id),
    FOREIGN KEY (trainer_id) REFERENCES trainers(trainer_id)
);

-- Insert plans
INSERT INTO plans (plan_name, duration_months, price) VALUES
('Basic', 1, 50.00),
('Standard', 3, 135.00),
('Premium', 6, 240.00),
('Gold', 12, 450.00),
('Student', 3, 100.00);

-- Insert trainers
INSERT INTO trainers (trainer_name, specialization) VALUES
('John Smith', 'Weight Training'),
('Emily Davis', 'Cardio & HIIT'),
('Mark Lee', 'Yoga & Flexibility');

-- Insert members
INSERT INTO members (member_name, join_date) VALUES
('Alice', '2025-07-01'),
('Bob', '2025-07-02'),
('Charlie', '2025-07-03'),
('Diana', '2025-07-04'),
('Eve', '2025-07-05'),
('Frank', '2025-07-06'),
('Grace', '2025-07-07'),
('Henry', '2025-07-08'),
('Ivy', '2025-07-09'),
('Jack', '2025-07-10');

-- Insert subscriptions
INSERT INTO subscriptions (member_id, plan_id, trainer_id, start_date, end_date) VALUES
(1, 1, 1, '2025-07-01', '2025-07-31'),
(2, 2, 2, '2025-07-02', '2025-10-01'),
(3, 3, 3, '2025-07-03', '2026-01-02'),
(4, 1, 2, '2025-07-04', '2025-08-03'),
(5, 4, 1, '2025-07-05', '2026-07-04'),
(6, 5, 3, '2025-07-06', '2025-10-05'),
(7, 2, 2, '2025-07-07', '2025-10-06'),
(8, 1, 1, '2025-07-08', '2025-08-07'),
(9, 3, 2, '2025-07-09', '2026-01-08'),
(10, 4, 3, '2025-07-10', '2026-07-09');

-- Update a member’s plan (e.g., upgrade member_id 1 to plan_id 4 - Gold)
UPDATE subscriptions
SET plan_id = 4
WHERE member_id = 1;

-- Delete expired subscriptions (assume today is '2025-07-29')
DELETE FROM subscriptions
WHERE end_date < '2025-07-29';

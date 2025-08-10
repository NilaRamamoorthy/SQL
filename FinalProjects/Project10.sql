-- 1. Create Database
CREATE DATABASE project_management_tracker;
USE project_management_tracker;

-- 2. Create Tables

-- Projects table
CREATE TABLE projects (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Tasks table
CREATE TABLE tasks (
    id INT PRIMARY KEY AUTO_INCREMENT,
    project_id INT,
    name VARCHAR(100) NOT NULL,
    status ENUM('Pending', 'In Progress', 'Completed') DEFAULT 'Pending',
    FOREIGN KEY (project_id) REFERENCES projects(id)
);

-- Task assignments table
CREATE TABLE task_assignments (
    task_id INT,
    user_id INT,
    PRIMARY KEY (task_id, user_id),
    FOREIGN KEY (task_id) REFERENCES tasks(id),
    FOREIGN KEY (user_id) REFERENCES users(id)  -- This assumes 'users' table exists
);

-- If you don't already have a users table from other modules, create it here
CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- 3. Insert Sample Data

-- Users
INSERT INTO users (name) VALUES
('Alice'),
('Bob'),
('Charlie');

-- Projects
INSERT INTO projects (name) VALUES
('Website Redesign'),
('Mobile App Development');

-- Tasks
INSERT INTO tasks (project_id, name, status) VALUES
(1, 'Design Homepage', 'Completed'),
(1, 'Develop Backend', 'In Progress'),
(1, 'Test Website', 'Pending'),
(2, 'Design App UI', 'In Progress'),
(2, 'Integrate API', 'Pending');

-- Task Assignments
INSERT INTO task_assignments (task_id, user_id) VALUES
(1, 1), -- Alice on Design Homepage
(2, 2), -- Bob on Backend
(3, 3), -- Charlie on Testing
(4, 1), -- Alice on App UI
(5, 2); -- Bob on API Integration

-- 4. JOIN: Get all tasks with project and assigned users
SELECT 
    p.name AS project_name,
    t.name AS task_name,
    t.status,
    u.name AS assigned_user
FROM tasks t
JOIN projects p ON t.project_id = p.id
JOIN task_assignments ta ON t.id = ta.task_id
JOIN users u ON ta.user_id = u.id
ORDER BY p.name, t.name;

-- 5. Status Tracking: Count tasks by status per project
SELECT 
    p.name AS project_name,
    t.status,
    COUNT(*) AS task_count
FROM tasks t
JOIN projects p ON t.project_id = p.id
GROUP BY p.name, t.status
ORDER BY p.name;

-- 6. User-Task Associations: All tasks assigned to each user
SELECT 
    u.name AS user_name,
    p.name AS project_name,
    t.name AS task_name,
    t.status
FROM users u
JOIN task_assignments ta ON u.id = ta.user_id
JOIN tasks t ON ta.task_id = t.id
JOIN projects p ON t.project_id = p.id
ORDER BY u.name, project_name;

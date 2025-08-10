-- 1. Create Database
CREATE DATABASE job_scheduling_system;
USE job_scheduling_system;

-- 2. Create Tables

-- Jobs table
CREATE TABLE jobs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    frequency VARCHAR(50) NOT NULL -- e.g., 'daily', 'hourly', 'weekly'
);

-- Job logs table
CREATE TABLE job_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    job_id INT NOT NULL,
    run_time DATETIME NOT NULL,
    status ENUM('success', 'failed', 'running') NOT NULL,
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE
);

-- 3. Insert Sample Data

INSERT INTO jobs (name, frequency) VALUES
('Data Backup', 'daily'),
('Email Notifications', 'hourly'),
('Report Generation', 'weekly');

INSERT INTO job_logs (job_id, run_time, status) VALUES
(1, '2025-08-10 02:00:00', 'success'),
(1, '2025-08-09 02:00:00', 'success'),
(2, '2025-08-11 09:00:00', 'failed'),
(2, '2025-08-11 08:00:00', 'success'),
(3, '2025-08-08 06:00:00', 'success');

-- 4. Query: Last run time for each job
SELECT 
    j.id AS job_id,
    j.name,
    MAX(l.run_time) AS last_run
FROM jobs j
LEFT JOIN job_logs l ON j.id = l.job_id
GROUP BY j.id, j.name;

-- 5. Query: Status count by job
SELECT 
    j.id AS job_id,
    j.name,
    l.status,
    COUNT(*) AS status_count
FROM jobs j
JOIN job_logs l ON j.id = l.job_id
GROUP BY j.id, j.name, l.status;

-- 6. Query: Next run estimation (simple logic based on frequency)
SELECT 
    j.id,
    j.name,
    CASE 
        WHEN j.frequency = 'daily' THEN DATE_ADD(MAX(l.run_time), INTERVAL 1 DAY)
        WHEN j.frequency = 'hourly' THEN DATE_ADD(MAX(l.run_time), INTERVAL 1 HOUR)
        WHEN j.frequency = 'weekly' THEN DATE_ADD(MAX(l.run_time), INTERVAL 7 DAY)
    END AS next_run
FROM jobs j
LEFT JOIN job_logs l ON j.id = l.job_id
GROUP BY j.id, j.name, j.frequency;

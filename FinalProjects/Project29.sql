-- 1. Create Database
CREATE DATABASE recruitment_portal;
USE recruitment_portal;

-- 2. Create Tables

-- Jobs Table
CREATE TABLE jobs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(150) NOT NULL,
    company VARCHAR(100) NOT NULL
);

-- Candidates Table
CREATE TABLE candidates (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Applications Table
CREATE TABLE applications (
    job_id INT NOT NULL,
    candidate_id INT NOT NULL,
    status ENUM('Applied', 'Interview Scheduled', 'Rejected', 'Hired') NOT NULL DEFAULT 'Applied',
    applied_at DATETIME NOT NULL,
    PRIMARY KEY (job_id, candidate_id),
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
    FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE
);

-- 3. Insert Sample Data

-- Jobs
INSERT INTO jobs (title, company) VALUES
('Software Engineer', 'TechCorp'),
('Data Analyst', 'DataWorks'),
('Project Manager', 'BuildIt');

-- Candidates
INSERT INTO candidates (name) VALUES
('Alice Johnson'),
('Bob Smith'),
('Charlie Davis'),
('Diana Prince');

-- Applications
INSERT INTO applications (job_id, candidate_id, status, applied_at) VALUES
(1, 1, 'Applied', '2025-08-01 09:00:00'),
(1, 2, 'Interview Scheduled', '2025-08-02 10:00:00'),
(1, 3, 'Rejected', '2025-08-03 11:00:00'),
(2, 1, 'Hired', '2025-08-04 12:00:00'),
(2, 4, 'Applied', '2025-08-05 13:00:00'),
(3, 2, 'Applied', '2025-08-06 14:00:00');

-- 4. Query: Filter candidates by status (Example: 'Applied')
SELECT 
    c.name AS candidate_name,
    j.title AS job_title,
    j.company
FROM applications a
JOIN candidates c ON a.candidate_id = c.id
JOIN jobs j ON a.job_id = j.id
WHERE a.status = 'Applied';

-- 5. Query: Count applicants per job
SELECT 
    j.title AS job_title,
    j.company,
    COUNT(a.candidate_id) AS total_applicants
FROM jobs j
LEFT JOIN applications a ON j.id = a.job_id
GROUP BY j.id;

-- 6. Query: List all applications with candidate and job details
SELECT 
    c.name AS candidate_name,
    j.title AS job_title,
    j.company,
    a.status,
    a.applied_at
FROM applications a
JOIN candidates c ON a.candidate_id = c.id
JOIN jobs j ON a.job_id = j.id
ORDER BY a.applied_at DESC;

-- 7. Query: Applicants for a specific job (Example: Data Analyst)
SELECT 
    c.name AS candidate_name,
    a.status
FROM applications a
JOIN candidates c ON a.candidate_id = c.id
JOIN jobs j ON a.job_id = j.id
WHERE j.title = 'Data Analyst';

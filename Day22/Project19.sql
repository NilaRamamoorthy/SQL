-- 1. Create Database and Use
CREATE DATABASE IF NOT EXISTS job_portal;
USE job_portal;

-- 2. Create Tables

CREATE TABLE companies (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255)
);

CREATE TABLE jobs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT,
    title VARCHAR(255),
    role_type ENUM('Full-Time', 'Internship'),
    posted_date DATE,
    FOREIGN KEY (company_id) REFERENCES companies(id)
);

CREATE TABLE applicants (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    email VARCHAR(255)
);

CREATE TABLE applications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    job_id INT,
    applicant_id INT,
    application_date DATE,
    status ENUM('Shortlisted', 'Rejected', 'In Review') DEFAULT 'In Review',
    FOREIGN KEY (job_id) REFERENCES jobs(id),
    FOREIGN KEY (applicant_id) REFERENCES applicants(id)
);

-- 3. Insert Sample Data

INSERT INTO companies (name) VALUES
('TechCorp'),
('InnovateLLC'),
('StartUp Inc.');

INSERT INTO jobs (company_id, title, role_type, posted_date) VALUES
(1, 'Software Engineer', 'Full-Time', '2025-06-01'),
(1, 'Data Analyst Intern', 'Internship', '2025-07-10'),
(2, 'Product Manager', 'Full-Time', '2025-06-15'),
(3, 'Marketing Intern', 'Internship', '2025-07-05');

INSERT INTO applicants (name, email) VALUES
('Alice Johnson', 'alice@example.com'),
('Bob Smith', 'bob@example.com'),
('Carol White', 'carol@example.com'),
('David Brown', 'david@example.com');

INSERT INTO applications (job_id, applicant_id, application_date, status) VALUES
(1, 1, '2025-07-01', 'Shortlisted'),
(2, 1, '2025-07-05', 'In Review'),
(3, 1, '2025-07-10', 'Rejected'),
(4, 2, '2025-07-15', 'In Review'),
(1, 3, '2025-07-02', 'Shortlisted'),
(3, 3, '2025-07-08', 'In Review'),
(1, 4, '2025-07-12', 'Rejected'),
(2, 4, '2025-07-13', 'In Review'),
(4, 4, '2025-07-14', 'Shortlisted');

-- 4. Subquery: Jobs applied by applicants with more than 3 applications

SELECT
    a.id AS applicant_id,
    a.name AS applicant_name,
    j.id AS job_id,
    j.title AS job_title,
    ap.application_date
FROM applicants a
JOIN applications ap ON a.id = ap.applicant_id
JOIN jobs j ON ap.job_id = j.id
WHERE a.id IN (
    SELECT applicant_id
    FROM applications
    GROUP BY applicant_id
    HAVING COUNT(*) > 3
);

-- 5. CASE: Mark application status with readable labels (already ENUM, but showing example with CASE)

SELECT
    ap.id,
    a.name AS applicant_name,
    j.title AS job_title,
    CASE ap.status
        WHEN 'Shortlisted' THEN 'Shortlisted'
        WHEN 'Rejected' THEN 'Rejected'
        WHEN 'In Review' THEN 'In Review'
        ELSE 'Unknown'
    END AS application_status
FROM applications ap
JOIN applicants a ON ap.applicant_id = a.id
JOIN jobs j ON ap.job_id = j.id;

-- 6. JOIN + GROUP BY: Calculate applications per job

SELECT 
    j.id AS job_id,
    j.title,
    COUNT(ap.id) AS application_count
FROM jobs j
LEFT JOIN applications ap ON j.id = ap.job_id
GROUP BY j.id, j.title;

-- 7. UNION: Combine full-time and internship roles (list job titles by role type)

SELECT title, 'Full-Time' AS role_type FROM jobs WHERE role_type = 'Full-Time'
UNION
SELECT title, 'Internship' AS role_type FROM jobs WHERE role_type = 'Internship';

-- 8. Correlated Subquery: Find most applied job per applicant

SELECT 
    a.id AS applicant_id,
    a.name AS applicant_name,
    (
        SELECT j.title
        FROM applications ap
        JOIN jobs j ON ap.job_id = j.id
        WHERE ap.applicant_id = a.id
        GROUP BY ap.job_id
        ORDER BY COUNT(*) DESC
        LIMIT 1
    ) AS most_applied_job
FROM applicants a;

-- 9. Date Filter: Recent applications in last 30 days

SELECT 
    ap.id,
    a.name AS applicant_name,
    j.title AS job_title,
    ap.application_date
FROM applications ap
JOIN applicants a ON ap.applicant_id = a.id
JOIN jobs j ON ap.job_id = j.id
WHERE ap.application_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);

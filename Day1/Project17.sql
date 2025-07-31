-- Drop and create database
DROP DATABASE IF EXISTS job_portal_db;
CREATE DATABASE job_portal_db;
USE job_portal_db;

-- Create tables

CREATE TABLE companies (
    company_id INT AUTO_INCREMENT PRIMARY KEY,
    company_name VARCHAR(150) NOT NULL UNIQUE,
    location VARCHAR(100)
);

CREATE TABLE jobs (
    job_id INT AUTO_INCREMENT PRIMARY KEY,
    company_id INT NOT NULL,
    job_title VARCHAR(150) NOT NULL,
    job_description TEXT,
    location VARCHAR(100),
    salary DECIMAL(10,2),
    FOREIGN KEY (company_id) REFERENCES companies(company_id)
);

CREATE TABLE applicants (
    applicant_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20)
);

CREATE TABLE applications (
    application_id INT AUTO_INCREMENT PRIMARY KEY,
    job_id INT NOT NULL,
    applicant_id INT NOT NULL,
    application_date DATE NOT NULL,
    status VARCHAR(50) DEFAULT 'Pending',
    FOREIGN KEY (job_id) REFERENCES jobs(job_id),
    FOREIGN KEY (applicant_id) REFERENCES applicants(applicant_id)
);

-- Insert sample data

INSERT INTO companies (company_name, location) VALUES
('Tech Innovators', 'New York'),
('Health Corp', 'Chicago'),
('Finance Solutions', 'San Francisco'),
('EduLearn', 'Boston'),
('Retail Group', 'Seattle');

INSERT INTO jobs (company_id, job_title, job_description, location, salary) VALUES
(1, 'Software Engineer', 'Develop and maintain software solutions.', 'New York', 90000),
(1, 'Data Analyst', 'Analyze and interpret complex data.', 'New York', 70000),
(2, 'Nurse', 'Provide patient care and support.', 'Chicago', 60000),
(2, 'Pharmacist', 'Manage and dispense medications.', 'Chicago', 85000),
(3, 'Accountant', 'Manage financial records.', 'San Francisco', 75000),
(3, 'Financial Advisor', 'Advise clients on financial plans.', 'San Francisco', 80000),
(4, 'Teacher', 'Teach various subjects.', 'Boston', 55000),
(4, 'Curriculum Developer', 'Design educational programs.', 'Boston', 65000),
(5, 'Store Manager', 'Oversee retail store operations.', 'Seattle', 60000),
(5, 'Sales Associate', 'Assist customers and sales.', 'Seattle', 40000);

INSERT INTO applicants (full_name, email, phone) VALUES
('Alice Johnson', 'alice.johnson@example.com', '555-1111'),
('Bob Smith', 'bob.smith@example.com', '555-2222'),
('Carol Lee', 'carol.lee@example.com', '555-3333'),
('David Kim', 'david.kim@example.com', '555-4444'),
('Eva Brown', 'eva.brown@example.com', '555-5555'),
('Frank Wright', 'frank.wright@example.com', '555-6666'),
('Grace Hall', 'grace.hall@example.com', '555-7777'),
('Henry Adams', 'henry.adams@example.com', '555-8888'),
('Isabel Clark', 'isabel.clark@example.com', '555-9999'),
('Jack Turner', 'jack.turner@example.com', '555-0000'),
('Karen Scott', 'karen.scott@example.com', '555-1010'),
('Leo Martin', 'leo.martin@example.com', '555-2020'),
('Mia Walker', 'mia.walker@example.com', '555-3030'),
('Nathan Young', 'nathan.young@example.com', '555-4040'),
('Olivia King', 'olivia.king@example.com', '555-5050');

INSERT INTO applications (job_id, applicant_id, application_date, status) VALUES
(1, 1, '2025-07-01', 'Pending'),
(2, 2, '2025-07-02', 'Reviewed'),
(3, 3, '2025-07-03', 'Pending'),
(4, 4, '2025-07-04', 'Interview Scheduled'),
(5, 5, '2025-07-05', 'Rejected'),
(6, 6, '2025-07-06', 'Pending'),
(7, 7, '2025-07-07', 'Pending'),
(8, 8, '2025-07-08', 'Reviewed'),
(9, 9, '2025-07-09', 'Pending'),
(10, 10, '2025-07-10', 'Pending'),
(1, 11, '2025-07-11', 'Pending'),
(2, 12, '2025-07-12', 'Pending'),
(3, 13, '2025-07-13', 'Interview Scheduled'),
(4, 14, '2025-07-14', 'Pending'),
(5, 15, '2025-07-15', 'Pending');

-- Queries

-- Find all jobs a specific user (applicant_id = ?) has applied for (example applicant_id = 1)
SELECT j.job_id, j.job_title, j.location, j.salary, c.company_name, a.application_date, a.status
FROM applications a
JOIN jobs j ON a.job_id = j.job_id
JOIN companies c ON j.company_id = c.company_id
WHERE a.applicant_id = 1;

-- Count applications per company
SELECT c.company_name, COUNT(a.application_id) AS total_applications
FROM companies c
JOIN jobs j ON c.company_id = j.company_id
JOIN applications a ON j.job_id = a.job_id
GROUP BY c.company_id;


CREATE DATABASE IF NOT EXISTS JobPortalDB;
USE JobPortalDB;

-- Step 1: Create tables

CREATE TABLE recruiters (
    recruiter_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE jobs (
    job_id INT PRIMARY KEY AUTO_INCREMENT,
    recruiter_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    deadline DATE NOT NULL,
    experience_required INT NOT NULL,
    CHECK (experience_required >= 0),
    FOREIGN KEY (recruiter_id) REFERENCES recruiters(recruiter_id) ON DELETE CASCADE
);

CREATE TABLE applicants (
    applicant_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    experience INT NOT NULL,
    CHECK (experience >= 0)
);

CREATE TABLE applications (
    application_id INT PRIMARY KEY AUTO_INCREMENT,
    job_id INT NOT NULL,
    applicant_id INT NOT NULL,
    apply_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Applied', 'Interview', 'Rejected', 'Hired') DEFAULT 'Applied',
    UNIQUE KEY unique_app (job_id, applicant_id),
    FOREIGN KEY (job_id) REFERENCES jobs(job_id) ON DELETE CASCADE,
    FOREIGN KEY (applicant_id) REFERENCES applicants(applicant_id) ON DELETE CASCADE
);

-- Step 2: Sample inserts

INSERT INTO recruiters (name, email) VALUES
('Tech Corp', 'hr@techcorp.com'),
('Innovate LLC', 'jobs@innovate.com');

INSERT INTO jobs (recruiter_id, title, description, deadline, experience_required) VALUES
(1, 'Software Engineer', 'Develop software applications', '2025-12-31', 2),
(2, 'Data Analyst', 'Analyze business data', '2025-11-30', 1);

INSERT INTO applicants (name, email, experience) VALUES
('Alice Johnson', 'alice@example.com', 3),
('Bob Smith', 'bob@example.com', 1);

INSERT INTO applications (job_id, applicant_id) VALUES
(1, 1),
(2, 2);

-- Step 3: Update status example

UPDATE applications
SET status = 'Interview'
WHERE application_id = 1;

-- Step 4: Delete applications past deadline

DELETE a FROM applications a
JOIN jobs j ON a.job_id = j.job_id
WHERE j.deadline < CURDATE();

-- Step 5: Drop and recreate CHECK constraint on experience (for example to require minimum experience 1)

-- Drop existing CHECK constraint on applicants (MySQL does not support named constraints easily, so we recreate table)
-- Workaround: recreate table with new CHECK

-- Backup old data
CREATE TABLE applicants_backup LIKE applicants;
INSERT INTO applicants_backup SELECT * FROM applicants;

-- Drop original applicants table
DROP TABLE applicants;

-- Recreate applicants with modified CHECK constraint (experience >= 1)
CREATE TABLE applicants (
    applicant_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    experience INT NOT NULL,
    CHECK (experience >= 1)
);

-- Restore data (filter out invalid rows)
INSERT INTO applicants (applicant_id, name, email, experience)
SELECT applicant_id, name, email, experience FROM applicants_backup WHERE experience >= 1;

DROP TABLE applicants_backup;

-- Step 6: Transaction to post job + notify applicants

DELIMITER //
CREATE PROCEDURE post_job_notify(
    IN p_recruiter_id INT,
    IN p_title VARCHAR(150),
    IN p_description TEXT,
    IN p_deadline DATE,
    IN p_experience_required INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Posting job failed, transaction rolled back';
    END;

    START TRANSACTION;

    -- Insert new job
    INSERT INTO jobs (recruiter_id, title, description, deadline, experience_required)
    VALUES (p_recruiter_id, p_title, p_description, p_deadline, p_experience_required);

    -- Get last inserted job id
    SET @last_job_id = LAST_INSERT_ID();

    -- Notify applicants with sufficient experience (simple insert into a notification table)

    CREATE TEMPORARY TABLE IF NOT EXISTS notifications (
        notification_id INT AUTO_INCREMENT PRIMARY KEY,
        applicant_id INT NOT NULL,
        job_id INT NOT NULL,
        notify_time DATETIME DEFAULT CURRENT_TIMESTAMP
    );

    INSERT INTO notifications (applicant_id, job_id)
    SELECT applicant_id, @last_job_id
    FROM applicants
    WHERE experience >= p_experience_required;

    COMMIT;
END //
DELIMITER ;

-- Step 7: Sample usage of procedure

CALL post_job_notify(1, 'Frontend Developer', 'Develop UI components', '2025-10-31', 2);

-- Step 8: View notifications for demo

SELECT * FROM notifications;


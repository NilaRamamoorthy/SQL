-- 1. Create Database and Use
CREATE DATABASE IF NOT EXISTS hospital_db;
USE hospital_db;

-- 2. Create Tables

CREATE TABLE departments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE doctors (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(id)
);

CREATE TABLE patients (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    dob DATE
);

CREATE TABLE appointments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT,
    doctor_id INT,
    appointment_date DATE,
    visit_type VARCHAR(50),  -- 'Emergency' or 'Routine'
    FOREIGN KEY (patient_id) REFERENCES patients(id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(id)
);

-- 3. Insert Sample Data

INSERT INTO departments (name) VALUES ('Cardiology'), ('Neurology'), ('Orthopedics');

INSERT INTO doctors (name, department_id) VALUES 
('Dr. Smith', 1), ('Dr. Jones', 2), ('Dr. Brown', 3);

INSERT INTO patients (name, dob) VALUES 
('Alice Johnson', '1980-05-12'),
('Bob Lee', '1975-11-30'),
('Charlie Kim', '1990-03-22');

INSERT INTO appointments (patient_id, doctor_id, appointment_date, visit_type) VALUES
(1, 1, '2025-08-01', 'Routine'),
(1, 2, '2025-08-02', 'Emergency'),
(2, 1, '2025-08-03', 'Routine'),
(3, 3, '2025-07-30', 'Routine');

-- 4. LEFT JOIN: Show all patients, even those with no appointments

SELECT
    p.id AS patient_id,
    p.name AS patient_name,
    a.appointment_date,
    a.visit_type
FROM patients p
LEFT JOIN appointments a ON p.id = a.patient_id
ORDER BY p.id, a.appointment_date;

-- 5. Filter appointments in a date range using BETWEEN (e.g., August 1 to August 5, 2025)

SELECT *
FROM appointments
WHERE appointment_date BETWEEN '2025-08-01' AND '2025-08-05';

-- 6. Aggregate visit counts per department

SELECT
    d.name AS department,
    COUNT(a.id) AS total_visits
FROM departments d
LEFT JOIN doctors doc ON d.id = doc.department_id
LEFT JOIN appointments a ON doc.id = a.doctor_id
GROUP BY d.id, d.name;

-- 7. FULL OUTER JOIN to get all appointments and doctors, even if missing

-- Note: MySQL does not support FULL OUTER JOIN directly.
-- Emulate FULL OUTER JOIN using UNION of LEFT JOIN and RIGHT JOIN.

SELECT 
    a.id AS appointment_id,
    d.name AS doctor_name,
    a.appointment_date,
    a.visit_type
FROM appointments a
LEFT JOIN doctors d ON a.doctor_id = d.id

UNION

SELECT
    a.id AS appointment_id,
    d.name AS doctor_name,
    a.appointment_date,
    a.visit_type
FROM appointments a
RIGHT JOIN doctors d ON a.doctor_id = d.id
ORDER BY appointment_id;

-- 8. Subquery in FROM: summarize daily appointments count

SELECT
    daily_stats.appointment_date,
    daily_stats.visit_count
FROM (
    SELECT appointment_date, COUNT(*) AS visit_count
    FROM appointments
    GROUP BY appointment_date
) AS daily_stats
ORDER BY daily_stats.appointment_date;

-- 9. CASE to flag emergency vs routine visits

SELECT
    id,
    patient_id,
    doctor_id,
    appointment_date,
    visit_type,
    CASE 
        WHEN visit_type = 'Emergency' THEN 'High Priority'
        WHEN visit_type = 'Routine' THEN 'Standard Priority'
        ELSE 'Unknown'
    END AS priority_flag
FROM appointments;

-- 10. UNION to combine regular and emergency visits (separate queries for illustration)

-- Regular visits
SELECT
    id,
    patient_id,
    doctor_id,
    appointment_date,
    'Routine' AS visit_type
FROM appointments
WHERE visit_type = 'Routine'

UNION

-- Emergency visits
SELECT
    id,
    patient_id,
    doctor_id,
    appointment_date,
    'Emergency' AS visit_type
FROM appointments
WHERE visit_type = 'Emergency'
ORDER BY appointment_date;

-- 1. Create Database
CREATE DATABASE hospital_patient_tracker;
USE hospital_patient_tracker;

-- 2. Create Tables

-- Patients table
CREATE TABLE patients (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    dob DATE NOT NULL
);

-- Doctors table
CREATE TABLE doctors (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100) NOT NULL
);

-- Visits table
CREATE TABLE visits (
    id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    visit_time DATETIME NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES patients(id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(id)
);


ALTER TABLE visits
ADD CONSTRAINT unique_doctor_time UNIQUE (doctor_id, visit_time);

-- 3. Insert Sample Data

-- Patients
INSERT INTO patients (name, dob) VALUES
('Alice Brown', '1990-05-12'),
('Bob Carter', '1985-11-23'),
('Charlie Davis', '2000-02-14');

-- Doctors
INSERT INTO doctors (name, specialization) VALUES
('Dr. Smith', 'Cardiology'),
('Dr. Johnson', 'Dermatology'),
('Dr. Lee', 'Pediatrics');

-- Visits
INSERT INTO visits (patient_id, doctor_id, visit_time) VALUES
(1, 1, '2025-08-10 09:00:00'),
(2, 1, '2025-08-10 10:00:00'),
(3, 2, '2025-08-11 11:00:00'),
(1, 3, '2025-08-12 14:00:00');

-- 4. Query: Get patients by doctor and date
SELECT 
    d.name AS doctor_name,
    p.name AS patient_name,
    p.dob,
    v.visit_time
FROM visits v
JOIN doctors d ON v.doctor_id = d.id
JOIN patients p ON v.patient_id = p.id
WHERE d.name = 'Dr. Smith'
  AND DATE(v.visit_time) = '2025-08-10'
ORDER BY v.visit_time;

-- 5. Query: All visits sorted by doctor and time
SELECT 
    d.name AS doctor_name,
    d.specialization,
    p.name AS patient_name,
    v.visit_time
FROM visits v
JOIN doctors d ON v.doctor_id = d.id
JOIN patients p ON v.patient_id = p.id
ORDER BY d.name, v.visit_time;

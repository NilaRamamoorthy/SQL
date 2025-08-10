-- 1. Create Database
CREATE DATABASE hospital_records;
USE hospital_records;

-- 2. Create Tables

CREATE TABLE patients (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    dob DATE NOT NULL
);

CREATE TABLE doctors (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    specialization VARCHAR(255)
);

CREATE TABLE appointments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATETIME NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES patients(id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(id)
);

CREATE TABLE treatments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    appointment_id INT NOT NULL,
    treatment_desc VARCHAR(255),
    cost DECIMAL(10,2),
    FOREIGN KEY (appointment_id) REFERENCES appointments(id)
);

-- 3. Insert Sample Data

INSERT INTO patients (name, dob) VALUES
('Alice', '1980-05-20'),
('Bob', '1975-07-15'),
('Charlie', '1980-05-20'),  -- Same DOB as Alice
('Diana', '1990-12-10'),
('Eve', '1985-01-30');

INSERT INTO doctors (name, specialization) VALUES
('Dr. Smith', 'Cardiology'),
('Dr. Johnson', 'Neurology'),
('Dr. Lee', 'Orthopedics');

INSERT INTO appointments (patient_id, doctor_id, appointment_date) VALUES
(1, 1, '2025-07-01 10:00:00'),
(2, 1, '2025-07-01 11:00:00'),
(3, 2, '2025-07-02 09:30:00'),
(4, 2, '2025-07-03 14:00:00'),
(5, 1, '2025-07-04 15:00:00');

INSERT INTO treatments (appointment_id, treatment_desc, cost) VALUES
(1, 'ECG', 200.00),
(2, 'Stress Test', 350.00),
(3, 'MRI Scan', 1200.00),
(4, 'Physical Therapy', 400.00),
(5, 'Blood Test', 150.00);

-- 4. Queries

-- a) Total patients treated per doctor (COUNT distinct patients)
SELECT 
    d.name AS doctor_name,
    COUNT(DISTINCT a.patient_id) AS patients_treated
FROM doctors d
JOIN appointments a ON d.id = a.doctor_id
GROUP BY d.id, d.name;

-- b) Average treatment cost per doctor
SELECT 
    d.name AS doctor_name,
    ROUND(AVG(t.cost), 2) AS avg_treatment_cost
FROM doctors d
JOIN appointments a ON d.id = a.doctor_id
JOIN treatments t ON a.id = t.appointment_id
GROUP BY d.id, d.name;

-- c) Doctors who treated more than 10 patients (HAVING)
SELECT 
    d.name AS doctor_name,
    COUNT(DISTINCT a.patient_id) AS patients_treated
FROM doctors d
JOIN appointments a ON d.id = a.doctor_id
GROUP BY d.id, d.name
HAVING patients_treated > 10;

-- d) INNER JOIN: Appointments + Doctors
SELECT
    a.id AS appointment_id,
    p.name AS patient_name,
    d.name AS doctor_name,
    a.appointment_date
FROM appointments a
JOIN doctors d ON a.doctor_id = d.id
JOIN patients p ON a.patient_id = p.id;

-- e) RIGHT JOIN: All doctors, including those with no appointments
SELECT
    d.id AS doctor_id,
    d.name AS doctor_name,
    COUNT(a.id) AS appointment_count
FROM appointments a
RIGHT JOIN doctors d ON a.doctor_id = d.id
GROUP BY d.id, d.name;

-- f) SELF JOIN on patients to find those with same birth date
SELECT 
    p1.id AS patient1_id,
    p1.name AS patient1_name,
    p2.id AS patient2_id,
    p2.name AS patient2_name,
    p1.dob
FROM patients p1
JOIN patients p2 ON p1.dob = p2.dob AND p1.id < p2.id
ORDER BY p1.dob;

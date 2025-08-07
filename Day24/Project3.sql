-- STEP 1: Create Database & Use It
CREATE DATABASE HospitalRecords;
USE HospitalRecords;

-- STEP 2: Normalize to 3NF — Separate patients & visits
CREATE TABLE patients (
  patient_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100),
  dob DATE,
  gender VARCHAR(10)
);

CREATE TABLE doctors (
  doctor_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100),
  department_id INT
);

CREATE TABLE departments (
  department_id INT PRIMARY KEY AUTO_INCREMENT,
  department_name VARCHAR(100)
);

CREATE TABLE appointments (
  appointment_id INT PRIMARY KEY AUTO_INCREMENT,
  appointment_date DATETIME,
  patient_id INT,
  doctor_id INT,
  notes TEXT,
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
  FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

CREATE TABLE medications (
  medication_id INT PRIMARY KEY AUTO_INCREMENT,
  appointment_id INT,
  name VARCHAR(255),
  dosage VARCHAR(50),
  duration VARCHAR(50),
  FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id)
);

-- STEP 3: Create Indexes
-- Clustered: appointment_id via PK
CREATE INDEX idx_appointments_date ON appointments (appointment_date);
CREATE INDEX idx_appointments_patient ON appointments (patient_id);
CREATE INDEX idx_appointments_doctor ON appointments (doctor_id);

-- STEP 4: Analyze Execution Plan (example lookup)
EXPLAIN
SELECT *
FROM appointments
WHERE patient_id = 123
  AND appointment_date BETWEEN '2025-07-01' AND '2025-07-31';

-- STEP 5: Subquery to Find Patients with Most Visits
SELECT p.patient_id, p.name, COUNT(a.appointment_id) AS visit_count
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
GROUP BY p.patient_id, p.name
ORDER BY visit_count DESC
LIMIT 10;

-- STEP 6: Denormalized View for Dashboard Analytics
CREATE VIEW dashboard_appointments AS
SELECT
  a.appointment_date,
  p.patient_id, p.name AS patient_name,
  d.doctor_id, d.name AS doctor_name,
  dept.department_name,
  COUNT(m.medication_id) AS meds_prescribed
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id
LEFT JOIN departments dept ON d.department_id = dept.department_id
LEFT JOIN medications m ON a.appointment_id = m.appointment_id
GROUP BY a.appointment_id, a.appointment_date,
         p.patient_id, p.name,
         d.doctor_id, d.name, dept.department_name;

-- STEP 7: Retrieve Last 5 Appointments for a Patient (pagination)
SELECT *
FROM appointments
WHERE patient_id = 123
ORDER BY appointment_date DESC
LIMIT 5;

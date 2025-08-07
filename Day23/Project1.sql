-- Step 1: Create and Use Database
CREATE DATABASE IF NOT EXISTS HospitalSystem;
USE HospitalSystem;

-- Step 2: Create Tables

-- Departments
CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL
);

-- Doctors
CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100),
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Patients
CREATE TABLE patients (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    gender VARCHAR(10),
    CHECK (age BETWEEN 0 AND 120)
);

-- Appointments
CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATETIME NOT NULL,
    status VARCHAR(50) DEFAULT 'Scheduled',
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

-- Step 3: Insert Sample Data

INSERT INTO departments (department_name) VALUES
('Cardiology'), ('Neurology'), ('Pediatrics');

INSERT INTO doctors (name, specialization, department_id) VALUES
('Dr. Smith', 'Cardiologist', 1),
('Dr. Alice', 'Neurologist', 2);

-- Insert patients (with NOT NULL constraints and valid CHECK)
INSERT INTO patients (name, age, gender) VALUES
('John Doe', 45, 'Male'),
('Jane Roe', 30, 'Female');

-- Insert appointments (FKs enforced)
INSERT INTO appointments (patient_id, doctor_id, appointment_date, status) VALUES
(1, 1, '2025-08-10 10:00:00', 'Confirmed'),
(2, 2, '2025-08-11 11:00:00', 'Scheduled');

-- Step 4: Update Doctor Info
UPDATE doctors
SET specialization = 'Interventional Cardiologist', department_id = 1
WHERE doctor_id = 1;

-- Step 5: Use SAVEPOINT before deleting a patient

START TRANSACTION;

SAVEPOINT before_delete;

-- Deleting a patient (and cascade deleting appointments)
DELETE FROM patients WHERE patient_id = 2;

-- To undo the delete, use rollback
 ROLLBACK TO before_delete;

-- To commit delete:
 COMMIT;

-- Step 6: Demonstrate atomicity - update doctor and appointment together

START TRANSACTION;

-- Update doctor
UPDATE doctors
SET specialization = 'General Physician'
WHERE doctor_id = 1;

-- Update appointment
UPDATE appointments
SET status = 'Rescheduled', appointment_date = '2025-08-15 09:30:00'
WHERE appointment_id = 1;

-- If both succeed
COMMIT;

-- If something fails, use:
-- ROLLBACK;

-- Step 7: SELECTs for verification

-- Check all doctors
SELECT * FROM doctors;

-- Check all patients
SELECT * FROM patients;

-- Check appointments
SELECT * FROM appointments;


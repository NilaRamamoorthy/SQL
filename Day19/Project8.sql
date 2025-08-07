
-- Step 1: Create database
DROP DATABASE IF EXISTS hospital_db;
CREATE DATABASE hospital_db;
USE hospital_db;

-- Step 2: Create tables

CREATE TABLE departments (
  department_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE doctors (
  doctor_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  department_id INT NOT NULL,
  specialization VARCHAR(100),
  FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE TABLE patients (
  patient_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  dob DATE,
  gender ENUM('Male', 'Female', 'Other'),
  contact VARCHAR(15)
);

CREATE TABLE appointments (
  appointment_id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT NOT NULL,
  doctor_id INT NOT NULL,
  appointment_date DATE NOT NULL,
  reason TEXT,
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
  FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

-- Step 3: Insert data

INSERT INTO departments (name) VALUES 
('Cardiology'), 
('Neurology'), 
('Orthopedics'), 
('Pediatrics'), 
('Dermatology');

INSERT INTO doctors (name, department_id, specialization) VALUES 
('Dr. Smith', 1, 'Cardiologist'),
('Dr. Taylor', 2, 'Neurologist'),
('Dr. Adams', 3, 'Orthopedic Surgeon'),
('Dr. Lee', 4, 'Pediatrician'),
('Dr. Patel', 5, 'Dermatologist'),
('Dr. Wang', 1, 'Cardiologist'),
('Dr. Brown', 2, 'Neurosurgeon'),
('Dr. Green', 3, 'Sports Medicine'),
('Dr. Johnson', 4, 'Child Specialist'),
('Dr. Davis', 5, 'Cosmetic Dermatologist');

INSERT INTO patients (name, dob, gender, contact) VALUES
('Alice', '1990-05-10', 'Female', '9876543210'),
('Bob', '1985-03-12', 'Male', '9823456789'),
('Charlie', '2000-07-18', 'Male', '9801234567'),
('Diana', '1975-09-25', 'Female', '9812345678'),
('Ethan', '2010-01-01', 'Male', '9845671234'),
('Fiona', '1995-11-23', 'Female', '9789012345'),
('George', '1965-02-14', 'Male', '9776543210'),
('Hannah', '2005-06-20', 'Female', '9765432109'),
('Ian', '1988-08-08', 'Male', '9754321098'),
('Jill', '1992-04-30', 'Female', '9743210987'),
('Kevin', '1998-12-19', 'Male', '9732109876'),
('Lily', '2001-10-05', 'Female', '9721098765'),
('Mike', '1993-03-17', 'Male', '9710987654'),
('Nina', '1980-12-31', 'Female', '9709876543'),
('Oscar', '1996-06-15', 'Male', '9698765432');

INSERT INTO appointments (patient_id, doctor_id, appointment_date, reason) VALUES
(1, 1, '2025-07-30', 'Chest pain'),
(2, 2, '2025-07-30', 'Migraine'),
(3, 3, '2025-08-01', 'Knee pain'),
(4, 4, '2025-08-02', 'Child fever'),
(5, 5, '2025-08-02', 'Skin rash'),
(6, 1, '2025-08-03', 'High BP'),
(7, 2, '2025-08-03', 'Memory loss'),
(8, 3, '2025-08-03', 'Fracture'),
(9, 4, '2025-08-04', 'Vaccination'),
(10, 5, '2025-08-04', 'Skin allergy'),
(11, 6, '2025-08-04', 'ECG follow-up'),
(12, 7, '2025-08-05', 'Seizure'),
(13, 8, '2025-08-05', 'Back pain'),
(14, 9, '2025-08-05', 'Routine checkup'),
(15, 10, '2025-08-06', 'Acne treatment'),
(1, 6, '2025-08-06', 'Heart checkup'),
(2, 7, '2025-08-06', 'Neuro consultation'),
(3, 8, '2025-08-07', 'Sports injury'),
(4, 9, '2025-08-07', 'Child fever'),
(5, 10, '2025-08-07', 'Skin peeling');

-- Step 4: Queries

-- Find appointments by date
SELECT 
  a.appointment_id,
  p.name AS patient_name,
  d.name AS doctor_name,
  a.appointment_date,
  a.reason
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id
WHERE a.appointment_date = '2025-08-04';

-- Find doctors by department
SELECT 
  d.name AS doctor_name,
  dept.name AS department_name,
  d.specialization
FROM doctors d
JOIN departments dept ON d.department_id = dept.department_id
WHERE dept.name = 'Cardiology';

-- Count patients per doctor
SELECT 
  doc.name AS doctor_name,
  COUNT(a.patient_id) AS total_patients
FROM doctors doc
LEFT JOIN appointments a ON doc.doctor_id = a.doctor_id
GROUP BY doc.doctor_id
ORDER BY total_patients DESC;

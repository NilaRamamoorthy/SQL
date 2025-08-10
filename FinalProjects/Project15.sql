-- 1. Create Database
CREATE DATABASE health_records_system;
USE health_records_system;

-- 2. Create Tables

-- Patients table
CREATE TABLE patients (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    dob DATE NOT NULL
);

-- Prescriptions table
CREATE TABLE prescriptions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    date DATE NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES patients(id)
);

-- Medications table
CREATE TABLE medications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Prescription details (many-to-many between prescriptions & medications)
CREATE TABLE prescription_details (
    prescription_id INT NOT NULL,
    medication_id INT NOT NULL,
    dosage VARCHAR(50) NOT NULL,
    PRIMARY KEY (prescription_id, medication_id),
    FOREIGN KEY (prescription_id) REFERENCES prescriptions(id),
    FOREIGN KEY (medication_id) REFERENCES medications(id)
);

-- 3. Insert Sample Data

-- Patients
INSERT INTO patients (name, dob) VALUES
('Alice Brown', '1990-05-12'),
('Bob Carter', '1985-11-23'),
('Charlie Davis', '2000-02-14');

-- Medications
INSERT INTO medications (name) VALUES
('Amoxicillin'),
('Paracetamol'),
('Ibuprofen'),
('Metformin');

-- Prescriptions
INSERT INTO prescriptions (patient_id, date) VALUES
(1, '2025-08-01'),
(2, '2025-08-02'),
(1, '2025-08-05');

-- Prescription Details
INSERT INTO prescription_details (prescription_id, medication_id, dosage) VALUES
(1, 1, '500mg twice daily'),
(1, 2, '500mg every 6 hours'),
(2, 3, '200mg twice daily'),
(3, 4, '500mg daily');

-- 4. Query: Join to get all prescriptions with medication details
SELECT 
    p.name AS patient_name,
    pr.date AS prescription_date,
    m.name AS medication_name,
    pd.dosage
FROM prescriptions pr
JOIN patients p ON pr.patient_id = p.id
JOIN prescription_details pd ON pr.id = pd.prescription_id
JOIN medications m ON pd.medication_id = m.id
ORDER BY p.name, pr.date;

-- 5. Query: Filter prescriptions by patient and date range
SELECT 
    p.name AS patient_name,
    pr.date AS prescription_date,
    m.name AS medication_name,
    pd.dosage
FROM prescriptions pr
JOIN patients p ON pr.patient_id = p.id
JOIN prescription_details pd ON pr.id = pd.prescription_id
JOIN medications m ON pd.medication_id = m.id
WHERE p.name = 'Alice Brown'
  AND pr.date BETWEEN '2025-08-01' AND '2025-08-10'
ORDER BY pr.date;

-- 1. Create Database and Use
CREATE DATABASE IF NOT EXISTS hospital_monitoring;
USE hospital_monitoring;

-- 2. Create Tables

CREATE TABLE patients (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    admission_date DATE,
    discharge_date DATE NULL
);

CREATE TABLE doctors (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    department VARCHAR(100)
);

CREATE TABLE appointments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT,
    doctor_id INT,
    appointment_date DATE,
    FOREIGN KEY (patient_id) REFERENCES patients(id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(id)
);

CREATE TABLE treatments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT,
    doctor_id INT,
    treatment_date DATE,
    treatment_type VARCHAR(255),
    bill_amount DECIMAL(10,2),
    FOREIGN KEY (patient_id) REFERENCES patients(id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(id)
);

CREATE TABLE outpatients (
    id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT,
    visit_date DATE,
    FOREIGN KEY (patient_id) REFERENCES patients(id)
);

CREATE TABLE inpatients (
    id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT,
    admission_date DATE,
    discharge_date DATE,
    FOREIGN KEY (patient_id) REFERENCES patients(id)
);

-- 3. Insert Sample Data

INSERT INTO patients (name, admission_date, discharge_date) VALUES
('John Doe', '2025-06-10', '2025-06-20'),
('Jane Smith', '2025-07-01', NULL),
('Mike Johnson', '2025-05-15', '2025-05-30'),
('Emily Davis', '2025-07-05', '2025-07-10'),
('Anna Brown', '2025-06-25', '2025-07-05');

INSERT INTO doctors (name, department) VALUES
('Dr. Adams', 'Cardiology'),
('Dr. Baker', 'Neurology'),
('Dr. Clark', 'Oncology');

INSERT INTO appointments (patient_id, doctor_id, appointment_date) VALUES
(1, 1, '2025-06-12'),
(2, 2, '2025-07-02'),
(3, 3, '2025-05-20'),
(1, 1, '2025-06-18'),
(4, 2, '2025-07-06'),
(5, 3, '2025-06-28');

INSERT INTO treatments (patient_id, doctor_id, treatment_date, treatment_type, bill_amount) VALUES
(1, 1, '2025-06-12', 'ECG', 5000),
(1, 1, '2025-06-18', 'Angiography', 15000),
(2, 2, '2025-07-02', 'MRI', 20000),
(3, 3, '2025-05-20', 'Chemotherapy', 25000),
(3, 3, '2025-05-25', 'Radiation', 30000),
(3, 3, '2025-05-28', 'Follow-up', 8000),
(4, 2, '2025-07-06', 'EEG', 4000),
(5, 3, '2025-06-28', 'Chemotherapy', 28000);

INSERT INTO outpatients (patient_id, visit_date) VALUES
(2, '2025-07-02'),
(4, '2025-07-06');

INSERT INTO inpatients (patient_id, admission_date, discharge_date) VALUES
(1, '2025-06-10', '2025-06-20'),
(3, '2025-05-15', '2025-05-30'),
(5, '2025-06-25', '2025-07-05');

-- 4a. Subquery in FROM to calculate total patients per doctor
SELECT 
    d.id AS doctor_id,
    d.name AS doctor_name,
    d.department,
    IFNULL(tp.total_patients, 0) AS total_patients
FROM doctors d
LEFT JOIN (
    SELECT doctor_id, COUNT(DISTINCT patient_id) AS total_patients
    FROM treatments
    GROUP BY doctor_id
) tp ON d.id = tp.doctor_id;

-- 4b. Subquery in WHERE to get patients treated more than 3 times
SELECT 
    p.id,
    p.name,
    (SELECT COUNT(*) FROM treatments t WHERE t.patient_id = p.id) AS treatment_count
FROM patients p
WHERE (SELECT COUNT(*) FROM treatments t WHERE t.patient_id = p.id) > 3;

-- 4c. CASE to flag "Critical" patients based on treatment count >3 or bill amount > 25000
SELECT
    p.id,
    p.name,
    COUNT(t.id) AS treatment_count,
    SUM(t.bill_amount) AS total_bill,
    CASE 
        WHEN COUNT(t.id) > 3 OR SUM(t.bill_amount) > 25000 THEN 'Critical'
        ELSE 'Stable'
    END AS patient_status
FROM patients p
LEFT JOIN treatments t ON p.id = t.patient_id
GROUP BY p.id, p.name;

-- 4d. Correlated subquery to find patient with longest hospital stay per department
SELECT
    d.department,
    p.id AS patient_id,
    p.name,
    DATEDIFF(
        COALESCE(p.discharge_date, CURDATE()),
        p.admission_date
    ) AS stay_duration
FROM patients p
JOIN treatments t ON p.id = t.patient_id
JOIN doctors d ON t.doctor_id = d.id
WHERE p.id = (
    SELECT p2.id
    FROM patients p2
    JOIN treatments t2 ON p2.id = t2.patient_id
    JOIN doctors d2 ON t2.doctor_id = d2.id
    WHERE d2.department = d.department
    ORDER BY DATEDIFF(COALESCE(p2.discharge_date, CURDATE()), p2.admission_date) DESC
    LIMIT 1
)
GROUP BY d.department, p.id, p.name, stay_duration;

-- 4e. Date functions to find patients treated in last 30 days
SELECT DISTINCT
    p.id,
    p.name,
    t.treatment_date
FROM patients p
JOIN treatments t ON p.id = t.patient_id
WHERE t.treatment_date >= CURDATE() - INTERVAL 30 DAY;

-- 4f. UNION to combine outpatient and inpatient records
SELECT
    p.id AS patient_id,
    p.name,
    'Outpatient' AS patient_type,
    o.visit_date AS date
FROM patients p
JOIN outpatients o ON p.id = o.patient_id

UNION

SELECT
    p.id AS patient_id,
    p.name,
    'Inpatient' AS patient_type,
    i.admission_date AS date
FROM patients p
JOIN inpatients i ON p.id = i.patient_id;

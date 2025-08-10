-- 1. Create Database
CREATE DATABASE IF NOT EXISTS healthcare_analytics;
USE healthcare_analytics;

-- 2. OLTP Tables

CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY,
    doctor_name VARCHAR(255),
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    patient_name VARCHAR(255),
    birth_date DATE,
    gender CHAR(1)
);

CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    department_id INT,
    scheduled_time DATETIME,
    checkin_time DATETIME,
    checkout_time DATETIME,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id),
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- 3. Star Schema Warehouse Tables

CREATE TABLE dim_time (
    time_id INT PRIMARY KEY AUTO_INCREMENT,
    date DATE,
    year INT,
    quarter INT,
    month INT,
    day INT,
    day_of_week VARCHAR(10),
    is_weekend BOOLEAN
);

CREATE TABLE dim_doctor (
    doctor_id INT PRIMARY KEY,
    doctor_name VARCHAR(255),
    department_id INT
);

CREATE TABLE dim_patient (
    patient_id INT PRIMARY KEY,
    patient_name VARCHAR(255),
    birth_date DATE,
    gender CHAR(1)
);

CREATE TABLE dim_department (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100)
);

CREATE TABLE fact_visits (
    visit_id INT PRIMARY KEY AUTO_INCREMENT,
    time_id INT,
    doctor_id INT,
    patient_id INT,
    department_id INT,
    wait_time_minutes INT,
    visit_duration_minutes INT,
    FOREIGN KEY (time_id) REFERENCES dim_time(time_id),
    FOREIGN KEY (doctor_id) REFERENCES dim_doctor(doctor_id),
    FOREIGN KEY (patient_id) REFERENCES dim_patient(patient_id),
    FOREIGN KEY (department_id) REFERENCES dim_department(department_id)
);

-- 4. Insert sample data into OLTP tables

INSERT INTO departments VALUES
(1, 'Cardiology'),
(2, 'Neurology'),
(3, 'Pediatrics');

INSERT INTO doctors VALUES
(101, 'Dr. Smith', 1),
(102, 'Dr. Jones', 2),
(103, 'Dr. Williams', 3);

INSERT INTO patients VALUES
(201, 'Alice Brown', '1980-05-15', 'F'),
(202, 'Bob Green', '1975-11-20', 'M'),
(203, 'Carol White', '1990-07-30', 'F');

INSERT INTO appointments VALUES
(1001, 201, 101, 1, '2025-08-01 09:00:00', '2025-08-01 09:10:00', '2025-08-01 09:40:00'),
(1002, 202, 101, 1, '2025-08-01 10:00:00', '2025-08-01 10:20:00', '2025-08-01 10:50:00'),
(1003, 203, 102, 2, '2025-08-01 09:30:00', '2025-08-01 09:40:00', '2025-08-01 10:00:00'),
(1004, 201, 103, 3, '2025-08-02 08:00:00', '2025-08-02 08:05:00', '2025-08-02 08:35:00');

-- 5. Populate dimension tables from OLTP (simulate ETL)

-- Populate dim_time with distinct dates from appointments
INSERT INTO dim_time (date, year, quarter, month, day, day_of_week, is_weekend)
SELECT DISTINCT 
    DATE(scheduled_time) AS date,
    YEAR(scheduled_time),
    QUARTER(scheduled_time),
    MONTH(scheduled_time),
    DAY(scheduled_time),
    DAYNAME(scheduled_time),
    CASE WHEN DAYOFWEEK(scheduled_time) IN (1,7) THEN TRUE ELSE FALSE END
FROM appointments;

-- Populate dim_doctor
INSERT INTO dim_doctor (doctor_id, doctor_name, department_id)
SELECT doctor_id, doctor_name, department_id FROM doctors;

-- Populate dim_patient
INSERT INTO dim_patient (patient_id, patient_name, birth_date, gender)
SELECT patient_id, patient_name, birth_date, gender FROM patients;

-- Populate dim_department
INSERT INTO dim_department (department_id, department_name)
SELECT department_id, name FROM departments;

-- Helper: Get time_id for a given date
-- (Use JOIN to map appointments date to dim_time.time_id)

-- 6. Populate fact_visits from appointments (ETL)

INSERT INTO fact_visits (time_id, doctor_id, patient_id, department_id, wait_time_minutes, visit_duration_minutes)
SELECT 
    dt.time_id,
    a.doctor_id,
    a.patient_id,
    a.department_id,
    TIMESTAMPDIFF(MINUTE, a.scheduled_time, a.checkin_time) AS wait_time_minutes,
    TIMESTAMPDIFF(MINUTE, a.checkin_time, a.checkout_time) AS visit_duration_minutes
FROM appointments a
JOIN dim_time dt ON DATE(a.scheduled_time) = dt.date;

-- 7. OLAP Queries

-- a) Average wait time per doctor
SELECT
    d.doctor_name,
    AVG(f.wait_time_minutes) AS avg_wait_time_minutes,
    COUNT(f.visit_id) AS visit_count
FROM fact_visits f
JOIN dim_doctor d ON f.doctor_id = d.doctor_id
GROUP BY d.doctor_name
ORDER BY avg_wait_time_minutes ASC;

-- b) Total visits and avg wait time per department
SELECT
    dep.department_name,
    COUNT(f.visit_id) AS total_visits,
    AVG(f.wait_time_minutes) AS avg_wait_time_minutes
FROM fact_visits f
JOIN dim_department dep ON f.department_id = dep.department_id
GROUP BY dep.department_name
ORDER BY total_visits DESC;

-- c) Compare OLAP summary with OLTP raw count per doctor (for validation)
SELECT 
    d.doctor_name,
    COUNT(a.appointment_id) AS oltp_appointments,
    COALESCE(olap_visits.visit_count,0) AS olap_visits_count
FROM doctors d
LEFT JOIN appointments a ON d.doctor_id = a.doctor_id
LEFT JOIN (
    SELECT doctor_id, COUNT(visit_id) AS visit_count
    FROM fact_visits
    GROUP BY doctor_id
) olap_visits ON d.doctor_id = olap_visits.doctor_id
GROUP BY d.doctor_name;


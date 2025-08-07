-- Step 1: Create the Database
CREATE DATABASE DoctorAppointments;

-- Step 2: Use the Database
USE DoctorAppointments;

-- Step 3: Create the 'appointments' Table
CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY,
    patient_name VARCHAR(100),
    doctor_name VARCHAR(100),
    date DATE,
    status VARCHAR(50),
    notes TEXT
);

-- Step 4: Insert Sample Data
INSERT INTO appointments (appointment_id, patient_name, doctor_name, date, status, notes)
VALUES
    (1, 'John Smith', 'Dr. Alice Johnson', '2025-08-10', 'Scheduled', 'First-time consultation'),
    (2, 'Emily Davis', 'Dr. Bob Lee', '2025-08-12', 'Completed', NULL),
    (3, 'Michael Brown', 'Dr. Alice Johnson', '2025-08-13', 'Cancelled', 'Patient ill'),
    (4, 'Sarah Wilson', 'Dr. Charlie Kim', '2025-08-14', 'Scheduled', 'Routine check-up'),
    (5, 'David Thomas', 'Dr. Alice Johnson', '2025-08-15', 'Completed', 'Follow-up visit');

-- Step 5: Retrieve Appointments Within a Given Week
SELECT * FROM appointments
WHERE date BETWEEN '2025-08-10' AND '2025-08-16';

-- Step 6: Find Patients with 'th' in Their Name
SELECT * FROM appointments
WHERE patient_name LIKE '%th%';

-- Step 7: Show Doctor Name, Date, and Status
SELECT doctor_name, date, status FROM appointments;

-- Step 8: Identify Appointments with NULL Notes
SELECT * FROM appointments
WHERE notes IS NULL;

-- Step 9: Retrieve Distinct Doctors List
SELECT DISTINCT doctor_name FROM appointments;

-- Step 10: Sort Appointments by Date in Descending Order
SELECT * FROM appointments
ORDER BY date DESC;

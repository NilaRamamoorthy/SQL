-- Step 1: Create Database and Use It
CREATE DATABASE HospitalManagement;
USE HospitalManagement;

-- Step 2: Create normalized tables

-- Patients
CREATE TABLE patients (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    birth_date DATE NOT NULL
);

-- Doctors
CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    specialty VARCHAR(100),
    availability INT NOT NULL DEFAULT 10 -- number of available slots
);

-- Appointments
CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATETIME NOT NULL,
    status VARCHAR(50) DEFAULT 'Scheduled',
    billing_amount DECIMAL(10,2),
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

-- Visits (to log patient visits)
CREATE TABLE visits (
    visit_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    visit_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);
-- Insert sample data for testing

INSERT INTO patients (name, birth_date) VALUES
('Alice Smith', '1980-05-12'),
('Bob Johnson', '1992-08-25'),
('Carol White', '1975-11-30');

INSERT INTO doctors (name, specialty, availability) VALUES
('Dr. Green', 'Cardiology', 5),
('Dr. Brown', 'Neurology', 8);

INSERT INTO appointments (patient_id, doctor_id, appointment_date, status, billing_amount) VALUES
(1, 1, '2025-08-10 10:00:00', 'Scheduled', 150.00),
(2, 1, '2025-08-11 11:00:00', 'Scheduled', 200.00),
(3, 2, '2025-08-12 14:00:00', 'Scheduled', 180.00);



-- Step 3: Create view to show patient summary (name, age, latest appointment date)
CREATE VIEW view_patient_summary AS
SELECT
    p.patient_id,
    p.name,
    TIMESTAMPDIFF(YEAR, p.birth_date, CURDATE()) AS age,
    (SELECT MAX(appointment_date) FROM appointments a WHERE a.patient_id = p.patient_id) AS latest_appointment
FROM patients p;

-- Step 4: Stored procedure to add a patient visit and auto-log it
DELIMITER //
CREATE PROCEDURE add_patient_visit(
    IN p_patient_id INT,
    IN p_doctor_id INT,
    IN p_notes TEXT
)
BEGIN
    -- Insert into visits table
    INSERT INTO visits(patient_id, doctor_id, notes) VALUES (p_patient_id, p_doctor_id, p_notes);

    -- Also insert an appointment as a log (optional)
    INSERT INTO appointments(patient_id, doctor_id, appointment_date, status)
    VALUES (p_patient_id, p_doctor_id, NOW(), 'Completed');
END //
DELIMITER ;

-- Step 5: Function to get doctor schedule (appointments)
DELIMITER //
CREATE FUNCTION get_doctor_schedule(p_doctor_id INT)
RETURNS TEXT
DETERMINISTIC
BEGIN
    DECLARE schedule TEXT DEFAULT '';
    DECLARE done INT DEFAULT FALSE;
    DECLARE appt_date DATETIME;
    DECLARE appt_cursor CURSOR FOR
        SELECT appointment_date FROM appointments
        WHERE doctor_id = p_doctor_id AND status = 'Scheduled'
        ORDER BY appointment_date;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN appt_cursor;
    read_loop: LOOP
        FETCH appt_cursor INTO appt_date;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SET schedule = CONCAT(schedule, DATE_FORMAT(appt_date, '%Y-%m-%d %H:%i'), '; ');
    END LOOP;
    CLOSE appt_cursor;

    RETURN schedule;
END //
DELIMITER ;

-- Step 6: Trigger to update doctor availability after appointment insert
DELIMITER //
CREATE TRIGGER after_insert_appointment
AFTER INSERT ON appointments
FOR EACH ROW
BEGIN
    -- Reduce availability by 1 if status is Scheduled
    IF NEW.status = 'Scheduled' THEN
        UPDATE doctors SET availability = availability - 1 WHERE doctor_id = NEW.doctor_id AND availability > 0;
    END IF;
END //
DELIMITER ;

-- Step 7: Abstraction: restrict non-admin users access via views

-- Create a read-only user if not exists
CREATE USER IF NOT EXISTS 'nonadmin'@'%' IDENTIFIED BY 'password123';

-- Revoke all privileges on the whole database for nonadmin
REVOKE ALL PRIVILEGES, GRANT OPTION FROM HospitalManagement;

-- Grant SELECT only on view_patient_summary view
GRANT SELECT ON HospitalManagement.view_patient_summary TO 'nonadmin'@'%';

-- Flush privileges to apply changes
FLUSH PRIVILEGES;




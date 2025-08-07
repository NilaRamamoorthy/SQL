
CREATE DATABASE IF NOT EXISTS HealthcareDB;
USE HealthcareDB;

-- Step 1: Create tables

CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    specialty VARCHAR(100)
);

CREATE TABLE patients (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    birth_date DATE NOT NULL
);

CREATE TABLE medications (
    medication_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    stock INT NOT NULL CHECK (stock >= 0)
);

CREATE TABLE prescriptions (
    prescription_id INT PRIMARY KEY AUTO_INCREMENT,
    doctor_id INT NOT NULL,
    patient_id INT NOT NULL,
    medication_id INT,
    dosage INT CHECK (dosage >= 1 AND dosage <= 5),
    prescribed_date DATE ,
    notes TEXT,
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE CASCADE,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
    FOREIGN KEY (medication_id) REFERENCES medications(medication_id) ON DELETE SET NULL
);

-- Step 2: Insert sample data

INSERT INTO doctors (name, specialty) VALUES
('Dr. Smith', 'Cardiology'),
('Dr. Lee', 'Neurology');

INSERT INTO patients (name, birth_date) VALUES
('Alice Brown', '1985-03-25'),
('Bob Green', '1970-07-19');

INSERT INTO medications (name, stock) VALUES
('Aspirin', 100),
('Ibuprofen', 50);

-- Step 3: Modify NOT NULL constraint on medication_id in prescriptions (make optional)

-- First drop FK constraint for medication_id
ALTER TABLE prescriptions DROP FOREIGN KEY prescriptions_ibfk_3;

-- Alter column to allow NULL (if not already)
ALTER TABLE prescriptions MODIFY medication_id INT NULL;

-- Recreate FK with ON DELETE SET NULL
ALTER TABLE prescriptions
ADD CONSTRAINT fk_medication FOREIGN KEY (medication_id) REFERENCES medications(medication_id) ON DELETE SET NULL;

-- Step 4: Transaction to insert prescription and update stock atomically

DELIMITER //
CREATE PROCEDURE add_prescription(
    IN p_doctor_id INT,
    IN p_patient_id INT,
    IN p_medication_id INT,
    IN p_dosage INT,
    IN p_notes TEXT
)
BEGIN
    DECLARE v_stock INT;

    START TRANSACTION;

    -- Check medication stock
    SELECT stock INTO v_stock FROM medications WHERE medication_id = p_medication_id FOR UPDATE;

    IF v_stock IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Medication does not exist';
    ELSEIF v_stock < 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Medication out of stock';
    ELSEIF p_dosage < 1 OR p_dosage > 5 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Dosage out of allowed range (1-5)';
    ELSE
        -- Insert prescription
        INSERT INTO prescriptions (doctor_id, patient_id, medication_id, dosage, notes)
        VALUES (p_doctor_id, p_patient_id, p_medication_id, p_dosage, p_notes);

        -- Update medication stock (reduce by 1 for each prescription)
        UPDATE medications SET stock = stock - 1 WHERE medication_id = p_medication_id;
    END IF;

    COMMIT;
END //
DELIMITER ;

-- Step 5: Delete prescriptions older than 6 months

DELETE FROM prescriptions WHERE prescribed_date < DATE_SUB(CURDATE(), INTERVAL 6 MONTH);

-- Step 6: Sample usage: add prescription

CALL add_prescription(1, 1, 1, 3, 'Take after meals');

-- Step 7: Verify data

SELECT * FROM prescriptions;
SELECT * FROM medications;


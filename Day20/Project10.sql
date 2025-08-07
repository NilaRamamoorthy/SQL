-- 1. Create database and switch to it
CREATE DATABASE IF NOT EXISTS vehicle_service_db;
USE vehicle_service_db;

-- 2. Create the services table
CREATE TABLE services (
  service_id INT AUTO_INCREMENT PRIMARY KEY,
  vehicle_no VARCHAR(20) NOT NULL,
  service_type VARCHAR(50) NOT NULL,
  cost DECIMAL(10,2) NOT NULL,
  service_date DATE NOT NULL,
  technician VARCHAR(100)
);

-- 3. Insert sample data
INSERT INTO services (vehicle_no, service_type, cost, service_date, technician) VALUES
('MH12AB1239', 'Oil Change',     750.00, '2025-07-20', 'Technician A'),
('KL07XY789',  'Tire Rotation', 1200.00, '2025-08-01', 'Technician B'),
('MH12CD345', 'Brake Service',   450.00, '2025-07-10', NULL),
('KA05EF999', 'Engine Check',   1800.00, '2025-07-25', 'Technician C'),
('TN10GH129', 'Battery Replace', 900.00, '2025-08-03', NULL),
('DL05IJ129', 'AC Service',      650.00, '2025-06-15', 'Technician D');

-- Assume today is 2025-08-06
-- 4. Queries per requirements:

-- A) Vehicles serviced in the last 30 days (from 2025‑08‑06), with vehicle_no ending with '9', cost between 500 and 2000
SELECT vehicle_no, service_type, cost
FROM services
WHERE service_date BETWEEN DATE_SUB('2025-08-06', INTERVAL 30 DAY) AND '2025-08-06'
  AND vehicle_no LIKE '%9'
  AND cost BETWEEN 500 AND 2000
ORDER BY service_date DESC, cost ASC;

-- B) Identify records with NULL technician
SELECT vehicle_no, service_type, cost
FROM services
WHERE technician IS NULL
ORDER BY service_date DESC, cost ASC;

-- C) List all distinct service types
SELECT DISTINCT service_type
FROM services
ORDER BY service_type ASC;

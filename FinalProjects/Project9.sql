-- 1. Create Database
CREATE DATABASE appointment_scheduler;
USE appointment_scheduler;

-- 2. Create Tables

-- Users table
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Services table
CREATE TABLE services (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Appointments table
CREATE TABLE appointments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    service_id INT,
    appointment_time DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (service_id) REFERENCES services(id)
);

-- 3. Insert Sample Data

-- Users
INSERT INTO users (name) VALUES
('Alice'),
('Bob'),
('Charlie'),
('Diana');

-- Services
INSERT INTO services (name) VALUES
('Haircut'),
('Dental Checkup'),
('Massage Therapy');

-- Appointments
INSERT INTO appointments (user_id, service_id, appointment_time) VALUES
(1, 1, '2025-08-11 10:00:00'),
(2, 1, '2025-08-11 11:00:00'),
(3, 2, '2025-08-11 14:00:00'),
(4, 3, '2025-08-12 09:00:00'),
(1, 3, '2025-08-12 11:30:00');

-- 4. Detect Time Clashes (Same service, same time)
SELECT 
    a1.id AS appointment1_id,
    a2.id AS appointment2_id,
    s.name AS service_name,
    a1.appointment_time
FROM appointments a1
JOIN appointments a2 
    ON a1.id < a2.id
    AND a1.service_id = a2.service_id
    AND a1.appointment_time = a2.appointment_time
JOIN services s ON a1.service_id = s.id;

-- 5. Filter by Date (Appointments on '2025-08-11')
SELECT 
    u.name AS user_name,
    s.name AS service_name,
    a.appointment_time
FROM appointments a
JOIN users u ON a.user_id = u.id
JOIN services s ON a.service_id = s.id
WHERE DATE(a.appointment_time) = '2025-08-11'
ORDER BY a.appointment_time;

-- 6. Filter by Service (All 'Haircut' appointments)
SELECT 
    u.name AS user_name,
    s.name AS service_name,
    a.appointment_time
FROM appointments a
JOIN users u ON a.user_id = u.id
JOIN services s ON a.service_id = s.id
WHERE s.name = 'Haircut'
ORDER BY a.appointment_time;

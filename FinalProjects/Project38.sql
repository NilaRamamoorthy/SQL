-- 1. Create Database
CREATE DATABASE qr_code_entry_log;
USE qr_code_entry_log;

-- 2. Create Tables

-- Locations
CREATE TABLE locations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Users
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Entry Logs
CREATE TABLE entry_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    location_id INT NOT NULL,
    entry_time DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (location_id) REFERENCES locations(id) ON DELETE CASCADE
);

-- 3. Insert Sample Data

-- Locations
INSERT INTO locations (name) VALUES
('Main Office'),
('Warehouse'),
('Research Lab');

-- Users
INSERT INTO users (name) VALUES
('Alice Smith'),
('Bob Johnson'),
('Charlie Lee'),
('Diana White');

-- Entry Logs
INSERT INTO entry_logs (user_id, location_id, entry_time) VALUES
(1, 1, '2025-08-10 08:55:00'),
(2, 1, '2025-08-10 09:05:00'),
(3, 2, '2025-08-10 09:15:00'),
(1, 3, '2025-08-10 10:00:00'),
(4, 1, '2025-08-10 10:20:00'),
(2, 2, '2025-08-11 08:45:00'),
(3, 3, '2025-08-11 09:00:00'),
(1, 1, '2025-08-11 09:10:00');

-- 4. Query: Count entries per location
SELECT 
    l.name AS location_name,
    COUNT(e.id) AS total_entries
FROM locations l
LEFT JOIN entry_logs e ON l.id = e.location_id
GROUP BY l.id
ORDER BY total_entries DESC;

-- 5. Query: Filter entries by specific date
SELECT 
    e.id AS entry_id,
    u.name AS user_name,
    l.name AS location_name,
    e.entry_time
FROM entry_logs e
JOIN users u ON e.user_id = u.id
JOIN locations l ON e.location_id = l.id
WHERE DATE(e.entry_time) = '2025-08-10'
ORDER BY e.entry_time;

-- 6. Query: Entries in the last 2 hours
SELECT 
    u.name AS user_name,
    l.name AS location_name,
    e.entry_time
FROM entry_logs e
JOIN users u ON e.user_id = u.id
JOIN locations l ON e.location_id = l.id
WHERE e.entry_time >= NOW() - INTERVAL 2 HOUR
ORDER BY e.entry_time DESC;

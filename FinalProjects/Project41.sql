-- 1. Create Database
CREATE DATABASE restaurant_reservation;
USE restaurant_reservation;

-- 2. Create Tables

-- Tables in the restaurant
CREATE TABLE tables (
    id INT PRIMARY KEY AUTO_INCREMENT,
    table_number INT NOT NULL UNIQUE,
    capacity INT NOT NULL
);

-- Guests
CREATE TABLE guests (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Reservations
CREATE TABLE reservations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    guest_id INT NOT NULL,
    table_id INT NOT NULL,
    date DATE NOT NULL,
    time_slot VARCHAR(20) NOT NULL, -- e.g., '18:00-20:00'
    FOREIGN KEY (guest_id) REFERENCES guests(id) ON DELETE CASCADE,
    FOREIGN KEY (table_id) REFERENCES tables(id) ON DELETE CASCADE
);

-- 3. Insert Sample Data

-- Restaurant tables
INSERT INTO tables (table_number, capacity) VALUES
(1, 2),
(2, 4),
(3, 4),
(4, 6);

-- Guests
INSERT INTO guests (name) VALUES
('John Doe'),
('Alice Johnson'),
('Bob Smith'),
('Emma Brown');

-- Reservations
INSERT INTO reservations (guest_id, table_id, date, time_slot) VALUES
(1, 1, '2025-08-11', '18:00-20:00'),
(2, 2, '2025-08-11', '19:00-21:00'),
(3, 3, '2025-08-11', '18:00-20:00'),
(4, 4, '2025-08-12', '20:00-22:00');

-- 4. Query: Detect overlapping reservations for a table
-- (Assuming same date and overlapping time slot is a conflict)
SELECT r1.id AS reservation1_id, r2.id AS reservation2_id, t.table_number, r1.date, r1.time_slot, r2.time_slot
FROM reservations r1
JOIN reservations r2 
    ON r1.table_id = r2.table_id
    AND r1.date = r2.date
    AND r1.id < r2.id
JOIN tables t ON r1.table_id = t.id
WHERE (
    SUBSTRING_INDEX(r1.time_slot, '-', 1) < SUBSTRING_INDEX(r2.time_slot, '-', -1)
    AND SUBSTRING_INDEX(r1.time_slot, '-', -1) > SUBSTRING_INDEX(r2.time_slot, '-', 1)
);

-- 5. Query: Daily reservation summary (count & guests)
SELECT 
    date,
    COUNT(*) AS total_reservations,
    GROUP_CONCAT(g.name ORDER BY g.name SEPARATOR ', ') AS guest_list
FROM reservations r
JOIN guests g ON r.guest_id = g.id
GROUP BY date
ORDER BY date;

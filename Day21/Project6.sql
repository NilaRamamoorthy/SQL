-- 1. Create Database
CREATE DATABASE hotel_booking;
USE hotel_booking;

-- 2. Create Tables

CREATE TABLE rooms (
    id INT PRIMARY KEY AUTO_INCREMENT,
    room_number VARCHAR(20) NOT NULL,
    room_type VARCHAR(50) NOT NULL
);

CREATE TABLE guests (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE bookings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    guest_id INT NOT NULL,
    room_id INT NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    FOREIGN KEY (guest_id) REFERENCES guests(id),
    FOREIGN KEY (room_id) REFERENCES rooms(id)
);

CREATE TABLE payments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    paid_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(id)
);

-- 3. Insert Sample Data

INSERT INTO rooms (room_number, room_type) VALUES
('101', 'Single'),
('102', 'Double'),
('103', 'Single'),
('104', 'Suite'),
('105', 'Double');

INSERT INTO guests (name) VALUES
('Alice'),
('Bob'),
('Charlie'),
('Diana');

INSERT INTO bookings (guest_id, room_id, from_date, to_date) VALUES
(1, 1, '2025-07-01', '2025-07-05'),
(2, 2, '2025-07-02', '2025-07-06'),
(1, 1, '2025-07-10', '2025-07-12'),
(3, 3, '2025-07-03', '2025-07-07'),
(4, 4, '2025-07-04', '2025-07-08'),
(2, 2, '2025-07-10', '2025-07-15'),
(1, 5, '2025-07-05', '2025-07-07'),
(1, 1, '2025-07-15', '2025-07-18'),
(3, 1, '2025-07-20', '2025-07-22'),
(4, 2, '2025-07-21', '2025-07-23'),
(2, 2, '2025-07-25', '2025-07-30');

INSERT INTO payments (booking_id, amount) VALUES
(1, 500.00),
(2, 700.00),
(3, 250.00),
(4, 400.00),
(5, 1000.00),
(6, 900.00),
(7, 300.00),
(8, 450.00),
(9, 350.00),
(10, 600.00),
(11, 800.00);

-- 4. Queries

-- a) Total amount paid per guest
SELECT
    g.id AS guest_id,
    g.name AS guest_name,
    COALESCE(SUM(p.amount), 0) AS total_paid
FROM guests g
LEFT JOIN bookings b ON g.id = b.guest_id
LEFT JOIN payments p ON b.id = p.booking_id
GROUP BY g.id, g.name;

-- b) Rooms booked more than 5 times (COUNT, HAVING)
SELECT
    r.id AS room_id,
    r.room_number,
    COUNT(b.id) AS booking_count
FROM rooms r
LEFT JOIN bookings b ON r.id = b.room_id
GROUP BY r.id, r.room_number
HAVING booking_count > 5;

-- c) Group bookings by room type and calculate avg stay duration
SELECT
    r.room_type,
    AVG(DATEDIFF(b.to_date, b.from_date)) AS avg_stay_days
FROM rooms r
JOIN bookings b ON r.id = b.room_id
GROUP BY r.room_type;

-- d) INNER JOIN: guests ↔ bookings ↔ rooms
SELECT
    g.name AS guest_name,
    r.room_number,
    r.room_type,
    b.from_date,
    b.to_date
FROM guests g
JOIN bookings b ON g.id = b.guest_id
JOIN rooms r ON b.room_id = r.id;

-- e) FULL OUTER JOIN: rooms and bookings
-- MySQL doesn't support FULL OUTER JOIN natively.
-- Workaround with UNION of LEFT and RIGHT JOIN

SELECT
    r.id AS room_id,
    r.room_number,
    b.id AS booking_id,
    b.guest_id,
    b.from_date,
    b.to_date
FROM rooms r
LEFT JOIN bookings b ON r.id = b.room_id

UNION

SELECT
    r.id AS room_id,
    r.room_number,
    b.id AS booking_id,
    b.guest_id,
    b.from_date,
    b.to_date
FROM bookings b
LEFT JOIN rooms r ON r.id = b.room_id;

-- f) SELF JOIN to find guests who booked same room multiple times

SELECT
    b1.guest_id,
    g.name AS guest_name,
    b1.room_id,
    r.room_number,
    b1.from_date AS booking1_start,
    b1.to_date AS booking1_end,
    b2.from_date AS booking2_start,
    b2.to_date AS booking2_end
FROM bookings b1
JOIN bookings b2 
    ON b1.guest_id = b2.guest_id
    AND b1.room_id = b2.room_id
    AND b1.id < b2.id
JOIN guests g ON b1.guest_id = g.id
JOIN rooms r ON b1.room_id = r.id
ORDER BY b1.guest_id, b1.room_id;

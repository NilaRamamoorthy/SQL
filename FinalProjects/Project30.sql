-- 1. Create Database
CREATE DATABASE hotel_booking_system;
USE hotel_booking_system;

-- 2. Create Tables

-- Rooms Table
CREATE TABLE rooms (
    id INT PRIMARY KEY AUTO_INCREMENT,
    number VARCHAR(10) NOT NULL UNIQUE,
    type ENUM('Single', 'Double', 'Suite') NOT NULL
);

-- Guests Table
CREATE TABLE guests (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Bookings Table
CREATE TABLE bookings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    room_id INT NOT NULL,
    guest_id INT NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE CASCADE,
    FOREIGN KEY (guest_id) REFERENCES guests(id) ON DELETE CASCADE,
    CHECK (from_date < to_date)
);

-- 3. Insert Sample Data

-- Rooms
INSERT INTO rooms (number, type) VALUES
('101', 'Single'),
('102', 'Double'),
('201', 'Suite');

-- Guests
INSERT INTO guests (name) VALUES
('John Doe'),
('Emily Carter'),
('Michael Brown');

-- Bookings
INSERT INTO bookings (room_id, guest_id, from_date, to_date) VALUES
(1, 1, '2025-08-10', '2025-08-12'),
(2, 2, '2025-08-11', '2025-08-15'),
(3, 3, '2025-08-09', '2025-08-11');

-- 4. Query: Find available rooms for a given date range (Example: 2025-08-11 to 2025-08-13)
SELECT r.id, r.number, r.type
FROM rooms r
WHERE r.id NOT IN (
    SELECT b.room_id
    FROM bookings b
    WHERE ('2025-08-11' < b.to_date) AND ('2025-08-13' > b.from_date)
);

-- 5. Query: Check overlapping bookings for a specific room (Example: Room 101)
SELECT b.*
FROM bookings b
JOIN rooms r ON b.room_id = r.id
WHERE r.number = '101'
AND ('2025-08-11' < b.to_date) AND ('2025-08-13' > b.from_date);

-- 6. Query: All bookings with guest and room details
SELECT 
    g.name AS guest_name,
    r.number AS room_number,
    r.type AS room_type,
    b.from_date,
    b.to_date
FROM bookings b
JOIN guests g ON b.guest_id = g.id
JOIN rooms r ON b.room_id = r.id
ORDER BY b.from_date;

-- 7. Query: Count bookings per room
SELECT 
    r.number AS room_number,
    COUNT(b.id) AS total_bookings
FROM rooms r
LEFT JOIN bookings b ON r.id = b.room_id
GROUP BY r.id;

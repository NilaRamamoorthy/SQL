-- Create database and use it
CREATE DATABASE IF NOT EXISTS hotel_guest_db;
USE hotel_guest_db;

-- Create the guests table
CREATE TABLE guests (
  guest_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  room_type VARCHAR(50),
  check_in DATE NOT NULL,
  check_out DATE NOT NULL,
  payment_status VARCHAR(20)
);

-- Insert sample data
INSERT INTO guests (name, room_type, check_in, check_out, payment_status) VALUES
('Kevin Jones',   'Suite',    '2025-07-25', '2025-08-02', 'Paid'),
('Karen Smith',   'Deluxe',   '2025-07-28', '2025-08-03', NULL),
('Kyle Brown',    'Standard', '2025-08-01', '2025-08-05', 'Paid'),
('Kim Nguyen',    'Deluxe',   '2025-08-04', '2025-08-07', NULL),
('Alan Walker',   'Standard', '2025-07-20', '2025-07-22', 'Paid'),
('Kate Winslet',  'Suite',    '2025-08-02', '2025-08-06', 'Pending');

-- 1. Guests who stayed between two dates, with NULL payment_status
SELECT name, room_type, check_in
FROM guests
WHERE check_in BETWEEN '2025-07-30' AND '2025-08-05'
  AND payment_status IS NULL
ORDER BY check_out DESC, name ASC;

-- 2. Guests whose names start with 'K'
SELECT name, room_type, check_in
FROM guests
WHERE name LIKE 'K%'
ORDER BY check_out DESC, name ASC;

-- 3. List all distinct room types
SELECT DISTINCT room_type
FROM guests
ORDER BY room_type ASC;

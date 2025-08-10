-- 1. Create Database and Use
CREATE DATABASE IF NOT EXISTS hotel_system;
USE hotel_system;

-- 2. Create Tables

CREATE TABLE rooms (
    id INT PRIMARY KEY AUTO_INCREMENT,
    room_number VARCHAR(20),
    room_type VARCHAR(50) -- e.g. Economy, Deluxe, Suite
);

CREATE TABLE guests (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    email VARCHAR(255)
);

CREATE TABLE bookings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    guest_id INT,
    room_id INT,
    check_in DATE,
    check_out DATE,
    status ENUM('Completed', 'Upcoming'),
    FOREIGN KEY (guest_id) REFERENCES guests(id),
    FOREIGN KEY (room_id) REFERENCES rooms(id)
);

CREATE TABLE payments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT,
    amount DECIMAL(10, 2),
    payment_date DATE,
    FOREIGN KEY (booking_id) REFERENCES bookings(id)
);

-- 3. Insert Sample Data

INSERT INTO rooms (room_number, room_type) VALUES
('101', 'Economy'),
('102', 'Deluxe'),
('103', 'Suite'),
('104', 'Economy'),
('105', 'Deluxe');

INSERT INTO guests (name, email) VALUES
('Alice Johnson', 'alice@example.com'),
('Bob Smith', 'bob@example.com'),
('Carol White', 'carol@example.com');

INSERT INTO bookings (guest_id, room_id, check_in, check_out, status) VALUES
(1, 1, '2025-07-01', '2025-07-05', 'Completed'),
(2, 2, '2025-07-10', '2025-07-12', 'Upcoming'),
(1, 3, '2025-07-15', '2025-07-20', 'Upcoming'),
(3, 1, '2025-06-20', '2025-06-25', 'Completed'),
(2, 5, '2025-07-03', '2025-07-08', 'Completed');

INSERT INTO payments (booking_id, amount, payment_date) VALUES
(1, 500.00, '2025-07-01'),
(3, 1200.00, '2025-07-15'),
(4, 400.00, '2025-06-20'),
(5, 700.00, '2025-07-03');

-- 4. Subquery in SELECT to show bill summary per guest (total amount paid)

SELECT
    g.id AS guest_id,
    g.name AS guest_name,
    (
        SELECT COALESCE(SUM(p.amount), 0)
        FROM bookings b
        JOIN payments p ON b.id = p.booking_id
        WHERE b.guest_id = g.id
    ) AS total_amount_paid
FROM guests g;

-- 5. CASE to label room types (assuming room_type stored literally, but show example with CASE)

SELECT
    id,
    room_number,
    room_type,
    CASE
        WHEN room_type = 'Economy' THEN 'Economy'
        WHEN room_type = 'Deluxe' THEN 'Deluxe'
        WHEN room_type = 'Suite' THEN 'Suite'
        ELSE 'Other'
    END AS room_type_label
FROM rooms;

-- 6. UNION to combine completed and upcoming bookings

SELECT
    id,
    guest_id,
    room_id,
    check_in,
    check_out,
    status
FROM bookings
WHERE status = 'Completed'

UNION ALL

SELECT
    id,
    guest_id,
    room_id,
    check_in,
    check_out,
    status
FROM bookings
WHERE status = 'Upcoming';

-- 7. Correlated subquery to find most frequent guest per room type

SELECT DISTINCT
    r.room_type,
    (
        SELECT g.name
        FROM bookings b
        JOIN guests g ON b.guest_id = g.id
        WHERE b.room_id = r.id
        GROUP BY g.id
        ORDER BY COUNT(*) DESC
        LIMIT 1
    ) AS most_frequent_guest
FROM rooms r;

-- 8. JOIN + GROUP BY for revenue per room type

SELECT
    r.room_type,
    COALESCE(SUM(p.amount), 0) AS total_revenue
FROM rooms r
LEFT JOIN bookings b ON r.id = b.room_id
LEFT JOIN payments p ON b.id = p.booking_id
GROUP BY r.room_type;

-- 9. Date filtering for check-in/check-out analytics (e.g., bookings in July 2025)

SELECT
    b.id,
    g.name AS guest_name,
    r.room_number,
    b.check_in,
    b.check_out,
    b.status
FROM bookings b
JOIN guests g ON b.guest_id = g.id
JOIN rooms r ON b.room_id = r.id
WHERE (b.check_in BETWEEN '2025-07-01' AND '2025-07-31')
   OR (b.check_out BETWEEN '2025-07-01' AND '2025-07-31');

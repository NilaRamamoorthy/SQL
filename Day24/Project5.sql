-- Step 1: Create Database and Use It
CREATE DATABASE HotelBooking;
USE HotelBooking;

-- Step 2: Normalize to 3NF — Table Definitions
CREATE TABLE guests (
  guest_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100),
  email VARCHAR(200),
  phone VARCHAR(50)
);

CREATE TABLE room_types (
  room_type_id INT PRIMARY KEY AUTO_INCREMENT,
  type_name VARCHAR(50),
  description TEXT,
  price_per_night DECIMAL(10,2)
);

CREATE TABLE rooms (
  room_id INT PRIMARY KEY AUTO_INCREMENT,
  room_number VARCHAR(10),
  room_type_id INT,
  FOREIGN KEY (room_type_id) REFERENCES room_types(room_type_id)
);

CREATE TABLE bookings (
  booking_id INT PRIMARY KEY AUTO_INCREMENT,
  guest_id INT,
  room_id INT,
  check_in DATE,
  check_out DATE,
  status VARCHAR(50),
  FOREIGN KEY (guest_id) REFERENCES guests(guest_id),
  FOREIGN KEY (room_id) REFERENCES rooms(room_id)
);

CREATE TABLE payments (
  payment_id INT PRIMARY KEY AUTO_INCREMENT,
  booking_id INT,
  amount DECIMAL(10,2),
  payment_date DATE,
  method VARCHAR(50),
  FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);

-- Step 3: Insert Sample Data
INSERT INTO guests (name, email, phone) VALUES
('Ravi Kumar', 'ravi.kumar@example.com', '9876543210'),
('Sita Sharma', 'sita.sharma@example.com', '8765432109'),
('Anil Mehta', 'anil.mehta@example.com', '7654321098'),
('Pooja Singh', 'pooja.singh@example.com', '6543210987'),
('Rahul Patel', 'rahul.patel@example.com', '5432109876');

INSERT INTO room_types (type_name, description, price_per_night) VALUES
('Standard', 'Basic amenities', 100.00),
('Deluxe', 'Luxury amenities', 150.00),
('Suite', 'Premium suite', 300.00);

INSERT INTO rooms (room_number, room_type_id) VALUES
('101', 1),
('102', 1),
('201', 2),
('301', 3),
('401', 2);

INSERT INTO bookings (guest_id, room_id, check_in, check_out, status) VALUES
(1, 101, '2025-05-20', '2025-05-22', 'Checked-out'),
(2, 102, '2025-05-22', '2025-05-27', 'Checked-out'),
(3, 201, '2025-05-23', '2025-05-28', 'Checked-out'),
(4, 301, '2025-05-24', '2025-05-25', 'Checked-out'),
(5, 401, '2025-05-25', '2025-05-30', 'Checked-out'),
(1, 201, '2025-06-01', '2025-06-03', 'Checked-out');

INSERT INTO payments (booking_id, amount, payment_date, method) VALUES
(1, 200.00, '2025-05-22', 'Credit Card'),
(2, 500.00, '2025-05-27', 'Cash'),
(3, 750.00, '2025-05-28', 'Credit Card'),
(4, 150.00, '2025-05-25', 'Cash'),
(5, 1000.00, '2025-05-30', 'Credit Card'),
(6, 600.00, '2025-06-03', 'Debit Card');

-- Step 4: Create Indexes for Performance
CREATE INDEX idx_room_type ON rooms(room_type_id);
CREATE INDEX idx_check_in ON bookings(check_in);
CREATE INDEX idx_bookings_guest ON bookings(guest_id);

-- Step 5: Analyze Execution Plan for Booking History Queries
EXPLAIN
SELECT b.booking_id, g.name, r.room_number, b.check_in, b.check_out
FROM bookings b
JOIN guests g ON b.guest_id = g.guest_id
JOIN rooms r ON b.room_id = r.room_id
WHERE b.guest_id = 1
  AND b.check_in BETWEEN '2025-05-01' AND '2025-06-30';

-- Step 6: Optimize Join Performance Across Guests, Rooms, Payments
EXPLAIN
SELECT g.name AS guest, r.room_number, p.amount, p.payment_date
FROM payments p
JOIN bookings b ON p.booking_id = b.booking_id
JOIN guests g ON b.guest_id = g.guest_id
JOIN rooms r ON b.room_id = r.room_id
WHERE p.payment_date >= '2025-05-01';

-- Step 7: Denormalized Table for Daily Revenue Reporting
CREATE TABLE daily_revenue AS
SELECT
  b.check_in AS date,
  SUM(p.amount) AS total_revenue,
  COUNT(DISTINCT b.booking_id) AS bookings_count
FROM bookings b
JOIN payments p ON b.booking_id = p.booking_id
GROUP BY b.check_in;

CREATE INDEX idx_daily_revenue_date ON daily_revenue(date);

-- Step 8: Top 10 Highest-Paying Guests
SELECT g.guest_id, g.name, SUM(p.amount) AS total_paid
FROM guests g
JOIN bookings b ON g.guest_id = b.guest_id
JOIN payments p ON b.booking_id = p.booking_id
GROUP BY g.guest_id, g.name
ORDER BY total_paid DESC
LIMIT 10;

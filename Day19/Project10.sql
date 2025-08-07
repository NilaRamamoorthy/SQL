-- Create database and use
DROP DATABASE IF EXISTS hotel_db;
CREATE DATABASE hotel_db;
USE hotel_db;

-- Create tables
CREATE TABLE rooms (
  room_id INT AUTO_INCREMENT PRIMARY KEY,
  room_type VARCHAR(50) NOT NULL,
  rate_per_night DECIMAL(8,2) NOT NULL
);

CREATE TABLE guests (
  guest_id INT AUTO_INCREMENT PRIMARY KEY,
  guest_name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE
);

CREATE TABLE services (
  service_id INT AUTO_INCREMENT PRIMARY KEY,
  description VARCHAR(100) NOT NULL,
  charge DECIMAL(8,2) NOT NULL
);

CREATE TABLE bookings (
  booking_id INT AUTO_INCREMENT PRIMARY KEY,
  guest_id INT NOT NULL,
  room_id INT NOT NULL,
  checkin_date DATE NOT NULL,
  checkout_date DATE NOT NULL,
  FOREIGN KEY (guest_id) REFERENCES guests(guest_id),
  FOREIGN KEY (room_id) REFERENCES rooms(room_id)
);

CREATE TABLE booking_services (
  booking_id INT,
  service_id INT,
  quantity INT DEFAULT 1,
  PRIMARY KEY (booking_id, service_id),
  FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
  FOREIGN KEY (service_id) REFERENCES services(service_id)
);

-- Insert sample data
INSERT INTO rooms (room_type, rate_per_night) VALUES
('Single', 50.00),
('Double', 80.00),
('Suite', 150.00),
('Family', 120.00),
('Deluxe', 200.00);

INSERT INTO guests (guest_name, email) VALUES
('Alice','alice@hotel.com'),
('Bob','bob@hotel.com'),
('Charlie','charlie@hotel.com'),
('Diana','diana@hotel.com'),
('Eve','eve@hotel.com'),
('Frank','frank@hotel.com'),
('Grace','grace@hotel.com'),
('Henry','henry@hotel.com'),
('Ivy','ivy@hotel.com'),
('Jack','jack@hotel.com');

INSERT INTO services (description, charge) VALUES
('Breakfast', 10.00),
('Spa', 50.00),
('Laundry', 15.00),
('Airport Pickup', 30.00);

INSERT INTO bookings (guest_id, room_id, checkin_date, checkout_date) VALUES
(1,1,'2025-08-01','2025-08-05'),
(2,2,'2025-08-03','2025-08-06'),
(3,3,'2025-08-04','2025-08-10'),
(4,4,'2025-08-02','2025-08-04'),
(5,5,'2025-08-06','2025-08-09'),
(6,1,'2025-08-07','2025-08-10'),
(7,2,'2025-08-08','2025-08-12'),
(8,3,'2025-08-05','2025-08-08'),
(9,4,'2025-08-09','2025-08-12'),
(10,5,'2025-08-10','2025-08-13');

INSERT INTO booking_services (booking_id, service_id, quantity) VALUES
(1,1,4),(1,2,1),
(2,1,3),
(3,3,2),(3,4,1),
(4,1,2),
(5,2,1),(5,4,1),
(6,1,3),(6,3,1),
(7,1,4),
(8,2,1),(8,3,1),
(9,1,5),(9,4,1),
(10,1,3),(10,2,1);

-- Queries

-- 1. Show booking duration (days) per booking
SELECT b.booking_id, g.guest_name, r.room_type,
  DATEDIFF(b.checkout_date, b.checkin_date) AS nights
FROM bookings b
JOIN guests g ON g.guest_id = b.guest_id
JOIN rooms r ON r.room_id = b.room_id;

-- 2. Total service charges per guest
SELECT g.guest_name, SUM(s.charge * bs.quantity) AS total_service_charges
FROM booking_services bs
JOIN bookings b ON bs.booking_id = b.booking_id
JOIN guests g ON b.guest_id = g.guest_id
JOIN services s ON bs.service_id = s.service_id
GROUP BY g.guest_id;

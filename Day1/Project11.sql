-- Drop and create the database
DROP DATABASE IF EXISTS airline_db;
CREATE DATABASE airline_db;
USE airline_db;

-- Create the airports table
CREATE TABLE airports (
    airport_id INT AUTO_INCREMENT PRIMARY KEY,
    airport_name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    code VARCHAR(10) UNIQUE NOT NULL
);

-- Create the flights table
CREATE TABLE flights (
    flight_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_number VARCHAR(10) UNIQUE NOT NULL,
    departure_airport_id INT,
    arrival_airport_id INT,
    departure_time DATETIME,
    arrival_time DATETIME,
    FOREIGN KEY (departure_airport_id) REFERENCES airports(airport_id),
    FOREIGN KEY (arrival_airport_id) REFERENCES airports(airport_id)
);

-- Create the passengers table
CREATE TABLE passengers (
    passenger_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    passport_number VARCHAR(20) UNIQUE NOT NULL
);

-- Create the bookings table
CREATE TABLE bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    passenger_id INT NOT NULL,
    flight_id INT NOT NULL,
    seat_number VARCHAR(10),
    booking_date DATE,
    FOREIGN KEY (passenger_id) REFERENCES passengers(passenger_id),
    FOREIGN KEY (flight_id) REFERENCES flights(flight_id)
);

-- Insert sample airports
INSERT INTO airports (airport_name, city, code) VALUES
('Indira Gandhi International Airport', 'Delhi', 'DEL'),
('Chhatrapati Shivaji Maharaj International', 'Mumbai', 'BOM'),
('Kempegowda International Airport', 'Bangalore', 'BLR'),
('Rajiv Gandhi International Airport', 'Hyderabad', 'HYD'),
('Netaji Subhas Chandra Bose Intl', 'Kolkata', 'CCU');

-- Insert sample flights
INSERT INTO flights (flight_number, departure_airport_id, arrival_airport_id, departure_time, arrival_time) VALUES
('AI101', 1, 2, '2025-08-01 08:00:00', '2025-08-01 10:00:00'),
('6E203', 2, 3, '2025-08-01 11:00:00', '2025-08-01 13:00:00'),
('SG305', 3, 4, '2025-08-01 14:00:00', '2025-08-01 16:00:00'),
('AI202', 1, 5, '2025-08-02 09:30:00', '2025-08-02 12:30:00'),
('6E450', 5, 1, '2025-08-03 07:00:00', '2025-08-03 10:00:00');

-- Insert sample passengers
INSERT INTO passengers (full_name, passport_number) VALUES
('Alice Sharma', 'P123456'),
('Bob Verma', 'P123457'),
('Charlie Das', 'P123458'),
('Diana Roy', 'P123459'),
('Eve Iyer', 'P123460'),
('Frank Dutta', 'P123461'),
('Grace Kapoor', 'P123462'),
('Henry Singh', 'P123463'),
('Ivy Mehta', 'P123464'),
('Jack Rao', 'P123465');

-- Insert bookings
INSERT INTO bookings (passenger_id, flight_id, seat_number, booking_date) VALUES
(1, 1, '12A', '2025-07-25'),
(2, 1, '12B', '2025-07-25'),
(3, 2, '14C', '2025-07-25'),
(4, 3, '15D', '2025-07-26'),
(5, 4, '16E', '2025-07-27'),
(6, 4, '16F', '2025-07-27'),
(7, 5, '10A', '2025-07-28'),
(8, 5, '10B', '2025-07-28'),
(9, 2, '14D', '2025-07-25'),
(10, 3, '15E', '2025-07-26');

-- 🔍 Query 1: List all flights between two airports (e.g., DEL to BOM)
SELECT 
    f.flight_number,
    a1.code AS departure_code,
    a2.code AS arrival_code,
    f.departure_time,
    f.arrival_time
FROM flights f
JOIN airports a1 ON f.departure_airport_id = a1.airport_id
JOIN airports a2 ON f.arrival_airport_id = a2.airport_id
WHERE a1.code = 'DEL' AND a2.code = 'BOM';

-- 🔍 Query 2: Passenger manifest for a flight (e.g., flight_id = 1)
SELECT 
    f.flight_number,
    p.full_name,
    b.seat_number
FROM bookings b
JOIN passengers p ON b.passenger_id = p.passenger_id
JOIN flights f ON b.flight_id = f.flight_id
WHERE f.flight_id = 1;

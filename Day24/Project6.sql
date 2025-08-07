-- Step 1: Create Database and Switch Context
CREATE DATABASE FlightReservationSystem;
USE FlightReservationSystem;

-- Step 2: Create normalized tables (3NF)

-- Airlines
CREATE TABLE airlines (
    airline_id INT PRIMARY KEY AUTO_INCREMENT,
    airline_name VARCHAR(255) NOT NULL UNIQUE
);

-- Airports
CREATE TABLE airports (
    airport_id INT PRIMARY KEY AUTO_INCREMENT,
    airport_code VARCHAR(10) NOT NULL UNIQUE,
    airport_name VARCHAR(255) NOT NULL,
    city VARCHAR(100),
    country VARCHAR(100)
);

-- Passengers
CREATE TABLE passengers (
    passenger_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE
);

-- Flights
CREATE TABLE flights (
    flight_id INT PRIMARY KEY AUTO_INCREMENT,
    airline_id INT NOT NULL,
    flight_number VARCHAR(20) NOT NULL,
    departure_airport INT NOT NULL,
    arrival_airport INT NOT NULL,
    flight_date DATE NOT NULL,
    departure_time TIME,
    arrival_time TIME,
    FOREIGN KEY (airline_id) REFERENCES airlines(airline_id),
    FOREIGN KEY (departure_airport) REFERENCES airports(airport_id),
    FOREIGN KEY (arrival_airport) REFERENCES airports(airport_id)
);

-- Bookings
CREATE TABLE bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    passenger_id INT NOT NULL,
    flight_id INT NOT NULL,
    booking_date DATE NOT NULL,
    seat_number VARCHAR(10),
    FOREIGN KEY (passenger_id) REFERENCES passengers(passenger_id),
    FOREIGN KEY (flight_id) REFERENCES flights(flight_id)
);


-- Insert sample data 


-- Airlines
INSERT INTO airlines (airline_name) VALUES
('Sky High Airlines'),
('Global Wings'),
('FastJet'),
('Cloud Nine Air');

-- Airports
INSERT INTO airports (airport_code, airport_name, city, country) VALUES
('JFK', 'John F. Kennedy International Airport', 'New York', 'USA'),
('LAX', 'Los Angeles International Airport', 'Los Angeles', 'USA'),
('LHR', 'Heathrow Airport', 'London', 'UK'),
('CDG', 'Charles de Gaulle Airport', 'Paris', 'France'),
('DXB', 'Dubai International Airport', 'Dubai', 'UAE');

-- Passengers
INSERT INTO passengers (first_name, last_name, email) VALUES
('Alice', 'Smith', 'alice.smith@example.com'),
('Bob', 'Johnson', 'bob.johnson@example.com'),
('Charlie', 'Brown', 'charlie.brown@example.com'),
('Diana', 'Prince', 'diana.prince@example.com'),
('Ethan', 'Hunt', 'ethan.hunt@example.com');

-- Flights
INSERT INTO flights (airline_id, flight_number, departure_airport, arrival_airport, flight_date, departure_time, arrival_time) VALUES
(1, 'SH123', 1, 2, '2025-08-20', '09:00:00', '12:00:00'),
(2, 'GW456', 2, 3, '2025-08-21', '14:30:00', '22:00:00'),
(3, 'FJ789', 3, 4, '2025-08-22', '08:00:00', '10:00:00'),
(1, 'SH101', 4, 5, '2025-08-23', '15:45:00', '20:00:00'),
(4, 'CN202', 5, 1, '2025-08-24', '06:00:00', '12:30:00'),
(2, 'GW303', 1, 3, '2025-09-01', '10:00:00', '18:00:00');

-- Bookings
INSERT INTO bookings (passenger_id, flight_id, booking_date, seat_number) VALUES
(1, 1, '2025-07-01', '12A'),
(1, 6, '2025-07-15', '14C'),
(2, 2, '2025-07-02', '7B'),
(3, 3, '2025-07-03', '8C'),
(4, 4, '2025-07-04', '3D'),
(5, 5, '2025-07-05', '2A'),
(2, 6, '2025-07-10', '16F'),
(3, 1, '2025-07-11', '9A');



-- Step 3: Create Indexes for faster searches
CREATE INDEX idx_flight_date ON flights(flight_date);
CREATE INDEX idx_departure_airport ON flights(departure_airport);
CREATE INDEX idx_passenger_id ON bookings(passenger_id);

-- Step 4: EXPLAIN example to analyze search by airport and date
EXPLAIN
SELECT f.flight_id, f.flight_number, a.airline_name, ap1.airport_code AS departure, ap2.airport_code AS arrival, f.flight_date
FROM flights f
JOIN airlines a ON f.airline_id = a.airline_id
JOIN airports ap1 ON f.departure_airport = ap1.airport_id
JOIN airports ap2 ON f.arrival_airport = ap2.airport_id
WHERE f.departure_airport = 1
  AND f.flight_date = '2025-09-01';

-- Step 5: Subquery to find passengers with the most flights
SELECT p.passenger_id, p.first_name, p.last_name, COUNT(b.flight_id) AS flight_count
FROM passengers p
JOIN bookings b ON p.passenger_id = b.passenger_id
GROUP BY p.passenger_id, p.first_name, p.last_name
ORDER BY flight_count DESC
LIMIT 10;

-- Step 6: Create denormalized table for frequent flyer reporting
CREATE TABLE frequent_flyers AS
SELECT 
  p.passenger_id,
  p.first_name,
  p.last_name,
  COUNT(b.flight_id) AS total_flights,
  MIN(b.booking_date) AS first_booking,
  MAX(f.flight_date) AS last_flight_date
FROM passengers p
JOIN bookings b ON p.passenger_id = b.passenger_id
JOIN flights f ON b.flight_id = f.flight_id
GROUP BY p.passenger_id, p.first_name, p.last_name;

-- Step 7: Query to display next 5 upcoming flights
SELECT f.flight_id, f.flight_number, a.airline_name, ap1.airport_code AS departure, ap2.airport_code AS arrival, f.flight_date, f.departure_time
FROM flights f
JOIN airlines a ON f.airline_id = a.airline_id
JOIN airports ap1 ON f.departure_airport = ap1.airport_id
JOIN airports ap2 ON f.arrival_airport = ap2.airport_id
WHERE f.flight_date >= CURDATE()
ORDER BY f.flight_date, f.departure_time
LIMIT 5;


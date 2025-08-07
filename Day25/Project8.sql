

-- Step 1: Create Database and Use It
CREATE DATABASE IF NOT EXISTS FlightReservation;
USE FlightReservation;

-- Step 2: Create Normalized Tables

-- Airports
CREATE TABLE airports (
    airport_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    code VARCHAR(10),
    city VARCHAR(100)
);

-- Airlines
CREATE TABLE airlines (
    airline_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    code VARCHAR(10)
);

-- Flights
CREATE TABLE flights (
    flight_id INT PRIMARY KEY AUTO_INCREMENT,
    airline_id INT,
    departure_airport INT,
    arrival_airport INT,
    departure_time DATETIME,
    arrival_time DATETIME,
    notes TEXT,  -- internal notes
    FOREIGN KEY (airline_id) REFERENCES airlines(airline_id),
    FOREIGN KEY (departure_airport) REFERENCES airports(airport_id),
    FOREIGN KEY (arrival_airport) REFERENCES airports(airport_id)
);

-- Passengers
CREATE TABLE passengers (
    passenger_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    email VARCHAR(100)
);

-- Bookings
CREATE TABLE bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    flight_id INT,
    passenger_id INT,
    pnr VARCHAR(10) UNIQUE,
    status VARCHAR(50) DEFAULT 'Booked',
    checkin BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (flight_id) REFERENCES flights(flight_id),
    FOREIGN KEY (passenger_id) REFERENCES passengers(passenger_id)
);

-- Audit Log for Check-ins
CREATE TABLE checkin_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT,
    checkin_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);

-- Step 3: Insert Sample Data

INSERT INTO airports (name, code, city) VALUES
('John F Kennedy Intl', 'JFK', 'New York'),
('Los Angeles Intl', 'LAX', 'Los Angeles');

INSERT INTO airlines (name, code) VALUES
('SkyJet Airways', 'SJ'),
('Eagle Fly', 'EF');

INSERT INTO flights (airline_id, departure_airport, arrival_airport, departure_time, arrival_time, notes)
VALUES
(1, 1, 2, '2025-08-15 08:00:00', '2025-08-15 11:30:00', 'Crew change at JFK'),
(2, 2, 1, '2025-08-16 14:00:00', '2025-08-16 21:00:00', 'Runway maintenance warning');

INSERT INTO passengers (name, email) VALUES
('Alice Johnson', 'alice@example.com'),
('Bob Smith', 'bob@example.com');

-- Step 4: Create View (exclude internal notes and employee info)

CREATE OR REPLACE VIEW view_flight_schedule AS
SELECT
    f.flight_id,
    a1.city AS departure_city,
    a2.city AS arrival_city,
    al.name AS airline,
    f.departure_time,
    f.arrival_time
FROM flights f
JOIN airports a1 ON f.departure_airport = a1.airport_id
JOIN airports a2 ON f.arrival_airport = a2.airport_id
JOIN airlines al ON f.airline_id = al.airline_id;

-- Step 5: Stored Procedure to Book a Flight (returns PNR)

DELIMITER //
CREATE PROCEDURE book_flight(
    IN p_flight_id INT,
    IN p_passenger_id INT,
    OUT p_pnr VARCHAR(10)
)
BEGIN
    SET p_pnr = CONCAT('PNR', LPAD(FLOOR(RAND() * 1000000), 6, '0'));
    
    INSERT INTO bookings (flight_id, passenger_id, pnr)
    VALUES (p_flight_id, p_passenger_id, p_pnr);
END //
DELIMITER ;

-- Step 6: Function to Get Passenger Count Per Flight

DELIMITER //
CREATE FUNCTION get_passenger_count(p_flight_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE count_passengers INT;
    SELECT COUNT(*) INTO count_passengers
    FROM bookings
    WHERE flight_id = p_flight_id;
    RETURN count_passengers;
END //
DELIMITER ;

-- Step 7: Trigger to Log Check-in and Mark as Boarded

DELIMITER //
CREATE TRIGGER after_checkin
AFTER UPDATE ON bookings
FOR EACH ROW
BEGIN
    IF NEW.checkin = TRUE AND OLD.checkin = FALSE THEN
        INSERT INTO checkin_log (booking_id) VALUES (NEW.booking_id);
        UPDATE bookings SET status = 'Boarded' WHERE booking_id = NEW.booking_id;
    END IF;
END //
DELIMITER ;

-- Step 8: Secure Views for Customer Access (no emails or internal data)

CREATE OR REPLACE VIEW view_my_bookings AS
SELECT
    b.pnr,
    f.departure_time,
    f.arrival_time,
    a1.city AS from_city,
    a2.city AS to_city,
    b.status
FROM bookings b
JOIN flights f ON b.flight_id = f.flight_id
JOIN airports a1 ON f.departure_airport = a1.airport_id
JOIN airports a2 ON f.arrival_airport = a2.airport_id;

-- Step 9: Sample Usage

-- View flight schedule (for customers)
SELECT * FROM view_flight_schedule;

-- Book a flight for Alice (passenger_id = 1, flight_id = 1)
CALL book_flight(1, 1, @pnr);
SELECT @pnr AS booked_pnr;

-- Count passengers on flight 1
SELECT get_passenger_count(1) AS passenger_count;

-- Simulate check-in
UPDATE bookings SET checkin = TRUE WHERE pnr = @pnr;

-- View customer-facing bookings
SELECT * FROM view_my_bookings;

-- View check-in logs
SELECT * FROM checkin_log;


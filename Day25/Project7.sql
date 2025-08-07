

-- Step 1: Create Database and Use It
CREATE DATABASE IF NOT EXISTS HotelBookingSystem;
USE HotelBookingSystem;

-- Step 2: Create Tables

-- Rooms table
CREATE TABLE rooms (
    room_id INT PRIMARY KEY AUTO_INCREMENT,
    room_number VARCHAR(10) NOT NULL,
    room_type VARCHAR(50) NOT NULL,
    rate_per_night DECIMAL(10,2) NOT NULL,
    is_available BOOLEAN DEFAULT TRUE
);

-- Maintenance schedule (internal use)
CREATE TABLE maintenance (
    maintenance_id INT PRIMARY KEY AUTO_INCREMENT,
    room_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    notes TEXT,
    FOREIGN KEY (room_id) REFERENCES rooms(room_id)
);

-- Guests
CREATE TABLE guests (
    guest_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    contact_info VARCHAR(100)
);

-- Bookings
CREATE TABLE bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    room_id INT NOT NULL,
    guest_id INT NOT NULL,
    check_in DATE NOT NULL,
    check_out DATE NOT NULL,
    total_cost DECIMAL(10,2),
    FOREIGN KEY (room_id) REFERENCES rooms(room_id),
    FOREIGN KEY (guest_id) REFERENCES guests(guest_id)
);

-- Booking audit log (for internal tracking)
CREATE TABLE booking_audit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT,
    log_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    action VARCHAR(50)
);

-- Step 3: Sample Data

INSERT INTO rooms (room_number, room_type, rate_per_night, is_available) VALUES
('101', 'Single', 100.00, TRUE),
('102', 'Double', 150.00, TRUE),
('201', 'Suite', 300.00, TRUE);

INSERT INTO guests (name, contact_info) VALUES
('Alice Smith', 'alice@example.com'),
('Bob Johnson', 'bob@example.com');

INSERT INTO maintenance (room_id, start_date, end_date, notes) VALUES
(3, '2025-08-10', '2025-08-15', 'AC repair');

-- Step 4: Create View for Receptionists (hide maintenance schedule)

CREATE OR REPLACE VIEW view_available_rooms AS
SELECT room_id, room_number, room_type, rate_per_night
FROM rooms
WHERE is_available = TRUE
  AND room_id NOT IN (
    SELECT room_id
    FROM maintenance
    WHERE CURDATE() BETWEEN start_date AND end_date
  );

-- Step 5: Stored Procedure to Book a Room Atomically

DELIMITER //
CREATE PROCEDURE book_room(
    IN p_room_id INT,
    IN p_guest_id INT,
    IN p_check_in DATE,
    IN p_check_out DATE
)
BEGIN
    DECLARE cost DECIMAL(10,2);

    -- Calculate cost
    SET cost = DATEDIFF(p_check_out, p_check_in) *
               (SELECT rate_per_night FROM rooms WHERE room_id = p_room_id);

    -- Start transaction
    START TRANSACTION;

    -- Insert booking
    INSERT INTO bookings (room_id, guest_id, check_in, check_out, total_cost)
    VALUES (p_room_id, p_guest_id, p_check_in, p_check_out, cost);

    -- Update room availability
    UPDATE rooms SET is_available = FALSE WHERE room_id = p_room_id;

    -- Commit
    COMMIT;
END //
DELIMITER ;

-- Step 6: Function to Calculate Stay Cost

DELIMITER //
CREATE FUNCTION calculate_stay_cost(
    p_room_id INT,
    p_check_in DATE,
    p_check_out DATE
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE rate DECIMAL(10,2);
    DECLARE duration INT;
    SELECT rate_per_night INTO rate FROM rooms WHERE room_id = p_room_id;
    SET duration = DATEDIFF(p_check_out, p_check_in);
    RETURN rate * duration;
END //
DELIMITER ;

-- Step 7: Trigger to Log Booking and Update Room Availability

DELIMITER //
CREATE TRIGGER after_booking
AFTER INSERT ON bookings
FOR EACH ROW
BEGIN
    -- Log the booking
    INSERT INTO booking_audit (booking_id, action)
    VALUES (NEW.booking_id, 'Booking Created');

    -- Already handled by procedure: UPDATE rooms SET is_available = FALSE
END //
DELIMITER ;

-- Step 8: Sample Usage

-- 1. View available rooms for today
SELECT * FROM view_available_rooms;

-- 2. Calculate stay cost for room 1 for 3 nights
SELECT calculate_stay_cost(1, '2025-08-10', '2025-08-13') AS stay_cost;

-- 3. Book a room (room_id 1 for guest_id 1 from 10 to 13 Aug)
CALL book_room(1, 1, '2025-08-10', '2025-08-13');

-- 4. Verify room availability and bookings
SELECT * FROM rooms;
SELECT * FROM bookings;
SELECT * FROM booking_audit;


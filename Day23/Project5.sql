-- Step 1: Create and use database
CREATE DATABASE IF NOT EXISTS HotelDB;
USE HotelDB;

-- Step 2: Create tables

-- Guests table
CREATE TABLE guests (
    guest_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100)
);

-- Rooms table
CREATE TABLE rooms (
    room_id INT PRIMARY KEY AUTO_INCREMENT,
    room_number VARCHAR(10) NOT NULL UNIQUE,
    room_type VARCHAR(50),
    room_capacity INT NOT NULL CHECK (room_capacity > 0),
    status ENUM('Available', 'Occupied', 'Maintenance') DEFAULT 'Available'
);

-- Bookings table
CREATE TABLE bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    guest_id INT NOT NULL,
    room_id INT NOT NULL,
    check_in DATE NOT NULL,
    check_out DATE NOT NULL,
    number_of_guests INT NOT NULL,
    -- CHECK to ensure number_of_guests <= room_capacity (via subquery)
    CONSTRAINT chk_guest_count CHECK (
        number_of_guests <= (
            SELECT room_capacity FROM rooms WHERE room_id = room_id
        )
    ),
    CONSTRAINT chk_min_stay CHECK (
        DATEDIFF(check_out, check_in) >= 1
    ),
    FOREIGN KEY (guest_id) REFERENCES guests(guest_id) ON DELETE CASCADE,
    FOREIGN KEY (room_id) REFERENCES rooms(room_id) ON DELETE RESTRICT
);

-- Payments table
CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_method VARCHAR(50),
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE
);

-- Step 3: Insert sample data

INSERT INTO guests (name, phone, email) VALUES
('John Doe', '1234567890', 'john@example.com'),
('Jane Smith', '0987654321', 'jane@example.com');

INSERT INTO rooms (room_number, room_type, room_capacity, status) VALUES
('101', 'Single', 1, 'Available'),
('102', 'Double', 2, 'Available'),
('201', 'Suite', 4, 'Maintenance');

-- Step 4: Modify and drop a constraint on minimum stay duration

-- Drop existing CHECK constraint on min stay (MySQL 8.0+ syntax)
ALTER TABLE bookings DROP CHECK chk_min_stay;

-- Add new CHECK for minimum stay of 2 days
ALTER TABLE bookings ADD CONSTRAINT chk_min_stay CHECK (
    DATEDIFF(check_out, check_in) >= 2
);

-- Step 5: Procedure to make booking and payment in one transaction

DELIMITER //
CREATE PROCEDURE make_booking_payment(
    IN p_guest_id INT,
    IN p_room_id INT,
    IN p_check_in DATE,
    IN p_check_out DATE,
    IN p_number_of_guests INT,
    IN p_amount DECIMAL(10,2),
    IN p_payment_method VARCHAR(50)
)
BEGIN
    DECLARE v_booking_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transaction failed, rolled back';
    END;

    START TRANSACTION;

    -- Insert booking
    INSERT INTO bookings (guest_id, room_id, check_in, check_out, number_of_guests)
    VALUES (p_guest_id, p_room_id, p_check_in, p_check_out, p_number_of_guests);

    SET v_booking_id = LAST_INSERT_ID();

    -- Insert payment
    INSERT INTO payments (booking_id, amount, payment_method)
    VALUES (v_booking_id, p_amount, p_payment_method);

    -- Update room status to 'Occupied' if booking successful and check-in date is today or earlier
    IF p_check_in <= CURDATE() THEN
        UPDATE rooms SET status = 'Occupied' WHERE room_id = p_room_id;
    END IF;

    COMMIT;
END //
DELIMITER ;

-- Step 6: Trigger to update room status on check-out

DELIMITER //
CREATE TRIGGER after_booking_delete
AFTER DELETE ON bookings
FOR EACH ROW
BEGIN
    -- Check if room has other active bookings
    IF NOT EXISTS (
        SELECT 1 FROM bookings
        WHERE room_id = OLD.room_id
          AND check_out > CURDATE()
    ) THEN
        -- Set room status to Available if no future bookings
        UPDATE rooms SET status = 'Available' WHERE room_id = OLD.room_id;
    END IF;
END //
DELIMITER ;

-- Step 7: Update room status on check-in and check-out manually or via procedures

-- Step 8: Sample usage

-- Successful booking + payment
CALL make_booking_payment(1, 2, '2025-08-10', '2025-08-13', 2, 450.00, 'Credit Card');

-- Try booking with too many guests (should fail)
CALL make_booking_payment(2, 1, '2025-08-15', '2025-08-16', 2, 100.00, 'Cash'); -- 2 guests in room capacity 1

-- Delete booking (payment should cascade delete)
DELETE FROM bookings WHERE booking_id = 1;

-- Check tables
SELECT * FROM guests;
SELECT * FROM rooms;
SELECT * FROM bookings;
SELECT * FROM payments;

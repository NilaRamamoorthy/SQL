CREATE DATABASE IF NOT EXISTS FlightBookingDB;
USE FlightBookingDB;

-- Step 1: Create tables

CREATE TABLE flights (
    flight_id INT PRIMARY KEY AUTO_INCREMENT,
    flight_number VARCHAR(20) NOT NULL UNIQUE,
    departure_airport VARCHAR(50) NOT NULL,
    arrival_airport VARCHAR(50) NOT NULL,
    flight_date DATE NOT NULL,
    status ENUM('Scheduled', 'Delayed', 'Cancelled', 'Completed') DEFAULT 'Scheduled',
    total_seats INT NOT NULL CHECK (total_seats > 0),
    seats_available INT NOT NULL CHECK (seats_available >= 0),
    CHECK (flight_date >= CURDATE())
);

CREATE TABLE passengers (
    passenger_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20)
);

CREATE TABLE tickets (
    ticket_id INT PRIMARY KEY AUTO_INCREMENT,
    flight_id INT NOT NULL,
    passenger_id INT NOT NULL,
    seat_no VARCHAR(10) NOT NULL,
    booked_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    paid BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (flight_id) REFERENCES flights(flight_id) ON DELETE CASCADE,
    FOREIGN KEY (passenger_id) REFERENCES passengers(passenger_id) ON DELETE CASCADE
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    ticket_id INT NOT NULL,
    payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    payment_method VARCHAR(50),
    FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id) ON DELETE CASCADE
);

-- Step 2: Insert sample data

INSERT INTO flights (flight_number, departure_airport, arrival_airport, flight_date, total_seats, seats_available) VALUES
('FL123', 'JFK', 'LAX', CURDATE() + INTERVAL 10 DAY, 150, 150),
('FL456', 'LAX', 'ORD', CURDATE() + INTERVAL 5 DAY, 200, 200);

INSERT INTO passengers (name, email, phone) VALUES
('Alice Johnson', 'alice@example.com', '1234567890'),
('Bob Smith', 'bob@example.com', '0987654321');

-- Step 3: Drop NOT NULL constraint on seat_no and recreate it

-- Step 3a: Drop NOT NULL on seat_no (in MySQL, need workaround)
-- MySQL doesn't support dropping NOT NULL easily, so we recreate the column:

ALTER TABLE tickets MODIFY seat_no VARCHAR(10) NULL;

-- Step 3b: Recreate NOT NULL on seat_no
ALTER TABLE tickets MODIFY seat_no VARCHAR(10) NOT NULL;

-- Step 4: Delete unpaid tickets older than X days (e.g., 3 days)

DELETE FROM tickets
WHERE paid = FALSE
AND booked_date < NOW() - INTERVAL 3 DAY;

-- Step 5: Procedure to insert ticket + payment transactionally

DELIMITER //
CREATE PROCEDURE book_ticket(
    IN p_flight_id INT,
    IN p_passenger_id INT,
    IN p_seat_no VARCHAR(10),
    IN p_amount DECIMAL(10,2),
    IN p_payment_method VARCHAR(50),
    OUT p_ticket_id INT,
    OUT p_success BOOLEAN
)
BEGIN
    DECLARE v_seats_available INT;

    START TRANSACTION;

    -- Check seat availability
    SELECT seats_available INTO v_seats_available FROM flights WHERE flight_id = p_flight_id FOR UPDATE;

    IF v_seats_available <= 0 THEN
        SET p_success = FALSE;
        ROLLBACK;
        LEAVE proc_end;
    END IF;

    -- Insert ticket
    INSERT INTO tickets (flight_id, passenger_id, seat_no, paid) VALUES (p_flight_id, p_passenger_id, p_seat_no, FALSE);
    SET p_ticket_id = LAST_INSERT_ID();

    -- Insert payment
    INSERT INTO payments (ticket_id, amount, payment_method) VALUES (p_ticket_id, p_amount, p_payment_method);

    -- Mark ticket as paid
    UPDATE tickets SET paid = TRUE WHERE ticket_id = p_ticket_id;

    -- Decrement seats_available
    UPDATE flights SET seats_available = seats_available - 1 WHERE flight_id = p_flight_id;

    SET p_success = TRUE;

    COMMIT;

 
END //
DELIMITER ;

-- Step 6: Update flight status and seat count (example update)

UPDATE flights SET status = 'Delayed' WHERE flight_id = 1;

-- Step 7: Sample usage of the procedure

CALL book_ticket(1, 1, '12A', 300.00, 'Credit Card', @new_ticket_id, @success);
SELECT @new_ticket_id AS TicketID, @success AS Success;

-- Step 8: Show tickets and payments

SELECT t.ticket_id, t.flight_id, t.passenger_id, t.seat_no, t.paid, p.amount, p.payment_method, p.payment_date
FROM tickets t
JOIN payments p ON t.ticket_id = p.ticket_id;


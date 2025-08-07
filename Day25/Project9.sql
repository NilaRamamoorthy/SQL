

-- Step 1: Create Database and Use It
CREATE DATABASE IF NOT EXISTS MovieBooking;
USE MovieBooking;

-- Step 2: Create Normalized Tables

-- Movies
CREATE TABLE movies (
    movie_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100),
    duration INT, -- in minutes
    genre VARCHAR(50)
);

-- Theaters
CREATE TABLE theaters (
    theater_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    location VARCHAR(100),
    total_seats INT
);

-- Shows
CREATE TABLE shows (
    show_id INT PRIMARY KEY AUTO_INCREMENT,
    movie_id INT,
    theater_id INT,
    show_time DATETIME,
    available_seats INT,
    backend_hold_info TEXT, -- Internal logic (to be hidden)
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id),
    FOREIGN KEY (theater_id) REFERENCES theaters(theater_id)
);

-- Customers
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    email VARCHAR(100)
);

-- Bookings
CREATE TABLE bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    show_id INT,
    seat_count INT,
    booking_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (show_id) REFERENCES shows(show_id)
);

-- Step 3: Insert Sample Data

INSERT INTO movies (title, duration, genre) VALUES
('Inception', 148, 'Sci-Fi'),
('Avengers: Endgame', 181, 'Action');

INSERT INTO theaters (name, location, total_seats) VALUES
('Cineplex A', 'Downtown', 100),
('MovieMax B', 'Uptown', 80);

INSERT INTO shows (movie_id, theater_id, show_time, available_seats, backend_hold_info) VALUES
(1, 1, '2025-08-10 19:00:00', 100, 'Held: 0 seats'),
(2, 2, '2025-08-11 21:00:00', 80, 'Held: 0 seats');

INSERT INTO customers (name, email) VALUES
('Alice', 'alice@mail.com'),
('Bob', 'bob@mail.com');

-- Step 4: Create Abstracted View (for frontend)

CREATE OR REPLACE VIEW view_now_showing AS
SELECT
    s.show_id,
    m.title,
    t.name AS theater,
    s.show_time,
    s.available_seats
FROM shows s
JOIN movies m ON s.movie_id = m.movie_id
JOIN theaters t ON s.theater_id = t.theater_id;

-- Step 5: Stored Procedure to Book Tickets

DELIMITER //
CREATE PROCEDURE book_ticket(
    IN p_customer_id INT,
    IN p_show_id INT,
    IN p_seat_count INT
)
BEGIN
    DECLARE current_available INT;

    -- Check current seat availability
    SELECT available_seats INTO current_available
    FROM shows WHERE show_id = p_show_id;

    IF current_available >= p_seat_count THEN
        -- Insert booking
        INSERT INTO bookings (customer_id, show_id, seat_count)
        VALUES (p_customer_id, p_show_id, p_seat_count);

        -- Update available seats
        UPDATE shows
        SET available_seats = available_seats - p_seat_count
        WHERE show_id = p_show_id;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Not enough seats available';
    END IF;
END //
DELIMITER ;

-- Step 6: Function to Get Available Seats

DELIMITER //
CREATE FUNCTION get_available_seats(p_show_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE seats INT;
    SELECT available_seats INTO seats FROM shows WHERE show_id = p_show_id;
    RETURN seats;
END //
DELIMITER ;

-- Step 7: Trigger to Prevent Booking if Houseful

DELIMITER //
CREATE TRIGGER before_booking
BEFORE INSERT ON bookings
FOR EACH ROW
BEGIN
    DECLARE current_avail INT;
    SELECT available_seats INTO current_avail FROM shows WHERE show_id = NEW.show_id;

    IF current_avail < NEW.seat_count THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot book: Show is houseful or insufficient seats.';
    END IF;
END //
DELIMITER ;

-- Step 8: Restrict Public Access to Abstracted Views

-- Example: create a limited user and grant view-only access
-- (Note: to execute these, you'd need SUPER privileges)

-- CREATE USER 'viewer'@'%' IDENTIFIED BY 'securepass';
-- GRANT SELECT ON MovieBooking.view_now_showing TO 'viewer'@'%';
-- REVOKE ALL ON MovieBooking.* FROM 'viewer'@'%';

-- Step 9: Sample Usage

-- View shows for frontend
SELECT * FROM view_now_showing;

-- Book 2 seats for Alice (customer_id = 1, show_id = 1)
CALL book_ticket(1, 1, 2);

-- Check available seats for show 1
SELECT get_available_seats(1) AS seats_left;

-- Attempt invalid booking (more seats than available)
-- CALL book_ticket(2, 1, 999); -- Will trigger error

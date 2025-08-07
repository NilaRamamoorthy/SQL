CREATE DATABASE IF NOT EXISTS VehicleRentalDB;
USE VehicleRentalDB;

-- Step 1: Create tables

CREATE TABLE vehicles (
    vehicle_id INT PRIMARY KEY AUTO_INCREMENT,
    make VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    year YEAR NOT NULL,
    mileage INT NOT NULL DEFAULT 0,
    fuel_level DECIMAL(5,2) NOT NULL DEFAULT 100.00,
    available BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100) UNIQUE
);

CREATE TABLE rentals (
    rental_id INT PRIMARY KEY AUTO_INCREMENT,
    vehicle_id INT NOT NULL,
    customer_id INT NOT NULL,
    rental_date DATE NOT NULL,
    return_date DATE,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    status ENUM('Ongoing', 'Completed', 'Cancelled') NOT NULL DEFAULT 'Ongoing',
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CHECK (return_date IS NULL OR return_date > rental_date)
);

CREATE TABLE invoices (
    invoice_id INT PRIMARY KEY AUTO_INCREMENT,
    rental_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    invoice_date DATE NOT NULL ,
    FOREIGN KEY (rental_id) REFERENCES rentals(rental_id) ON DELETE CASCADE
);

-- Step 2: Insert sample data

INSERT INTO vehicles (make, model, year, mileage, fuel_level, available) VALUES
('Toyota', 'Corolla', 2018, 30000, 80.00, TRUE),
('Honda', 'Civic', 2020, 15000, 90.00, TRUE);

INSERT INTO customers (name, phone, email) VALUES
('John Doe', '1234567890', 'john@example.com'),
('Jane Smith', '0987654321', 'jane@example.com');

-- Step 3: Procedure to insert rental with savepoint and rollback on pricing error

DELIMITER //
CREATE PROCEDURE add_rental(
    IN p_vehicle_id INT,
    IN p_customer_id INT,
    IN p_rental_date DATE,
    IN p_return_date DATE,
    IN p_price DECIMAL(10,2),
    OUT p_rental_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_rental_id = NULL;
    END;

    START TRANSACTION;

    -- Check vehicle availability
    IF (SELECT available FROM vehicles WHERE vehicle_id = p_vehicle_id) = FALSE THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vehicle is not available for rental';
    END IF;

    -- Savepoint before inserting rental
    SAVEPOINT before_rental_insert;

    -- Validate price
    IF p_price < 0 THEN
        ROLLBACK TO SAVEPOINT before_rental_insert;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid price value';
    END IF;

    -- Insert rental
    INSERT INTO rentals (vehicle_id, customer_id, rental_date, return_date, price)
    VALUES (p_vehicle_id, p_customer_id, p_rental_date, p_return_date, p_price);

    SET p_rental_id = LAST_INSERT_ID();

    -- Update vehicle availability
    UPDATE vehicles SET available = FALSE WHERE vehicle_id = p_vehicle_id;

    COMMIT;
END //
DELIMITER ;

-- Step 4: Procedure to update mileage and fuel after return

DELIMITER //
CREATE PROCEDURE return_vehicle(
    IN p_rental_id INT,
    IN p_mileage_added INT,
    IN p_fuel_level DECIMAL(5,2),
    IN p_return_date DATE
)
BEGIN
    DECLARE v_vehicle_id INT;

    START TRANSACTION;

    -- Get vehicle_id from rental
    SELECT vehicle_id INTO v_vehicle_id FROM rentals WHERE rental_id = p_rental_id;

    -- Update rentals table with return_date and status
    UPDATE rentals
    SET return_date = p_return_date,
        status = 'Completed'
    WHERE rental_id = p_rental_id;

    -- Update vehicle mileage and fuel level, and set available to TRUE
    UPDATE vehicles
    SET mileage = mileage + p_mileage_added,
        fuel_level = p_fuel_level,
        available = TRUE
    WHERE vehicle_id = v_vehicle_id;

    COMMIT;
END //
DELIMITER ;

-- Step 5: Trigger to prevent invalid return_date (enforce CHECK on return_date > rental_date)

DELIMITER //
CREATE TRIGGER check_return_date
BEFORE UPDATE ON rentals
FOR EACH ROW
BEGIN
    IF NEW.return_date IS NOT NULL AND NEW.return_date <= NEW.rental_date THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'return_date must be after rental_date';
    END IF;
END //
DELIMITER ;

-- Step 6: Delete completed rentals older than 3 months

DELETE FROM rentals
WHERE status = 'Completed'
AND return_date < CURDATE() - INTERVAL 3 MONTH;

-- Step 7: Demonstrate durability: 
-- Insert a rental, disconnect and reconnect and show data persists

-- Call the procedure to add rental (example)
CALL add_rental(1, 1, '2025-07-01', '2025-07-05', 500.00, @rental_id);
SELECT @rental_id;

-- After reconnecting, check rental exists
SELECT * FROM rentals WHERE rental_id = @rental_id;

-- Update mileage and fuel after return
CALL return_vehicle(@rental_id, 350, 75.50, '2025-07-05');

-- Check updated vehicle info
SELECT * FROM vehicles WHERE vehicle_id = 1;

-- Check rental status
SELECT * FROM rentals WHERE rental_id = @rental_id;


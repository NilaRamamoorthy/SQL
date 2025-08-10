-- 1. Create Database
CREATE DATABASE vehicle_rental;
USE vehicle_rental;

-- 2. Create Tables

-- Vehicles
CREATE TABLE vehicles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    type VARCHAR(50) NOT NULL,
    plate_number VARCHAR(20) NOT NULL UNIQUE
);

-- Customers
CREATE TABLE customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Rentals
CREATE TABLE rentals (
    id INT PRIMARY KEY AUTO_INCREMENT,
    vehicle_id INT NOT NULL,
    customer_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
);

-- 3. Insert Sample Data

INSERT INTO vehicles (type, plate_number) VALUES
('Car', 'ABC-1234'),
('Van', 'XYZ-5678'),
('Motorbike', 'MNO-4321'),
('Truck', 'TRK-7890');

INSERT INTO customers (name) VALUES
('John Doe'),
('Alice Johnson'),
('Bob Smith');

INSERT INTO rentals (vehicle_id, customer_id, start_date, end_date) VALUES
(1, 1, '2025-08-01', '2025-08-05'),
(2, 2, '2025-08-03', '2025-08-07'),
(3, 3, '2025-08-10', '2025-08-12');

-- 4. Query: Calculate rental charges (assume $50/day for all vehicles)
SELECT 
    r.id AS rental_id,
    c.name AS customer,
    v.plate_number,
    DATEDIFF(r.end_date, r.start_date) + 1 AS rental_days,
    (DATEDIFF(r.end_date, r.start_date) + 1) * 50 AS total_charge
FROM rentals r
JOIN customers c ON r.customer_id = c.id
JOIN vehicles v ON r.vehicle_id = v.id;

-- 5. Query: Check available vehicles for a given date range
-- Example: Find vehicles available between '2025-08-04' and '2025-08-06'
SELECT v.*
FROM vehicles v
WHERE v.id NOT IN (
    SELECT vehicle_id
    FROM rentals
    WHERE NOT (
        end_date < '2025-08-04' OR start_date > '2025-08-06'
    )
);

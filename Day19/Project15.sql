-- Drop and create database

CREATE DATABASE rental_db;
USE rental_db;

-- Create tables
CREATE TABLE vehicle_types (
    vehicle_type_id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE vehicles (
    vehicle_id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_type_id INT NOT NULL,
    model VARCHAR(100) NOT NULL,
    license_plate VARCHAR(20) UNIQUE NOT NULL,
    FOREIGN KEY (vehicle_type_id) REFERENCES vehicle_types(vehicle_type_id)
);

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100) UNIQUE
);

CREATE TABLE rentals (
    rental_id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT NOT NULL,
    customer_id INT NOT NULL,
    rental_start DATE NOT NULL,
    rental_end DATE NOT NULL,
    rental_cost DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Insert sample data

INSERT INTO vehicle_types (type_name) VALUES
('Sedan'), ('SUV'), ('Truck'), ('Van'), ('Motorcycle');

INSERT INTO vehicles (vehicle_type_id, model, license_plate) VALUES
(1, 'Toyota Camry', 'ABC123'),
(2, 'Honda CRV', 'XYZ789'),
(3, 'Ford F-150', 'TRK456'),
(4, 'Dodge Caravan', 'VAN101'),
(5, 'Yamaha YZF', 'MOTO22');

INSERT INTO customers (full_name, phone, email) VALUES
('John Doe', '555-1234', 'john.doe@example.com'),
('Jane Smith', '555-5678', 'jane.smith@example.com'),
('Mike Johnson', '555-8765', 'mike.johnson@example.com');

INSERT INTO rentals (vehicle_id, customer_id, rental_start, rental_end, rental_cost) VALUES
(1, 1, '2025-07-01', '2025-07-05', 250.00),
(2, 2, '2025-07-03', '2025-07-07', 350.00),
(3, 1, '2025-07-10', '2025-07-12', 150.00),
(5, 3, '2025-07-05', '2025-07-06', 75.00);

-- Queries

-- Vehicles rented in a date range (e.g. rentals between 2025-07-01 and 2025-07-10)
SELECT v.model, v.license_plate, r.rental_start, r.rental_end, c.full_name
FROM rentals r
JOIN vehicles v ON r.vehicle_id = v.vehicle_id
JOIN customers c ON r.customer_id = c.customer_id
WHERE r.rental_start >= '2025-07-01' AND r.rental_end <= '2025-07-10';

-- Total income per vehicle type
SELECT vt.type_name, SUM(r.rental_cost) AS total_income
FROM rentals r
JOIN vehicles v ON r.vehicle_id = v.vehicle_id
JOIN vehicle_types vt ON v.vehicle_type_id = vt.vehicle_type_id
GROUP BY vt.type_name;

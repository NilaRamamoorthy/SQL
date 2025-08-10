-- 1. Create Database
CREATE DATABASE car_rental_service;
USE car_rental_service;

-- 2. Create Tables

CREATE TABLE vehicles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    model VARCHAR(255) NOT NULL,
    type VARCHAR(100) NOT NULL,  -- e.g., Sedan, SUV, Hatchback
    plate_number VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE rentals (
    id INT PRIMARY KEY AUTO_INCREMENT,
    vehicle_id INT NOT NULL,
    customer_id INT NOT NULL,
    rental_date DATE NOT NULL,
    return_date DATE,
    cost DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE payments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    rental_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (rental_id) REFERENCES rentals(id)
);

-- 3. Insert Sample Data

INSERT INTO vehicles (model, type, plate_number) VALUES
('Toyota Camry', 'Sedan', 'ABC123'),
('Honda CRV', 'SUV', 'DEF456'),
('Ford Fiesta', 'Hatchback', 'GHI789'),
('Toyota Camry', 'Sedan', 'JKL012'),
('Honda CRV', 'SUV', 'MNO345');

INSERT INTO customers (name) VALUES
('Alice'),
('Bob'),
('Charlie'),
('Diana');

INSERT INTO rentals (vehicle_id, customer_id, rental_date, return_date, cost) VALUES
(1, 1, '2025-07-01', '2025-07-05', 500),
(1, 2, '2025-07-06', '2025-07-08', 300),
(2, 1, '2025-07-02', '2025-07-04', 400),
(3, 3, '2025-07-03', '2025-07-06', 350),
(1, 4, '2025-07-10', '2025-07-15', 750),
(4, 2, '2025-07-07', '2025-07-09', 320),
(5, 1, '2025-07-08', '2025-07-12', 600),
(1, 3, '2025-07-16', '2025-07-18', 280),
(1, 1, '2025-07-19', '2025-07-22', 550),
(2, 4, '2025-07-20', '2025-07-23', 450),
(1, 2, '2025-07-23', '2025-07-25', 350),
(1, 3, '2025-07-26', '2025-07-28', 330);

INSERT INTO payments (rental_id, payment_date, amount) VALUES
(1, '2025-07-01', 500),
(2, '2025-07-06', 300),
(3, '2025-07-02', 400),
(4, '2025-07-03', 350),
(5, '2025-07-10', 750),
(6, '2025-07-07', 320),
(7, '2025-07-08', 600),
(8, '2025-07-16', 280),
(9, '2025-07-19', 550),
(10, '2025-07-20', 450),
(11, '2025-07-23', 350),
(12, '2025-07-26', 330);

-- 4. Queries

-- a) Total rentals per vehicle
SELECT
    v.id,
    v.model,
    v.type,
    COUNT(r.id) AS total_rentals
FROM vehicles v
LEFT JOIN rentals r ON v.id = r.vehicle_id
GROUP BY v.id, v.model, v.type
ORDER BY total_rentals DESC;

-- b) Vehicles rented more than 10 times (HAVING)
SELECT
    v.id,
    v.model,
    v.type,
    COUNT(r.id) AS total_rentals
FROM vehicles v
JOIN rentals r ON v.id = r.vehicle_id
GROUP BY v.id, v.model, v.type
HAVING total_rentals > 10;

-- c) Average rental cost per car type
SELECT
    v.type,
    ROUND(AVG(r.cost), 2) AS avg_rental_cost
FROM vehicles v
JOIN rentals r ON v.id = r.vehicle_id
GROUP BY v.type;

-- d) INNER JOIN rentals ↔ vehicles (rental info with vehicle details)
SELECT
    r.id AS rental_id,
    v.model,
    v.type,
    r.rental_date,
    r.return_date,
    r.cost
FROM rentals r
JOIN vehicles v ON r.vehicle_id = v.id;

-- e) LEFT JOIN vehicles ↔ payments (show vehicles and their payments if any)
SELECT
    v.id AS vehicle_id,
    v.model,
    v.type,
    p.amount,
    p.payment_date
FROM vehicles v
LEFT JOIN rentals r ON v.id = r.vehicle_id
LEFT JOIN payments p ON r.id = p.rental_id
ORDER BY v.id, p.payment_date;

-- f) SELF JOIN: cars of the same model and type (distinct pairs)
SELECT
    v1.id AS vehicle1_id,
    v1.model,
    v1.type,
    v2.id AS vehicle2_id
FROM vehicles v1
JOIN vehicles v2 ON v1.model = v2.model AND v1.type = v2.type AND v1.id < v2.id
ORDER BY v1.model, v1.type;

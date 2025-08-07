-- Drop and create database

CREATE DATABASE medical_store_db;
USE medical_store_db;

-- Create tables
CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(150) NOT NULL,
    contact VARCHAR(100)
);

CREATE TABLE medicines (
    medicine_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    batch_number VARCHAR(50) NOT NULL,
    expiry_date DATE NOT NULL,
    supplier_id INT NOT NULL,
    price DECIMAL(8, 2) NOT NULL,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

CREATE TABLE stock (
    stock_id INT AUTO_INCREMENT PRIMARY KEY,
    medicine_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    FOREIGN KEY (medicine_id) REFERENCES medicines(medicine_id)
);

CREATE TABLE sales (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    medicine_id INT NOT NULL,
    sale_date DATE NOT NULL,
    quantity_sold INT NOT NULL,
    FOREIGN KEY (medicine_id) REFERENCES medicines(medicine_id)
);

-- Insert sample data

INSERT INTO suppliers (supplier_name, contact) VALUES
('Health Suppliers Inc.', 'healthsuppliers@example.com'),
('Pharma Wholesale', 'pharmawholesale@example.com'),
('Medicorp', 'medicorp@example.com');

INSERT INTO medicines (name, batch_number, expiry_date, supplier_id, price) VALUES
('Paracetamol', 'B123', '2026-05-01', 1, 0.50),
('Ibuprofen', 'I456', '2025-12-31', 2, 0.75),
('Amoxicillin', 'A789', '2024-10-15', 3, 1.20),
('Cough Syrup', 'C012', '2025-08-20', 1, 3.50),
('Vitamin C', 'V345', '2026-03-30', 2, 0.80);

INSERT INTO stock (medicine_id, quantity) VALUES
(1, 100),
(2, 50),
(3, 20),
(4, 75),
(5, 150);

INSERT INTO sales (medicine_id, sale_date, quantity_sold) VALUES
(1, '2025-07-01', 10),
(2, '2025-07-02', 5),
(3, '2025-07-03', 3),
(4, '2025-07-04', 7),
(5, '2025-07-05', 20);

-- Queries

-- Find low stock items (threshold: less than 30)
SELECT m.name, s.quantity
FROM stock s
JOIN medicines m ON s.medicine_id = m.medicine_id
WHERE s.quantity < 30;

-- Sales by medicine and supplier
SELECT m.name, sup.supplier_name, SUM(s.quantity_sold) AS total_sales
FROM sales s
JOIN medicines m ON s.medicine_id = m.medicine_id
JOIN suppliers sup ON m.supplier_id = sup.supplier_id
GROUP BY m.medicine_id, sup.supplier_name;

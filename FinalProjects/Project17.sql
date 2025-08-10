-- 1. Create Database
CREATE DATABASE invoice_generator;
USE invoice_generator;

-- 2. Create Tables

-- Clients Table
CREATE TABLE clients (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Invoices Table
CREATE TABLE invoices (
    id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT NOT NULL,
    date DATE NOT NULL,
    FOREIGN KEY (client_id) REFERENCES clients(id)
);

-- Invoice Items Table
CREATE TABLE invoice_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    invoice_id INT NOT NULL,
    description VARCHAR(255) NOT NULL,
    quantity INT NOT NULL,
    rate DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (invoice_id) REFERENCES invoices(id)
);

-- 3. Insert Sample Data

-- Clients
INSERT INTO clients (name) VALUES
('Acme Corp'),
('Tech Solutions'),
('Bright Future LLC');

-- Invoices
INSERT INTO invoices (client_id, date) VALUES
(1, '2025-08-01'),
(2, '2025-08-03'),
(1, '2025-08-05');

-- Invoice Items
INSERT INTO invoice_items (invoice_id, description, quantity, rate) VALUES
(1, 'Website Design', 1, 500.00),
(1, 'Hosting (1 year)', 1, 120.00),
(2, 'Mobile App Development', 2, 800.00),
(2, 'Maintenance (Monthly)', 3, 150.00),
(3, 'SEO Optimization', 1, 300.00),
(3, 'Content Writing', 5, 50.00);

-- 4. Query: Calculate Subtotal and Total per Invoice
SELECT 
    i.id AS invoice_id,
    c.name AS client_name,
    i.date,
    SUM(ii.quantity * ii.rate) AS subtotal,
    SUM(ii.quantity * ii.rate) * 1.10 AS total_with_tax -- Example: 10% tax
FROM invoices i
JOIN clients c ON i.client_id = c.id
JOIN invoice_items ii ON i.id = ii.invoice_id
GROUP BY i.id, c.name, i.date
ORDER BY i.id;

-- 5. Query: Detailed Invoice with Items
SELECT 
    i.id AS invoice_id,
    c.name AS client_name,
    i.date,
    ii.description,
    ii.quantity,
    ii.rate,
    (ii.quantity * ii.rate) AS line_total
FROM invoices i
JOIN clients c ON i.client_id = c.id
JOIN invoice_items ii ON i.id = ii.invoice_id
ORDER BY i.id, ii.id;

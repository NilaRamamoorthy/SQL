-- 1. Create Database and Use
CREATE DATABASE IF NOT EXISTS real_estate_analyzer;
USE real_estate_analyzer;

-- 2. Create Tables

CREATE TABLE agents (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    city VARCHAR(255)
);

CREATE TABLE clients (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255)
);

CREATE TABLE properties (
    id INT PRIMARY KEY AUTO_INCREMENT,
    agent_id INT,
    type VARCHAR(50), -- e.g., 'residential', 'commercial', etc.
    address VARCHAR(255),
    listed_date DATE,
    price DECIMAL(12,2),
    status ENUM('Listed', 'Sold'),
    FOREIGN KEY (agent_id) REFERENCES agents(id)
);

CREATE TABLE sales (
    id INT PRIMARY KEY AUTO_INCREMENT,
    property_id INT,
    client_id INT,
    sale_date DATE,
    sale_price DECIMAL(12,2),
    FOREIGN KEY (property_id) REFERENCES properties(id),
    FOREIGN KEY (client_id) REFERENCES clients(id)
);

-- 3. Insert Sample Data

INSERT INTO agents (name, city) VALUES
('Alice Smith', 'New York'),
('Bob Johnson', 'Los Angeles'),
('Catherine Lee', 'New York');

INSERT INTO clients (name) VALUES
('Client A'),
('Client B'),
('Client C');

INSERT INTO properties (agent_id, type, address, listed_date, price, status) VALUES
(1, 'residential', '123 Elm St', '2025-06-01', 500000, 'Sold'),
(1, 'commercial', '456 Oak Ave', '2025-07-10', 1200000, 'Listed'),
(2, 'residential', '789 Pine Rd', '2025-05-20', 300000, 'Sold'),
(3, 'commercial', '321 Maple Ln', '2025-04-15', 800000, 'Sold'),
(3, 'residential', '654 Cedar St', '2025-08-01', 450000, 'Listed');

INSERT INTO sales (property_id, client_id, sale_date, sale_price) VALUES
(1, 1, '2025-07-15', 495000),
(3, 2, '2025-06-10', 290000),
(4, 3, '2025-05-01', 790000);

-- 4a. Subquery to find agents whose total sales are above company average

SELECT 
    a.id,
    a.name,
    total_sales
FROM agents a
JOIN (
    SELECT 
        p.agent_id,
        SUM(s.sale_price) AS total_sales
    FROM properties p
    JOIN sales s ON p.id = s.property_id
    GROUP BY p.agent_id
) AS agent_sales ON a.id = agent_sales.agent_id
WHERE agent_sales.total_sales > (
    SELECT AVG(total_agent_sales) FROM (
        SELECT SUM(sale_price) AS total_agent_sales
        FROM sales
        GROUP BY property_id
    ) AS avg_subquery
);

-- 4b. Use CASE to categorize property types

SELECT 
    id,
    address,
    CASE 
        WHEN LOWER(type) = 'residential' THEN 'Residential'
        WHEN LOWER(type) = 'commercial' THEN 'Commercial'
        ELSE 'Other'
    END AS property_category,
    status
FROM properties;

-- 4c. UNION ALL for properties sold vs still listed

SELECT 
    id, address, 'Sold' AS status
FROM properties
WHERE status = 'Sold'

UNION ALL

SELECT 
    id, address, 'Listed' AS status
FROM properties
WHERE status = 'Listed';

-- 4d. Correlated subquery to find highest sale per agent

SELECT 
    a.id AS agent_id,
    a.name AS agent_name,
    (SELECT MAX(sale_price) 
     FROM sales s 
     JOIN properties p ON s.property_id = p.id
     WHERE p.agent_id = a.id) AS highest_sale
FROM agents a;

-- 4e. JOIN + GROUP BY to show agent sales by city

SELECT 
    a.city,
    a.name AS agent_name,
    COUNT(s.id) AS total_sales,
    SUM(s.sale_price) AS total_revenue
FROM agents a
JOIN properties p ON a.id = p.agent_id
JOIN sales s ON p.id = s.property_id
GROUP BY a.city, a.name;

-- 4f. Use DATEDIFF to calculate time between listing and sale

SELECT 
    p.id AS property_id,
    p.address,
    p.listed_date,
    s.sale_date,
    DATEDIFF(s.sale_date, p.listed_date) AS days_to_sell
FROM properties p
JOIN sales s ON p.id = s.property_id;

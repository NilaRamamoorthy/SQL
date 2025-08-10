-- 1. Create Database
CREATE DATABASE real_estate;
USE real_estate;

-- 2. Create Tables

CREATE TABLE agents (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    area VARCHAR(100) NOT NULL
);

CREATE TABLE clients (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE properties (
    id INT PRIMARY KEY AUTO_INCREMENT,
    agent_id INT NOT NULL,
    location VARCHAR(100) NOT NULL,
    price DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (agent_id) REFERENCES agents(id)
);

CREATE TABLE inquiries (
    id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT NOT NULL,
    property_id INT NOT NULL,
    inquiry_date DATE NOT NULL,
    FOREIGN KEY (client_id) REFERENCES clients(id),
    FOREIGN KEY (property_id) REFERENCES properties(id)
);

-- 3. Insert Sample Data

INSERT INTO agents (name, area) VALUES
('Agent A', 'Downtown'),
('Agent B', 'Uptown'),
('Agent C', 'Downtown'),
('Agent D', 'Suburbs');

INSERT INTO clients (name) VALUES
('Client 1'),
('Client 2'),
('Client 3'),
('Client 4');

INSERT INTO properties (agent_id, location, price) VALUES
(1, 'Downtown', 500000),
(1, 'Downtown', 600000),
(2, 'Uptown', 400000),
(2, 'Uptown', 450000),
(3, 'Downtown', 550000),
(4, 'Suburbs', 350000);

INSERT INTO inquiries (client_id, property_id, inquiry_date) VALUES
(1, 1, '2025-07-01'),
(2, 1, '2025-07-02'),
(3, 2, '2025-07-03'),
(4, 3, '2025-07-04'),
(1, 4, '2025-07-05'),
(2, 5, '2025-07-06'),
(3, 6, '2025-07-07'),
(4, 1, '2025-07-08'),
(1, 3, '2025-07-09'),
(2, 5, '2025-07-10');

-- 4. Queries

-- a) Count properties listed per agent
SELECT 
    a.id AS agent_id,
    a.name AS agent_name,
    COUNT(p.id) AS properties_listed
FROM agents a
LEFT JOIN properties p ON a.id = p.agent_id
GROUP BY a.id, a.name;

-- b) Average property price per location
SELECT 
    location,
    ROUND(AVG(price), 2) AS avg_price
FROM properties
GROUP BY location;

-- c) Agents with more than 20 inquiries (use INNER JOIN properties->agents->inquiries)
SELECT
    a.id AS agent_id,
    a.name AS agent_name,
    COUNT(i.id) AS inquiry_count
FROM agents a
JOIN properties p ON a.id = p.agent_id
JOIN inquiries i ON p.id = i.property_id
GROUP BY a.id, a.name
HAVING inquiry_count > 20;

-- d) INNER JOIN: properties ↔ agents ↔ inquiries (all inquiry details)
SELECT 
    i.id AS inquiry_id,
    c.name AS client_name,
    p.id AS property_id,
    p.location,
    p.price,
    a.name AS agent_name,
    i.inquiry_date
FROM inquiries i
JOIN properties p ON i.property_id = p.id
JOIN agents a ON p.agent_id = a.id
JOIN clients c ON i.client_id = c.id
ORDER BY i.inquiry_date;

-- e) LEFT JOIN: properties ↔ inquiries (properties with or without inquiries)
SELECT 
    p.id AS property_id,
    p.location,
    p.price,
    COUNT(i.id) AS inquiry_count
FROM properties p
LEFT JOIN inquiries i ON p.id = i.property_id
GROUP BY p.id, p.location, p.price;

-- f) SELF JOIN agents working in the same area
SELECT DISTINCT
    a1.id AS agent1_id,
    a1.name AS agent1_name,
    a2.id AS agent2_id,
    a2.name AS agent2_name,
    a1.area
FROM agents a1
JOIN agents a2 ON a1.area = a2.area AND a1.id < a2.id
ORDER BY a1.area, agent1_id, agent2_id;

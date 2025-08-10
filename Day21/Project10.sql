-- 1. Create Database
CREATE DATABASE sales_crm;
USE sales_crm;

-- 2. Create Tables

CREATE TABLE sales_reps (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    region VARCHAR(100)
);

CREATE TABLE leads (
    id INT PRIMARY KEY AUTO_INCREMENT,
    sales_rep_id INT NOT NULL,
    client_id INT,
    status VARCHAR(50) NOT NULL, -- e.g., 'open', 'closed', 'lost'
    created_at DATETIME NOT NULL,
    closed_at DATETIME,
    FOREIGN KEY (sales_rep_id) REFERENCES sales_reps(id)
);

CREATE TABLE clients (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    region VARCHAR(100)
);

CREATE TABLE meetings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    lead_id INT NOT NULL,
    meeting_date DATETIME NOT NULL,
    FOREIGN KEY (lead_id) REFERENCES leads(id)
);

-- 3. Insert Sample Data

INSERT INTO sales_reps (name, region) VALUES
('Alice', 'North'),
('Bob', 'South'),
('Charlie', 'North'),
('Diana', 'East');

INSERT INTO clients (name, region) VALUES
('Client A', 'North'),
('Client B', 'South'),
('Client C', 'East'),
('Client D', 'West');

INSERT INTO leads (sales_rep_id, client_id, status, created_at, closed_at) VALUES
(1, 1, 'closed', '2025-07-01 09:00:00', '2025-07-05 10:00:00'),
(1, 2, 'open', '2025-07-02 11:00:00', NULL),
(2, 3, 'closed', '2025-07-03 12:00:00', '2025-07-10 15:00:00'),
(3, 1, 'closed', '2025-07-04 14:00:00', '2025-07-06 09:00:00'),
(3, 4, 'closed', '2025-07-05 10:00:00', '2025-07-15 11:00:00'),
(4, NULL, 'lost', '2025-07-06 08:00:00', NULL),
(1, 3, 'closed', '2025-07-07 16:00:00', '2025-07-08 12:00:00'),
(1, 4, 'closed', '2025-07-08 17:00:00', '2025-07-09 09:00:00'),
(1, NULL, 'closed', '2025-07-09 18:00:00', '2025-07-10 10:00:00'),
(1, 2, 'closed', '2025-07-10 19:00:00', '2025-07-11 13:00:00'),
(1, 3, 'closed', '2025-07-11 20:00:00', '2025-07-12 14:00:00');

INSERT INTO meetings (lead_id, meeting_date) VALUES
(1, '2025-07-02 10:00:00'),
(3, '2025-07-04 09:00:00'),
(4, '2025-07-05 11:00:00'),
(7, '2025-07-08 14:00:00');

-- 4. Queries

-- a) Count leads per sales rep
SELECT
    sr.id,
    sr.name,
    COUNT(l.id) AS total_leads
FROM sales_reps sr
LEFT JOIN leads l ON sr.id = l.sales_rep_id
GROUP BY sr.id, sr.name;

-- b) Average conversion time (closed leads only) per sales rep in hours
SELECT
    sr.id,
    sr.name,
    ROUND(AVG(TIMESTAMPDIFF(HOUR, l.created_at, l.closed_at)), 2) AS avg_conversion_hours
FROM sales_reps sr
JOIN leads l ON sr.id = l.sales_rep_id
WHERE l.status = 'closed' AND l.closed_at IS NOT NULL
GROUP BY sr.id, sr.name;

-- c) Reps who closed more than 5 deals (HAVING)
SELECT
    sr.id,
    sr.name,
    COUNT(l.id) AS closed_deals
FROM sales_reps sr
JOIN leads l ON sr.id = l.sales_rep_id
WHERE l.status = 'closed'
GROUP BY sr.id, sr.name
HAVING closed_deals > 5;

-- d) INNER JOIN reps and leads (all leads with rep info)
SELECT
    sr.name AS sales_rep_name,
    l.id AS lead_id,
    l.status,
    l.created_at,
    l.closed_at
FROM sales_reps sr
JOIN leads l ON sr.id = l.sales_rep_id;

-- e) RIGHT JOIN: reps and clients (all clients with reps if assigned)
SELECT
    c.id AS client_id,
    c.name AS client_name,
    c.region AS client_region,
    sr.id AS sales_rep_id,
    sr.name AS sales_rep_name,
    sr.region AS sales_rep_region
FROM sales_reps sr
RIGHT JOIN clients c ON sr.region = c.region
ORDER BY c.name;

-- f) SELF JOIN to compare reps from the same region
SELECT
    sr1.id AS rep1_id,
    sr1.name AS rep1_name,
    sr2.id AS rep2_id,
    sr2.name AS rep2_name,
    sr1.region
FROM sales_reps sr1
JOIN sales_reps sr2 ON sr1.region = sr2.region AND sr1.id < sr2.id
ORDER BY sr1.region, sr1.name, sr2.name;

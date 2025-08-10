-- 1. Create Database
CREATE DATABASE it_support;
USE it_support;

-- 2. Create Tables

CREATE TABLE technicians (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE clients (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE tickets (
    id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT NOT NULL,
    technician_id INT,
    issue_type VARCHAR(100) NOT NULL,
    status VARCHAR(50),
    created_at DATETIME NOT NULL,
    resolved_at DATETIME,
    FOREIGN KEY (client_id) REFERENCES clients(id),
    FOREIGN KEY (technician_id) REFERENCES technicians(id)
);

-- 3. Insert Sample Data

INSERT INTO technicians (name) VALUES
('Alice'),
('Bob'),
('Charlie');

INSERT INTO clients (name) VALUES
('Client A'),
('Client B'),
('Client C'),
('Client D');

INSERT INTO tickets (client_id, technician_id, issue_type, status, created_at, resolved_at) VALUES
(1, 1, 'Network', 'Resolved', '2025-08-01 08:00:00', '2025-08-01 12:00:00'),
(2, 2, 'Software', 'Resolved', '2025-08-02 09:00:00', '2025-08-02 15:00:00'),
(3, 1, 'Hardware', 'In Progress', '2025-08-03 10:00:00', NULL),
(4, NULL, 'Network', 'Open', '2025-08-04 11:00:00', NULL),
(1, 3, 'Software', 'Resolved', '2025-08-05 08:30:00', '2025-08-05 12:30:00'),
(2, 1, 'Network', 'Resolved', '2025-08-06 09:15:00', '2025-08-06 13:45:00'),
(3, 2, 'Software', 'Resolved', '2025-08-07 10:30:00', '2025-08-07 14:00:00'),
(4, 3, 'Hardware', 'Resolved', '2025-08-08 11:45:00', '2025-08-08 16:00:00'),
(1, 1, 'Network', 'Resolved', '2025-08-09 08:00:00', '2025-08-09 12:00:00'),
(2, 2, 'Network', 'Open', '2025-08-10 09:00:00', NULL);

-- 4. Queries

-- a) Count of tickets per technician
SELECT 
    t.id AS technician_id,
    t.name AS technician_name,
    COUNT(tk.id) AS ticket_count
FROM technicians t
LEFT JOIN tickets tk ON t.id = tk.technician_id
GROUP BY t.id, t.name
ORDER BY ticket_count DESC;

-- b) Average resolution time per technician (in hours)
SELECT
    t.id AS technician_id,
    t.name AS technician_name,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, tk.created_at, tk.resolved_at))/60, 2) AS avg_resolution_hours
FROM technicians t
JOIN tickets tk ON t.id = tk.technician_id
WHERE tk.resolved_at IS NOT NULL
GROUP BY t.id, t.name;

-- c) Technicians handling more than 10 tickets
SELECT 
    t.id AS technician_id,
    t.name AS technician_name,
    COUNT(tk.id) AS ticket_count
FROM technicians t
JOIN tickets tk ON t.id = tk.technician_id
GROUP BY t.id, t.name
HAVING ticket_count > 10;

-- d) INNER JOIN tickets ↔ technicians (list tickets with tech info)
SELECT 
    tk.id AS ticket_id,
    c.name AS client_name,
    t.name AS technician_name,
    tk.issue_type,
    tk.status,
    tk.created_at,
    tk.resolved_at
FROM tickets tk
JOIN technicians t ON tk.technician_id = t.id
JOIN clients c ON tk.client_id = c.id
ORDER BY tk.created_at DESC;

-- e) LEFT JOIN clients ↔ tickets (clients and their tickets, including clients without tickets)
SELECT 
    c.id AS client_id,
    c.name AS client_name,
    tk.id AS ticket_id,
    tk.issue_type,
    tk.status
FROM clients c
LEFT JOIN tickets tk ON c.id = tk.client_id
ORDER BY c.id;

-- f) SELF JOIN tickets with same issue types (pairs of tickets with same issue_type)
SELECT DISTINCT
    tk1.id AS ticket1_id,
    tk1.client_id AS ticket1_client,
    tk1.issue_type,
    tk2.id AS ticket2_id,
    tk2.client_id AS ticket2_client
FROM tickets tk1
JOIN tickets tk2 ON tk1.issue_type = tk2.issue_type AND tk1.id < tk2.id
ORDER BY tk1.issue_type, ticket1_id, ticket2_id;

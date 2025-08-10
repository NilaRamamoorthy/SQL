-- 1. Create Database
CREATE DATABASE it_support_system;
USE it_support_system;

-- 2. Create Tables

-- Support tickets
CREATE TABLE tickets (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    issue VARCHAR(255) NOT NULL,
    status ENUM('Open', 'In Progress', 'Resolved', 'Closed') NOT NULL DEFAULT 'Open',
    created_at DATETIME NOT NULL,
    resolved_at DATETIME NULL
);

-- Support staff
CREATE TABLE support_staff (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Ticket assignments
CREATE TABLE assignments (
    ticket_id INT NOT NULL,
    staff_id INT NOT NULL,
    PRIMARY KEY (ticket_id, staff_id),
    FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON DELETE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES support_staff(id) ON DELETE CASCADE
);

-- 3. Insert Sample Data

-- Support Staff
INSERT INTO support_staff (name) VALUES
('Alice Johnson'),
('Bob Smith'),
('Charlie Lee');

-- Tickets
INSERT INTO tickets (user_id, issue, status, created_at, resolved_at) VALUES
(101, 'Cannot connect to Wi-Fi', 'Resolved', '2025-08-01 09:00:00', '2025-08-01 10:30:00'),
(102, 'Computer is running slow', 'Resolved', '2025-08-02 11:15:00', '2025-08-02 14:00:00'),
(103, 'Email not syncing', 'In Progress', '2025-08-03 08:45:00', NULL),
(104, 'Printer not responding', 'Closed', '2025-08-03 10:00:00', '2025-08-03 12:00:00'),
(105, 'VPN access denied', 'Resolved', '2025-08-04 09:30:00', '2025-08-04 11:00:00');

-- Assignments
INSERT INTO assignments (ticket_id, staff_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 1),
(5, 2);

-- 4. Query: Average resolution time (in hours)
SELECT 
    AVG(TIMESTAMPDIFF(MINUTE, created_at, resolved_at)) / 60 AS avg_resolution_hours
FROM tickets
WHERE resolved_at IS NOT NULL;

-- 5. Query: Ticket volume by status
SELECT 
    status,
    COUNT(*) AS ticket_count
FROM tickets
GROUP BY status;

-- 6. Query: Tickets handled by each support staff
SELECT 
    s.name AS staff_name,
    COUNT(a.ticket_id) AS tickets_assigned
FROM support_staff s
LEFT JOIN assignments a ON s.id = a.staff_id
GROUP BY s.id
ORDER BY tickets_assigned DESC;

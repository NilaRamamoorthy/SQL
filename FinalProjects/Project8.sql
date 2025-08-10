-- 1. Create Database
CREATE DATABASE sales_crm;
USE sales_crm;

-- 2. Create Tables

-- Users table
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Leads table
CREATE TABLE leads (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    source VARCHAR(50)
);

-- Deals table
CREATE TABLE deals (
    id INT PRIMARY KEY AUTO_INCREMENT,
    lead_id INT,
    user_id INT,
    stage ENUM('Prospecting', 'Proposal Sent', 'Negotiation', 'Closed Won', 'Closed Lost') NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    created_at DATE NOT NULL,
    FOREIGN KEY (lead_id) REFERENCES leads(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 3. Insert Sample Data

-- Users (Sales reps)
INSERT INTO users (name) VALUES
('Alice'),
('Bob'),
('Charlie');

-- Leads
INSERT INTO leads (name, source) VALUES
('Acme Corp', 'Website'),
('Globex Ltd', 'Referral'),
('Initech', 'Email Campaign'),
('Umbrella Inc', 'Social Media'),
('Wayne Enterprises', 'Cold Call');

-- Deals
INSERT INTO deals (lead_id, user_id, stage, amount, created_at) VALUES
(1, 1, 'Prospecting', 5000.00, '2025-08-01'),
(1, 1, 'Proposal Sent', 5000.00, '2025-08-03'),
(1, 1, 'Closed Won', 5000.00, '2025-08-05'),
(2, 2, 'Prospecting', 8000.00, '2025-08-02'),
(2, 2, 'Negotiation', 8000.00, '2025-08-04'),
(2, 2, 'Closed Lost', 8000.00, '2025-08-06'),
(3, 3, 'Prospecting', 3000.00, '2025-08-01'),
(3, 3, 'Proposal Sent', 3000.00, '2025-08-07'),
(4, 1, 'Prospecting', 10000.00, '2025-08-03'),
(5, 2, 'Prospecting', 7000.00, '2025-08-02');

-- 4. CTE: Latest Stage per Deal
WITH latest_deals AS (
    SELECT 
        d.lead_id,
        l.name AS lead_name,
        u.name AS sales_rep,
        d.amount,
        d.stage,
        d.created_at,
        ROW_NUMBER() OVER (PARTITION BY d.lead_id ORDER BY d.created_at DESC) AS rn
    FROM deals d
    JOIN leads l ON d.lead_id = l.id
    JOIN users u ON d.user_id = u.id
)
SELECT *
FROM latest_deals
WHERE rn = 1;

-- 5. Window Function: Deal Progression by Date
SELECT 
    l.name AS lead_name,
    u.name AS sales_rep,
    d.stage,
    d.amount,
    d.created_at,
    RANK() OVER (PARTITION BY d.lead_id ORDER BY d.created_at) AS stage_order
FROM deals d
JOIN leads l ON d.lead_id = l.id
JOIN users u ON d.user_id = u.id
ORDER BY lead_name, stage_order;

-- 6. Filter Deals by Status (e.g., Closed Won)
SELECT 
    l.name AS lead_name,
    u.name AS sales_rep,
    d.amount,
    d.stage,
    d.created_at
FROM deals d
JOIN leads l ON d.lead_id = l.id
JOIN users u ON d.user_id = u.id
WHERE d.stage = 'Closed Won';

-- 7. Filter Deals by Date Range (e.g., August 2025)
SELECT 
    l.name AS lead_name,
    u.name AS sales_rep,
    d.amount,
    d.stage,
    d.created_at
FROM deals d
JOIN leads l ON d.lead_id = l.id
JOIN users u ON d.user_id = u.id
WHERE MONTH(d.created_at) = 8
  AND YEAR(d.created_at) = 2025;

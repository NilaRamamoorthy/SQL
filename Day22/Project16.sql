-- 1. Create Database and Use
CREATE DATABASE IF NOT EXISTS insurance_monitoring;
USE insurance_monitoring;

-- 2. Create Tables

CREATE TABLE clients (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    insurance_type VARCHAR(100) NOT NULL
);

CREATE TABLE agents (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE claims (
    id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT NOT NULL,
    agent_id INT NOT NULL,
    claim_amount DECIMAL(12,2) NOT NULL,
    claim_status ENUM('Approved', 'Pending', 'Rejected') NOT NULL,
    claim_date DATE NOT NULL,
    policy_type ENUM('Old', 'New') NOT NULL,
    FOREIGN KEY (client_id) REFERENCES clients(id),
    FOREIGN KEY (agent_id) REFERENCES agents(id)
);

CREATE TABLE payments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    claim_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (claim_id) REFERENCES claims(id)
);

-- 3. Insert Sample Data

INSERT INTO clients (name, insurance_type) VALUES
('John Doe', 'Health'),
('Jane Smith', 'Auto'),
('Alice Johnson', 'Life'),
('Bob Brown', 'Health');

INSERT INTO agents (name) VALUES
('Agent A'),
('Agent B'),
('Agent C');

INSERT INTO claims (client_id, agent_id, claim_amount, claim_status, claim_date, policy_type) VALUES
(1, 1, 5000.00, 'Approved', '2025-07-15', 'Old'),
(2, 2, 15000.00, 'Pending', '2025-08-02', 'New'),
(3, 1, 8000.00, 'Rejected', '2025-06-25', 'Old'),
(4, 3, 20000.00, 'Approved', '2025-07-30', 'New'),
(1, 2, 7000.00, 'Pending', '2025-08-05', 'New'),
(3, 3, 12000.00, 'Approved', '2025-08-01', 'New');

INSERT INTO payments (claim_id, payment_date, amount) VALUES
(1, '2025-07-20', 5000.00),
(4, '2025-08-05', 20000.00),
(6, '2025-08-10', 12000.00);

-- 4. Query: Subquery to calculate average claim per insurance type

SELECT 
    c.insurance_type,
    AVG(cl.claim_amount) AS avg_claim_amount
FROM clients c
JOIN claims cl ON c.id = cl.client_id
GROUP BY c.insurance_type;

-- 5. Query: CASE to show claim status with description

SELECT
    id,
    client_id,
    claim_amount,
    claim_status,
    CASE
        WHEN claim_status = 'Approved' THEN 'Approved'
        WHEN claim_status = 'Pending' THEN 'Under Review'
        WHEN claim_status = 'Rejected' THEN 'Denied'
        ELSE 'Unknown'
    END AS status_description,
    claim_date
FROM claims;

-- 6. Query: UNION ALL for old and new policy claims

SELECT * FROM claims WHERE policy_type = 'Old'
UNION ALL
SELECT * FROM claims WHERE policy_type = 'New';

-- 7. Query: Correlated subquery to get highest claim per client

SELECT
    c.id AS client_id,
    c.name,
    (
        SELECT MAX(claim_amount)
        FROM claims cl
        WHERE cl.client_id = c.id
    ) AS highest_claim
FROM clients c;

-- 8. Query: JOIN + GROUP BY to find average claims per agent

SELECT 
    a.id AS agent_id,
    a.name AS agent_name,
    AVG(cl.claim_amount) AS avg_claim_amount,
    COUNT(cl.id) AS total_claims
FROM agents a
LEFT JOIN claims cl ON a.id = cl.agent_id
GROUP BY a.id, a.name;

-- 9. Query: Date filtering for claims filed this quarter

SELECT *
FROM claims
WHERE QUARTER(claim_date) = QUARTER(CURDATE())
AND YEAR(claim_date) = YEAR(CURDATE());

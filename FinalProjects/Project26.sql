-- 1. Create Database
CREATE DATABASE donation_management_system;
USE donation_management_system;

-- 2. Create Tables

-- Donors Table
CREATE TABLE donors (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Causes Table
CREATE TABLE causes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(150) NOT NULL
);

-- Donations Table
CREATE TABLE donations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    donor_id INT NOT NULL,
    cause_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    donated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (donor_id) REFERENCES donors(id) ON DELETE CASCADE,
    FOREIGN KEY (cause_id) REFERENCES causes(id) ON DELETE CASCADE
);

-- 3. Insert Sample Data

-- Donors
INSERT INTO donors (name) VALUES
('Alice Johnson'),
('Bob Smith'),
('Charlie Davis');

-- Causes
INSERT INTO causes (title) VALUES
('Clean Water Project'),
('School Supplies for Kids'),
('Animal Shelter Support');

-- Donations
INSERT INTO donations (donor_id, cause_id, amount, donated_at) VALUES
(1, 1, 100.00, '2025-08-01 10:15:00'),
(1, 2, 50.00,  '2025-08-03 12:00:00'),
(2, 1, 200.00, '2025-08-04 14:30:00'),
(2, 3, 75.00,  '2025-08-05 09:45:00'),
(3, 1, 150.00, '2025-08-06 16:20:00'),
(3, 2, 120.00, '2025-08-07 11:10:00');

-- 4. Query: Total donations per cause
SELECT 
    c.title AS cause_title,
    SUM(d.amount) AS total_donations
FROM donations d
JOIN causes c ON d.cause_id = c.id
GROUP BY c.title
ORDER BY total_donations DESC;

-- 5. Query: Ranking causes by total funds raised
SELECT 
    c.title,
    SUM(d.amount) AS total_raised,
    RANK() OVER (ORDER BY SUM(d.amount) DESC) AS cause_rank
FROM donations d
JOIN causes c ON d.cause_id = c.id
GROUP BY c.title;

-- 6. Query: Donations made by a specific donor
SELECT 
    donors.name AS donor_name,
    causes.title AS cause_title,
    donations.amount,
    donations.donated_at
FROM donations
JOIN donors ON donations.donor_id = donors.id
JOIN causes ON donations.cause_id = causes.id
WHERE donors.name = 'Alice Johnson'
ORDER BY donations.donated_at;

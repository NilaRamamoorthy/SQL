-- 1. Create Database
CREATE DATABASE asset_management;
USE asset_management;

-- 2. Create Tables

-- Assets table
CREATE TABLE assets (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL
);

-- Users table
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Assignments table
CREATE TABLE assignments (
    asset_id INT NOT NULL,
    user_id INT NOT NULL,
    assigned_date DATE NOT NULL,
    returned_date DATE NULL,
    PRIMARY KEY (asset_id, assigned_date),
    FOREIGN KEY (asset_id) REFERENCES assets(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 3. Insert Sample Data

-- Assets
INSERT INTO assets (name, category) VALUES
('Laptop Dell XPS', 'Electronics'),
('Projector Epson X500', 'Electronics'),
('Office Chair Ergonomic', 'Furniture'),
('iPhone 14 Pro', 'Electronics');

-- Users
INSERT INTO users (name) VALUES
('Alice'),
('Bob'),
('Charlie');

-- Assignments
INSERT INTO assignments (asset_id, user_id, assigned_date, returned_date) VALUES
(1, 1, '2025-08-01', NULL),          -- Currently assigned to Alice
(2, 2, '2025-07-20', '2025-08-05'), -- Returned
(3, 3, '2025-08-03', NULL),          -- Currently assigned to Charlie
(4, 2, '2025-06-15', '2025-07-01'); -- Returned

-- 4. Query: Current assignments (not yet returned)
SELECT 
    a.id AS asset_id,
    a.name AS asset_name,
    u.name AS assigned_to,
    asg.assigned_date
FROM assets a
JOIN assignments asg ON a.id = asg.asset_id
JOIN users u ON asg.user_id = u.id
WHERE asg.returned_date IS NULL
ORDER BY asg.assigned_date;

-- 5. Query: Asset availability (assets not currently assigned)
SELECT 
    a.id AS asset_id,
    a.name AS asset_name,
    a.category
FROM assets a
WHERE a.id NOT IN (
    SELECT asset_id 
    FROM assignments
    WHERE returned_date IS NULL
);

-- 6. Query: Assignment history of a specific asset
SELECT 
    a.name AS asset_name,
    u.name AS assigned_to,
    asg.assigned_date,
    asg.returned_date
FROM assignments asg
JOIN assets a ON asg.asset_id = a.id
JOIN users u ON asg.user_id = u.id
WHERE a.id = 1
ORDER BY asg.assigned_date DESC;

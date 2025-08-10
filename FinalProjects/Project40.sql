-- 1. Create Database
CREATE DATABASE freelance_management;
USE freelance_management;

-- 2. Create Tables

-- Freelancers table
CREATE TABLE freelancers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    skill VARCHAR(100) NOT NULL
);

-- Projects table
CREATE TABLE projects (
    id INT PRIMARY KEY AUTO_INCREMENT,
    client_name VARCHAR(100) NOT NULL,
    title VARCHAR(150) NOT NULL
);

-- Proposals table
CREATE TABLE proposals (
    id INT PRIMARY KEY AUTO_INCREMENT,
    freelancer_id INT NOT NULL,
    project_id INT NOT NULL,
    bid_amount DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'accepted', 'rejected') DEFAULT 'pending',
    FOREIGN KEY (freelancer_id) REFERENCES freelancers(id) ON DELETE CASCADE,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);

-- 3. Insert Sample Data

-- Freelancers
INSERT INTO freelancers (name, skill) VALUES
('Alice Johnson', 'Web Development'),
('Bob Smith', 'Graphic Design'),
('Charlie Brown', 'Content Writing');

-- Projects
INSERT INTO projects (client_name, title) VALUES
('Acme Corp', 'E-commerce Website'),
('Bright Media', 'Logo Redesign'),
('TechWorld', 'Blog Content Creation');

-- Proposals
INSERT INTO proposals (freelancer_id, project_id, bid_amount, status) VALUES
(1, 1, 1500.00, 'accepted'),
(2, 1, 1400.00, 'rejected'),
(3, 3, 500.00, 'pending'),
(1, 2, 300.00, 'pending'),
(2, 2, 350.00, 'accepted'),
(3, 3, 550.00, 'accepted');

-- 4. Query: Count projects per freelancer (only accepted proposals)
SELECT 
    f.name AS freelancer_name,
    COUNT(p.id) AS accepted_projects
FROM proposals pr
JOIN freelancers f ON pr.freelancer_id = f.id
JOIN projects p ON pr.project_id = p.id
WHERE pr.status = 'accepted'
GROUP BY f.id
ORDER BY accepted_projects DESC;

-- 5. Query: List all proposals for a given project with bid details
SELECT 
    p.title AS project_title,
    f.name AS freelancer_name,
    pr.bid_amount,
    pr.status
FROM proposals pr
JOIN freelancers f ON pr.freelancer_id = f.id
JOIN projects p ON pr.project_id = p.id
WHERE p.id = 1
ORDER BY pr.bid_amount ASC;

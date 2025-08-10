-- 1. Create Database
CREATE DATABASE multi_tenant_saas;
USE multi_tenant_saas;

-- 2. Create Tables

-- Tenants table (companies/clients)
CREATE TABLE tenants (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

-- Users table (linked to tenants)
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    tenant_id INT NOT NULL,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);

-- Data table (tenant-owned content)
CREATE TABLE data (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tenant_id INT NOT NULL,
    content TEXT NOT NULL,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);

-- 3. Insert Sample Data

INSERT INTO tenants (name) VALUES
('Acme Corp'),
('Beta Solutions'),
('CloudWorks');

INSERT INTO users (name, tenant_id) VALUES
('Alice', 1),
('Bob', 1),
('Charlie', 2),
('Diana', 3);

INSERT INTO data (tenant_id, content) VALUES
(1, 'Acme Corp document A'),
(1, 'Acme Corp document B'),
(2, 'Beta Solutions spec sheet'),
(3, 'CloudWorks project notes');

-- 4. Query: Fetch all users for a given tenant
SELECT u.id, u.name
FROM users u
JOIN tenants t ON u.tenant_id = t.id
WHERE t.name = 'Acme Corp';

-- 5. Query: Fetch all data for a specific tenant by ID
SELECT d.id, d.content
FROM data d
WHERE d.tenant_id = 2;

-- 6. Query: Count data records per tenant
SELECT t.id, t.name, COUNT(d.id) AS data_count
FROM tenants t
LEFT JOIN data d ON t.id = d.tenant_id
GROUP BY t.id, t.name;

-- 1. Create Database
CREATE DATABASE inventory_system;
USE inventory_system;

-- 2. Create Tables

-- Products table
CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    stock INT NOT NULL DEFAULT 0
);

-- Suppliers table
CREATE TABLE suppliers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Inventory logs table
CREATE TABLE inventory_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    supplier_id INT,
    action ENUM('IN', 'OUT') NOT NULL,
    qty INT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
);

-- 3. Trigger to auto-update stock
DELIMITER $$

CREATE TRIGGER update_stock_after_log
AFTER INSERT ON inventory_logs
FOR EACH ROW
BEGIN
    IF NEW.action = 'IN' THEN
        UPDATE products
        SET stock = stock + NEW.qty
        WHERE id = NEW.product_id;
    ELSEIF NEW.action = 'OUT' THEN
        UPDATE products
        SET stock = stock - NEW.qty
        WHERE id = NEW.product_id;
    END IF;
END$$

DELIMITER ;

-- 4. Insert Sample Data

-- Products
INSERT INTO products (name, stock) VALUES
('Laptop', 10),
('Mouse', 25),
('Keyboard', 5),
('Monitor', 12),
('Printer', 3);

-- Suppliers
INSERT INTO suppliers (name) VALUES
('TechSupplier Pvt Ltd'),
('Gadget World'),
('ElectroHub Inc.');

-- Inventory Logs (Trigger will auto-update stock)
INSERT INTO inventory_logs (product_id, supplier_id, action, qty)
VALUES
(1, 1, 'OUT', 3),   -- Laptop stock will decrease by 3
(3, 2, 'IN', 10),   -- Keyboard stock will increase by 10
(5, 3, 'IN', 5),    -- Printer stock will increase by 5
(2, 1, 'OUT', 5),   -- Mouse stock will decrease by 5
(4, 2, 'OUT', 2);   -- Monitor stock will decrease by 2

-- 5. Stock Status with CASE WHEN
SELECT 
    id,
    name,
    stock,
    CASE 
        WHEN stock <= 5 THEN 'Reorder Now'
        WHEN stock BETWEEN 6 AND 15 THEN 'Low Stock'
        ELSE 'In Stock'
    END AS stock_status
FROM products;

-- 6. Latest Supplier for Each Product
SELECT 
    p.id,
    p.name,
    p.stock,
    s.name AS last_supplier
FROM products p
LEFT JOIN suppliers s ON s.id = (
    SELECT supplier_id
    FROM inventory_logs
    WHERE product_id = p.id
    ORDER BY timestamp DESC
    LIMIT 1
);

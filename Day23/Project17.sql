
CREATE DATABASE IF NOT EXISTS WarehouseDB;
USE WarehouseDB;

-- Step 1: Create tables

CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    contact_info VARCHAR(255)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0)
);

CREATE TABLE batches (
    batch_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    batch_number VARCHAR(50) NOT NULL,
    manufactured_date DATE NOT NULL,
    expiry_date DATE NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    CHECK (expiry_date > manufactured_date)
);

CREATE TABLE deliveries (
    delivery_id INT PRIMARY KEY AUTO_INCREMENT,
    batch_id INT NOT NULL,
    supplier_id INT NOT NULL,
    delivery_date DATE NOT NULL,
    quantity_delivered INT NOT NULL CHECK (quantity_delivered > 0),
    FOREIGN KEY (batch_id) REFERENCES batches(batch_id) ON DELETE CASCADE,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

-- Step 2: Insert sample data for suppliers and products

INSERT INTO suppliers (name, contact_info) VALUES
('Supplier A', 'contactA@example.com'),
('Supplier B', 'contactB@example.com');

INSERT INTO products (name, description) VALUES
('Product 1', 'Description for product 1'),
('Product 2', 'Description for product 2');

-- Step 3: Insert sample batches

INSERT INTO batches (product_id, batch_number, manufactured_date, expiry_date, quantity) VALUES
(1, 'BATCH1001', '2025-01-01', '2026-01-01', 100),
(2, 'BATCH2001', '2025-02-01', '2025-12-31', 200);

-- Step 4: Drop and recreate FOREIGN KEY on deliveries.supplier_id (example)

-- Drop foreign key (assumes constraint name is deliveries_ibfk_2, adjust as needed)
ALTER TABLE deliveries DROP FOREIGN KEY deliveries_ibfk_2;

-- Recreate foreign key with ON DELETE CASCADE (example)
ALTER TABLE deliveries
ADD CONSTRAINT fk_deliveries_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id) ON DELETE CASCADE;

-- Step 5: Transaction to register a delivery and update product stock atomically

DELIMITER //
CREATE PROCEDURE register_delivery(
    IN p_batch_id INT,
    IN p_supplier_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_product_id INT;
    DECLARE v_batch_qty INT;

    -- Validate supplier exists
    IF NOT EXISTS (SELECT 1 FROM suppliers WHERE supplier_id = p_supplier_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Supplier does not exist.';
    END IF;

    -- Validate batch exists and get product_id
    SELECT product_id, quantity INTO v_product_id, v_batch_qty FROM batches WHERE batch_id = p_batch_id;
    IF v_product_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Batch does not exist.';
    END IF;

    -- Start transaction
    START TRANSACTION;

    -- Insert delivery record
    INSERT INTO deliveries(batch_id, supplier_id, quantity_delivered)
    VALUES (p_batch_id, p_supplier_id, p_quantity);

    -- Update batch quantity
    UPDATE batches SET quantity = quantity + p_quantity WHERE batch_id = p_batch_id;

    -- Update product stock accordingly
    UPDATE products SET stock = stock + p_quantity WHERE product_id = v_product_id;

    COMMIT;
END //
DELIMITER ;

-- Step 6: Sample usage to register a delivery

CALL register_delivery(1, 1, 50);

-- Step 7: Delete expired batches

DELETE FROM batches WHERE expiry_date < CURRENT_DATE;

-- Step 8: Verify current stocks and batches

SELECT * FROM products;
SELECT * FROM batches;
SELECT * FROM deliveries;
SELECT * FROM suppliers;


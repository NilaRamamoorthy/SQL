-- Step 1: Create and use database
CREATE DATABASE IF NOT EXISTS GroceryDB;
USE GroceryDB;

-- Step 2: Create tables

-- Categories table
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

-- Suppliers table
CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_name VARCHAR(150) NOT NULL UNIQUE,
    contact_email VARCHAR(100)
);

-- Products table
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_code VARCHAR(50) NOT NULL,
    product_name VARCHAR(150) NOT NULL,
    category_id INT NOT NULL,
    supplier_id INT NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    quantity INT NOT NULL CHECK (quantity >= 0),
    expiration_date DATE,
    UNIQUE (product_code),
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

-- Stock logs table (to track inventory changes)
CREATE TABLE stock_logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    change_quantity INT NOT NULL,
    log_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reason VARCHAR(255),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Step 3: Insert sample data

INSERT INTO categories (category_name) VALUES
('Fruits'),
('Vegetables'),
('Dairy');

INSERT INTO suppliers (supplier_name, contact_email) VALUES
('Fresh Farms', 'contact@freshfarms.com'),
('Dairy Best', 'sales@dairybest.com');

INSERT INTO products (product_code, product_name, category_id, supplier_id, price, quantity, expiration_date) VALUES
('FRU123', 'Apple', 1, 1, 1.20, 100, '2025-12-31'),
('VEG456', 'Carrot', 2, 1, 0.80, 200, '2025-09-15'),
('DAI789', 'Milk', 3, 2, 2.50, 50, '2025-08-10');

-- Step 4: Drop and recreate UNIQUE constraint on product_code

ALTER TABLE products DROP INDEX product_code;
ALTER TABLE products ADD UNIQUE (product_code);

-- Step 5: Procedure to update price and quantity with validation and atomicity

DELIMITER //
CREATE PROCEDURE update_inventory(
    IN p_product_id INT,
    IN p_new_price DECIMAL(10,2),
    IN p_quantity_change INT,
    IN p_reason VARCHAR(255)
)
BEGIN
    DECLARE current_quantity INT;

    -- Start transaction
    START TRANSACTION;

    -- Get current quantity
    SELECT quantity INTO current_quantity FROM products WHERE product_id = p_product_id FOR UPDATE;

    -- Check quantity won't go negative
    IF current_quantity + p_quantity_change < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Quantity cannot be negative';
    ELSE
        -- Update price if valid
        IF p_new_price >= 0 THEN
            UPDATE products SET price = p_new_price WHERE product_id = p_product_id;
        ELSE
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Price cannot be negative';
        END IF;

        -- Update quantity
        UPDATE products SET quantity = quantity + p_quantity_change WHERE product_id = p_product_id;

        -- Insert into stock_logs
        INSERT INTO stock_logs(product_id, change_quantity, reason) VALUES (p_product_id, p_quantity_change, p_reason);
    END IF;

    COMMIT;
END //
DELIMITER ;

-- Step 6: Procedure to delete expired products

DELIMITER //
CREATE PROCEDURE delete_expired_products()
BEGIN
    DELETE FROM products WHERE expiration_date < CURDATE();
END //
DELIMITER ;

-- Step 7: Bulk price update with SAVEPOINT and rollback on failure

DELIMITER //
CREATE PROCEDURE bulk_update_prices()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK TO sp1;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bulk price update failed, rolled back';
    END;

    START TRANSACTION;

    SAVEPOINT sp1;

    -- Example updates, replace with your logic or dynamic input
    CALL update_inventory(1, 1.30, 0, 'Price update');
    CALL update_inventory(2, 0.85, 0, 'Price update');
    CALL update_inventory(3, -1.00, 0, 'Invalid price update'); -- This will cause failure and rollback

    COMMIT;
END //
DELIMITER ;

-- Step 8: Sample usage

-- Successful inventory update
CALL update_inventory(1, 1.25, -10, 'Sold 10 apples');

-- Try deleting expired products (none will be deleted if all dates are future)
CALL delete_expired_products();

-- Try bulk update prices (will rollback due to negative price on product 3)
-- CALL bulk_update_prices();

-- Check current products
SELECT * FROM products;

-- Check stock logs
SELECT * FROM stock_logs;

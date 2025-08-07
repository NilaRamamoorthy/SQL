CREATE DATABASE IF NOT EXISTS RestaurantDB;
USE RestaurantDB;

-- Step 1: Create tables

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20)
);

CREATE TABLE menu_items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    item_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    availability INT NOT NULL CHECK (availability >= 0)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    item_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity <= 10),
    order_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    table_number INT, -- will add NOT NULL later
    status ENUM('Pending', 'Paid', 'Cancelled') DEFAULT 'Pending',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES menu_items(item_id) ON DELETE CASCADE
);

CREATE TABLE bills (
    bill_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    bill_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
);

-- Step 2: Insert sample data

INSERT INTO customers (name, phone) VALUES
('Alice Johnson', '1234567890'),
('Bob Williams', '0987654321');

INSERT INTO menu_items (item_name, price, availability) VALUES
('Burger', 5.99, 50),
('Pizza', 12.49, 20),
('Pasta', 8.75, 15);

-- Step 3: Drop and reapply NOT NULL constraint on table_number in orders

-- First, ensure no NULLs in table_number
UPDATE orders SET table_number = 1 WHERE table_number IS NULL;

-- Drop NOT NULL (MySQL doesn’t allow direct dropping of NOT NULL easily)
-- Instead, modify column to allow NULL temporarily
ALTER TABLE orders MODIFY table_number INT NULL;

-- Reapply NOT NULL constraint
ALTER TABLE orders MODIFY table_number INT NOT NULL;

-- Step 4: Trigger to update item availability after order insertion

DELIMITER //
CREATE TRIGGER after_order_insert
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    -- Decrease availability by quantity ordered if enough stock exists
    IF (SELECT availability FROM menu_items WHERE item_id = NEW.item_id) >= NEW.quantity THEN
        UPDATE menu_items SET availability = availability - NEW.quantity WHERE item_id = NEW.item_id;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Not enough availability for ordered item';
    END IF;
END;
//
DELIMITER ;

-- Step 5: Delete unpaid orders after timeout (e.g., after 1 hour)

DELIMITER //
CREATE EVENT IF NOT EXISTS ev_delete_unpaid_orders
ON SCHEDULE EVERY 1 HOUR
DO
BEGIN
    DELETE FROM orders WHERE status = 'Pending' AND order_time < NOW() - INTERVAL 1 HOUR;
END;
//
DELIMITER ;

-- Step 6: Transaction to create order and bill atomically

DELIMITER //
CREATE PROCEDURE place_order(
    IN p_customer_id INT,
    IN p_item_id INT,
    IN p_quantity INT,
    IN p_table_number INT,
    OUT p_order_id INT,
    OUT p_bill_id INT
)
BEGIN
    DECLARE total DECIMAL(10,2);
    DECLARE availability_count INT;

    START TRANSACTION;

    -- Check availability
    SELECT availability INTO availability_count FROM menu_items WHERE item_id = p_item_id FOR UPDATE;

    IF availability_count < p_quantity THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient item availability';
    ELSE
        -- Insert order
        INSERT INTO orders (customer_id, item_id, quantity, table_number)
        VALUES (p_customer_id, p_item_id, p_quantity, p_table_number);
        SET p_order_id = LAST_INSERT_ID();

        -- Calculate total amount
        SELECT price * p_quantity INTO total FROM menu_items WHERE item_id = p_item_id;

        -- Insert bill
        INSERT INTO bills (order_id, total_amount) VALUES (p_order_id, total);
        SET p_bill_id = LAST_INSERT_ID();

        COMMIT;
    END IF;
END;
//
DELIMITER ;

-- Step 7: Sample usage of place_order procedure

CALL place_order(1, 2, 3, 5, @order_id, @bill_id);
SELECT @order_id AS OrderID, @bill_id AS BillID;

-- Step 8: Verify updated availability and inserted data

SELECT * FROM menu_items;
SELECT * FROM orders;
SELECT * FROM bills;


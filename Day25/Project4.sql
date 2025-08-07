-- Step 1: Create database and use it
CREATE DATABASE IF NOT EXISTS FoodDelivery;
USE FoodDelivery;

-- Step 2: Create normalized tables

-- Suppliers
CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_name VARCHAR(255) NOT NULL
);

-- Menu items
CREATE TABLE menu_items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    item_name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    supplier_cost DECIMAL(10,2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    supplier_id INT NOT NULL,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

-- Customers
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(255) NOT NULL
);

-- Orders
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'Pending',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Order items
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    item_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (item_id) REFERENCES menu_items(item_id)
);

-- Delivery queue
CREATE TABLE delivery_queue (
    delivery_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    assigned_to VARCHAR(255),
    eta DATETIME,
    status VARCHAR(50) DEFAULT 'Queued',
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Step 3: Create view for customers hiding supplier cost
CREATE OR REPLACE VIEW view_menu_items AS
SELECT item_id, item_name, price, stock_quantity
FROM menu_items;

-- Step 4: Procedure to place food order, deduct stock, and return receipt
DELIMITER //
CREATE PROCEDURE place_food_order(
    IN p_customer_id INT,
    IN p_items JSON, -- JSON array [{"item_id":1,"quantity":2}, {"item_id":2,"quantity":1}]
    OUT p_order_id INT,
    OUT p_total DECIMAL(10,2)
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE item_id INT;
    DECLARE quantity INT;
    DECLARE unit_price DECIMAL(10,2);
    DECLARE total DECIMAL(10,2) DEFAULT 0.0;
    DECLARE idx INT DEFAULT 0;
    DECLARE items_count INT;
    DECLARE cur_item JSON;
    
    -- Insert new order with total_amount=0 temporarily
    INSERT INTO orders(customer_id, total_amount) VALUES (p_customer_id, 0);
    SET p_order_id = LAST_INSERT_ID();
    
    SET items_count = JSON_LENGTH(p_items);
    
    WHILE idx < items_count DO
        SET cur_item = JSON_EXTRACT(p_items, CONCAT('$[', idx, ']'));
        SET item_id = JSON_UNQUOTE(JSON_EXTRACT(cur_item, '$.item_id'));
        SET quantity = CAST(JSON_UNQUOTE(JSON_EXTRACT(cur_item, '$.quantity')) AS UNSIGNED);
        
        -- Get current price and stock
        SELECT price, stock_quantity INTO unit_price, @stock FROM menu_items WHERE item_id = item_id;
        
        IF @stock < quantity THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = CONCAT('Insufficient stock for item_id=', item_id);
        END IF;
        
        -- Deduct stock
        UPDATE menu_items SET stock_quantity = stock_quantity - quantity WHERE item_id = item_id;
        
        -- Insert into order_items
        INSERT INTO order_items(order_id, item_id, quantity, unit_price)
        VALUES (p_order_id, item_id, quantity, unit_price);
        
        SET total = total + (unit_price * quantity);
        SET idx = idx + 1;
    END WHILE;
    
    -- Update total_amount in orders table
    UPDATE orders SET total_amount = total WHERE order_id = p_order_id;
    
    SET p_total = total;
END //
DELIMITER ;

-- Step 5: Function to get delivery ETA for an order
DELIMITER //
CREATE FUNCTION get_delivery_eta(p_order_id INT) RETURNS DATETIME
DETERMINISTIC
BEGIN
    DECLARE v_eta DATETIME;
    
    SELECT eta INTO v_eta FROM delivery_queue WHERE order_id = p_order_id ORDER BY eta DESC LIMIT 1;
    
    RETURN v_eta;
END //
DELIMITER ;

-- Step 6: Trigger after order inserted to insert into delivery_queue
DELIMITER //
CREATE TRIGGER after_order_placed
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    INSERT INTO delivery_queue(order_id, status)
    VALUES (NEW.order_id, 'Queued');
END //
DELIMITER ;

-- Step 7: User Access Control Example (simplified)
-- Admin user with full access
CREATE USER IF NOT EXISTS 'admin'@'%' IDENTIFIED BY 'adminpass';
GRANT ALL PRIVILEGES ON FoodDelivery.* TO 'admin'@'%';

-- Customer user with limited access (can only SELECT from view_menu_items and own orders)
CREATE USER IF NOT EXISTS 'customer'@'%' IDENTIFIED BY 'custpass';
GRANT SELECT ON FoodDelivery.view_menu_items TO 'customer'@'%';
GRANT SELECT ON FoodDelivery.orders TO 'customer'@'%';
GRANT SELECT ON FoodDelivery.order_items TO 'customer'@'%';

-- Revoke direct access to menu_items and suppliers for customers
REVOKE ALL PRIVILEGES ON FoodDelivery.menu_items FROM 'customer'@'%';
REVOKE ALL PRIVILEGES ON FoodDelivery.suppliers FROM 'customer'@'%';




-- Sample data 
INSERT INTO suppliers (supplier_name) VALUES ('Supplier A'), ('Supplier B');

INSERT INTO menu_items (item_name, price, supplier_cost, stock_quantity, supplier_id) VALUES
('Burger', 5.99, 3.00, 50, 1),
('Pizza', 9.99, 5.00, 30, 2),
('Salad', 4.50, 2.00, 20, 1);

INSERT INTO customers (customer_name) VALUES ('John Doe'), ('Jane Roe');

-- Example call for placing an order:
CALL place_food_order(1, '[{"item_id":1,"quantity":2},{"item_id":3,"quantity":1}]', @order_id, @total);
SELECT @order_id, @total;

-- Example call for delivery ETA:
 SELECT get_delivery_eta(1);

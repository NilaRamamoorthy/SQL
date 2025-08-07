-- Step 1: Create Database and Use It
CREATE DATABASE IF NOT EXISTS ECommerceOrderSystem;
USE ECommerceOrderSystem;

-- Step 2: Create Tables

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(50)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    discount DECIMAL(10,2) DEFAULT 0,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE order_audit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    audit_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    action VARCHAR(100) NOT NULL
);


INSERT INTO customers (customer_name, email, phone) VALUES
('John Doe', 'john@example.com', '1234567890'),
('Jane Smith', 'jane@example.com', '0987654321');

INSERT INTO products (product_name, price) VALUES
('Laptop', 1200.00),
('Smartphone', 800.00),
('Wireless Mouse', 25.00);
-- Step 3: Create view to show order summary hiding discount logic
CREATE OR REPLACE VIEW view_order_summary AS
SELECT 
    o.order_id,
    c.customer_name,
    SUM(p.price * oi.quantity) AS total_amount -- total without discount shown here
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY o.order_id, c.customer_name;

-- Step 4: Stored procedure to place order (insert into orders and order_items)
DELIMITER //
CREATE PROCEDURE place_order(
    IN p_customer_id INT,
    IN p_product_ids TEXT, -- comma separated product_ids
    IN p_quantities TEXT -- comma separated quantities (same order)
)
BEGIN
    DECLARE v_order_id INT;
    DECLARE v_pos INT DEFAULT 1;
    DECLARE v_product_id INT;
    DECLARE v_quantity INT;
    DECLARE v_next_pos INT;
    DECLARE v_product_ids_length INT;
    DECLARE v_quantities_length INT;
    DECLARE v_product_ids_sub TEXT;
    DECLARE v_quantities_sub TEXT;

    -- Insert new order (discount = 0 for simplicity)
    INSERT INTO orders (customer_id) VALUES (p_customer_id);
    SET v_order_id = LAST_INSERT_ID();

    -- Loop over product_ids and quantities, parse comma separated values
    SET v_product_ids_length = LENGTH(p_product_ids);
    SET v_quantities_length = LENGTH(p_quantities);

    WHILE v_pos <= v_product_ids_length DO
        -- Extract next product_id
        SET v_next_pos = LOCATE(',', p_product_ids, v_pos);
        IF v_next_pos = 0 THEN
            SET v_next_pos = v_product_ids_length + 1;
        END IF;
        SET v_product_ids_sub = SUBSTRING(p_product_ids, v_pos, v_next_pos - v_pos);
        SET v_product_id = CAST(v_product_ids_sub AS UNSIGNED);

        -- Extract next quantity
        SET v_next_pos = LOCATE(',', p_quantities, v_pos);
        IF v_next_pos = 0 THEN
            SET v_next_pos = v_quantities_length + 1;
        END IF;
        SET v_quantities_sub = SUBSTRING(p_quantities, v_pos, v_next_pos - v_pos);
        SET v_quantity = CAST(v_quantities_sub AS UNSIGNED);

        -- Insert into order_items
        INSERT INTO order_items (order_id, product_id, quantity)
        VALUES (v_order_id, v_product_id, v_quantity);

        SET v_pos = v_next_pos + 1;
    END WHILE;
END //
DELIMITER ;

-- Step 5: Function to calculate total cost of an order (including discount)
DELIMITER //
CREATE FUNCTION get_order_total(p_order_id INT) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(10,2);

    SELECT 
        IFNULL(SUM(p.price * oi.quantity), 0) - IFNULL(o.discount, 0)
    INTO v_total
    FROM orders o
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    LEFT JOIN products p ON oi.product_id = p.product_id
    WHERE o.order_id = p_order_id;

    RETURN IF(v_total < 0, 0, v_total);
END //
DELIMITER ;

-- Step 6: Trigger to log new orders into order_audit
DELIMITER //
CREATE TRIGGER after_order_insert
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    INSERT INTO order_audit(order_id, action) VALUES (NEW.order_id, 'Order Created');
END //
DELIMITER ;

-- Step 7: Create read-only view of customer info for employee access
CREATE OR REPLACE VIEW view_customer_info AS
SELECT customer_id, customer_name FROM customers;

-- Step 8: User privileges (example, run as admin)
-- Create employee user (read-only)
CREATE USER IF NOT EXISTS 'employee'@'%' IDENTIFIED BY 'employee_pass';

-- Revoke all privileges to start clean
REVOKE ALL PRIVILEGES, GRANT OPTION FROM  ECommerceOrderSystem;

-- Grant SELECT only on views to employee
GRANT SELECT ON ECommerceOrderSystem.view_order_summary TO 'employee'@'%';
GRANT SELECT ON ECommerceOrderSystem.view_customer_info TO 'employee'@'%';

FLUSH PRIVILEGES;


CALL place_order(1, '1,3', '1,2');


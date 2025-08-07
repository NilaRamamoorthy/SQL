CREATE DATABASE IF NOT EXISTS CRMDB;
USE CRMDB;

-- Step 1: Create tables

CREATE TABLE leads (
    lead_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    status ENUM('New', 'Contacted', 'Qualified', 'Converted', 'Lost') DEFAULT 'New',
    followup_count INT DEFAULT 0 CHECK (followup_count <= 5),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    sale_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

CREATE TABLE followups (
    followup_id INT PRIMARY KEY AUTO_INCREMENT,
    lead_id INT NOT NULL,
    followup_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    FOREIGN KEY (lead_id) REFERENCES leads(lead_id) ON DELETE CASCADE
);

-- Step 2: Insert sample lead data

INSERT INTO leads (name, phone, email, status, followup_count) VALUES
('John Doe', '1234567890', 'john@example.com', 'New', 0),
('Jane Smith', '0987654321', 'jane@example.com', 'Contacted', 1),
('Alice Johnson', '1112223333', 'alice@example.com', 'Qualified', 2);

-- Step 3: Update lead status example

UPDATE leads SET status = 'Converted' WHERE lead_id = 3;

-- Step 4: Delete leads older than 1 year

DELETE FROM leads WHERE created_at < DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

-- Step 5: Drop and reapply FOREIGN KEY on sales.customer_id

-- Drop FK
ALTER TABLE sales DROP FOREIGN KEY sales_ibfk_1; -- Replace sales_ibfk_1 with actual FK name if different

-- Recreate FK
ALTER TABLE sales
ADD CONSTRAINT fk_sales_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE;

-- Step 6: Transaction to convert lead to customer and log sale

DELIMITER //
CREATE PROCEDURE convert_lead_to_customer(
    IN p_lead_id INT,
    IN p_sale_amount DECIMAL(10,2)
)
BEGIN
    DECLARE v_name VARCHAR(100);
    DECLARE v_phone VARCHAR(15);
    DECLARE v_email VARCHAR(100);
    DECLARE v_customer_id INT;

    START TRANSACTION;

    -- Get lead details
    SELECT name, phone, email INTO v_name, v_phone, v_email FROM leads WHERE lead_id = p_lead_id FOR UPDATE;

    -- Insert into customers
    INSERT INTO customers (name, phone, email) VALUES (v_name, v_phone, v_email);
    SET v_customer_id = LAST_INSERT_ID();

    -- Insert sale
    INSERT INTO sales (customer_id, amount) VALUES (v_customer_id, p_sale_amount);

    -- Update lead status to Converted
    UPDATE leads SET status = 'Converted' WHERE lead_id = p_lead_id;

    COMMIT;
END //
DELIMITER ;

-- Step 7: Sample call to convert lead to customer and log sale

CALL convert_lead_to_customer(1, 1000.00);

-- Step 8: Show customers and sales after conversion

SELECT * FROM customers;
SELECT * FROM sales;
SELECT * FROM leads;


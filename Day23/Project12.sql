CREATE DATABASE IF NOT EXISTS OnlineShoppingDB;
USE OnlineShoppingDB;

-- Step 1: Create tables

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    stock INT NOT NULL CHECK (stock >= 0)
);

CREATE TABLE cart_items (
    cart_item_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity BETWEEN 1 AND 10),
    added_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_user_product (user_id, product_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    total_price DECIMAL(10,2) NOT NULL CHECK (total_price >= 0),
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity BETWEEN 1 AND 10),
    price_at_order DECIMAL(10,2) NOT NULL CHECK (price_at_order >= 0),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Step 2: Insert sample data

INSERT INTO users (username, email) VALUES
('alice', 'alice@example.com'),
('bob', 'bob@example.com');

INSERT INTO products (name, price, stock) VALUES
('Laptop', 999.99, 10),
('Headphones', 199.99, 50),
('Mouse', 29.99, 100);

INSERT INTO cart_items (user_id, product_id, quantity) VALUES
(1, 1, 1),  -- Alice adds 1 Laptop
(1, 3, 2),  -- Alice adds 2 Mouse
(2, 2, 1);  -- Bob adds 1 Headphones

-- Step 3: Drop and re-add UNIQUE constraint on cart_items (user_id, product_id)

ALTER TABLE cart_items DROP INDEX unique_user_product;

ALTER TABLE cart_items ADD UNIQUE KEY unique_user_product (user_id, product_id);

-- Step 4: Delete abandoned carts older than 7 days

DELETE FROM cart_items WHERE added_at < NOW() - INTERVAL 7 DAY;

-- Step 5: Transaction to place order, update stock, and clear cart

DELIMITER //
CREATE PROCEDURE place_order(IN p_user_id INT, OUT p_order_id INT, OUT p_success BOOLEAN)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_product_id INT;
    DECLARE v_quantity INT;
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_total DECIMAL(10,2) DEFAULT 0;

    DECLARE cur CURSOR FOR
        SELECT product_id, quantity FROM cart_items WHERE user_id = p_user_id;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    START TRANSACTION;

    -- Calculate total and check stock
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_product_id, v_quantity;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SELECT price, stock INTO v_price, @stock FROM products WHERE product_id = v_product_id FOR UPDATE;

        IF @stock < v_quantity THEN
            SET p_success = FALSE;
            ROLLBACK;
            LEAVE read_loop;
        END IF;

        SET v_total = v_total + v_price * v_quantity;
    END LOOP;
    CLOSE cur;

    IF p_success IS NOT FALSE THEN
        -- Insert order
        INSERT INTO orders (user_id, total_price) VALUES (p_user_id, v_total);
        SET p_order_id = LAST_INSERT_ID();

        -- Insert order_items and update stock
        OPEN cur;
        SET done = FALSE;
        read_loop2: LOOP
            FETCH cur INTO v_product_id, v_quantity;
            IF done THEN
                LEAVE read_loop2;
            END IF;

            SELECT price INTO v_price FROM products WHERE product_id = v_product_id;

            INSERT INTO order_items (order_id, product_id, quantity, price_at_order)
            VALUES (p_order_id, v_product_id, v_quantity, v_price);

            UPDATE products SET stock = stock - v_quantity WHERE product_id = v_product_id;
        END LOOP;
        CLOSE cur;

        -- Clear cart
        DELETE FROM cart_items WHERE user_id = p_user_id;

        SET p_success = TRUE;
        COMMIT;
    END IF;
END //
DELIMITER ;

-- Step 6: Sample call to place_order

CALL place_order(1, @new_order_id, @order_success);
SELECT @new_order_id AS OrderID, @order_success AS Success;

-- Step 7: Show updated stock and orders

SELECT * FROM products;

SELECT * FROM orders WHERE order_id = @new_order_id;

SELECT * FROM order_items WHERE order_id = @new_order_id;

SELECT * FROM cart_items WHERE user_id = 1;


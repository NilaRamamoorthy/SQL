-- =======================================
-- 1. CREATE DATABASE AND SELECT IT
-- =======================================
CREATE DATABASE  shopping_cart;
USE shopping_cart;


-- 2. CREATE TABLES

-- Users table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE
);

-- Products table (same structure as in the catalog)
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL,
    image_url VARCHAR(255)
);

-- Carts table
CREATE TABLE carts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Cart items table (many-to-many between carts and products)
CREATE TABLE cart_items (
    cart_id INT,
    product_id INT,
    quantity INT NOT NULL DEFAULT 1,
    PRIMARY KEY (cart_id, product_id),
    FOREIGN KEY (cart_id) REFERENCES carts(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- 3. INSERT SAMPLE DATA


-- Users
INSERT INTO users (name, email) VALUES
('Alice', 'alice@example.com'),
('Bob', 'bob@example.com');

-- Products
INSERT INTO products (name, description, price, stock, image_url) VALUES
('Laptop', 'High performance laptop', 1200.00, 10, 'https://example.com/laptop.jpg'),
('Headphones', 'Noise-cancelling headphones', 150.00, 20, 'https://example.com/headphones.jpg'),
('Book', 'Interesting novel', 25.00, 100, 'https://example.com/book.jpg');

-- Carts
INSERT INTO carts (user_id) VALUES (1), (2);

-- Cart Items (Alice adds 2 laptops and 1 book, Bob adds 1 headphone)
INSERT INTO cart_items (cart_id, product_id, quantity) VALUES
(1, 1, 2), -- Alice's cart, Laptop
(1, 3, 1), -- Alice's cart, Book
(2, 2, 1); -- Bob's cart, Headphones


-- 1. Get all items in a user's cart (with product details)
SELECT 
    ci.cart_id,
    u.name AS user,
    p.name AS product,
    p.price,
    ci.quantity,
    (p.price * ci.quantity) AS total_item_price
FROM cart_items ci
JOIN carts c ON ci.cart_id = c.id
JOIN users u ON c.user_id = u.id
JOIN products p ON ci.product_id = p.id
WHERE u.id = 1; -- Alice's cart

-- 2. Calculate total value of a user's cart
SELECT 
    u.name AS user,
    SUM(p.price * ci.quantity) AS total_cart_value
FROM cart_items ci
JOIN carts c ON ci.cart_id = c.id
JOIN users u ON c.user_id = u.id
JOIN products p ON ci.product_id = p.id
WHERE u.id = 1 -- Alice
GROUP BY u.name;

-- 3. Add a product to a user's cart (insert or increase quantity)
-- Example: Alice adds 1 more book
INSERT INTO cart_items (cart_id, product_id, quantity)
VALUES (1, 3, 1)
ON DUPLICATE KEY UPDATE quantity = quantity + 1;

-- 4. Update quantity of an item in the cart
-- Example: Set book quantity in Alice's cart to 5
UPDATE cart_items
SET quantity = 5
WHERE cart_id = 1 AND product_id = 3;

-- 5. Remove an item from the cart
-- Example: Remove laptop from Alice's cart
DELETE FROM cart_items
WHERE cart_id = 1 AND product_id = 1;

-- 6. Clear all items from a user's cart
DELETE FROM cart_items
WHERE cart_id = (SELECT id FROM carts WHERE user_id = 1); -- Alice

-- 7. Count number of items in a user's cart (total quantity)
SELECT 
    u.name AS user,
    SUM(ci.quantity) AS total_items
FROM cart_items ci
JOIN carts c ON ci.cart_id = c.id
JOIN users u ON c.user_id = u.id
WHERE u.id = 1
GROUP BY u.name;

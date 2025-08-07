-- Step 1: Create the Database
CREATE DATABASE OnlineOrderManagement;

-- Step 2: Use the Database
USE OnlineOrderManagement;

-- Step 3: Create the 'orders' Table
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100),
    total DECIMAL(10, 2),
    order_date DATE,
    status VARCHAR(50),
    address VARCHAR(255)
);

-- Step 4: Insert Sample Data
INSERT INTO orders (customer_name, total, order_date, status, address)
VALUES
    ('Rajesh Kumar', 1200.50, '2025-08-01', 'Shipped', '123, MG Road, Chennai'),
    ('Ravi Shankar', 850.75, '2025-08-02', 'Delivered', '456, Anna Salai, Chennai'),
    ('Priya Rani', 1500.00, '2025-08-03', 'Pending', '789, T Nagar, Chennai'),
    ('Ravi Kumar', 2000.00, '2025-08-04', 'Shipped', '101, Mount Road, Chennai'),
    ('Radhika Sharma', 950.25, '2025-08-05', 'Cancelled', '202, Besant Nagar, Chennai');

-- Step 5: Retrieve Orders Placed in the Last 7 Days
SELECT * FROM orders
WHERE order_date >= CURRENT_DATE - INTERVAL 7 DAY
ORDER BY order_date DESC, total DESC;

-- Step 6: Find Customers with Names Starting with 'R'
SELECT * FROM orders
WHERE customer_name LIKE 'R%';

-- Step 7: Identify Orders with NULL Status
SELECT * FROM orders
WHERE status IS NULL;

-- Step 8: List Distinct Addresses
SELECT DISTINCT address FROM orders;

-- Step 9: Sort Orders by Order Date and Total in Descending Order
SELECT * FROM orders
ORDER BY order_date DESC, total DESC;

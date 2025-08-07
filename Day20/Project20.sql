-- Step 1: Create the Database
CREATE DATABASE RetailSalesTracker;

-- Step 2: Use the Database
USE RetailSalesTracker;

-- Step 3: Create the 'sales' Table
CREATE TABLE sales (
    sale_id INT PRIMARY KEY AUTO_INCREMENT,
    item_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10, 2),
    quantity INT,
    sale_date DATE
);

-- Step 4: Insert Sample Data
INSERT INTO sales (item_name, category, price, quantity, sale_date)
VALUES
    ('ProMax Smartphone', 'Electronics', 599.99, 3, '2025-08-01'),
    ('UltraPro Headphones', 'Electronics', 199.99, 5, '2025-08-02'),
    ('ProClean Vacuum', 'Home Appliances', 299.99, 2, '2025-08-03'),
    ('ProCook Blender', 'Kitchenware', 129.99, 4, '2025-08-04'),
    ('ProFit Treadmill', 'Fitness', 799.99, 1, '2025-08-05');

-- Step 5: Retrieve Items with Price > 500 and Quantity >= 2
SELECT * FROM sales
WHERE price > 500 AND quantity >= 2
ORDER BY sale_date DESC, price DESC;

-- Step 6: Find Items Containing 'Pro' in Their Name
SELECT * FROM sales
WHERE item_name LIKE '%Pro%';

-- Step 7: Check for NULL in Quantity
SELECT * FROM sales
WHERE quantity IS NULL;

-- Step 8: List Distinct Categories
SELECT DISTINCT category FROM sales;

-- Step 9: Sort by Sale Date and Price in Descending Order
SELECT * FROM sales
ORDER BY sale_date DESC, price DESC;

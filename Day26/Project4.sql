-- 1. Create Database and Use
CREATE DATABASE IF NOT EXISTS product_analysis;
USE product_analysis;

-- 2. Create Tables

CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    name VARCHAR(100),
    parent_id INT NULL,
    created_at DATE,
    FOREIGN KEY (parent_id) REFERENCES categories(category_id)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    category_id INT,
    available BOOLEAN,
    created_at DATE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- 3. Insert Sample Data

INSERT INTO categories (category_id, name, parent_id, created_at) VALUES
(1, 'Electronics', NULL, '2023-01-01'),
(2, 'Computers', 1, '2023-01-05'),
(3, 'Laptops', 2, '2023-01-10'),
(4, 'Desktops', 2, '2023-01-12'),
(5, 'Smartphones', 1, '2023-01-15'),
(6, 'Accessories', 1, '2023-01-20'),
(7, 'Chargers', 6, '2023-01-25');

INSERT INTO products (product_id, name, category_id, available, created_at) VALUES
(101, 'Gaming Laptop', 3, TRUE, '2023-02-01'),
(102, 'Office Laptop', 3, TRUE, '2023-02-05'),
(103, 'Desktop PC', 4, FALSE, '2023-02-07'),
(104, 'iPhone', 5, TRUE, '2023-02-10'),
(105, 'Android Phone', 5, TRUE, '2023-02-12'),
(106, 'USB Charger', 7, FALSE, '2023-02-15'),
(107, 'Laptop Charger', 7, TRUE, '2023-02-18');

-- 4. Recursive CTE: Full category tree with hierarchy level

WITH RECURSIVE category_tree AS (
    SELECT
        category_id,
        name,
        parent_id,
        name AS full_path,
        1 AS level
    FROM categories
    WHERE parent_id IS NULL
    
    UNION ALL
    
    SELECT
        c.category_id,
        c.name,
        c.parent_id,
        CONCAT(ct.full_path, ' > ', c.name),
        ct.level + 1
    FROM categories c
    INNER JOIN category_tree ct ON c.parent_id = ct.category_id
)

SELECT * FROM category_tree ORDER BY full_path;

-- 5. Category product count and rank by total products

WITH product_counts AS (
    SELECT
        c.category_id,
        c.name,
        COUNT(p.product_id) AS product_count
    FROM categories c
    LEFT JOIN products p ON c.category_id = p.category_id
    GROUP BY c.category_id, c.name
),
ranked_categories AS (
    SELECT
        category_id,
        name,
        product_count,
        RANK() OVER (ORDER BY product_count DESC) AS rank_by_products
    FROM product_counts
)

SELECT * FROM ranked_categories ORDER BY rank_by_products;

-- 6. Simulating category movement over time using LEAD()/LAG()
-- Assume created_at is category creation date, order categories by this to see movement

WITH category_movement AS (
    SELECT
        category_id,
        name,
        created_at,
        LAG(name) OVER (ORDER BY created_at) AS previous_category,
        LEAD(name) OVER (ORDER BY created_at) AS next_category
    FROM categories
)

SELECT * FROM category_movement ORDER BY created_at;

-- 7. CTE for product availability report by category

WITH product_availability AS (
    SELECT
        c.category_id,
        c.name AS category_name,
        COUNT(p.product_id) AS total_products,
        SUM(CASE WHEN p.available THEN 1 ELSE 0 END) AS available_products,
        SUM(CASE WHEN p.available THEN 0 ELSE 1 END) AS unavailable_products
    FROM categories c
    LEFT JOIN products p ON c.category_id = p.category_id
    GROUP BY c.category_id, c.name
)

SELECT * FROM product_availability ORDER BY category_name;

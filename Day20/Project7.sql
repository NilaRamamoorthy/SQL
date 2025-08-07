-- ### Create database and switch to it
CREATE DATABASE IF NOT EXISTS feedback_db;
USE feedback_db;

-- ### Create feedback table
CREATE TABLE feedback (
  feedback_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_name VARCHAR(100) NOT NULL,
  rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  product VARCHAR(100) NOT NULL,
  submitted_date DATE NOT NULL
);

-- ### Insert sample data
INSERT INTO feedback (customer_name, rating, comment, product, submitted_date) VALUES
('Alice', 5, 'Excellent service and fast delivery', 'Smartphone', '2025-07-10'),
('Bob', 4, 'Product is good but slow to charge', 'Smartphone', '2025-07-20'),
('Carol', 3, 'Average experience', 'Laptop', '2025-07-25'),
('Dave', 5, NULL, 'Smartphone', '2025-08-01'),
('Eve', 4, 'Very responsive and not slow', 'Tablet', '2025-08-02'),
('Frank', 2, 'Too slow performance', 'Smartphone', '2025-06-15'),
('Grace', 5, 'Outstanding!', 'Headphones', '2025-07-15');

-- ### 1. Retrieve feedback for product "Smartphone" with rating ≥ 4
SELECT customer_name, rating, comment
FROM feedback
WHERE product = 'Smartphone'
  AND rating >= 4
ORDER BY rating DESC, submitted_date DESC;

-- ### 2. Find comments that contain the word "slow" (case-insensitive)
SELECT customer_name, rating, comment
FROM feedback
WHERE comment LIKE '%slow%'
ORDER BY rating DESC, submitted_date DESC;

-- ### 3. Feedback submitted within the last 30 days (from today, 2025‑08‑06 assumed)
SELECT customer_name, rating, comment
FROM feedback
WHERE submitted_date BETWEEN DATE_SUB('2025-08-06', INTERVAL 30 DAY) AND '2025-08-06'
ORDER BY rating DESC, submitted_date DESC;

-- ### 4. Identify feedback entries with NULL comment
SELECT customer_name, rating, comment
FROM feedback
WHERE comment IS NULL
ORDER BY rating DESC, submitted_date DESC;

-- ### 5. List all distinct products reviewed
SELECT DISTINCT product
FROM feedback
ORDER BY product ASC;

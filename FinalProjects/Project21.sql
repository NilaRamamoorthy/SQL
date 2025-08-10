-- 1. Create Database
CREATE DATABASE blog_management;
USE blog_management;

-- 2. Create Tables

-- Users Table
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Posts Table
CREATE TABLE posts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    published_date DATE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Comments Table
CREATE TABLE comments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    comment_text TEXT NOT NULL,
    commented_at DATETIME NOT NULL,
    FOREIGN KEY (post_id) REFERENCES posts(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 3. Insert Sample Data

-- Users
INSERT INTO users (name) VALUES
('Alice Johnson'),
('Bob Smith'),
('Charlie Davis'),
('Diana Miller');

-- Posts
INSERT INTO posts (user_id, title, content, published_date) VALUES
(1, 'Getting Started with MySQL', 'This post covers basic MySQL concepts.', '2025-01-10'),
(2, 'Advanced SQL Tricks', 'Learn about CTEs, Window functions, and more.', '2025-01-15'),
(1, 'Database Indexing', 'Indexing tips for performance optimization.', '2025-02-05');

-- Comments
INSERT INTO comments (post_id, user_id, comment_text, commented_at) VALUES
(1, 2, 'Great introduction, very helpful!', '2025-01-11 09:30:00'),
(1, 3, 'Thanks, I learned a lot.', '2025-01-12 14:20:00'),
(2, 1, 'Nice tips, I will use them in my project.', '2025-01-16 10:05:00'),
(3, 4, 'Could you also cover composite indexes?', '2025-02-06 16:45:00');

-- 4. Query: Join Comments with Posts and Users
SELECT 
    p.id AS post_id,
    p.title,
    u.name AS post_author,
    c.comment_text,
    cu.name AS comment_author,
    c.commented_at
FROM posts p
JOIN users u ON p.user_id = u.id
LEFT JOIN comments c ON p.id = c.post_id
LEFT JOIN users cu ON c.user_id = cu.id
ORDER BY p.published_date, c.commented_at;

-- 5. Query: Filter Posts by Specific User
SELECT 
    p.id,
    p.title,
    p.published_date,
    u.name AS author
FROM posts p
JOIN users u ON p.user_id = u.id
WHERE u.name = 'Alice Johnson'
ORDER BY p.published_date DESC;

-- 6. Query: Filter Posts by Date Range
SELECT 
    p.id,
    p.title,
    p.published_date,
    u.name AS author
FROM posts p
JOIN users u ON p.user_id = u.id
WHERE p.published_date BETWEEN '2025-01-01' AND '2025-01-31'
ORDER BY p.published_date;

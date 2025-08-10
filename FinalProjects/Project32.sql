-- 1. Create Database
CREATE DATABASE forum_system;
USE forum_system;

-- 2. Create Tables

-- Users table
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Threads table
CREATE TABLE threads (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    user_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Posts table
CREATE TABLE posts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    thread_id INT NOT NULL,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    parent_post_id INT NULL,
    posted_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (thread_id) REFERENCES threads(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_post_id) REFERENCES posts(id) ON DELETE CASCADE
);

-- 3. Insert Sample Data

-- Users
INSERT INTO users (name) VALUES
('Alice'),
('Bob'),
('Charlie');

-- Threads
INSERT INTO threads (title, user_id) VALUES
('Best programming language?', 1),
('How to learn SQL?', 2);

-- Posts (root posts and replies)
INSERT INTO posts (thread_id, user_id, content, parent_post_id) VALUES
(1, 1, 'I think Python is the best.', NULL),
(1, 2, 'JavaScript is more versatile.', NULL),
(1, 3, 'I prefer C++ for performance.', NULL),
(1, 2, 'Python is easier for beginners.', 1),  -- Reply to Alice
(1, 1, 'JavaScript can be tricky.', 2),        -- Reply to Bob
(2, 2, 'Start with SELECT queries.', NULL),
(2, 3, 'Practice with small projects.', 6);

-- 4. Query: Get all posts in a thread with reply relationships (self join)
SELECT 
    p.id AS post_id,
    p.content AS post_content,
    u.name AS posted_by,
    parent.content AS replied_to_content
FROM posts p
JOIN users u ON p.user_id = u.id
LEFT JOIN posts parent ON p.parent_post_id = parent.id
WHERE p.thread_id = 1
ORDER BY p.posted_at;

-- 5. Query: Count total posts per thread (view aggregation)
SELECT 
    t.title,
    COUNT(p.id) AS total_posts
FROM threads t
LEFT JOIN posts p ON t.id = p.thread_id
GROUP BY t.id
ORDER BY total_posts DESC;

-- 6. Query: Get root posts and their replies in one thread
SELECT 
    root.id AS root_post_id,
    root.content AS root_post,
    reply.id AS reply_post_id,
    reply.content AS reply_post
FROM posts root
LEFT JOIN posts reply ON root.id = reply.parent_post_id
WHERE root.thread_id = 1
AND root.parent_post_id IS NULL
ORDER BY root.posted_at, reply.posted_at;

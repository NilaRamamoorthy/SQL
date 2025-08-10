-- 1. Create Database
CREATE DATABASE notification_system;
USE notification_system;

-- 2. Create Tables

-- Users Table
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Notifications Table
CREATE TABLE notifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    message TEXT NOT NULL,
    status ENUM('unread', 'read') DEFAULT 'unread',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 3. Insert Sample Data

-- Users
INSERT INTO users (name) VALUES
('Alice Johnson'),
('Bob Smith'),
('Charlie Davis');

-- Notifications
INSERT INTO notifications (user_id, message, status, created_at) VALUES
(1, 'Your order has been shipped.', 'unread', '2025-08-01 09:00:00'),
(1, 'Your password was changed successfully.', 'read', '2025-08-02 10:30:00'),
(2, 'New comment on your post.', 'unread', '2025-08-03 14:15:00'),
(2, 'System maintenance scheduled for tonight.', 'unread', '2025-08-04 08:45:00'),
(3, 'Your subscription will expire soon.', 'unread', '2025-08-05 17:20:00');

-- 4. Query: Count unread notifications per user
SELECT 
    u.name AS user_name,
    COUNT(n.id) AS unread_count
FROM users u
LEFT JOIN notifications n ON u.id = n.user_id AND n.status = 'unread'
GROUP BY u.name;

-- 5. Query: Get all unread notifications for a specific user (example: Bob Smith)
SELECT 
    n.id,
    n.message,
    n.created_at
FROM notifications n
JOIN users u ON n.user_id = u.id
WHERE u.name = 'Bob Smith' AND n.status = 'unread'
ORDER BY n.created_at DESC;

-- 6. Query: Mark all notifications as read for a user (example: Alice Johnson)
UPDATE notifications
SET status = 'read'
WHERE user_id = (SELECT id FROM users WHERE name = 'Alice Johnson');

-- 7. Query: Fetch recent notifications (latest 5 for each user)
SELECT *
FROM (
    SELECT 
        n.id,
        u.name AS user_name,
        n.message,
        n.status,
        n.created_at,
        ROW_NUMBER() OVER (PARTITION BY u.id ORDER BY n.created_at DESC) AS rn
    FROM notifications n
    JOIN users u ON n.user_id = u.id
) ranked
WHERE rn <= 5
ORDER BY user_name, created_at DESC;

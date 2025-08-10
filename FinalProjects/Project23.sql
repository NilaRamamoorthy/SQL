-- 1. Create Database
CREATE DATABASE messaging_system;
USE messaging_system;

-- 2. Create Tables

-- Users Table
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Conversations Table
CREATE TABLE conversations (
    id INT PRIMARY KEY AUTO_INCREMENT
    -- Additional fields like topic, created_at can be added if needed
);

-- Messages Table
CREATE TABLE messages (
    id INT PRIMARY KEY AUTO_INCREMENT,
    conversation_id INT NOT NULL,
    sender_id INT NOT NULL,
    message_text TEXT NOT NULL,
    sent_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 3. Insert Sample Data

-- Users
INSERT INTO users (name) VALUES
('Alice'),
('Bob'),
('Charlie');

-- Conversations
INSERT INTO conversations VALUES
(1), -- Conversation between Alice & Bob
(2); -- Conversation between Alice & Charlie

-- Messages
INSERT INTO messages (conversation_id, sender_id, message_text) VALUES
(1, 1, 'Hey Bob, how are you?'),
(1, 2, 'Hi Alice, I’m good! You?'),
(1, 1, 'I’m great, thanks for asking.'),
(2, 1, 'Hey Charlie, are we still meeting tomorrow?'),
(2, 3, 'Yes, see you at 10 AM.');

-- 4. Query: Get the most recent message per conversation
SELECT m1.conversation_id, m1.message_text, m1.sent_at, u.name AS sender_name
FROM messages m1
JOIN users u ON m1.sender_id = u.id
WHERE m1.sent_at = (
    SELECT MAX(m2.sent_at)
    FROM messages m2
    WHERE m2.conversation_id = m1.conversation_id
);

-- 5. Query: Get all messages in a specific conversation (threaded by time)
SELECT m.id, u.name AS sender_name, m.message_text, m.sent_at
FROM messages m
JOIN users u ON m.sender_id = u.id
WHERE m.conversation_id = 1
ORDER BY m.sent_at ASC;

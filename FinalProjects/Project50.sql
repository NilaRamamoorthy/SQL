-- 1. Create Database
CREATE DATABASE event_management;
USE event_management;

-- 2. Create Tables
CREATE TABLE events (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    max_capacity INT NOT NULL CHECK (max_capacity > 0)
);

CREATE TABLE attendees (
    event_id INT NOT NULL,
    user_id INT NOT NULL,
    registered_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (event_id, user_id),
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE
);

-- 3. Insert Sample Data
INSERT INTO events (title, max_capacity) VALUES
('Tech Conference 2025', 3),
('Music Festival', 5),
('Startup Meetup', 2);

INSERT INTO attendees (event_id, user_id) VALUES
(1, 101),
(1, 102),
(1, 103),
(2, 201),
(2, 202),
(3, 301);

-- 4. Query: Event-wise participant count
SELECT 
    e.id,
    e.title,
    COUNT(a.user_id) AS participant_count
FROM events e
LEFT JOIN attendees a ON e.id = a.event_id
GROUP BY e.id, e.title;

-- 5. Query: Capacity alerts (events at or over capacity)
SELECT 
    e.id,
    e.title,
    COUNT(a.user_id) AS participant_count,
    e.max_capacity,
    CASE 
        WHEN COUNT(a.user_id) >= e.max_capacity THEN 'Full'
        ELSE 'Available'
    END AS status
FROM events e
LEFT JOIN attendees a ON e.id = a.event_id
GROUP BY e.id, e.title, e.max_capacity
HAVING participant_count >= e.max_capacity;

-- 6. Query: Events with available slots
SELECT 
    e.id,
    e.title,
    e.max_capacity - COUNT(a.user_id) AS available_slots
FROM events e
LEFT JOIN attendees a ON e.id = a.event_id
GROUP BY e.id, e.title, e.max_capacity
HAVING available_slots > 0;

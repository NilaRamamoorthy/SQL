-- Drop and recreate the database

CREATE DATABASE event_portal;
USE event_portal;

-- Create tables
CREATE TABLE events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    event_name VARCHAR(150) NOT NULL,
    event_date DATE NOT NULL,
    location VARCHAR(255)
);

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE registrations (
    registration_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    event_id INT NOT NULL,
    registration_date DATE DEFAULT CURDATE(),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (event_id) REFERENCES events(event_id),
    UNIQUE(user_id, event_id)  -- user can register only once per event
);

-- Insert sample events
INSERT INTO events (event_name, event_date, location) VALUES
('Tech Conference 2025', '2025-08-15', 'Convention Center'),
('Music Fest 2025', '2025-09-05', 'City Park'),
('Art Expo 2025', '2025-10-10', 'Art Gallery'),
('Startup Meetup', '2025-07-25', 'Innovation Hub'),
('Health & Wellness Fair', '2025-11-01', 'Community Center');

-- Insert sample users
INSERT INTO users (full_name, email) VALUES
('Alice Walker', 'alice.walker@example.com'),
('Bob Martin', 'bob.martin@example.com'),
('Cathy Brown', 'cathy.brown@example.com'),
('David Wilson', 'david.wilson@example.com'),
('Eva Harris', 'eva.harris@example.com');

-- Insert sample registrations
INSERT INTO registrations (user_id, event_id) VALUES
(1, 1),
(1, 3),
(2, 1),
(3, 2),
(4, 4),
(5, 5),
(2, 3),
(3, 4);

-- Query 1: Show number of registrations per event
SELECT 
    e.event_name,
    COUNT(r.registration_id) AS registrations_count
FROM events e
LEFT JOIN registrations r ON e.event_id = r.event_id
GROUP BY e.event_id, e.event_name;

-- Query 2: List upcoming events (events with date today or later)
SELECT 
    event_name,
    event_date,
    location
FROM events
WHERE event_date >= CURDATE()
ORDER BY event_date ASC;

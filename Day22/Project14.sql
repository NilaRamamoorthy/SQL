-- 1. Create Database and Use
CREATE DATABASE IF NOT EXISTS event_tracker;
USE event_tracker;

-- 2. Create Tables

CREATE TABLE events (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    event_date DATE NOT NULL,
    capacity INT NOT NULL,
    is_online BOOLEAN DEFAULT FALSE
);

CREATE TABLE attendees (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255)
);

CREATE TABLE registrations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    event_id INT NOT NULL,
    attendee_id INT NOT NULL,
    registration_date DATE NOT NULL,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
    FOREIGN KEY (attendee_id) REFERENCES attendees(id) ON DELETE CASCADE
);

CREATE TABLE feedback (
    id INT PRIMARY KEY AUTO_INCREMENT,
    event_id INT NOT NULL,
    attendee_id INT NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comments TEXT,
    FOREIGN KEY (event_id) REFERENCES events(id),
    FOREIGN KEY (attendee_id) REFERENCES attendees(id)
);

-- 3. Insert Sample Data

INSERT INTO events (title, event_date, capacity, is_online) VALUES
('Tech Webinar', '2025-09-20', 100, TRUE),
('Music Concert', '2025-10-05', 500, FALSE),
('Startup Workshop', '2025-09-25', 50, FALSE),
('Online Yoga Session', '2025-09-18', 150, TRUE);

INSERT INTO attendees (name, email) VALUES
('Alice', 'alice@example.com'),
('Bob', 'bob@example.com'),
('Charlie', 'charlie@example.com'),
('Diana', 'diana@example.com'),
('Evan', 'evan@example.com');

INSERT INTO registrations (event_id, attendee_id, registration_date) VALUES
(1, 1, '2025-09-10'),
(1, 2, '2025-09-11'),
(2, 3, '2025-09-20'),
(2, 4, '2025-09-21'),
(3, 1, '2025-09-15'),
(3, 5, '2025-09-16'),
(4, 2, '2025-09-12'),
(4, 5, '2025-09-13');

INSERT INTO feedback (event_id, attendee_id, rating, comments) VALUES
(1, 1, 5, 'Excellent webinar!'),
(1, 2, 4, 'Very informative.'),
(2, 3, 5, 'Amazing concert!'),
(3, 1, 3, 'Good workshop.'),
(4, 5, 4, 'Relaxing session.');

-- 4. Query: Subquery in SELECT to calculate feedback rating per event

SELECT 
    e.id,
    e.title,
    e.capacity,
    (SELECT AVG(f.rating) FROM feedback f WHERE f.event_id = e.id) AS avg_feedback_rating
FROM events e;

-- 5. Query: CASE to classify events based on turnout percentage

SELECT
    e.id,
    e.title,
    COUNT(r.attendee_id) AS registrations_count,
    e.capacity,
    ROUND((COUNT(r.attendee_id) / e.capacity) * 100, 2) AS turnout_percentage,
    CASE 
        WHEN (COUNT(r.attendee_id) / e.capacity) >= 0.75 THEN 'High Turnout'
        WHEN (COUNT(r.attendee_id) / e.capacity) >= 0.4 THEN 'Medium Turnout'
        ELSE 'Low Turnout'
    END AS turnout_classification
FROM events e
LEFT JOIN registrations r ON e.id = r.event_id
GROUP BY e.id, e.title, e.capacity;

-- 6. Query: UNION ALL to combine online and offline events

SELECT 
    id, title, event_date, capacity, 'Online' AS event_type
FROM events
WHERE is_online = TRUE

UNION ALL

SELECT 
    id, title, event_date, capacity, 'Offline' AS event_type
FROM events
WHERE is_online = FALSE;

-- 7. Query: Correlated subquery to find top participant per event (attendee with most registrations)

SELECT 
    e.id AS event_id,
    e.title,
    (
        SELECT a.name 
        FROM attendees a
        JOIN registrations r2 ON a.id = r2.attendee_id
        WHERE r2.event_id = e.id
        GROUP BY a.id
        ORDER BY COUNT(r2.id) DESC
        LIMIT 1
    ) AS top_participant
FROM events e;

-- 8. Query: JOIN + GROUP BY to show event-wise engagement (registrations and feedback count)

SELECT 
    e.id,
    e.title,
    COUNT(DISTINCT r.attendee_id) AS total_registrations,
    COUNT(DISTINCT f.id) AS total_feedbacks
FROM events e
LEFT JOIN registrations r ON e.id = r.event_id
LEFT JOIN feedback f ON e.id = f.event_id
GROUP BY e.id, e.title;

-- 9. Query: Date filtering for upcoming events (events in next 30 days)

SELECT 
    id,
    title,
    event_date
FROM events
WHERE event_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY)
ORDER BY event_date;

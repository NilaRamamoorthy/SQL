-- 1. Create Database
CREATE DATABASE streaming_analytics;
USE streaming_analytics;

-- 2. Create Tables

CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    subscription_id INT
);

CREATE TABLE subscriptions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    plan_name VARCHAR(100) NOT NULL
);

CREATE TABLE movies (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    genre VARCHAR(100) NOT NULL
);

CREATE TABLE views (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    movie_id INT NOT NULL,
    watch_time INT NOT NULL, -- in minutes
    viewed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (movie_id) REFERENCES movies(id)
);

-- 3. Insert Sample Data

INSERT INTO subscriptions (plan_name) VALUES
('Basic'),
('Standard'),
('Premium');

INSERT INTO users (name, subscription_id) VALUES
('Alice', 1),
('Bob', 2),
('Charlie', 2),
('Diana', 3),
('Eve', NULL);

INSERT INTO movies (title, genre) VALUES
('The Great Escape', 'Action'),
('Love in Paris', 'Romance'),
('Space Odyssey', 'Sci-Fi'),
('Mystery Manor', 'Mystery'),
('Comedy Nights', 'Comedy');

-- Insert views, some movies have > 500 views simulated with multiple entries
INSERT INTO views (user_id, movie_id, watch_time, viewed_at) VALUES
(1, 1, 120, '2025-07-01 10:00:00'),
(2, 1, 110, '2025-07-01 12:00:00'),
(3, 2, 90, '2025-07-02 15:00:00'),
(1, 3, 150, '2025-07-03 18:00:00'),
(4, 3, 130, '2025-07-04 20:00:00'),
(5, 4, 100, '2025-07-05 08:00:00'),
(1, 1, 115, '2025-07-06 14:00:00'),
(2, 1, 105, '2025-07-07 16:00:00');

-- To simulate >500 views for movie 1, bulk insert
INSERT INTO views (user_id, movie_id, watch_time, viewed_at)
SELECT 1, 1, 120, NOW() FROM 
    (SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) t1,
    (SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) t2,
    (SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) t3
LIMIT 500;

-- 4. Queries

-- a) Total views per movie
SELECT
    m.id,
    m.title,
    COUNT(v.id) AS total_views
FROM movies m
LEFT JOIN views v ON m.id = v.movie_id
GROUP BY m.id, m.title;

-- b) Average watch time per genre
SELECT
    m.genre,
    ROUND(AVG(v.watch_time), 2) AS avg_watch_time_minutes
FROM movies m
JOIN views v ON m.id = v.movie_id
GROUP BY m.genre;

-- c) Movies with more than 500 views (HAVING)
SELECT
    m.id,
    m.title,
    COUNT(v.id) AS total_views
FROM movies m
JOIN views v ON m.id = v.movie_id
GROUP BY m.id, m.title
HAVING total_views > 500;

-- d) INNER JOIN views and movies (all views with movie info)
SELECT
    v.id AS view_id,
    u.name AS user_name,
    m.title AS movie_title,
    v.watch_time,
    v.viewed_at
FROM views v
JOIN movies m ON v.movie_id = m.id
JOIN users u ON v.user_id = u.id;

-- e) LEFT JOIN users and subscriptions
SELECT
    u.id,
    u.name,
    s.plan_name
FROM users u
LEFT JOIN subscriptions s ON u.subscription_id = s.id;

-- f) SELF JOIN on users to find friends with same subscription plan
-- Assuming "friends" = users with same subscription_id, different users
SELECT
    u1.id AS user1_id,
    u1.name AS user1_name,
    u2.id AS user2_id,
    u2.name AS user2_name,
    s.plan_name
FROM users u1
JOIN users u2 ON u1.subscription_id = u2.subscription_id AND u1.id < u2.id
JOIN subscriptions s ON u1.subscription_id = s.id
ORDER BY s.plan_name, u1.name, u2.name;

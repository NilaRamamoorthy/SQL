-- Step 1: Create Database and Use It
CREATE DATABASE MovieStreamingAnalytics;
USE MovieStreamingAnalytics;

-- Step 2: Create normalized tables (3NF)

-- Genres
CREATE TABLE genres (
    genre_id INT PRIMARY KEY AUTO_INCREMENT,
    genre_name VARCHAR(100) NOT NULL UNIQUE
);

-- Movies
CREATE TABLE movies (
    movie_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    genre_id INT NOT NULL,
    release_year YEAR,
    duration_minutes INT,
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id)
);

-- Users
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(255),
    subscription_id INT,
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(subscription_id)
);

-- Subscriptions
CREATE TABLE subscriptions (
    subscription_id INT PRIMARY KEY AUTO_INCREMENT,
    subscription_type VARCHAR(100) NOT NULL,
    price DECIMAL(10,2)
);

-- Watch History (many-to-many user <-> movies with watch date and watch time)
CREATE TABLE watch_history (
    watch_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    movie_id INT NOT NULL,
    watch_date DATE NOT NULL,
    watch_time_minutes INT NOT NULL,  -- how many minutes watched in this session
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
);



-- Insert sample data


-- Genres
INSERT INTO genres (genre_name) VALUES
('Action'), ('Comedy'), ('Drama'), ('Sci-Fi'), ('Horror');

-- Movies
INSERT INTO movies (title, genre_id, release_year, duration_minutes) VALUES
('Action Movie 1', 1, 2020, 120),
('Comedy Movie 1', 2, 2019, 90),
('Drama Movie 1', 3, 2021, 110),
('Sci-Fi Movie 1', 4, 2022, 130),
('Horror Movie 1', 5, 2018, 95),
('Action Movie 2', 1, 2023, 125),
('Comedy Movie 2', 2, 2020, 100),
('Drama Movie 2', 3, 2019, 115);

-- Subscriptions
INSERT INTO subscriptions (subscription_type, price) VALUES
('Basic', 9.99),
('Standard', 14.99),
('Premium', 19.99);

-- Users
INSERT INTO users (username, email, subscription_id) VALUES
('userA', 'userA@example.com', 1),
('userB', 'userB@example.com', 2),
('userC', 'userC@example.com', 3),
('userD', 'userD@example.com', 2),
('userE', 'userE@example.com', 1);

-- Watch History (user_id, movie_id, watch_date, watch_time_minutes)
INSERT INTO watch_history (user_id, movie_id, watch_date, watch_time_minutes) VALUES
(1, 1, '2023-07-01', 120),
(1, 2, '2023-07-02', 90),
(1, 3, '2023-07-03', 110),
(2, 1, '2023-07-01', 60),
(2, 4, '2023-07-04', 130),
(3, 5, '2023-07-05', 95),
(3, 6, '2023-07-06', 125),
(4, 7, '2023-07-07', 100),
(4, 1, '2023-07-07', 120),
(5, 8, '2023-07-03', 115),
(5, 3, '2023-07-02', 110);


-- Step 3: Create indexes for performance
CREATE INDEX idx_watch_user ON watch_history(user_id);
CREATE INDEX idx_watch_movie ON watch_history(movie_id);
CREATE INDEX idx_watch_date ON watch_history(watch_date);

-- Step 4: EXPLAIN example to optimize user watch time query
EXPLAIN
SELECT u.user_id, u.username, SUM(w.watch_time_minutes) AS total_watch_time
FROM users u
JOIN watch_history w ON u.user_id = w.user_id
WHERE w.watch_date BETWEEN '2023-07-01' AND '2023-07-07'
GROUP BY u.user_id, u.username
ORDER BY total_watch_time DESC;

-- Step 5: Subquery to find users watching the most movies in a week
SELECT u.user_id, u.username, COUNT(DISTINCT w.movie_id) AS movies_watched
FROM users u
JOIN watch_history w ON u.user_id = w.user_id
WHERE w.watch_date BETWEEN '2023-07-01' AND '2023-07-07'
GROUP BY u.user_id, u.username
HAVING movies_watched = (
    SELECT MAX(movie_count) FROM (
        SELECT user_id, COUNT(DISTINCT movie_id) AS movie_count
        FROM watch_history
        WHERE watch_date BETWEEN '2023-07-01' AND '2023-07-07'
        GROUP BY user_id
    ) AS sub
);

-- Step 6: Denormalized monthly user engagement report
CREATE TABLE monthly_user_engagement AS
SELECT
    YEAR(w.watch_date) AS year,
    MONTH(w.watch_date) AS month,
    u.user_id,
    u.username,
    COUNT(DISTINCT w.movie_id) AS unique_movies_watched,
    SUM(w.watch_time_minutes) AS total_watch_time
FROM watch_history w
JOIN users u ON w.user_id = u.user_id
GROUP BY YEAR(w.watch_date), MONTH(w.watch_date), u.user_id, u.username;

-- Add index on year/month for reporting speed
CREATE INDEX idx_monthly_engagement_ym ON monthly_user_engagement(year, month);

-- Step 7: Use LIMIT for top 10 most-watched movies (by total watch time)
SELECT m.movie_id, m.title, SUM(w.watch_time_minutes) AS total_watch_time
FROM watch_history w
JOIN movies m ON w.movie_id = m.movie_id
GROUP BY m.movie_id, m.title
ORDER BY total_watch_time DESC
LIMIT 10;

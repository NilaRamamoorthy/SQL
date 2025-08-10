-- 1. Create Database and Use
CREATE DATABASE IF NOT EXISTS music_streaming;
USE music_streaming;

-- 2. Create Tables

CREATE TABLE artists (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE songs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    artist_id INT,
    genre VARCHAR(100),
    FOREIGN KEY (artist_id) REFERENCES artists(id)
);

CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(255) NOT NULL
);

CREATE TABLE play_history (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    song_id INT,
    played_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (song_id) REFERENCES songs(id)
);

-- 3. Insert Sample Data

INSERT INTO artists (name) VALUES
('The Beatles'), ('Taylor Swift'), ('Adele');

INSERT INTO songs (title, artist_id, genre) VALUES
('Love Me Do', 1, 'Rock'),
('Blank Space', 2, 'Pop'),
('Love Story', 2, 'Pop'),
('Hello', 3, 'Soul'),
('Someone Like You', 3, 'Soul'),
('Crazy in Love', NULL, 'Pop');

INSERT INTO users (username) VALUES
('alice'), ('bob'), ('charlie'), ('diana');

INSERT INTO play_history (user_id, song_id, played_at) VALUES
(1, 1, NOW()),
(1, 3, NOW()),
(1, 3, NOW()),
(1, 2, NOW()),
(2, 2, NOW()),
(2, 4, NOW()),
(3, 1, NOW()),
(3, 1, NOW()),
(3, 5, NOW()),
(3, 3, NOW()),
(4, 3, NOW()),
(4, 3, NOW()),
(4, 3, NOW()),
(4, 3, NOW()),
(4, 3, NOW()),
(4, 3, NOW()),
(4, 3, NOW()),
(4, 3, NOW()),
(4, 3, NOW()),
(4, 3, NOW());

-- 4. Query: JOIN to show who listened to which song

SELECT u.username, s.title, a.name AS artist, ph.played_at
FROM play_history ph
JOIN users u ON ph.user_id = u.id
JOIN songs s ON ph.song_id = s.id
LEFT JOIN artists a ON s.artist_id = a.id
ORDER BY ph.played_at DESC;

-- 5. Query: GROUP BY + COUNT to get top songs by play count

SELECT s.title, a.name AS artist, COUNT(*) AS play_count
FROM play_history ph
JOIN songs s ON ph.song_id = s.id
LEFT JOIN artists a ON s.artist_id = a.id
GROUP BY s.id, s.title, a.name
ORDER BY play_count DESC
LIMIT 10;

-- 6. Query: ORDER BY for most played artists

SELECT a.name AS artist, COUNT(*) AS total_plays
FROM play_history ph
JOIN songs s ON ph.song_id = s.id
JOIN artists a ON s.artist_id = a.id
GROUP BY a.id, a.name
ORDER BY total_plays DESC;

-- 7. Query: Subquery to get users who listened to the same artist > 10 times

SELECT user_id, artist_id, total_plays FROM (
    SELECT ph.user_id, s.artist_id, COUNT(*) AS total_plays
    FROM play_history ph
    JOIN songs s ON ph.song_id = s.id
    WHERE s.artist_id IS NOT NULL
    GROUP BY ph.user_id, s.artist_id
) AS user_artist_plays
WHERE total_plays > 10;

-- 8. Query: Use CASE to label users as “Light”, “Moderate”, “Heavy” listeners based on total plays

SELECT
    u.username,
    total_plays,
    CASE
        WHEN total_plays >= 50 THEN 'Heavy'
        WHEN total_plays >= 20 THEN 'Moderate'
        ELSE 'Light'
    END AS listener_category
FROM (
    SELECT user_id, COUNT(*) AS total_plays
    FROM play_history
    GROUP BY user_id
) AS user_plays
JOIN users u ON user_plays.user_id = u.id
ORDER BY total_plays DESC;

-- 9. Query: Filter songs by LIKE '%Love%' for romantic songs

SELECT s.title, a.name AS artist, s.genre
FROM songs s
LEFT JOIN artists a ON s.artist_id = a.id
WHERE s.title LIKE '%Love%'
ORDER BY s.title;

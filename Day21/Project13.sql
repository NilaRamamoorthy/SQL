-- 1. Create Database
CREATE DATABASE music_streaming;
USE music_streaming;

-- 2. Create Tables

CREATE TABLE artists (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE songs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    artist_id INT NOT NULL,
    genre VARCHAR(100) NOT NULL,
    duration_sec INT NOT NULL,  -- duration of song in seconds
    FOREIGN KEY (artist_id) REFERENCES artists(id)
);

CREATE TABLE listeners (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE plays (
    id INT PRIMARY KEY AUTO_INCREMENT,
    song_id INT NOT NULL,
    listener_id INT NOT NULL,
    play_duration_sec INT NOT NULL,  -- duration listened in seconds
    play_time DATETIME NOT NULL,
    FOREIGN KEY (song_id) REFERENCES songs(id),
    FOREIGN KEY (listener_id) REFERENCES listeners(id)
);

-- 3. Insert Sample Data

INSERT INTO artists (name) VALUES
('Taylor Swift'),
('Ed Sheeran'),
('Adele'),
('Drake');

INSERT INTO songs (title, artist_id, genre, duration_sec) VALUES
('Love Story', 1, 'Pop', 230),
('Shape of You', 2, 'Pop', 240),
('Hello', 3, 'Soul', 300),
('God''s Plan', 4, 'Hip-Hop', 210),
('Blank Space', 1, 'Pop', 220),
('Photograph', 2, 'Pop', 260);

INSERT INTO listeners (name) VALUES
('Alice'),
('Bob'),
('Charlie'),
('Diana');

INSERT INTO plays (song_id, listener_id, play_duration_sec, play_time) VALUES
(1, 1, 230, '2025-08-01 10:00:00'),
(2, 1, 240, '2025-08-01 10:05:00'),
(3, 2, 290, '2025-08-01 11:00:00'),
(1, 3, 200, '2025-08-01 12:00:00'),
(4, 4, 210, '2025-08-01 13:00:00'),
(2, 2, 240, '2025-08-01 14:00:00'),
(5, 1, 220, '2025-08-01 15:00:00'),
(6, 3, 260, '2025-08-01 16:00:00'),
(2, 4, 240, '2025-08-01 17:00:00'),
(1, 2, 230, '2025-08-01 18:00:00'),
(5, 2, 220, '2025-08-01 19:00:00'),
(1, 4, 230, '2025-08-01 20:00:00'),
(2, 3, 240, '2025-08-01 21:00:00'),
(6, 4, 260, '2025-08-01 22:00:00');

-- 4. Queries

-- a) Total plays per song
SELECT
    s.id,
    s.title,
    COUNT(p.id) AS total_plays
FROM songs s
LEFT JOIN plays p ON s.id = p.song_id
GROUP BY s.id, s.title
ORDER BY total_plays DESC;

-- b) Average play duration per genre
SELECT
    s.genre,
    ROUND(AVG(p.play_duration_sec), 2) AS avg_play_duration_sec
FROM songs s
JOIN plays p ON s.id = p.song_id
GROUP BY s.genre;

-- c) Artists with songs played > 1,000 times (HAVING)
SELECT
    a.id,
    a.name,
    COUNT(p.id) AS total_plays
FROM artists a
JOIN songs s ON a.id = s.artist_id
JOIN plays p ON s.id = p.song_id
GROUP BY a.id, a.name
HAVING total_plays > 1000;

-- d) INNER JOIN: songs ↔ plays (show plays with song info)
SELECT
    p.id,
    s.title,
    p.listener_id,
    p.play_duration_sec,
    p.play_time
FROM plays p
JOIN songs s ON p.song_id = s.id;

-- e) RIGHT JOIN: listeners ↔ plays (all plays + listeners even with no plays)
SELECT
    l.id AS listener_id,
    l.name,
    p.id AS play_id,
    p.song_id,
    p.play_time
FROM plays p
RIGHT JOIN listeners l ON p.listener_id = l.id
ORDER BY l.id;

-- f) SELF JOIN to list listeners who play similar genres
-- Find pairs of listeners who played songs in the same genre

SELECT DISTINCT
    l1.id AS listener1_id,
    l1.name AS listener1_name,
    l2.id AS listener2_id,
    l2.name AS listener2_name,
    s.genre
FROM listeners l1
JOIN plays p1 ON l1.id = p1.listener_id
JOIN songs s ON p1.song_id = s.id
JOIN plays p2 ON s.genre = (SELECT genre FROM songs WHERE id = p2.song_id)
JOIN listeners l2 ON p2.listener_id = l2.id
WHERE l1.id < l2.id  -- avoid duplicate pairs and self-pairing
ORDER BY s.genre, l1.id, l2.id;

-- 1. Create Database
CREATE DATABASE movie_database;
USE movie_database;

-- 2. Create Tables

-- Genres Table
CREATE TABLE genres (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE
);

-- Movies Table
CREATE TABLE movies (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    release_year INT NOT NULL,
    genre_id INT NOT NULL,
    FOREIGN KEY (genre_id) REFERENCES genres(id) ON DELETE CASCADE
);

-- Ratings Table
CREATE TABLE ratings (
    user_id INT NOT NULL,
    movie_id INT NOT NULL,
    score DECIMAL(3,1) CHECK (score BETWEEN 0 AND 10),
    PRIMARY KEY (user_id, movie_id),
    FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE
);

-- 3. Insert Sample Data

-- Genres
INSERT INTO genres (name) VALUES
('Action'),
('Drama'),
('Comedy'),
('Sci-Fi');

-- Movies
INSERT INTO movies (title, release_year, genre_id) VALUES
('Inception', 2010, 4),
('The Dark Knight', 2008, 1),
('Forrest Gump', 1994, 2),
('The Hangover', 2009, 3);

-- Ratings
INSERT INTO ratings (user_id, movie_id, score) VALUES
(1, 1, 9.0),
(2, 1, 8.5),
(3, 1, 9.5),
(1, 2, 9.8),
(2, 2, 9.5),
(3, 3, 8.9),
(4, 3, 9.1),
(1, 4, 7.5),
(2, 4, 8.0);

-- 4. Query: Average rating per movie
SELECT 
    m.title,
    ROUND(AVG(r.score), 2) AS avg_rating
FROM movies m
LEFT JOIN ratings r ON m.id = r.movie_id
GROUP BY m.id
ORDER BY avg_rating DESC;

-- 5. Query: Movies with their genres and average ratings
SELECT 
    m.title,
    g.name AS genre,
    ROUND(AVG(r.score), 2) AS avg_rating
FROM movies m
JOIN genres g ON m.genre_id = g.id
LEFT JOIN ratings r ON m.id = r.movie_id
GROUP BY m.id, g.name
ORDER BY genre, avg_rating DESC;

-- 6. Query: Top 3 highest-rated movies overall
SELECT 
    m.title,
    ROUND(AVG(r.score), 2) AS avg_rating
FROM movies m
JOIN ratings r ON m.id = r.movie_id
GROUP BY m.id
ORDER BY avg_rating DESC
LIMIT 3;

-- 7. Query: All movies in a given genre (Example: Action)
SELECT 
    m.title,
    m.release_year,
    g.name AS genre
FROM movies m
JOIN genres g ON m.genre_id = g.id
WHERE g.name = 'Action'
ORDER BY m.release_year DESC;

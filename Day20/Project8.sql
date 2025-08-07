--  Create database and switch to it
CREATE DATABASE IF NOT EXISTS movie_rental_db;
USE movie_rental_db;

--  Create the movies table
CREATE TABLE movies (
  movie_id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  genre VARCHAR(50),
  price DECIMAL(8,2),
  rating DECIMAL(3,2),
  available BOOLEAN
);

-- Insert sample data
INSERT INTO movies (title, genre, price, rating, available) VALUES
('Star Wars: A New Hope',          'Action',     499.00, 4.8, TRUE),
('The Star Trek Journey',           'Action',     349.00, 4.2, TRUE),
('Slow and Steady',                'Thriller',   299.00, 3.9, TRUE),
('Fast & Furious',                 'Action',     599.00, 5.0, FALSE),
('Star Speed',                     'Action',     450.00, 4.5, TRUE),
('Thrill Night',                   'Thriller',   799.00, 4.7, TRUE),
('Unknown Galaxy',                 'Sci-Fi',     299.00, NULL, TRUE),
('Silent Night',                   'Thriller',   199.00, NULL, FALSE);

-- 1. List all available Action or Thriller movies (showing title, genre, rating)
SELEcT title, genre, rating
FROM movies
WHERE available = TRUE
  AND genre IN ('Action', 'Thriller')
ORDER BY rating DESC, price ASC;

-- 2. Find movies whose title contains “Star” using LIKE
SELECT title, genre, rating
FROM movies
WHERE title LIKE '%Star%'
ORDER BY rating DESC, price ASC;

-- 3. Identify movies with NULL ratings
SELECT title, genre, rating
FROM movies
WHERE rating IS NULL
ORDER BY price ASC, title ASC;

-- 4. List all distinct genres
SELECT DISTINCT genre
FROM movies
ORDER BY genre ASC;

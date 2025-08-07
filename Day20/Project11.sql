-- 1. Create database and switch to it
CREATE DATABASE IF NOT EXISTS music_catalog;
USE music_catalog;

-- 2. Create the albums table
CREATE TABLE albums (
  album_id INT AUTO_INCREMENT PRIMARY KEY,
  artist VARCHAR(255),
  genre VARCHAR(100),
  title VARCHAR(255),
  release_year INT,
  price DECIMAL(10,2)
);

-- 3. Insert sample data
INSERT INTO albums (artist, genre, title, release_year, price) VALUES
('Brad Mehldau', 'Classical', 'After Bach', 2017, 15.99),
('Brad Mehldau', 'Jazz', 'Variations on a Melancholy Theme', 2021, 18.50),
('Samara Joy', 'Jazz', 'Portrait', 2024, NULL),
('Bill Charlap', 'Jazz', 'Hamstrings & Hurricanes', 2024, 22.00),
('Anthony de Mare', 'Classical', 'Liaisons: Re-Imagining Sondheim', 2015, 20.00),
('Unknown Artist', 'Rock', 'Love in the Dark', 2018, 12.00),
('Pop Singer', 'Pop', 'Love & Light', 2019, NULL);

-- 4. Query: albums in genre 'Jazz' or 'Classical' released after 2015
SELECT title, artist, price
FROM albums
WHERE genre IN ('Jazz', 'Classical')
  AND release_year > 2015
ORDER BY release_year DESC, title ASC;

-- 5. Query: list all distinct artists
SELECT DISTINCT artist
FROM albums
ORDER BY artist;

-- 6. Query: album titles containing "Love"
SELECT title, artist, price
FROM albums
WHERE title LIKE '%Love%'
ORDER BY release_year DESC, title ASC;

-- 7. Query: albums with NULL price
SELECT title, artist, price
FROM albums
WHERE price IS NULL
ORDER BY release_year DESC, title ASC;

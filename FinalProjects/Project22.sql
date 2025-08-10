-- 1. Create Database
CREATE DATABASE voting_system;
USE voting_system;

-- 2. Create Tables

-- Polls Table
CREATE TABLE polls (
    id INT PRIMARY KEY AUTO_INCREMENT,
    question VARCHAR(255) NOT NULL
);

-- Options Table
CREATE TABLE options (
    id INT PRIMARY KEY AUTO_INCREMENT,
    poll_id INT NOT NULL,
    option_text VARCHAR(255) NOT NULL,
    FOREIGN KEY (poll_id) REFERENCES polls(id) ON DELETE CASCADE
);

-- Votes Table
CREATE TABLE votes (
    user_id INT NOT NULL,
    option_id INT NOT NULL,
    voted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, option_id), -- Prevents duplicate votes for the same option
    FOREIGN KEY (option_id) REFERENCES options(id) ON DELETE CASCADE
);

-- 3. Insert Sample Data

-- Polls
INSERT INTO polls (question) VALUES
('What is your favorite programming language?'),
('Which database do you prefer?');

-- Options for Poll 1
INSERT INTO options (poll_id, option_text) VALUES
(1, 'Python'),
(1, 'Java'),
(1, 'C++'),
(1, 'JavaScript');

-- Options for Poll 2
INSERT INTO options (poll_id, option_text) VALUES
(2, 'MySQL'),
(2, 'PostgreSQL'),
(2, 'SQLite'),
(2, 'MongoDB');

-- Votes
INSERT INTO votes (user_id, option_id) VALUES
(1, 1),
(2, 1),
(3, 2),
(4, 4),
(1, 6),
(2, 5),
(3, 8);

-- 4. Query: Count Votes by Option for a Given Poll
SELECT 
    o.option_text,
    COUNT(v.user_id) AS vote_count
FROM options o
LEFT JOIN votes v ON o.id = v.option_id
WHERE o.poll_id = 1
GROUP BY o.id, o.option_text
ORDER BY vote_count DESC;

-- 5. Query: Prevent Duplicate Vote for the Same Poll
-- (This logic ensures a user can vote only once per poll)
ALTER TABLE votes
ADD CONSTRAINT unique_vote_per_poll UNIQUE (user_id, option_id);

-- Alternatively, use a BEFORE INSERT trigger to check across poll_id:
-- (Optional advanced approach)
DELIMITER //
CREATE TRIGGER prevent_multiple_votes
BEFORE INSERT ON votes
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM votes v
        JOIN options o ON v.option_id = o.id
        WHERE v.user_id = NEW.user_id
        AND o.poll_id = (SELECT poll_id FROM options WHERE id = NEW.option_id)
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User has already voted in this poll';
    END IF;
END;
//
DELIMITER ;

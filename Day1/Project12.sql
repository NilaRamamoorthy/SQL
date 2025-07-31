-- Drop and create database
DROP DATABASE IF EXISTS voting_db;
CREATE DATABASE voting_db;
USE voting_db;

-- Tables
CREATE TABLE voters (
    voter_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE elections (
    election_id INT AUTO_INCREMENT PRIMARY KEY,
    election_name VARCHAR(100) NOT NULL,
    election_date DATE NOT NULL
);

CREATE TABLE candidates (
    candidate_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    election_id INT NOT NULL,
    FOREIGN KEY (election_id) REFERENCES elections(election_id)
);

CREATE TABLE votes (
    vote_id INT AUTO_INCREMENT PRIMARY KEY,
    voter_id INT NOT NULL,
    candidate_id INT NOT NULL,
    election_id INT NOT NULL,
    vote_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (voter_id, election_id),
    FOREIGN KEY (voter_id) REFERENCES voters(voter_id),
    FOREIGN KEY (candidate_id) REFERENCES candidates(candidate_id),
    FOREIGN KEY (election_id) REFERENCES elections(election_id)
);

-- Insert sample elections
INSERT INTO elections (election_name, election_date) VALUES
('City Mayor Election', '2025-10-01'),
('School Board Election', '2025-11-15'),
('Local Council Election', '2025-12-05');

-- Insert sample voters
INSERT INTO voters (full_name, email) VALUES
('Alice Johnson', 'alice@example.com'),
('Bob Smith', 'bob@example.com'),
('Carol Lee', 'carol@example.com'),
('David Kim', 'david@example.com'),
('Eva Wong', 'eva@example.com');

-- Insert candidates for each election
INSERT INTO candidates (full_name, election_id) VALUES
('John Doe', 1),
('Jane Roe', 1),
('Mark Twain', 2),
('Mary Shelley', 2),
('Peter Parker', 3),
('Mary Jane', 3);

-- Insert votes (each voter votes once per election)
INSERT INTO votes (voter_id, candidate_id, election_id) VALUES
(1, 1, 1),
(2, 2, 1),
(3, 1, 1),
(4, 3, 2),
(5, 4, 2),
(1, 5, 3),
(2, 6, 3);

-- Query 1: Count votes per candidate
SELECT c.full_name AS candidate, e.election_name, COUNT(v.vote_id) AS votes
FROM candidates c
LEFT JOIN votes v ON c.candidate_id = v.candidate_id
JOIN elections e ON c.election_id = e.election_id
GROUP BY c.candidate_id, e.election_name;

-- Query 2: Find election winners (highest votes per election)
SELECT
    e.election_name,
    c.full_name AS winner,
    COUNT(v.vote_id) AS total_votes
FROM elections e
JOIN candidates c ON e.election_id = c.election_id
LEFT JOIN votes v ON c.candidate_id = v.candidate_id
GROUP BY e.election_id, c.candidate_id
HAVING total_votes = (
    SELECT MAX(vote_count) FROM (
        SELECT COUNT(v2.vote_id) AS vote_count
        FROM candidates c2
        LEFT JOIN votes v2 ON c2.candidate_id = v2.candidate_id
        WHERE c2.election_id = e.election_id
        GROUP BY c2.candidate_id
    ) AS sub
);

-- Query 3: Update vote record (change vote from one candidate to another)
-- Example: Change voter 1's vote in election 1 from candidate 1 to candidate 2
UPDATE votes
SET candidate_id = 2
WHERE voter_id = 1 AND election_id = 1;

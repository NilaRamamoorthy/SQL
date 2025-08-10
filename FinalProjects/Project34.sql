-- 1. Create Database
CREATE DATABASE sports_tournament;
USE sports_tournament;

-- 2. Create Tables

-- Teams table
CREATE TABLE teams (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Matches table
CREATE TABLE matches (
    id INT PRIMARY KEY AUTO_INCREMENT,
    team1_id INT NOT NULL,
    team2_id INT NOT NULL,
    match_date DATE NOT NULL,
    FOREIGN KEY (team1_id) REFERENCES teams(id),
    FOREIGN KEY (team2_id) REFERENCES teams(id)
);

-- Scores table
CREATE TABLE scores (
    match_id INT NOT NULL,
    team_id INT NOT NULL,
    score INT NOT NULL,
    PRIMARY KEY (match_id, team_id),
    FOREIGN KEY (match_id) REFERENCES matches(id) ON DELETE CASCADE,
    FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE
);

-- 3. Insert Sample Data

-- Teams
INSERT INTO teams (name) VALUES
('Lions'),
('Tigers'),
('Bears'),
('Eagles');

-- Matches
INSERT INTO matches (team1_id, team2_id, match_date) VALUES
(1, 2, '2025-08-01'),
(3, 4, '2025-08-02'),
(1, 3, '2025-08-05'),
(2, 4, '2025-08-06');

-- Scores
INSERT INTO scores (match_id, team_id, score) VALUES
-- Match 1: Lions vs Tigers
(1, 1, 3),
(1, 2, 1),
-- Match 2: Bears vs Eagles
(2, 3, 0),
(2, 4, 2),
-- Match 3: Lions vs Bears
(3, 1, 1),
(3, 3, 1),
-- Match 4: Tigers vs Eagles
(4, 2, 2),
(4, 4, 4);

-- 4. Query: Win/Loss Statistics per Team
SELECT 
    t.name,
    SUM(CASE WHEN s.score > opp.score THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN s.score < opp.score THEN 1 ELSE 0 END) AS losses,
    SUM(CASE WHEN s.score = opp.score THEN 1 ELSE 0 END) AS draws
FROM teams t
LEFT JOIN scores s ON t.id = s.team_id
LEFT JOIN scores opp ON s.match_id = opp.match_id AND s.team_id <> opp.team_id
GROUP BY t.id
ORDER BY wins DESC, draws DESC;

-- 5. Query: Leaderboard Ranking (3 pts for win, 1 pt for draw)
SELECT 
    t.name,
    SUM(CASE WHEN s.score > opp.score THEN 3 
             WHEN s.score = opp.score THEN 1 
             ELSE 0 END) AS points
FROM teams t
LEFT JOIN scores s ON t.id = s.team_id
LEFT JOIN scores opp ON s.match_id = opp.match_id AND s.team_id <> opp.team_id
GROUP BY t.id
ORDER BY points DESC, t.name;

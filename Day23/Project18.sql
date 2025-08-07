
CREATE DATABASE IF NOT EXISTS VotingDB;
USE VotingDB;

-- Step 1: Create tables

CREATE TABLE voters (
    voter_id INT PRIMARY KEY AUTO_INCREMENT,
    unique_id VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    birth_date DATE NOT NULL,
    age INT GENERATED ALWAYS AS (TIMESTAMPDIFF(YEAR, birth_date, CURDATE())) STORED,
    CHECK (age >= 18)
);

CREATE TABLE elections (
    election_id INT PRIMARY KEY AUTO_INCREMENT,
    election_name VARCHAR(100) NOT NULL,
    election_date DATE NOT NULL
);

CREATE TABLE candidates (
    candidate_id INT PRIMARY KEY AUTO_INCREMENT,
    election_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    party VARCHAR(100),
    FOREIGN KEY (election_id) REFERENCES elections(election_id) ON DELETE CASCADE
);

CREATE TABLE votes (
    vote_id INT PRIMARY KEY AUTO_INCREMENT,
    voter_id INT NOT NULL,
    election_id INT NOT NULL,
    candidate_id INT NOT NULL,
    vote_status ENUM('Pending', 'Submitted', 'Cancelled') DEFAULT 'Pending',
    vote_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (voter_id) REFERENCES voters(voter_id) ON DELETE CASCADE,
    FOREIGN KEY (election_id) REFERENCES elections(election_id) ON DELETE CASCADE,
    FOREIGN KEY (candidate_id) REFERENCES candidates(candidate_id) ON DELETE CASCADE,
    UNIQUE KEY unique_vote (voter_id, election_id)  -- only one vote per election per voter by default
);

-- Step 2: Modify constraints to allow re-voting in test mode
-- This is done by temporarily dropping UNIQUE constraint on votes (voter_id, election_id)
-- and re-adding it after test mode.

-- Example commands to drop and recreate unique constraint:

-- DROP UNIQUE KEY unique_vote;
ALTER TABLE votes DROP INDEX unique_vote;

-- To allow re-voting (test mode), keep the unique constraint dropped.

-- To disallow re-voting again, recreate the unique constraint:
-- ALTER TABLE votes ADD UNIQUE KEY unique_vote (voter_id, election_id);

-- Step 3: Transaction procedure for casting vote + log + confirmation

DELIMITER //
CREATE PROCEDURE cast_vote(
    IN p_voter_id INT,
    IN p_election_id INT,
    IN p_candidate_id INT
)
BEGIN
    DECLARE exit handler for SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vote casting failed. Transaction rolled back.';
    END;

    START TRANSACTION;

    -- Insert vote (or update existing if allowing re-voting)
    IF EXISTS (
        SELECT 1 FROM votes WHERE voter_id = p_voter_id AND election_id = p_election_id
    ) THEN
        -- Update vote if re-voting allowed (no unique constraint)
        UPDATE votes
        SET candidate_id = p_candidate_id, vote_status = 'Submitted', vote_time = NOW()
        WHERE voter_id = p_voter_id AND election_id = p_election_id;
    ELSE
        -- Insert new vote
        INSERT INTO votes (voter_id, election_id, candidate_id, vote_status)
        VALUES (p_voter_id, p_election_id, p_candidate_id, 'Submitted');
    END IF;

    -- Insert log into a hypothetical audit log table (optional)
    -- For demo, create a simple log table:

    INSERT INTO vote_audit_log(voter_id, election_id, candidate_id, action_time, action)
    VALUES (p_voter_id, p_election_id, p_candidate_id, NOW(), 'Vote Cast');

    COMMIT;
END //
DELIMITER ;

-- Step 4: Create vote_audit_log table for logging actions

CREATE TABLE vote_audit_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    voter_id INT NOT NULL,
    election_id INT NOT NULL,
    candidate_id INT NOT NULL,
    action_time DATETIME NOT NULL,
    action VARCHAR(50) NOT NULL,
    FOREIGN KEY (voter_id) REFERENCES voters(voter_id),
    FOREIGN KEY (election_id) REFERENCES elections(election_id),
    FOREIGN KEY (candidate_id) REFERENCES candidates(candidate_id)
);

-- Step 5: Sample data insertion

INSERT INTO voters (unique_id, name, birth_date) VALUES
('VOTER001', 'Alice Johnson', '1990-06-15'),
('VOTER002', 'Bob Smith', '1985-12-02'),
('VOTER003', 'Charlie Brown', '2005-09-30'); -- This will fail CHECK age >= 18 if tested today

INSERT INTO elections (election_name, election_date) VALUES
('Presidential Election 2025', '2025-11-05');

INSERT INTO candidates (election_id, name, party) VALUES
(1, 'John Doe', 'Party A'),
(1, 'Jane Roe', 'Party B');

-- Step 6: Sample usage of cast_vote procedure

CALL cast_vote(1, 1, 1); -- Alice votes for John Doe
CALL cast_vote(2, 1, 2); -- Bob votes for Jane Roe

-- To allow re-voting (test mode), drop unique index first
ALTER TABLE votes DROP INDEX unique_vote;

-- Then cast vote again (updates previous vote)
CALL cast_vote(1, 1, 2); -- Alice changes vote to Jane Roe

-- Step 7: Delete invalid votes cascade example (e.g., delete a voter)

DELETE FROM voters WHERE voter_id = 3; -- If any votes exist, they get deleted automatically

-- Step 8: Verify votes and logs

SELECT * FROM votes;
SELECT * FROM vote_audit_log;


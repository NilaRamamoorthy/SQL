
CREATE DATABASE IF NOT EXISTS EventManagementDB;
USE EventManagementDB;

-- Step 1: Create tables

CREATE TABLE events (
    event_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(150) NOT NULL,
    event_date DATE NOT NULL,
    age_restriction BOOLEAN NOT NULL DEFAULT FALSE,
    CHECK (event_date >= CURDATE()),
    UNIQUE KEY unique_event_title (title)
);

CREATE TABLE attendees (
    attendee_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    age INT NOT NULL CHECK (age >= 0)
);

CREATE TABLE tickets (
    ticket_id INT PRIMARY KEY AUTO_INCREMENT,
    event_id INT NOT NULL,
    attendee_id INT NOT NULL,
    ticket_type ENUM('Regular', 'VIP', 'EarlyBird') NOT NULL DEFAULT 'Regular',
    purchase_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE,
    FOREIGN KEY (attendee_id) REFERENCES attendees(attendee_id) ON DELETE CASCADE
);

-- Step 2: Insert sample data

INSERT INTO events (title, event_date, age_restriction) VALUES
('Summer Music Fest', DATE_ADD(CURDATE(), INTERVAL 10 DAY), FALSE),
('Exclusive Wine Tasting', DATE_ADD(CURDATE(), INTERVAL 15 DAY), TRUE),
('Tech Conference 2025', DATE_ADD(CURDATE(), INTERVAL 20 DAY), FALSE);

INSERT INTO attendees (name, age) VALUES
('Alice Johnson', 25),
('Bob Smith', 17),
('Charlie Lee', 30);

-- Step 3: Update ticket type or event date examples

-- Change ticket type
UPDATE tickets SET ticket_type = 'VIP' WHERE ticket_id = 1;

-- Change event date
UPDATE events SET event_date = DATE_ADD(event_date, INTERVAL 1 DAY) WHERE event_id = 1;

-- Step 4: Delete expired events (past events) and dependent tickets
DELETE FROM events WHERE event_date < CURDATE();

-- Step 5: Modify UNIQUE constraint on event title

-- Drop the existing unique key
ALTER TABLE events DROP INDEX unique_event_title;

-- Recreate with a new condition (for example: unique per year)
ALTER TABLE events ADD UNIQUE KEY unique_event_title_year (title, YEAR(event_date));

-- Step 6: Transaction for bulk registrations with duplicate rollback

DELIMITER //
CREATE PROCEDURE bulk_register_attendees(
    IN p_event_id INT,
    IN p_names TEXT,   -- Comma-separated attendee names
    IN p_ages TEXT     -- Comma-separated ages matching names
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE name_val VARCHAR(100);
    DECLARE age_val INT;
    DECLARE i INT DEFAULT 1;
    DECLARE name_count INT;
    DECLARE duplicate_found BOOLEAN DEFAULT FALSE;

    -- Temporary variables to hold split values
    DECLARE cur_name VARCHAR(100);
    DECLARE cur_age INT;

    -- Split names and ages by comma - MySQL does not support arrays natively,
    -- so we'll simulate with a loop and SUBSTRING_INDEX.
    SET name_count = (LENGTH(p_names) - LENGTH(REPLACE(p_names, ',', ''))) + 1;

    START TRANSACTION;

    WHILE i <= name_count DO
        SET name_val = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p_names, ',', i), ',', -1));
        SET age_val = CAST(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p_ages, ',', i), ',', -1)) AS UNSIGNED);

        -- Insert attendee
        INSERT INTO attendees (name, age) VALUES (name_val, age_val);

        -- Check age restriction if event requires 18+
        IF (SELECT age_restriction FROM events WHERE event_id = p_event_id) = TRUE THEN
            IF age_val < 18 THEN
                SET duplicate_found = TRUE;
               
            END IF;
    

        -- Insert ticket, check for duplicates (same attendee and event)
        IF EXISTS (
            SELECT 1 FROM tickets t
            JOIN attendees a ON t.attendee_id = a.attendee_id
            WHERE t.event_id = p_event_id AND a.name = name_val
        ) THEN
            SET duplicate_found = TRUE;
            LEAVE;
        ELSE
            -- Get last inserted attendee id
            INSERT INTO tickets (event_id, attendee_id) VALUES (p_event_id, LAST_INSERT_ID());
        END IF;

        SET i = i + 1;
    END WHILE;

    IF duplicate_found THEN
        ROLLBACK;
    ELSE
        COMMIT;
    END IF;
END //
DELIMITER ;

-- Step 7: Sample use of bulk_register_attendees procedure

CALL bulk_register_attendees(
    1, 
    'David Green,Emily White,Frank Black', 
    '22,19,20'
);

-- Check inserted tickets and attendees
SELECT * FROM attendees;
SELECT * FROM tickets;
SELECT * FROM events;


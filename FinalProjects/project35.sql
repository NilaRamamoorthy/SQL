-- 1. Create Database
CREATE DATABASE survey_system;
USE survey_system;

-- 2. Create Tables

-- Surveys table
CREATE TABLE surveys (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL
);

-- Questions table
CREATE TABLE questions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    survey_id INT NOT NULL,
    question_text VARCHAR(500) NOT NULL,
    FOREIGN KEY (survey_id) REFERENCES surveys(id) ON DELETE CASCADE
);

-- Responses table
CREATE TABLE responses (
    user_id INT NOT NULL,
    question_id INT NOT NULL,
    answer_text VARCHAR(255) NOT NULL,
    PRIMARY KEY (user_id, question_id),
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
);

-- 3. Insert Sample Data

-- Surveys
INSERT INTO surveys (title) VALUES
('Customer Satisfaction Survey'),
('Product Feedback Survey');

-- Questions
INSERT INTO questions (survey_id, question_text) VALUES
(1, 'How satisfied are you with our service?'),
(1, 'Would you recommend us to a friend?'),
(2, 'How would you rate the product quality?'),
(2, 'What feature would you like to see next?');

-- Responses
INSERT INTO responses (user_id, question_id, answer_text) VALUES
(1, 1, 'Very Satisfied'),
(1, 2, 'Yes'),
(2, 1, 'Satisfied'),
(2, 2, 'Yes'),
(3, 1, 'Neutral'),
(3, 2, 'No'),
(1, 3, 'Excellent'),
(1, 4, 'Dark Mode'),
(2, 3, 'Good'),
(2, 4, 'More Colors'),
(3, 3, 'Average'),
(3, 4, 'Faster Speed');

-- 4. Query: Count answers per question
SELECT 
    q.question_text,
    r.answer_text,
    COUNT(*) AS response_count
FROM questions q
JOIN responses r ON q.id = r.question_id
GROUP BY q.id, r.answer_text
ORDER BY q.id, response_count DESC;

-- 5. Query: Pivot-style summary for a specific question
-- Example: How satisfied are you with our service?
SELECT 
    SUM(CASE WHEN answer_text = 'Very Satisfied' THEN 1 ELSE 0 END) AS Very_Satisfied,
    SUM(CASE WHEN answer_text = 'Satisfied' THEN 1 ELSE 0 END) AS Satisfied,
    SUM(CASE WHEN answer_text = 'Neutral' THEN 1 ELSE 0 END) AS Neutral
FROM responses
WHERE question_id = 1;

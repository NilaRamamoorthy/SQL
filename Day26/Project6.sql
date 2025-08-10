-- 1. Create database and use it
CREATE DATABASE IF NOT EXISTS call_center_reporting;
USE call_center_reporting;

-- 2. Create tables

CREATE TABLE agents (
    agent_id INT PRIMARY KEY,
    name VARCHAR(100),
    supervisor_id INT NULL,
    FOREIGN KEY (supervisor_id) REFERENCES agents(agent_id)
);

CREATE TABLE support_tickets (
    ticket_id INT PRIMARY KEY,
    agent_id INT,
    escalation_level VARCHAR(20), -- 'Agent', 'Supervisor', 'Manager'
    interaction_time DATETIME,
    resolution_time DATETIME,
    FOREIGN KEY (agent_id) REFERENCES agents(agent_id)
);

-- 3. Insert sample data

INSERT INTO agents (agent_id, name, supervisor_id) VALUES
(1, 'Alice', 3),
(2, 'Bob', 3),
(3, 'Charlie', NULL),
(4, 'Diana', 5),
(5, 'Eve', NULL);

INSERT INTO support_tickets (ticket_id, agent_id, escalation_level, interaction_time, resolution_time) VALUES
(1001, 1, 'Agent', '2025-08-01 09:00:00', '2025-08-01 09:30:00'),
(1002, 1, 'Supervisor', '2025-08-02 10:00:00', '2025-08-02 11:00:00'),
(1003, 2, 'Agent', '2025-08-03 13:00:00', '2025-08-03 13:45:00'),
(1004, 4, 'Manager', '2025-08-04 14:00:00', '2025-08-04 15:30:00'),
(1005, 2, 'Supervisor', '2025-08-05 08:00:00', '2025-08-05 08:50:00'),
(1006, 1, 'Agent', '2025-08-06 09:00:00', '2025-08-06 09:25:00');

-- 4. Recursive CTE to show escalation flow (Agent → Supervisor → Manager)

WITH RECURSIVE escalation_path AS (
    SELECT
        agent_id,
        name,
        supervisor_id,
        1 AS level,
        CAST(name AS CHAR(1000)) AS path
    FROM agents
    WHERE supervisor_id IS NULL -- top-level (Manager)

    UNION ALL

    SELECT
        a.agent_id,
        a.name,
        a.supervisor_id,
        ep.level + 1,
        CONCAT(ep.path, ' -> ', a.name)
    FROM agents a
    JOIN escalation_path ep ON a.supervisor_id = ep.agent_id
)

SELECT * FROM escalation_path ORDER BY level, name;

-- 5. Use ROW_NUMBER() to order support interactions per agent

WITH ordered_interactions AS (
    SELECT
        ticket_id,
        agent_id,
        escalation_level,
        interaction_time,
        resolution_time,
        ROW_NUMBER() OVER (PARTITION BY agent_id ORDER BY interaction_time) AS interaction_order
    FROM support_tickets
)

SELECT * FROM ordered_interactions ORDER BY agent_id, interaction_order;

-- 6. Use RANK() to find most escalated agents by number of escalations (levels above 'Agent')

WITH escalation_counts AS (
    SELECT
        agent_id,
        COUNT(*) AS escalations
    FROM support_tickets
    WHERE escalation_level != 'Agent'
    GROUP BY agent_id
)

SELECT
    agent_id,
    escalations,
    RANK() OVER (ORDER BY escalations DESC) AS escalation_rank
FROM escalation_counts
ORDER BY escalation_rank;

-- 7. Compare issue resolution time with LAG() to get previous resolution time per agent

WITH resolution_times AS (
    SELECT
        ticket_id,
        agent_id,
        escalation_level,
        interaction_time,
        resolution_time,
        TIMESTAMPDIFF(MINUTE, interaction_time, resolution_time) AS resolution_duration,
        LAG(TIMESTAMPDIFF(MINUTE, interaction_time, resolution_time)) OVER (PARTITION BY agent_id ORDER BY interaction_time) AS prev_resolution_duration
    FROM support_tickets
)

SELECT
    ticket_id,
    agent_id,
    escalation_level,
    interaction_time,
    resolution_time,
    resolution_duration,
    prev_resolution_duration,
    resolution_duration - prev_resolution_duration AS resolution_time_diff
FROM resolution_times
ORDER BY agent_id, interaction_time;

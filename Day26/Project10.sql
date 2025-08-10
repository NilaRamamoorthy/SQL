-- 1. Create database and tables
CREATE DATABASE IF NOT EXISTS doc_tracker;
USE doc_tracker;

CREATE TABLE documents (
    document_id INT PRIMARY KEY,
    document_name VARCHAR(100)
);

CREATE TABLE document_versions (
    version_id INT PRIMARY KEY AUTO_INCREMENT,
    document_id INT,
    version_number INT,
    content TEXT,
    change_summary VARCHAR(255),
    created_at DATE,
    FOREIGN KEY (document_id) REFERENCES documents(document_id)
);

CREATE TABLE document_dependencies (
    doc_id INT,
    depends_on_doc_id INT,
    PRIMARY KEY (doc_id, depends_on_doc_id),
    FOREIGN KEY (doc_id) REFERENCES documents(document_id),
    FOREIGN KEY (depends_on_doc_id) REFERENCES documents(document_id)
);

-- 2. Insert sample data
INSERT INTO documents (document_id, document_name) VALUES
(1, 'User Guide'),
(2, 'API Spec'),
(3, 'Installation Manual'),
(4, 'Release Notes');

INSERT INTO document_versions (document_id, version_number, content, change_summary, created_at) VALUES
(1, 1, 'Content v1', 'Initial release', '2025-01-01'),
(1, 2, 'Content v2', 'Added chapter 2', '2025-02-01'),
(1, 3, 'Content v3', 'Fixed typos', '2025-03-01'),
(2, 1, 'API v1', 'Initial API spec', '2025-01-15'),
(2, 2, 'API v2', 'Added new endpoints', '2025-02-20'),
(3, 1, 'Install v1', 'Initial manual', '2025-01-10'),
(4, 1, 'Release 1.0', 'First release notes', '2025-01-05');

INSERT INTO document_dependencies (doc_id, depends_on_doc_id) VALUES
(1, 2), -- User Guide depends on API Spec
(4, 1), -- Release Notes depends on User Guide
(4, 3); -- Release Notes depends on Installation Manual

-- 3. Query: List versions per document with ROW_NUMBER()
WITH VersionList AS (
    SELECT
        document_id,
        version_id,
        version_number,
        change_summary,
        created_at,
        ROW_NUMBER() OVER (PARTITION BY document_id ORDER BY version_number DESC) AS version_rank
    FROM document_versions
)

SELECT
    d.document_name,
    vl.version_number,
    vl.change_summary,
    vl.created_at,
    vl.version_rank
FROM VersionList vl
JOIN documents d ON d.document_id = vl.document_id
ORDER BY d.document_id, vl.version_number DESC;

-- 4. Query: Compare changes between versions using LAG()
WITH VersionChanges AS (
    SELECT
        document_id,
        version_number,
        change_summary,
        LAG(change_summary) OVER (PARTITION BY document_id ORDER BY version_number) AS prev_change_summary,
        created_at
    FROM document_versions
)
SELECT
    d.document_name,
    vc.version_number,
    vc.change_summary,
    vc.prev_change_summary,
    DATEDIFF(vc.created_at, LAG(vc.created_at) OVER (PARTITION BY vc.document_id ORDER BY vc.version_number)) AS days_since_last_version
FROM VersionChanges vc
JOIN documents d ON d.document_id = vc.document_id
ORDER BY d.document_id, vc.version_number;

-- 5. Query: Recursive CTE to trace document dependencies

WITH RECURSIVE DocDeps AS (
    SELECT
        doc_id,
        depends_on_doc_id,
        1 AS depth,
        CAST(doc_id AS CHAR(200)) AS path
    FROM document_dependencies

    UNION ALL

    SELECT
        dd.doc_id,
        d.depends_on_doc_id,
        dd.depth + 1,
        CONCAT(dd.path, '->', d.depends_on_doc_id)
    FROM DocDeps dd
    JOIN document_dependencies d ON dd.depends_on_doc_id = d.doc_id
)
SELECT
    d1.document_name AS document,
    d2.document_name AS depends_on,
    depth,
    path
FROM DocDeps dd
JOIN documents d1 ON dd.doc_id = d1.document_id
JOIN documents d2 ON dd.depends_on_doc_id = d2.document_id
ORDER BY dd.doc_id, depth;

-- 6. CTE to filter current (latest), outdated, and broken versions

WITH LatestVersions AS (
    SELECT
        document_id,
        MAX(version_number) AS latest_version
    FROM document_versions
    GROUP BY document_id
),
VersionStatus AS (
    SELECT
        dv.document_id,
        dv.version_number,
        dv.change_summary,
        CASE
            WHEN dv.version_number = lv.latest_version THEN 'Current'
            WHEN dv.version_number < lv.latest_version THEN 'Outdated'
            ELSE 'Unknown'
        END AS version_status
    FROM document_versions dv
    JOIN LatestVersions lv ON dv.document_id = lv.document_id
),
BrokenDocs AS (
    -- Example: Document versions with no dependencies considered broken if dependency exists in DocDeps
    SELECT DISTINCT document_id FROM document_dependencies
    WHERE depends_on_doc_id NOT IN (SELECT document_id FROM documents)
)

SELECT
    d.document_name,
    vs.version_number,
    vs.version_status,
    CASE WHEN d.document_id IN (SELECT document_id FROM BrokenDocs) THEN 'Broken' ELSE 'OK' END AS integrity_status
FROM VersionStatus vs
JOIN documents d ON vs.document_id = d.document_id
ORDER BY d.document_id, vs.version_number DESC;

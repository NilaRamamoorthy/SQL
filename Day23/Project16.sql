
CREATE DATABASE IF NOT EXISTS LoanProcessingDB;
USE LoanProcessingDB;

-- Step 1: Create tables

CREATE TABLE applicants (
    applicant_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    application_date DATE,
    status VARCHAR(50) NOT NULL DEFAULT 'Applied'
);

CREATE TABLE loans (
    loan_id INT PRIMARY KEY AUTO_INCREMENT,
    applicant_id INT NOT NULL,
    amount DECIMAL(12,2) NOT NULL CHECK (amount <= 1000000),
    loan_type VARCHAR(50),
    status VARCHAR(50) NOT NULL DEFAULT 'Pending',
    FOREIGN KEY (applicant_id) REFERENCES applicants(applicant_id) ON DELETE CASCADE
);

CREATE TABLE documents (
    document_id INT PRIMARY KEY AUTO_INCREMENT,
    applicant_id INT NOT NULL,
    document_type VARCHAR(50) NOT NULL,
    document_status VARCHAR(50) NOT NULL DEFAULT 'Pending',
    FOREIGN KEY (applicant_id) REFERENCES applicants(applicant_id) ON DELETE CASCADE
);

CREATE TABLE disbursements (
    disbursement_id INT PRIMARY KEY AUTO_INCREMENT,
    loan_id INT NOT NULL,
    disbursement_date DATE,
    amount DECIMAL(12,2) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'Pending',
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id) ON DELETE CASCADE
);

-- Step 2: Insert sample data

INSERT INTO applicants (name, email, phone) VALUES
('John Doe', 'john.doe@example.com', '1234567890'),
('Jane Smith', 'jane.smith@example.com', '0987654321');

INSERT INTO loans (applicant_id, amount, loan_type) VALUES
(1, 50000.00, 'Personal'),
(2, 150000.00, 'Home');

INSERT INTO documents (applicant_id, document_type, document_status) VALUES
(1, 'ID Proof', 'Verified'),
(1, 'Income Proof', 'Verified'),
(2, 'ID Proof', 'Pending'),
(2, 'Income Proof', 'Pending');

-- Step 3: Delete unverified applications (applicants with any unverified docs)

DELETE a FROM applicants a
WHERE EXISTS (
    SELECT 1 FROM documents d
    WHERE d.applicant_id = a.applicant_id AND d.document_status <> 'Verified'
);

-- Step 4: Transaction with SAVEPOINT to verify docs, approve loan, disburse funds atomically

DELIMITER //
CREATE PROCEDURE process_loan_application(IN p_applicant_id INT)
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transaction failed and rolled back.';
    END;

    START TRANSACTION;

    -- Check if all documents are verified for the applicant
    IF EXISTS (
        SELECT 1 FROM documents
        WHERE applicant_id = p_applicant_id AND document_status <> 'Verified'
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Not all documents verified.';
    END IF;

    SAVEPOINT before_approval;

    -- Update loan status to Approved
    UPDATE loans SET status = 'Approved'
    WHERE applicant_id = p_applicant_id AND status = 'Pending';

    -- Check that loan was updated
    IF ROW_COUNT() = 0 THEN
        ROLLBACK TO SAVEPOINT before_approval;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Loan approval failed.';
    END IF;

    -- Insert disbursement record
    INSERT INTO disbursements (loan_id, amount, status)
    SELECT loan_id, amount, 'Disbursed' FROM loans
    WHERE applicant_id = p_applicant_id AND status = 'Approved';

    -- Verify disbursement inserted
    IF ROW_COUNT() = 0 THEN
        ROLLBACK TO SAVEPOINT before_approval;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Disbursement failed.';
    END IF;

    -- Update applicant status to 'Processed'
    UPDATE applicants SET status = 'Processed' WHERE applicant_id = p_applicant_id;

    COMMIT;
END //
DELIMITER ;

-- Step 5: Sample usage - Process loan for applicant 1

CALL process_loan_application(1);

-- Step 6: Verify status after procedure

SELECT * FROM applicants;
SELECT * FROM loans;
SELECT * FROM disbursements;


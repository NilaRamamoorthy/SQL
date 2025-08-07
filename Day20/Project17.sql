-- Step 1: Create the Database
CREATE DATABASE LoanApplicationTracker;

-- Step 2: Use the Database
USE LoanApplicationTracker;

-- Step 3: Create the 'loans' Table
CREATE TABLE loans (
    loan_id INT PRIMARY KEY,
    applicant_name VARCHAR(100),
    amount DECIMAL(15, 2),
    loan_type VARCHAR(50),
    status VARCHAR(50),
    approval_date DATE
);

-- Step 4: Insert Sample Data
INSERT INTO loans (loan_id, applicant_name, amount, loan_type, status, approval_date)
VALUES
    (1, 'John Doe', 75000.00, 'Home', 'Approved', '2025-08-01'),
    (2, 'Jane Smith', 120000.00, 'Education', 'Pending', NULL),
    (3, 'Alice Johnson', 95000.00, 'Home', 'Approved', '2025-07-20'),
    (4, 'Bob Brown', 150000.00, 'Education', 'Rejected', '2025-06-15'),
    (5, 'Charlie Davis', 50000.00, 'Home', 'Pending', NULL);

-- Step 5: Retrieve Loans with Amount Between 50k and 2L
SELECT * FROM loans
WHERE amount BETWEEN 50000 AND 200000;

-- Step 6: Filter Loans by Loan Types 'Home' and 'Education'
SELECT * FROM loans
WHERE loan_type IN ('Home', 'Education');

-- Step 7: Identify Loans with NULL Approval Date
SELECT * FROM loans
WHERE approval_date IS NULL;

-- Step 8: Show Applicant Name, Amount, and Status
SELECT applicant_name, amount, status FROM loans;

-- Step 9: Sort Loans by Amount in Descending Order
SELECT * FROM loans
ORDER BY amount DESC;

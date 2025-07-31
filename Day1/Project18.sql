-- Banking Transaction System

CREATE DATABASE bank_db;
USE bank_db;

CREATE TABLE branches (
    branch_id INT AUTO_INCREMENT PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(150)
);

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20)
);

CREATE TABLE accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    branch_id INT NOT NULL,
    account_type VARCHAR(50),
    balance DECIMAL(15,2) DEFAULT 0.00,
    opened_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);

CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    transaction_type ENUM('credit', 'debit') NOT NULL,
    amount DECIMAL(15,2) NOT NULL CHECK (amount > 0),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    description VARCHAR(255),
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

-- Sample inserts

INSERT INTO branches (branch_name, location) VALUES
('Central Branch', 'Downtown'),
('North Branch', 'Northside'),
('East Branch', 'Eastside');

INSERT INTO customers (full_name, email, phone) VALUES
('John Doe', 'john.doe@example.com', '555-1234'),
('Jane Smith', 'jane.smith@example.com', '555-5678'),
('Bob Brown', 'bob.brown@example.com', '555-8765');

INSERT INTO accounts (customer_id, branch_id, account_type, balance, opened_date) VALUES
(1, 1, 'Savings', 5000.00, '2024-01-01'),
(2, 2, 'Checking', 3000.00, '2024-02-15'),
(3, 3, 'Savings', 10000.00, '2024-03-10');

INSERT INTO transactions (account_id, transaction_type, amount, description) VALUES
(1, 'credit', 1500.00, 'Salary Deposit'),
(1, 'debit', 200.00, 'ATM Withdrawal'),
(2, 'credit', 1000.00, 'Client Payment'),
(2, 'debit', 150.00, 'Bill Payment'),
(3, 'debit', 500.00, 'Rent Payment');

-- Queries:

-- Show transaction history for account_id = 1
SELECT transaction_id, transaction_type, amount, transaction_date, description
FROM transactions
WHERE account_id = 1
ORDER BY transaction_date DESC;

-- Calculate account balance for account_id = 1 (recalculate from transactions)
SELECT
  account_id,
  SUM(CASE WHEN transaction_type = 'credit' THEN amount ELSE 0 END) -
  SUM(CASE WHEN transaction_type = 'debit' THEN amount ELSE 0 END) AS calculated_balance
FROM transactions
WHERE account_id = 1
GROUP BY account_id;


---------------------------------------------------------------------------------------

-- School Exam Result Tracker

DROP DATABASE IF EXISTS exam_db;
CREATE DATABASE exam_db;
USE exam_db;

CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    class VARCHAR(20)
);

CREATE TABLE subjects (
    subject_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE teachers (
    teacher_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    subject_id INT,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

CREATE TABLE marks (
    mark_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    subject_id INT NOT NULL,
    marks_obtained INT CHECK (marks_obtained BETWEEN 0 AND 100),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

-- Sample inserts

INSERT INTO students (full_name, class) VALUES
('Alice Green', '10-A'),
('Bob White', '10-B'),
('Cathy Blue', '10-A'),
('David Black', '10-C');

INSERT INTO subjects (subject_name) VALUES
('Mathematics'),
('Science'),
('English'),
('History');

INSERT INTO teachers (full_name, subject_id) VALUES
('Mr. Thompson', 1),
('Ms. Lee', 2),
('Mrs. Gomez', 3),
('Mr. Patel', 4);

INSERT INTO marks (student_id, subject_id, marks_obtained) VALUES
(1, 1, 85),
(1, 2, 78),
(1, 3, 92),
(1, 4, 74),
(2, 1, 88),
(2, 2, 82),
(2, 3, 79),
(2, 4, 80),
(3, 1, 90),
(3, 2, 85),
(3, 3, 88),
(3, 4, 75),
(4, 1, 70),
(4, 2, 65),
(4, 3, 72),
(4, 4, 68);

-- Queries:

-- Calculate average marks per student
SELECT s.student_id, s.full_name, AVG(m.marks_obtained) AS average_marks
FROM students s
JOIN marks m ON s.student_id = m.student_id
GROUP BY s.student_id, s.full_name;

-- Rank students by marks in Mathematics (subject_id=1)
SELECT s.student_id, s.full_name, m.marks_obtained,
       RANK() OVER (ORDER BY m.marks_obtained DESC) AS rank
FROM students s
JOIN marks m ON s.student_id = m.student_id
WHERE m.subject_id = 1
ORDER BY rank;

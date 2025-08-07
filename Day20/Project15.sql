-- Step 1: Create the Database
CREATE DATABASE PetAdoptionRegistry;

-- Step 2: Use the Database
USE PetAdoptionRegistry;

-- Step 3: Create the 'pets' Table
CREATE TABLE pets (
    pet_id INT PRIMARY KEY,
    name VARCHAR(100),
    species VARCHAR(50),
    breed VARCHAR(100),
    age INT,
    adopted BOOLEAN,
    owner_name VARCHAR(100)
);

-- Step 4: Insert Sample Data
INSERT INTO pets (pet_id, name, species, breed, age, adopted, owner_name)
VALUES
    (1, 'Buddy', 'Dog', 'German Shepherd', 3, FALSE, NULL),
    (2, 'Milo', 'Cat', 'Maine Coon', 2, FALSE, NULL),
    (3, 'Bella', 'Dog', 'Golden Retriever', 4, TRUE, 'John Doe'),
    (4, 'Lucy', 'Cat', 'Siamese', 5, FALSE, NULL),
    (5, 'Max', 'Dog', 'Labrador Retriever', 1, TRUE, 'Jane Smith');

-- Step 5: Retrieve Pets Not Yet Adopted
SELECT * FROM pets WHERE adopted = FALSE;

-- Step 6: Retrieve Pets Aged Between 1 and 5 Years
SELECT * FROM pets WHERE age BETWEEN 1 AND 5;

-- Step 7: Retrieve Pets with 'Shepherd' in Their Breed
SELECT * FROM pets WHERE breed LIKE '%shepherd%';

-- Step 8: Retrieve Name, Breed, and Species of All Pets
SELECT name, breed, species FROM pets;

-- Step 9: Retrieve Pets with NULL Owner
SELECT * FROM pets WHERE owner_name IS NULL;

-- Step 10: Retrieve Distinct Species
SELECT DISTINCT species FROM pets
ORDER BY age, name;

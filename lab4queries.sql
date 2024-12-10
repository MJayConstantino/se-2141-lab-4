-- Part 2: Logical Design
-- Create Books Table Query
CREATE TABLE Books (
    isbn VARCHAR(13) UNIQUE PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    genre VARCHAR(100) NOT NULL,
    published_year INT NOT NULL,
    quantity_available INT NOT NULL CHECK (quantity_available >= 0)
);

-- Create Users Table Query
CREATE TABLE Users (
    user_id SERIAL UNIQUE PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    email_address VARCHAR(255) UNIQUE NOT NULL,
    membership_date DATE NOT NULL
);

-- Create Book_Loans Table Query
CREATE TABLE Book_Loans (
    user_id INT NOT NULL,
    isbn VARCHAR(13) NOT NULL,
    loan_date DATE NOT NULL,
    return_date DATE,
    status VARCHAR(20) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (isbn) REFERENCES Books(isbn)
);

-- Part 3: SQL Queries 
-- a. Insert a new book into the library with a quantity of 5. 
INSERT INTO Books (isbn, title, author, genre, published_year, quantity_available) 
VALUES ('9780385737951', 'The Maze Runner', 'James Dashner', 'Science Fiction', 2010, 5) 
RETURNING *;

-- b. Add a new user to the system.
INSERT INTO Users (full_name, email_address, membership_date) 
VALUES ('Michael Constantino', 'mjconstantino@gmail.com', CURRENT_DATE) 
RETURNING *;

-- c. Record a book loan for a user
INSERT INTO Book_Loans (user_id, isbn, loan_date, status) 
VALUES (1, '9780385737951', CURRENT_DATE, 'borrowed') 
RETURNING *;

-- d. Find all books borrowed by a specific user. 
SELECT b.title, b.author, bl.loan_date, bl.status  
FROM Book_Loans bl 
JOIN Books b ON bl.isbn = b.isbn 
WHERE bl.user_id = 1;

-- e. List all overdue loans. 
SELECT u.full_name, b.title, bl.loan_date, bl.return_date 
FROM Book_Loans bl 
JOIN Users u ON bl.user_id = u.user_id 
JOIN Books b ON bl.isbn = b.isbn 
WHERE bl.status = 'overdue';

-- Part 4: Data Integrity and Optimization 
-- Fast retrieval of overdue loans. 
SELECT * 
FROM Book_Loans 
WHERE status = 'overdue';


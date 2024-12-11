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

--RULES CHECK AVAILABILITY HANDLER
CREATE OR REPLACE FUNCTION check_book_availability() 
RETURNS TRIGGER AS $$
BEGIN
    -- Check if there are available copies of the book
    IF (SELECT quantity_available FROM Books WHERE isbn = NEW.isbn) <= 0 THEN
        RAISE EXCEPTION 'No copies available for this book';
    END IF;
    -- Update the book's available quantity when a loan is made
    UPDATE Books
    SET quantity_available = quantity_available - 1
    WHERE isbn = NEW.isbn;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER book_availability_check
BEFORE INSERT ON Book_Loans
FOR EACH ROW EXECUTE FUNCTION check_book_availability();

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
SELECT *
FROM Book_Loans 
WHERE status = 'overdue';

-- Part 4: Data Integrity and Optimization 
-- Fast retrieval of overdue loans. 
CREATE INDEX idx_overdue_loans 
ON Book_Loans (status, loan_date);

SELECT *
FROM Book_Loans 
WHERE status = 'overdue';


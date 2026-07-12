create database sales_management;
use sales_management;

CREATE TABLE branches (
    branch_id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    branch_name VARCHAR(100) NOT NULL,
    branch_admin_name VARCHAR(100) NOT NULL
);


CREATE TABLE customer_sales (
    sale_id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    branch_id INT NOT NULL,
    date DATE NOT NULL,
    name VARCHAR(100) NOT NULL,
    mobile_number VARCHAR(15) NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    gross_sales DECIMAL(12,2) NOT NULL,
    received_amount DECIMAL(12,2) NOT NULL,
    pending_amount DECIMAL(12,2) GENERATED ALWAYS AS (gross_sales - received_amount) STORED,
    status ENUM('Open','Close') DEFAULT 'Open',
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL,
    branch_id INT NOT NULL,
    role ENUM('Super Admin', 'Admin'),
    email varchar(255) UNIQUE NOT NULL,
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);

CREATE TABLE payment_splits (
    payment_id INT PRIMARY KEY AUTO_INCREMENT not null,
    sale_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount_paid DECIMAL(12,2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    FOREIGN KEY (sale_id) REFERENCES customer_sales(sale_id)    
    );
    
SHOW TABLES;
DESCRIBE branches;

DESCRIBE users;

DESCRIBE customer_sales;

DESCRIBE payment_splits; 

SELECT*FROM BRANCHES;
SELECT*FROM CUSTOMER_SALES LIMIT 5;
SELECT*FROM USERS;
SELECT*FROM PAYMENT_SPLITS LIMIT 5;

DELIMITER $$
CREATE TRIGGER update_received_amount
AFTER INSERT
ON payment_splits
FOR EACH ROW
BEGIN
	UPDATE customer_sales
    SET received_amount =( 
    SELECT SUM(amount_paid)
	FROM payment_splits
	WHERE sale_id = NEW.sale_id
	)
    WHERE sale_id = NEW.sale_id;
	UPDATE customer_sales
    SET status = CASE WHEN received_amount >= gross_sales THEN 'Close'
				 ELSE 'Open'
	END
    WHERE sale_id = NEW.sale_id;
END$$
DELIMITER ;

SHOW TRIGGERS;
use sales_management;

SELECT 
    *
FROM
    customer_sales
LIMIT 5;


SELECT 
    *
FROM
    payment_splits
LIMIT 5;

SELECT *FROM payment_splits
WHERE sale_id = 1;

#inserting a payment record from payment split to test the Trigger

INSERT INTO payment_splits(sale_id, payment_date, amount_paid, payment_method)
VALUES(1, '2024-01-06', 5000,'Cash'),


SELECT 
    sale_id,
    gross_sales,
    received_amount,
    pending_amount,
    status
FROM customer_sales
WHERE sale_id = 1;


#Analysis
#Basic Queries

#Retrieve all records from customer_sales

SELECT *
FROM customer_sales;

#Retrieve all records from branches

SELECT *
FROM branches;

#Retrieve all records from payment_splits

SELECT *
FROM payment_splits;

#Display all sales with status = 'Open'

SELECT *
FROM customer_sales
WHERE status = 'Open';

#Aggregation Queries

#Total gross sales across all branches
SELECT 
SUM(gross_sales) AS total_gross_sales
FROM customer_sales;


#Total received amount
SELECT 
SUM(received_amount) AS total_received_amount
FROM customer_sales;

#Total pending amount
SELECT 
SUM(pending_amount) AS total_pending_amount
FROM customer_sales;

#Total number of sales per branch
SELECT branch_id, COUNT(sale_id) AS total_sales
FROM customer_sales
GROUP BY branch_id;

#Join-Based Queries

#Retrieve sales details along with the branch name.
SELECT
cs.*,
b.branch_name
FROM customer_sales cs
JOIN branches b
ON cs.branch_id = b.branch_id;

#Show branch-wise total gross sales (using JOIN & GROUP BY).
SELECT
b.branch_name,
SUM(cs.gross_sales) AS total_sales
FROM customer_sales cs
JOIN branches b
ON cs.branch_id = b.branch_id
GROUP BY b.branch_name;

#Sales along with payment method
SELECT
cs.sale_id,
cs.name,
ps.payment_method,
ps.amount_paid
FROM customer_sales cs
JOIN payment_splits ps
ON cs.sale_id = ps.sale_id;

#Sales with total payment received
SELECT
cs.sale_id,
cs.name,
cs.gross_sales,
SUM(ps.amount_paid) AS total_received
FROM customer_sales cs
JOIN payment_splits ps
ON cs.sale_id = ps.sale_id
GROUP BY cs.sale_id;

#Financial Tracking Queries

#Find sales where the pending amount is greater than 5000
SELECT *
FROM customer_sales
WHERE pending_amount > 5000;

#Top 3 highest gross sales
SELECT *
FROM customer_sales
ORDER BY gross_sales DESC
LIMIT 3;

#Branch with highest gross sales
SELECT
b.branch_name,
SUM(cs.gross_sales) AS total_sales
FROM customer_sales cs
JOIN branches b
ON cs.branch_id = b.branch_id
GROUP BY b.branch_name
ORDER BY total_sales DESC
LIMIT 3;

#Payment method-wise collection
SELECT
payment_method,
SUM(amount_paid) AS total_collection
FROM payment_splits
GROUP BY payment_method;

#login moduleS
SELECT*FROM users;
SET SQL_SAFE_UPDATES = 0;
UPDATE users 
SET role = 'Super Admin'
WHERE username = 'admin_bangalore';

select*from customer_sales
where sale_id = '1001';


-- Creating database-- 
CREATE DATABASE Sql_Practise;

-- Use Database-- 
USE Sql_Practise;

-- 1. Table Setup: Sample Business Data-- 
CREATE TABLE Customers (
  customer_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50),
  email VARCHAR(100),
  city VARCHAR(50),
  signup_date DATE
);

CREATE TABLE Orders (
  order_id INT PRIMARY KEY AUTO_INCREMENT,
  customer_id INT,
  order_date DATE,
  total_amount DECIMAL(10,2),
  status VARCHAR(20),
  FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE Products (
  product_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50),
  category VARCHAR(30),
  price DECIMAL(8,2)
);

CREATE TABLE OrderDetails (
  order_detail_id INT PRIMARY KEY AUTO_INCREMENT,
  order_id INT,
  product_id INT,
  quantity INT,
  FOREIGN KEY (order_id) REFERENCES Orders(order_id),
  FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- FOR CUSTOMERS
INSERT INTO Customers (customer_id, name, email, city, signup_date) VALUES
(1, '0', 'user1@example.com', 'Hyderabad', '2023-01-01'),
(2, '1', 'user2@example.com', 'Bangalore', '2023-01-16'),
(3, '2', 'user3@example.com', 'Chennai', '2023-01-31'),
(4, '3', 'user4@example.com', 'Hyderabad', '2023-02-15'),
(5, '4', 'user5@example.com', 'Mumbai', '2023-03-02'),
(6, '5', 'user6@example.com', 'Delhi', '2023-03-17'),
(7, '6', 'user7@example.com', 'Chennai', '2023-04-01'),
(8, '7', 'user8@example.com', 'Bangalore', '2023-04-16'),
(9, '8', 'user9@example.com', 'Mumbai', '2023-05-01'),
(10, '9', 'user10@example.com', 'Hyderabad', '2023-05-16');

-- FOR PRODUCTS
INSERT INTO Products (product_id, name, category, price) VALUES
(1, '0', 'Electronics', 800),
(2, '1', 'Electronics', 500),
(3, '2', 'Electronics', 300),
(4, '3', 'Electronics', 20),
(5, '4', 'Electronics', 30),
(6, '5', 'Electronics', 150),
(7, '6', 'Electronics', 25),
(8, '7', 'Electronics', 75),
(9, '8', 'Electronics', 600),
(10, '9', 'Electronics', 200);

-- FOR ORDERS
INSERT INTO Orders (order_id, customer_id, order_date, total_amount, status) VALUES
(1, 1, '2023-03-01', 850, 'Completed'),
(2, 2, '2023-03-08', 550, 'Completed'),
(3, 2, '2023-03-15', 300, 'Pending'),
(4, 3, '2023-03-22', 320, 'Completed'),
(5, 5, '2023-03-29', 60, 'Cancelled'),
(6, 5, '2023-04-05', 180, 'Completed'),
(7, 6, '2023-04-12', 75, 'Pending'),
(8, 7, '2023-04-19', 90, 'Completed'),
(9, 9, '2023-04-26', 720, 'Completed'),
(10, 10, '2023-05-03', 250, 'Pending');


--  ORDER DETAILS
INSERT INTO OrderDetails (order_detail_id, order_id, product_id, quantity) VALUES
(1, 1, 1, 1),
(2, 1, 4, 2),
(3, 2, 2, 1),
(4, 3, 3, 1),
(5, 4, 5, 1),
(6, 5, 6, 2),
(7, 6, 7, 3),
(8, 7, 2, 1),
(9, 8, 9, 1),
(10, 10, 10, 2);


-- 2. Practice Queries – Ready to Use-- 

 -- A. Basic SELECTs-- 
SELECT * FROM Customers;
SELECT name, email FROM Customers WHERE city = 'Hyderabad';
SELECT * FROM Orders WHERE status = 'Completed';

 -- B. Aggregate Functions + Grouping-- 
 SELECT city, COUNT(*) AS total_customers FROM Customers GROUP BY city;
SELECT customer_id, SUM(total_amount) AS total_spent FROM Orders GROUP BY customer_id;
SELECT category, AVG(price) FROM Products GROUP BY category;

 -- C. Filtering with HAVING-- 
 SELECT customer_id, COUNT(order_id) AS total_orders
FROM Orders
GROUP BY customer_id
HAVING COUNT(order_id) > 5;

-- D. INNER JOIN (Customer + Orders)-- 
SELECT c.name, o.order_date, o.total_amount
FROM Customers c
INNER JOIN Orders o ON c.customer_id = o.customer_id;

-- E. LEFT JOIN-- 
SELECT c.name, o.order_id, o.total_amount
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id;

 -- F. Aggregation + JOIN -- 
 SELECT c.name, SUM(o.total_amount) AS total_spent
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.name;

-- G. Subquery-- 
SELECT name FROM Customers
WHERE customer_id IN (
  SELECT customer_id FROM Orders
  GROUP BY customer_id
  HAVING SUM(total_amount) > (
    SELECT AVG(total_amount) FROM Orders
  )
);

 -- H. CROSS JOIN (all product-customer combos-- 
 SELECT c.name, p.name AS product
FROM Customers c
CROSS JOIN Products p;

-- I. Ranking Orders by Value (Window Function)-- 
SELECT customer_id, order_id, total_amount,
       RANK() OVER (PARTITION BY customer_id ORDER BY total_amount DESC) AS spending_rank
FROM Orders;

 -- J. Latest Order for Each Customer (Subquery + JOIN)-- 
 SELECT c.name, o.order_id, o.order_date
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
WHERE o.order_date = (
  SELECT MAX(order_date)
  FROM Orders o2
  WHERE o2.customer_id = c.customer_id
);

-- K. Full Outer Join Simulation (MySQL doesn't support it natively)-- 
SELECT * FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
UNION
SELECT * FROM Customers c
RIGHT JOIN Orders o ON c.customer_id = o.customer_id;

--  L. Transactions – Simulating a Safe Bank Transfer
START TRANSACTION;

UPDATE Orders SET total_amount = total_amount - 100 WHERE order_id = 1;
UPDATE Orders SET total_amount = total_amount + 100 WHERE order_id = 2;

-- COMMIT to apply changes
COMMIT;

-- If something goes wrong, use:
-- ROLLBACK;

-- M. Creating a View – Customer Purchase Summary
CREATE VIEW CustomerSummary AS
SELECT c.name, COUNT(o.order_id) AS total_orders, SUM(o.total_amount) AS total_spent
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.name;
SELECT * FROM CustomerSummary WHERE total_spent > 500;

-- N. CTE – Monthly Order Totals
WITH MonthlySales AS (
  SELECT MONTH(order_date) AS month, SUM(total_amount) AS total_sales
  FROM Orders
  GROUP BY MONTH(order_date)
)
SELECT * FROM MonthlySales WHERE total_sales > 500;

-- O. Trigger – Auto Timestamp for New Customer Signup
CREATE TRIGGER add_signup_date
BEFORE INSERT ON Customers
FOR EACH ROW
SET NEW.signup_date = CURDATE();

-- P. Stored Procedure – Find Orders by City
DELIMITER //

CREATE PROCEDURE OrdersByCity(IN input_city VARCHAR(50))
BEGIN
  SELECT c.name, o.order_id, o.total_amount
  FROM Customers c
  JOIN Orders o ON c.customer_id = o.customer_id
  WHERE c.city = input_city;
END //

DELIMITER ;

-- Call it
CALL OrdersByCity('Hyderabad');

-- Q. Indexing – Speed Up City-Based Queries
CREATE INDEX idx_city ON Customers(city);

-- R. Window Function – Ranking Customer Orders
SELECT customer_id, order_id, total_amount,
       RANK() OVER (PARTITION BY customer_id ORDER BY total_amount DESC) AS order_rank
FROM Orders;

--  S. Revenue by Product
SELECT p.name AS product, SUM(p.price * od.quantity) AS total_revenue
FROM OrderDetails od
JOIN Products p ON od.product_id = p.product_id
GROUP BY p.name
ORDER BY total_revenue DESC;

-- T. Customers with No Orders
SELECT c.name
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- U. Products Never Ordered
SELECT p.name
FROM Products p
LEFT JOIN OrderDetails od ON p.product_id = od.product_id
WHERE od.order_detail_id IS NULL;

-- V. Total Orders and Spending Per City
SELECT c.city, COUNT(o.order_id) AS total_orders, SUM(o.total_amount) AS total_spent
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.city;

-- W. Running Total of Orders Per Customer
SELECT customer_id, order_id, order_date, total_amount,
       SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) AS running_total
FROM Orders;

--  X. Top 3 Highest Paying Customers
SELECT name, total_spent
FROM (
  SELECT c.name, SUM(o.total_amount) AS total_spent,
         RANK() OVER (ORDER BY SUM(o.total_amount) DESC) AS rnk
  FROM Customers c
  JOIN Orders o ON c.customer_id = o.customer_id
  GROUP BY c.name
) AS ranked
WHERE rnk <= 3;

-- Y. Most Recently Ordered Product Per Customer
SELECT o.customer_id, p.name AS last_product
FROM Orders o
JOIN OrderDetails od ON o.order_id = od.order_id
JOIN Products p ON od.product_id = p.product_id
WHERE o.order_date = (
  SELECT MAX(o2.order_date)
  FROM Orders o2
  WHERE o2.customer_id = o.customer_id
);



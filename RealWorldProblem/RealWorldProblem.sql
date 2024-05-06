USE casestudy;
SET SQL_SAFE_UPDATES = 0;
SET GLOBAL event_scheduler = ON;

-- 1. You have got duplciate rows in table you have to delete them.
CREATE TABLE employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    hire_date DATE NOT NULL
);
INSERT INTO employees (first_name, last_name, email, hire_date) VALUES
('John', 'Doe', 'johndoe@example.com', '2022-01-15'),
('Jane', 'Smith', 'janesmith@example.com', '2021-11-30'),
('Alice', 'Johnson', 'alicejohnson@example.com', '2022-03-10'),
('David', 'Brown', 'davidbrown@example.com', '2022-02-20'),
('Emily', 'Davis', 'emilydavis@example.com', '2022-04-05'),
('Michael', 'Wilson', 'michaelwilson@example.com', '2022-01-05'),
('Sarah', 'Taylor', 'sarahtaylor@example.com', '2022-03-25'),
('Kevin', 'Clark', 'kevinclark@example.com', '2022-02-15'),
('Jessica', 'Anderson', 'jessicaanderson@example.com', '2022-04-01'),
('Matthew', 'Martinez', 'matthewmartinez@example.com', '2022-01-10'),
('Laura', 'Robinson', 'laurarobinson@example.com', '2022-03-15'),
('Daniel', 'White', 'danielwhite@example.com', '2022-02-05'),
('Amy', 'Harris', 'amyharris@example.com', '2022-04-20'),
('Jason', 'Lee', 'jasonlee@example.com', '2022-01-20'),
('Rachel', 'Moore', 'rachelmoore@example.com', '2022-03-05'),
('Emily', 'Davis', 'emilydavis@example.com', '2022-04-05'),
('Matthew', 'Martinez', 'matthewmartinez@example.com', '2022-01-10');

DELETE 
FROM 
	employees 
WHERE 
	id 
IN
(
	SELECT 
    id 
	FROM 
		(
			SELECT 
				id,
                ROW_NUMBER() OVER(PARTITION BY first_name,last_name ORDER BY id) as rnk 
			FROM 
				employees
		) AS t WHERE rnk >1
);


-- 2. You sales manager and you have 3 territories under you,the manager decided that for each territory the salesperson who have  sold 
-- more than 30%  of the average of that territory  will  get  hike  and person who have done 80% less than the average salary will be '
-- issued PIP , now for all you have to  tell your manager if he/she will get a hike or will be in a PIP
create table sales
(  
    sales_person varchar(100),
    territory varchar(2),
    sales int 
);
INSERT INTO sales (sales_person, territory, sales) VALUES 
('John', 'A',40),
('Alice', 'A', 150),
('Michael', 'A', 200),
('Sarah', 'A', 120),
('Kevin', 'A', 180),
('Jessica', 'A', 90),
('David', 'A', 130),
('Emily', 'A', 140),
('Daniel', 'A', 270),
('Laura', 'A', 300),
('Jane', 'B', 180),
('Robert', 'B', 220),
('Mary', 'B', 190),
('Peter', 'B', 210),
('Emma', 'B', 130),
('Matthew', 'B', 140),
('Olivia', 'B', 170),
('William', 'B', 240),
('Sophia', 'B', 210),
('Andrew', 'B', 300),
('James', 'C', 300),
('Linda', 'C', 270),
('Richard', 'C', 320),
('Jennifer', 'C', 280),
('Charles', 'C', 250),
('Amanda', 'C', 290),
('Thomas', 'C', 260),
('Susan', 'C', 310),
('Paul', 'C', 280),
('Karen', 'C', 300);

set @a = (SELECT ROUND(AVG(sales),2) FROM sales WHERE territory = "A");
set @b = (SELECT ROUND(AVG(sales),2) FROM sales WHERE territory = "B");
set @c = (SELECT ROUND(AVG(sales),2) FROM sales WHERE territory = "C");

SELECT
	*,
	(
		CASE
			WHEN sales > 1.3 * territory_mean THEN "Hike"
			WHEN sales < 0.8 * territory_mean THEN "Pip"
			ELSE "Nothing"
		END
    ) AS "Reward"
FROM
(
	SELECT 
		*,
		(
			CASE 
				WHEN territory = "A" THEN @a
				WHEN territory = "B" THEN @b
				WHEN territory = "C" THEN @c
				ELSE NULL
			END
		)  AS territory_mean
	FROM sales
) AS t;


-- 3. You are database administrator for a university.University have declared result for a special exam however children were not 
-- happy with the marks as marks were not given appropriately and many students marksheet was blank , so they striked. Due to strike 
-- univerisity again checked the sheets and updates were made. Handle these updates
Create table students
( 
	roll int,
	s_name varchar(100),
	Marks  float
);
INSERT INTO students (roll, s_name, Marks) VALUES 
(1, 'John', 75),
(2, 'Alice', 55),
(3, 'Bob', 40),
(4, 'Sarah', 85),
(5, 'Mike', 65),
(6, 'Emily', 50),
(7, 'David', 70),
(8, 'Sophia', 45),
(9, 'Tom', 55),
(10, 'Emma', 80),
(11, 'James', 58),
(12, 'Lily', 72),
(13, 'Andrew', 55),
(14, 'Olivia', 62),
(15, 'Daniel', 78);

Create table std_updates
(
  roll int,
  s_name varchar(100),
  marks float 
);
INSERT INTO std_updates (roll, s_name, Marks) VALUES 
(8, 'Sophia', 75),   
(9, 'Tom', 85),
(16, 'Grace', 55),
(17, 'Henry', 72),
(18, 'Sophie', 45),
(19, 'Jack', 58),
(20, 'Ella', 42);

DELIMITER //
CREATE PROCEDURE ProcessUpdateAndInsert()
BEGIN
	UPDATE 
		students s1 
			INNER JOIN 
		std_updates s2 ON s1.roll = s2.roll
	SET 
		s1.marks = s2.marks;
    
    INSERT INTO students (roll,s_name,marks)
	SELECT 
		roll,
        s_name,marks
	FROM
	(
		SELECT 
			s1.roll as r1,
            s2.* 
		FROM 
			students s1 
				RIGHT JOIN 
			std_updates s2 ON s1.roll = s2.roll
	) AS t1 
    WHERE 
		r1 IS NULL;
    TRUNCATE std_updates;
END //
DELIMITER ;

CALL ProcessUpdateAndInsert();


-- 4. -- 4 You have  to make a procedure , where you will give 3 inputs string,deliminator and before and after command , based on the 
-- information provided you have to find that part of string in industry we have space constraints,thats why we try to make things as 
-- simple as possbile, and resuable things.
CREATE TABLE employees1 (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    emp_salary DECIMAL(10, 2)
);
INSERT INTO employees1 (emp_id, emp_name, emp_salary) VALUES
(1, 'Rahul Sharma', 50000.00),
(2, 'Priya Patel', 48000.00),
(3, 'Amit Singh', 55000.00),
(4, 'Sneha Reddy', 51000.00),
(5, 'Vivek Gupta', 49000.00),
(6, 'Ananya Desai', 52000.00),
(7, 'Rajesh Verma', 53000.00),
(8, 'Neha Mishra', 48000.00),
(9, 'Arun Kumar', 47000.00),
(10, 'Pooja Mehta', 54000.00);


DELIMITER //
CREATE FUNCTION string_split(s VARCHAR(100),d VARCHAR(5),c VARCHAR(10))
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
	set @l = LENGTH(d);
    set @p = LOCATE(d,s);
    set @o = 
		CASE 
			WHEN c LIKE "%before%" 
				THEN LEFT(s,@p) 
			ELSE 
				SUBSTRING(s,@p+1,LENGTH(s))
        END;
	RETURN @o;
END //
DELIMITER ;

SELECT *,string_split(emp_name," ","after") FROM employees1;


-- 5. You have a table that stores student information  roll number wise , now some of the students have left the school due to which the 
-- roll numbers became discontinuous.Now your task is to make them continuous.
CREATE TABLE students1 (
    roll_number INT PRIMARY KEY,
    name VARCHAR(50),
    marks DECIMAL(5, 2),
    favourite_subject VARCHAR(50)
);
INSERT INTO students1 (roll_number, name, marks, favourite_subject) VALUES
(1, 'Rahul Sharma', 75.5, 'Mathematics'),
(2, 'Priya Patel', 82.0, 'Science'),
(3, 'Amit Singh', 68.5, 'History'),
(4, 'Sneha Reddy', 90.75, 'English'),
(5, 'Vivek Gupta', 79.0, 'Physics'),
(6, 'Ananya Desai', 85.25, 'Chemistry'),
(7, 'Rajesh Verma', 72.0, 'Biology'),
(8, 'Neha Mishra', 88.5, 'Computer Science'),
(9, 'Arun Kumar', 76.75, 'Economics'),
(10, 'Pooja Mehta', 94.0, 'Geography'),
(11, 'Sanjay Gupta', 81.5, 'Mathematics'),
(12, 'Divya Sharma', 77.0, 'Science'),
(13, 'Rakesh Patel', 83.5, 'History'),
(14, 'Kavita Reddy', 89.25, 'English'),
(15, 'Ankit Verma', 72.0, 'Physics');

DELIMITER //
CREATE PROCEDURE renumber_student_after_delete()
BEGIN
	UPDATE 
		students1 as s 
			INNER JOIN
		(
			SELECT 
				*,
                ROW_NUMBER() OVER(ORDER BY roll_number) as rnk 
			FROM 
				students1
		) AS k ON s.roll_number = k.roll_number
		SET 
			s.roll_number = rnk;
END //
DELIMITER ;

DELIMITER //
CREATE EVENT IF NOT EXISTS renumber_students_event
ON SCHEDULE EVERY 20 SECOND
DO
BEGIN
	CALL renumber_student_after_delete();
END //
DELIMITER ;

SELECT * FROM students1;
DELETE FROM students1 WHERE roll_number IN (3,4,5);


-- 6. Create a system where it will check the warehouse before making the sale and if sufficient quantity is avaibale make the sale and 
-- store the sales transaction else show error for insufficient quantity.( like an ecommerce website, before making final transaction 
-- look for stock.)

CREATE TABLE products
   (
      product_code VARCHAR(20),
      product_name VARCHAR(20),
      price INT,
      Quantity_remaining INT,
      Quantity_sold INT
	);
INSERT INTO products (product_code, product_name, price, Quantity_remaining, Quantity_sold) VALUES
('RO001', 'Rolex Submariner', 7500, 20, 0),
('RO002', 'Rolex Datejust', 6000, 15, 0),
('RO003', 'Rolex Daytona', 8500, 25, 0),
('RO004', 'Rolex GMT-Master II', 7000, 18, 0),
('RO005', 'Rolex Explorer', 5500, 12, 0),
('RO006', 'Rolex Yacht-Master', 9000, 30, 0),
('RO007', 'Rolex Sky-Dweller', 9500, 22, 0);   
    
CREATE TABLE sales1
( 
     order_id INT AUTO_INCREMENT PRIMARY KEY,
     order_date DATE,
     product_code VARCHAR(10),
     Quantity_sold INT,
     per_quantity_price INT,
     total_sale_price INT
);

DELIMITER //
CREATE PROCEDURE MakeSale(IN pname VARCHAR(100),IN quantity INT)
BEGIN
	set @co = (SELECT product_code FROM products WHERE product_name = pname);
    set @qu = (SELECT quantity_remaining FROM products WHERE product_code = @co);
    set @pr = (SELECT price FROM products WHERE product_code = @co);
    
    IF quantity <= @qu
		THEN 
			INSERT INTO sales1(order_date,product_code,quantity_sold,per_quantity_price,total_sale_price) VALUES
			(CURRENT_DATE(),@co,quantity,@pr,quantity * @pr);
            SELECT "Sales Successful" AS message;
            UPDATE
				products
			SET
				quantity_remaining = quantity_remaining - quantity
			WHERE
				product_name = pname;
	ELSE
		SELECT "Insufficient Quantity Available" AS message;
    END IF;
END //
DELIMITER ;
CALL MakeSale("Rolex Submariner",5);


-- 7. You have a table where there is sales data for entire month you have to calculate cumultive sum for the entire  month data  show it
--  month wise and week wise both	
CREATE TABLE sales2 (
    sale_date DATE,
    day_of_week VARCHAR(20),
    sales_amount DECIMAL(10, 2)
);
INSERT INTO sales2 (sale_date, day_of_week, sales_amount) VALUES
('2024-04-01', 'Friday', 1500.00),
('2024-04-02', 'Saturday', 1800.50),
('2024-04-03', 'Sunday', 2500.75),
('2024-04-04', 'Monday', 3200.25),
('2024-04-05', 'Tuesday', 2800.60),
('2024-04-06', 'Wednesday', 2100.90),
('2024-04-07', 'Thursday', 3500.00),
('2024-04-08', 'Friday', 2200.00),
('2024-04-09', 'Saturday', 1900.25),
('2024-04-10', 'Sunday', 2600.75),
('2024-04-11', 'Monday', 3100.50),
('2024-04-12', 'Tuesday', 2900.80),
('2024-04-13', 'Wednesday', 2400.70),
('2024-04-14', 'Thursday', 3800.00),
('2024-04-15', 'Friday', 3200.50),
('2024-04-16', 'Saturday', 1800.75),
('2024-04-17', 'Sunday', 2700.25),
('2024-04-18', 'Monday', 3000.20),
('2024-04-19', 'Tuesday', 2600.90),
('2024-04-20', 'Wednesday', 2200.60),
('2024-04-21', 'Thursday', 3600.00),
('2024-04-22', 'Friday', 2900.50),
('2024-04-23', 'Saturday', 2100.75),
('2024-04-24', 'Sunday', 2800.25),
('2024-04-25', 'Monday', 3300.80),
('2024-04-26', 'Tuesday', 2700.70),
('2024-04-27', 'Wednesday', 2300.00),
('2024-04-28', 'Thursday', 3700.50),
('2024-04-29', 'Friday', 3100.75),
('2024-04-30', 'Saturday', 1900.25);

SELECT 
	s.sale_date,
    day_of_week,
    sales_amount,
    running_sum
FROM
	sales2 AS s
INNER JOIN
(
	SELECT 
		sale_date,
        SUM(sales_amount) OVER(ORDER BY sale_date) AS "running_sum" 
	FROM 
		sales2
) As k ON s.sale_date = k.sale_date
WHERE
	day_of_week="Friday";
    
    
-- 8. Given a Sales table containing SaleID,ProductID,SaleAmount,and SaleDate,write a SQL query to find the top 2 salespeople based 
-- on their total sales amount for the current month. If there's a tie in sales amount, prioritize the salesperson with the earlier 
-- registration date.
CREATE TABLE Sales3(
    Sale_man_registration_date DATE,
    ProductID INT,
    SaleAmount DECIMAL(10, 2),
    SaleDate DATE,
    SalespersonID INT
);
INSERT INTO Sales3(Sale_man_registration_date, ProductID, SaleAmount, SaleDate, SalespersonID) VALUES
('2023-07-15', 101, 150.00, '2023-07-05', 1),
('2023-07-15', 102, 200.00, '2023-07-10', 2),
('2023-07-15', 103, 180.00, '2023-07-15', 3),
('2023-07-15', 104, 220.00, '2023-07-20', 4),
('2023-07-15', 105, 190.00, '2023-07-25', 5),
('2023-07-15', 101, 210.00, '2023-08-05', 1),
('2023-07-15', 102, 180.00, '2023-08-10', 2),
('2023-07-15', 103, 200.00, '2023-08-15', 3),
('2023-07-15', 104, 190.00, '2023-08-20', 4),
('2023-07-15', 105, 220.00, '2023-08-25', 5),
('2024-01-10', 101, 230.00, '2024-01-05', 1),
('2024-01-10', 102, 190.00, '2024-01-10', 2),
('2024-01-10', 103, 220.00, '2024-01-15', 3),
('2024-01-10', 104, 190.00, '2024-01-20', 4),
('2024-01-10', 105, 230.00, '2024-01-25', 5),
('2024-01-10', 101, 240.00, '2024-02-05', 1),
('2024-01-10', 102, 180.00, '2024-02-10', 2),
('2024-01-10', 103, 220.00, '2024-02-15', 3),
('2024-01-10', 104, 200.00, '2024-02-20', 4),
('2024-01-10', 105, 210.00, '2024-02-25', 5),
('2024-04-15', 101, 250.00, '2024-04-05', 1),
('2024-04-15', 102, 200.00, '2024-04-10', 2),
('2024-04-15', 103, 180.00, '2024-04-15', 3),
('2024-04-15', 104, 220.00, '2024-04-20', 4),
('2024-04-15', 105, 220.00, '2024-04-25', 5),
('2024-04-15', 101, 210.00, '2024-05-05', 1),
('2024-04-15', 102, 180.00, '2024-05-10', 2),
('2024-04-15', 103, 200.00, '2024-05-15', 3),
('2024-04-15', 104, 190.00, '2024-05-20', 4),
('2024-04-15', 105, 220.00, '2024-05-25', 5);

SELECT 
	SalespersonID,
    SUM(SaleAmount) AS "Total" 
FROM 
	sales3 
WHERE 
	YEAR(SaleDate)=2024 
		AND 
	MONTH(SaleDate) = 5 
GROUP BY 
	SalespersonID
ORDER BY 
	Total DESC 
LIMIT 2;


-- 9. You have got transaction data in the format transaction id,date,type,amount and description,however this format is not
 -- easily interpretable,now you have to make it in the good format (month,year,revenue,expenditure,profit)
CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    transaction_date DATE,
    transaction_type VARCHAR(50),
    amount DECIMAL(10, 2),
    descriptions VARCHAR(1000)
);
INSERT INTO transactions (transaction_id, transaction_date, transaction_type, amount, descriptions) VALUES
(1, '2024-01-05', 'Expense', 500.00, 'Office supplies'),
(2, '2024-01-15', 'Revenue', 1500.00, 'Consulting fees'),
(3, '2024-02-10', 'Expense', 300.00, 'Travel expenses'),
(4, '2024-02-22', 'Revenue', 2000.00, 'Product sales'),
(5, '2024-03-03', 'Expense', 700.00, 'Advertising costs'),
(6, '2024-03-18', 'Revenue', 1800.00, 'Service subscriptions'),
(7, '2024-04-12', 'Expense', 400.00, 'Software licenses'),
(8, '2024-04-29', 'Revenue', 2500.00, 'Event sponsorship'),
(9, '2024-01-09', 'Expense', 600.00, 'Equipment maintenance'),
(10, '2024-01-14', 'Revenue', 1200.00, 'Online course sales'),
(11, '2024-02-20', 'Expense', 450.00, 'Utility bills'),
(12, '2024-02-25', 'Revenue', 3000.00, 'Consulting services'),
(13, '2024-03-05', 'Expense', 550.00, 'Office rent'),
(14, '2024-03-08', 'Revenue', 1800.00, 'Web development project'),
(15, '2024-04-19', 'Expense', 400.00, 'Employee training'),
(16, '2024-04-21', 'Revenue', 2200.00, 'Product sales'),
(17, '2024-01-28', 'Expense', 750.00, 'Marketing campaign'),
(18, '2024-01-15', 'Revenue', 1600.00, 'Consulting fees'),
(19, '2024-02-21', 'Expense', 350.00, 'Office supplies'),
(20, '2024-02-28', 'Revenue', 2800.00, 'Event ticket sales');
SELECT 
	MONTH(transaction_date) AS "months",
    YEAR(transaction_date) AS "Year",
	SUM(CASE WHEN transaction_type="Revenue" THEN amount ELSE 0 END) AS "Revenue",
	SUM(CASE WHEN transaction_type="Expense" THEN amount ELSE 0 END) AS "Expenditure"
FROM 
	transactions 
GROUP BY 
	YEAR(transaction_date),
	MONTH(transaction_date) 
ORDER BY 
	months;
CREATE DATABASE practice;
USE practice;

CREATE TABLE employee(
	emp_name VARCHAR(10), 
	dep_id INT, salary INT
);
INSERT INTO employee VALUES 
('Siva',1,30000),
('Ravi',2,40000),
('Prasad',1,50000),
('Sai',2,20000);


-- 1. Find the employees #with minimum #and maximum salary for each department:-
SELECT 
	dep_id,
	MAX(CASE WHEN e.salary = (SELECT MAX(salary) FROM employee WHERE dep_id = e.dep_id) THEN e.emp_name END) AS "Max Salary",
    MIN(CASE WHEN e.salary = (SELECT MIN(salary) FROM employee WHERE dep_id = e.dep_id) THEN e.emp_name END) AS "Min Salary"
FROM 
	employee e 
GROUP BY 
	dep_id;
    

CREATE TABLE sales 
(
    order_date date,
    customer VARCHAR(512),
    qty INT
);
   
INSERT INTO sales (order_date, customer, qty) VALUES ('2021-01-01', 'C1', '20');
INSERT INTO sales (order_date, customer, qty) VALUES ('2021-01-01', 'C2', '30');
INSERT INTO sales (order_date, customer, qty) VALUES ('2021-02-01', 'C1', '10');
INSERT INTO sales (order_date, customer, qty) VALUES ('2021-02-01', 'C3', '15');
INSERT INTO sales (order_date, customer, qty) VALUES ('2021-03-01', 'C5', '19');
INSERT INTO sales (order_date, customer, qty) VALUES ('2021-03-01', 'C4', '10');
INSERT INTO sales (order_date, customer, qty) VALUES ('2021-04-01', 'C3', '13');
INSERT INTO sales (order_date, customer, qty) VALUES ('2021-04-01', 'C5', '15');
INSERT INTO sales (order_date, customer, qty) VALUES ('2021-04-01', 'C6', '10');

-- 2. find the count of new customer added in each month
WITH first_order AS(
	SELECT
		customer,
        MIN(order_date) AS min_date
	FROM
		sales
	GROUP BY
		customer
)
SELECT MONTH(min_date), COUNT(*) FROM first_order GROUP BY MONTH(min_date);

create table mytable(
  	category varchar(20),
	product varchar(20),
	user_id int , 
  	spend int,
  	transaction_date DATE
);
Insert into mytable values
('appliance','refrigerator',165,246.00,'2021/12/26'),
('appliance','refrigerator',123,299.99,'2022/03/02'),
('appliance','washingmachine',123,219.80,'2022/03/02'),
('electronics','vacuum',178,152.00,'2022/04/05'),
('electronics','wirelessheadset',156,	249.90,'2022/07/08'),
('electronics','TV',145,189.00,'2022/07/15'),
('Television','TV',165,129.00,'2022/07/15'),
('Television','TV',163,129.00,'2022/07/15'),
('Television','TV',141,129.00,'2022/07/15'),
('toys','Ben10',145,189.00,'2022/07/15'),
('toys','Ben10',145,189.00,'2022/07/15'),
('toys','yoyo',165,129.00,'2022/07/15'),
('toys','yoyo',163,129.00,'2022/07/15'),
('toys','yoyo',141,129.00,'2022/07/15'),
('toys','yoyo',145,189.00,'2022/07/15'),
('electronics','vacuum',145,189.00,'2022/07/15');

-- 3. find the top 2 products in the top 2 categories based on spend amount

WITH top2_category AS
(    
	SELECT
		category,
		SUM(spend) AS category_spend
	FROM
		mytable
	GROUP BY
		category
	ORDER BY
		category_spend DESC
	LIMIT 2
)
SELECT
	category,
    product
FROM
(
	SELECT 
		category,
		product,
		RANK() OVER(PARTITION BY category ORDER BY SUM(spend) DESC) AS product_rank
	FROM
		mytable
	WHERE
		category IN (SELECT category FROM top2_category)
	GROUP BY
		category, product
) AS product_within_category_rank
WHERE
	product_rank <=2 ;
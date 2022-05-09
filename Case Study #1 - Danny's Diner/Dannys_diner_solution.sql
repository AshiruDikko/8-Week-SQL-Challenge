USE dannys_diner;
-- 1. What is the total amount each customer spent at the restaurant?

SELECT
	sales.customer_id,
    SUM(menu.price) AS total_spent
FROM menu
	LEFT JOIN sales
    	ON sales.product_id = menu.product_id
GROUP BY
	sales.customer_id
ORDER BY
	total_spent DESC;
    
-- 2. How many days has each customer visited the restaurant?
SELECT
	customer_id,
    COUNT(DISTINCT order_date) AS number_of_visits
FROM dannys_diner.sales
GROUP BY
	customer_id
ORDER BY
	number_of_visits DESC;

-- 3. What was the first item from the menu purchased by each customer?
CREATE TEMPORARY TABLE first_order
SELECT
	sales.customer_id,
    menu.product_name,
    sales.order_date,
    RANK() OVER(PARTITION BY sales.customer_id ORDER BY sales.order_date) AS ranking
    
FROM menu
	LEFT JOIN sales
    	ON sales.product_id = menu.product_id
GROUP BY
	sales.customer_id,
    menu.product_name,
    sales.order_date;
    
SELECT
	customer_id,
    product_name
FROM first_order
WHERE ranking = 1;
  
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT
	menu.product_name,
	COUNT(sales.product_id) AS most_ordered
FROM dannys_diner.sales
 	LEFT JOIN dannys_diner.menu
    	ON menu.product_id = sales.product_id
GROUP BY
	 menu.product_name
ORDER BY
	most_ordered DESC
LIMIT 1;

-- DROP TABLE IF EXISTS all_orders;   

-- 5. Which item was the most popular for each customer?
CREATE TEMPORARY TABLE all_orders
SELECT
	sales.customer_id AS customer_id,
    menu.product_name AS product_name,
    COUNT(sales.product_id) AS order_count,
    RANK () OVER(PARTITION BY sales.customer_id ORDER BY COUNT(sales.product_id) DESC) AS ranking 
    
FROM sales
	LEFT JOIN menu
		ON menu.product_id = sales.product_id
GROUP BY
	customer_id,
    product_name;

SELECT
	customer_id,
    product_name,
    order_count AS most_popular
FROM all_orders
WHERE ranking = 1;

-- 6. Which item was purchased first by the customer after they became a member?

SELECT
	sales.customer_id,
    sales.order_date,
    menu.product_name
FROM sales
	LEFT JOIN members
		ON sales.customer_id = members.customer_id
	LEFT JOIN menu
		ON sales.product_id = menu.product_id
WHERE sales.order_date >= members.join_date
GROUP BY
	sales.customer_id;
    
-- 7. Which item was purchased just before the customer became a member?

CREATE TEMPORARY TABLE last_order_before_membership
SELECT
	sales.customer_id,
    sales.order_date,
    members.join_date,
    menu.product_name,
    RANK() OVER(PARTITION BY sales.customer_id ORDER BY (sales.order_date) DESC) AS ranking 
FROM sales
	LEFT JOIN members
		ON sales.customer_id = members.customer_id
	LEFT JOIN menu
		ON sales.product_id = menu.product_id
 WHERE sales.order_date < members.join_date;
     
SELECT
	customer_id,
    order_date,
    product_name    
FROM last_order_before_membership
WHERE ranking = 1;

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT
	sales.customer_id,
    COUNT(DISTINCT sales.product_id) AS total_items,
    SUM(menu.price) AS amount_spent
FROM sales
	LEFT JOIN members
		ON sales.customer_id = members.customer_id
	LEFT JOIN menu
		ON sales.product_id = menu.product_id
WHERE sales.order_date < members.join_date
GROUP BY
	sales.customer_id;
    
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
CREATE TEMPORARY TABLE points
SELECT
	product_id,
    menu.price AS price,
    menu.product_name,
    (CASE 
    WHEN menu.product_id = 1 then menu.price * 20
    WHEN menu.product_id <> 1 then menu.price * 10
    ELSE NULL END) AS points
FROM menu;


SELECT
customer_id,
SUM(points) AS total_points
FROM points
	LEFT JOIN sales
		ON sales.product_id = points.product_id
GROUP BY
	customer_id
ORDER BY
	customer_id;
    
/* 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
 not just sushi - how many points do customer A and B have at the end of January? */
 

 CREATE TEMPORARY TABLE dates
 SELECT
 customer_id,
 join_date,
 DATE_ADD(join_date, INTERVAL 6 DAY) AS validity_period
 FROM members;

CREATE TEMPORARY TABLE customer_points
SELECT
	dates.customer_id,
	dates.validity_period,
    sales.order_date,
    dates.join_date,
    menu.price AS price,
    menu.product_name,
    SUM(CASE 
    WHEN menu.product_name = 'curry' THEN menu.price * 20
    WHEN order_date BETWEEN dates.join_date AND dates.validity_period THEN menu.price * 20
    ELSE menu.price * 10 END) AS points
FROM dates
	LEFT JOIN sales
		ON sales.customer_id = dates.customer_id
	LEFT JOIN menu
		ON sales.product_id = menu.product_id
WHERE sales.order_date >= dates.join_date AND sales.order_date <= '2021-01-31'
GROUP BY
	sales.order_date,
	dates.customer_id,
    price;
    
 -- Summary of points   
SELECT
customer_id,
SUM(points) AS total_points
FROM customer_points

GROUP BY
	customer_id;
    
-- BONUS QUESTIONS

-- Join all things   
SELECT
	sales.customer_id,
    sales.order_date,
    menu.product_name,
    menu.price,
    (CASE
		WHEN sales.order_date >= members.join_date THEN 'Y'
        WHEN sales.order_date < members.join_date THEN 'N'
        ELSE 'N' END) AS member
FROM sales
	LEFT JOIN members
		ON members.customer_id = sales.customer_id
	LEFT JOIN menu
		ON menu.product_id = sales.product_id;
        
-- Rank all the things 

CREATE TEMPORARY TABLE member_status	
SELECT
	sales.customer_id,
    sales.order_date,
    menu.product_name,
    menu.price,
    (CASE
		WHEN sales.order_date >= members.join_date THEN 'Y'
        WHEN sales.order_date < members.join_date THEN 'N'
        ELSE 'N' END) AS member
FROM sales
	LEFT JOIN members
		ON members.customer_id = sales.customer_id
	LEFT JOIN menu
		ON menu.product_id = sales.product_id;
        
SELECT *,
	CASE
		WHEN member = 'N' THEN NULL
        ELSE RANK() OVER(PARTITION BY customer_id, member ORDER BY order_date) END AS Ranking
FROM member_status;
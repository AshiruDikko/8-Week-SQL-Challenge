# Case Study #1: Danny's Diner

## Solution

View the whole query [here](https://github.com/AshiruDikko/8-Week-SQL-Challenge/blob/master/Case%20Study%20%231%20-%20Danny's%20Diner/Dannys_diner_solution.sql)

***

### 1. What is the total amount each customer spent at the restaurant?

````sql
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
````

#### Answer:
| customer_id | total_spent |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

- Customer A spent $76
- Customer B spent $74
- Customer C spent $36

***

### 2. How many days has each customer visited the restaurant?

````sql
SELECT
	customer_id,
    COUNT(DISTINCT order_date) AS number_of_visits
FROM sales
GROUP BY
	customer_id
ORDER BY
	number_of_visits DESC;
````

#### Answer:
| customer_id | number_of_visits |
| ----------- | ----------- |
| B           | 6          |
| A           | 4          |
| C           | 2          |

- **Customer A** had the most visits with **6**, followed by **customer B** with **4** and then **customer C** with **2**.

***

### 3. What was the first item from the menu purchased by each customer?

````sql
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
````

#### Answer:
| customer_id | product_name |
| ----------- | ----------- |
| A           | sushi        |
| A           | curry        |
| B           | curry        |
| C           | ramen        |

- Customer A's first orders were sushi and curry.
- Customer B's first order was curry.
- Customer C's first order was ramen.

***

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

````sql
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
````



#### Answer:
| product_name  | most_ordered |
| ----------- | ----------- |
| ramen       | 8|


- Ramen, and it was purchased 8 times.

***

### 5. Which item was the most popular for each customer?

````sql
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
````

#### Answer:
| customer_id | product_name | most_popular |
| ----------- | ---------- |------------  |
| A           | ramen        |  3   |
| B           | curry        |  2   |
| B           | sushi        |  2   |
| B           | ramen        |  2   |
| C           | ramen        |  3   |

- For **Customers A** and **C** it was **ramen** while for **customer B** it was **all items** on the menu.

***

### 6. Which item was purchased first by the customer after they became a member?

````sql
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
````


#### Answer:
| customer_id |  order_date |product_name
| ----------- | ----------  |----------|
| A           |  2021-01-07 |curry |
| B           |  2021-01-11 | sushi|

- Customer A's first order was curry.
- Customer B's first order was sushi.

***

### 7. Which item was purchased just before the customer became a member?

````sql
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
````

#### Answer:
| customer_id |order_date | product_name|
| ----------- | ----------  |----------|
| A           | 2021-01-01  |sushi |
| A           | 2021-01-01  |curry |
| B           | 2021-01-04  |sushi|

- Customer A’s last orders were sushi and curry.
- Customer B’s last order was sushi.

***

### 8. What is the total items and amount spent for each member before they became a member?

````sql
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
````


#### Answer:
| customer_id |total_items | amount_spent |
| ----------- | ---------- |----------  |
| A           | 2 |  25       |
| B           | 2 |  40       |

- Customer A spent $25 on 2 items before becoming a member.
- Customer B spent $40 on 2 items before becoming a member.

***

### 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

````sql
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
````


#### Answer:
| customer_id | total_points |
| ----------- | -------|
| A           | 860 |
| B           | 940 |
| C           | 360 |

- Customer A has 860 points.
- Customer B has 940 points.
- Customer C has 360 points.

***

### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

````sql
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

SELECT
customer_id,
SUM(points) AS total_points
FROM customer_points

GROUP BY
	customer_id;
````
#### PS: Per the question, our calculation starts from **after** the customer joins the program to the end of January.
#### Answer:
| customer_id | total_points |
| ----------- | ---------- |
| A           | 1020 |
| B           | 320 |

- Customer A's total points are 1,020
- Customer B's total points are 320

## BONUS QUESTIONS

### Join All The Things
##### Using customer_id, order_date, product_name, price and member columns. Recreate the table so that Danny and his team can quickly derive insights without needing to join underlying tables using SQL.

````sql
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
 ````

#### Answer:
| customer_id | order_date | product_name | price | member |
| ----------- | ---------- | -------------| ----- | ------ |
| A           | 2021-01-01 | sushi        | 10    | N      |
| A           | 2021-01-01 | curry        | 15    | N      |
| A           | 2021-01-07 | curry        | 15    | Y      |
| A           | 2021-01-10 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| B           | 2021-01-01 | curry        | 15    | N      |
| B           | 2021-01-02 | curry        | 15    | N      |
| B           | 2021-01-04 | sushi        | 10    | N      |
| B           | 2021-01-11 | sushi        | 10    | Y      |
| B           | 2021-01-16 | ramen        | 12    | Y      |
| B           | 2021-02-01 | ramen        | 12    | Y      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-07 | ramen        | 12    | N      |

***

### Rank All The Things
##### Danny also requires further information about the ```ranking``` of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ```ranking``` values for the records when customers are not yet part of the loyalty program.

````sql
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
````

#### Answer:
| customer_id | order_date | product_name | price | member | Ranking |
| ----------- | ---------- | -------------| ----- | ------ |-------- |
| A           |2021-01-01  | sushi        | 10    | N      | NULL    |
| A           | 2021-01-01 | curry        | 15    | N      | NULL    |
| A           | 2021-01-07 | curry        | 15    | Y      | 1       |
| A           | 2021-01-10 | ramen        | 12    | Y      | 2       |
| A           | 2021-01-11 | ramen        | 12    | Y      | 3       |
| A           | 2021-01-11 | ramen        | 12    | Y      | 3       |
| B           | 2021-01-01 | curry        | 15    | N      | NULL    |
| B           | 2021-01-02 | curry        | 15    | N      | NULL    |
| B           | 2021-01-04 | sushi        | 10    | N      | NULL    |
| B           | 2021-01-11 | sushi        | 10    | Y      | 1       |
| B           | 2021-01-16 | ramen        | 12    | Y      | 2       |
| B           | 2021-02-01 | ramen        | 12    | Y      | 3       |
| C           | 2021-01-01 | ramen        | 12    | N      | NULL    |
| C           | 2021-01-01 | ramen        | 12    | N      | NULL    |
| C           | 2021-01-07 | ramen        | 12    | N      | NULL    |


***

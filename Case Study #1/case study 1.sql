CREATE SCHEMA dannys_diner;
USE dannys_diner;

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  
  /* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

-- Example Query:
SELECT
  	product_id,
    product_name,
    price
FROM dannys_diner.menu
ORDER BY price DESC
LIMIT 5;


-- 1. What is the total amount each customer spent at the restaurant?
SELECT 
    sales.customer_id,
    SUM(menu.price) as total_money_spend
FROM dannys_diner.sales 
JOIN dannys_diner.menu ON sales.product_id = menu.product_id
GROUP BY customer_id
ORDER BY sales.customer_id ASC;


-- 2. How many days has each customer visited the restaurant?
SELECT 
   customer_id,
   COUNT(DISTINCT order_date) as total_days_visited
FROM dannys_diner.sales 
GROUP BY customer_id
ORDER BY customer_id ASC;


-- 3. What was the first item from the menu purchased by each customer?

WITH firstItem as (
  SELECT 
      sales.customer_id,
      sales.order_date,
      menu.product_name,
  RANK() OVER( PARTITION BY customer_id ORDER BY order_date ASC ) AS rnk,
  ROW_NUMBER() OVER( PARTITION BY customer_id ORDER BY order_date ASC ) AS rn
  FROM dannys_diner.sales
  JOIN dannys_diner.menu ON sales.product_id = menu.product_id
  )
SELECT 
  customer_id,
  product_name AS product
FROM firstItem
WHERE rn = 1;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT 
    s.product_id,
    m.product_name,
    COUNT(s.product_id) AS timePurchased
FROM dannys_diner.sales AS s
JOIN dannys_diner.menu AS m ON s.product_id = m.product_id
GROUP BY s.product_id, m.product_name
ORDER BY timePurchased DESC LIMIT 1;


-- 5. Which item was the most popular for each customer?

WITH items AS(
 SELECT 
    s.customer_id,
    m.product_name,
    COUNT(s.product_id) AS popularitem,
    RANK() OVER( PARTITION BY customer_id ORDER BY (COUNT(s.product_id)) DESC ) AS rnk
 FROM dannys_diner.sales AS s
 JOIN dannys_diner.menu AS m ON s.product_id = m.product_id
 GROUP BY s.product_id, m.product_name, s.customer_id
  )
SELECT 
  customer_id,
  GROUP_CONCAT(product_name)
FROM items
WHERE rnk = 1
GROUP BY items.customer_id;


-- 6. Which item was purchased first by the customer after they became a member?

WITH firstItem AS(
  SELECT
     s.customer_id,
     s.order_date,
     m.product_name,
     RANK() OVER( PARTITION BY s.customer_id ORDER BY s.order_date ) AS rnk
  FROM dannys_diner.sales s
  JOIN dannys_diner.menu m 
     ON s.product_id = m.product_id
  JOIN dannys_diner.members mem 
     ON s.customer_id = mem.customer_id
  WHERE s.order_date >= mem.join_date
  )
SELECT 
   customer_id,
   product_name
FROM firstItem
WHERE rnk = 1;


-- 7. Which item was purchased just before the customer became a member?

WITH Item AS(
  SELECT
     s.customer_id,
     s.order_date,
     m.product_name,
     RANK() OVER( PARTITION BY s.customer_id ORDER BY s.order_date DESC ) AS rnk
  FROM dannys_diner.sales s
  JOIN dannys_diner.menu m 
     ON s.product_id = m.product_id
  JOIN dannys_diner.members mem 
     ON s.customer_id = mem.customer_id
  WHERE s.order_date < mem.join_date
  )
SELECT 
   customer_id,
   GROUP_CONCAT(product_name)
FROM Item
WHERE rnk = 1
GROUP BY Item.customer_id;


-- 8. What is the total items and amount spent for each member before they became a member?

  SELECT
     s.customer_id,
     COUNT(m.product_name) AS total_item,
     SUM(m.price) AS amount_spent
  FROM dannys_diner.sales s
  JOIN dannys_diner.menu m 
     ON s.product_id = m.product_id
  JOIN dannys_diner.members mem 
     ON s.customer_id = mem.customer_id
  WHERE s.order_date < mem.join_date
  GROUP BY s.customer_id
  ORDER BY s.customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

  SELECT
     s.customer_id,
     SUM(CASE 
         WHEN m.product_name = 'sushi' THEN m.price*20
         ELSE m.price*10 
         END) AS points
  FROM dannys_diner.sales s
  JOIN dannys_diner.menu m 
     ON s.product_id = m.product_id
  GROUP BY s.customer_id
  ORDER BY s.customer_id;


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

   SELECT
    s.customer_id,
    SUM(CASE
        WHEN s.order_date BETWEEN mem.join_date AND (mem.join_date + INTERVAL 6 day) THEN m.price * 20
        ELSE m.price * 10
        END) AS points
  FROM dannys_diner.sales s
  JOIN dannys_diner.menu m ON s.product_id = m.product_id
  JOIN dannys_diner.members mem ON s.customer_id = mem.customer_id
  WHERE s.order_date <= '2021-01-31'
  AND s.order_date >= mem.join_date
  GROUP BY s.customer_id
  ORDER BY s.customer_id ASC;

-- Bonus 1. Join All The Things And Recreate The Table

SELECT 
     s.customer_id,
     s.order_date,
     m.product_name,
     m.price,
    (CASE 
       WHEN s.order_date < mem.join_date OR mem.join_date IS NULL THEN 'N'
       ELSE 'Y'
     END) AS member
FROM dannys_diner.sales s
  JOIN dannys_diner.menu m 
     ON s.product_id = m.product_id
  LEFT JOIN dannys_diner.members mem 
     ON s.customer_id = mem.customer_id
ORDER BY s.customer_id ASC, s.order_date ASC;   

-- Bonus 2.Rank All The Things

SELECT *,
  (CASE WHEN member ='Y' 
     THEN 
     RANK() OVER( PARTITION BY customer_id, member ORDER BY order_date ASC, price DESC)
     ELSE null
   END) AS ranking
FROM
(SELECT 
     s.customer_id,
     s.order_date,
     m.product_name,
     m.price,
    (CASE 
       WHEN s.order_date < mem.join_date OR mem.join_date IS NULL THEN 'N'
       ELSE 'Y'
     END) AS member
FROM dannys_diner.sales s
  JOIN dannys_diner.menu m 
     ON s.product_id = m.product_id
  LEFT JOIN dannys_diner.members mem 
     ON s.customer_id = mem.customer_id
ORDER BY s.customer_id ASC, s.order_date ASC) customer;       
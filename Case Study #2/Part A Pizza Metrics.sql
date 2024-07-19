CREATE SCHEMA pizza_runner;
USE pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
 
 -- Clean the Data
 -- (I) substituting the 'null' string and blank space with NULL in extras column in customer_orders
 UPDATE customer_orders
 SET extras = NULL
 WHERE extras = 'null' OR extras = '';
 
UPDATE customer_orders
SET exclusions = NULL
WHERE exclusions IN ('null','');
 
 -- (II) trimming km and any space from distance column in runner_orders table
 UPDATE runner_orders
 SET distance = TRIM(REPLACE(distance, 'km',''));
 
 UPDATE runner_orders
 SET distance = NULL
 WHERE distance = 'null';
 
 -- (III) substituting the 'null' string and blank space with NULL in cancellation column of runner_orders 
UPDATE runner_orders
SET cancellation = NULL
WHERE cancellation IN ('null','');

UPDATE runner_orders
SET duration = NULL
WHERE duration = 'null';

UPDATE runner_orders
SET pickup_time = NULL
WHERE pickup_time = 'null';

-- (IV) remove strings and null from duration column in runner_orders
UPDATE runner_orders
SET duration = REGEXP_REPLACE(duration, '[^0-9]', '')
WHERE duration IS NOT NULL;

-- (V) change datatype of distance and duration column
ALTER TABLE runner_orders
MODIFY COLUMN distance FLOAT;

ALTER TABLE runner_orders
MODIFY COLUMN duration INT;

-- (VI) check the type of columns in the table
describe runner_orders;
describe customer_orders;
describe pizza_names;
describe pizza_recipes;
describe pizza_toppings;
 
 
-- A. Pizza Metrics
-- 1. How many pizzas were ordered?
  SELECT COUNT(*) AS pizza_ordered
  FROM customer_orders;
  
-- 2. How many unique customer orders were made?
  SELECT COUNT(DISTINCT order_id) AS unique_orders
  FROM customer_orders;
  
-- 3. How many successful orders were delivered by each runner?
  SELECT runner_id, COUNT(order_id) AS success_order
  FROM runner_orders 
  WHERE cancellation IS NULL
  GROUP BY runner_id;
  
-- 4. How many of each type of pizza was delivered?
  SELECT c.pizza_id, COUNT(c.pizza_id) as total
  FROM customer_orders c
  JOIN runner_orders r ON c.order_id = r.order_id
  WHERE r.cancellation IS NULL
  GROUP BY c.pizza_id;
  
-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
  SELECT c.customer_id, p.pizza_name, COUNT(c.pizza_id) total_ordered
  FROM customer_orders c
  JOIN pizza_names p ON c.pizza_id = p.pizza_id
  GROUP BY c.customer_id, p.pizza_name
  ORDER BY c.customer_id ASC;
  
-- 6.What was the maximum number of pizzas delivered in a single order?
  SELECT MAX(total_pizza) AS maxpizza_delivered
  FROM (
    SELECT c.order_id, COUNT(c.pizza_id) total_pizza
    FROM customer_orders c
    JOIN runner_orders r ON c.order_id = r.order_id
    WHERE r.cancellation IS NULL
    GROUP BY c.order_id
    ) AS pizza_delivered;
   
-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT c.customer_id, COUNT(c.pizza_id) AS pizza,
SUM(CASE 
    WHEN c.exclusions IS NOT NULL OR c.extras IS NOT NULL THEN 1 
    ELSE 0
    END) AS atleast_1_change,
SUM(CASE
    WHEN c.exclusions IS NULL AND c.extras IS NULL THEN 1
    ELSE 0
    END) AS no_change
FROM customer_orders c
JOIN runner_orders r ON c.order_id = r.order_id
WHERE r.cancellation IS NULL
GROUP BY c.customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?
SELECT c.customer_id, COUNT(c.pizza_id) AS pizza,
SUM(CASE 
    WHEN c.exclusions IS NOT NULL AND c.extras IS NOT NULL THEN 1 
    ELSE 0
    END) AS both_change
FROM customer_orders c
JOIN runner_orders r ON c.order_id = r.order_id
WHERE r.cancellation IS NULL
GROUP BY c.customer_id;
    
-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT HOUR(order_time) AS order_hour,
COUNT(pizza_id) AS pizza_vol
FROM customer_orders
GROUP BY HOUR(order_time)
ORDER BY HOUR(order_time);

-- 10. What was the volume of orders for each day of the week?
SELECT DAYNAME(order_time) AS order_day,
COUNT(pizza_id) AS pizza_vol
FROM customer_orders
GROUP BY DAYNAME(order_time)
ORDER BY DAYNAME(order_time);
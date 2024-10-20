CREATE DATABASE pizzahut;
USE pizzahut;

-- Creating Table for Orders

CREATE TABLE orders
(
order_id INT NOT NULL,
order_date DATE NOT NULL,
order_time TIME NOT NULL,
PRIMARY KEY(order_id)
);

-- Creating Table for Order_details

CREATE TABLE order_details
(
order_details_id INT NOT NULL,
order_id INT NOT NULL,
pizza_id TEXT NOT NULL,
quantity INT NOT NULL,
PRIMARY KEY(order_details_id)
);



-- Q1. Retrieve the total number of orders placed. 

SELECT COUNT(order_id) AS Total_Orders FROM orders;

-- Q2. Calculate the total revenue generated from pizza sales.

SELECT ROUND(SUM(order_details.quantity * pizzas.price),2) AS Total_Sale
FROM order_details
JOIN pizzas
ON pizzas.pizza_id = order_details.pizza_id;

-- Q3. Identify the highest-priced pizza.

SELECT pizza_types.name, pizzas.price
FROM pizza_types
INNER JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC LIMIT 1;

-- Q4. Identify the most common pizza size ordered.

SELECT pizzas.size, COUNT(order_details.order_details_id) AS Order_COUNT
FROM pizzas
JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size 
ORDER BY Order_Count 
DESC LIMIT 1;

-- Q5. List the top 5 most ordered pizza types along with their quantities.

SELECT pizza_types.name, SUM(order_details.quantity) AS Count
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY count
DESC LIMIT 5; 

-- Q6. Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT pizza_types.category, sum(order_details.quantity) AS Total_Quantity
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY Total_Quantity DESC;

-- Q7. Determine the distribution of orders by hour of the day.

SELECT hour(order_time) AS Hours, count(order_id) AS No_of_orders 
FROM orders
GROUP BY hours;

-- Q8. Join relevant tables to find the category-wise distribution of pizzas.
SELECT pizza_types.category AS Category, count(pizza_types.name) AS Number_of_pizzas
FROM pizza_types
GROUP BY Category;

-- Q9. Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT round(avg(Total_orders),0) AS Avg_orders_per_day 
FROM
(SELECT orders.order_date, sum(order_details.quantity) AS Total_orders
FROM order_details
JOIN orders
ON orders.order_id = order_details.order_id
GROUP BY orders.order_date) AS Orders_qunatity; 

-- Q10. Determine the top 3 most ordered pizza types based on revenue.

SELECT pizza_types.name,
SUM(order_details.quantity * pizzas.price) AS Revenue
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY Revenue DESC LIMIT 3;

-- Q11. Calculate the percentage contribution of each pizza type to total revenue.

SELECT pizza_types.category,
ROUND(SUM(order_details.quantity * pizzas.price)/ (SELECT 
ROUND(SUM(order_details.quantity * pizzas.price),2) AS Total_Sale
FROM order_details
JOIN pizzas
ON pizzas.pizza_id = order_details.pizza_id)*100,2) AS Revenue
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY Revenue DESC LIMIT 3;


-- Q12. Analyze the cumulative revenue generated over time.

SELECT order_date,
SUM(Revenue) OVER(ORDER BY order_date) AS Cum_revenue
FROM 
(SELECT orders.order_date,
SUM(order_details.quantity * pizzas.price) AS Revenue
FROM order_details
JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id
JOIN orders
ON orders.order_id = order_details.order_id
GROUP BY orders.order_date) AS Sales;


-- Q13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT name,category, revenue FROM 
(SELECT category,name, revenue, 
rank() over(partition by category order by revenue) as rn
FROM
(SELECT pizza_types.category, pizza_types.name,
SUM(order_details.quantity * pizzas.price) AS Revenue
FROM pizza_types
JOIN pizzas
ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category, pizza_types.name) as A) as B
WHERE rn<=3;

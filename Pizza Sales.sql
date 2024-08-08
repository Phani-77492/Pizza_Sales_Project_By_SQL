	select * from dbo.pizza_types
	select * from dbo.pizzas
	select * from dbo.order_details
	select * from dbo.orders

--Retrieve the total number of orders placed

	select COUNT(order_id) Total_Orders from dbo.orders

--Calculate the total revenue generated from pizza sales

	select round(sum(order_details.quantity * pizzas.price),2) Total_Sales from dbo.order_details
	join dbo.pizzas
	on order_details.pizza_id = pizzas.pizza_id

--Identify the highest_priced Pizza

	with my_cte
	as (
	select pizza_types.name, round(pizzas.price,2) Pizza_Price from pizza_types
	join pizzas
	on pizza_types.pizza_type_id = pizzas.pizza_type_id
	)
	select top 1 * from my_cte
	order by Pizza_Price desc

--Identify the most common pizza size ordered
	
	with Cte_2
	as (
	select pizzas.size, count(quantity) Total_Quantity from order_details
	join pizzas
	on order_details.pizza_id = pizzas.pizza_id
	group by pizzas.size
	)
	select * from Cte_2
	order by Total_Quantity desc


	select pizzas.size, count(quantity) Total_Quantity from order_details
	join pizzas
	on order_details.pizza_id = pizzas.pizza_id
	group by pizzas.size

--List the top 5 most ordered pizza types along with their quantities

	select * from pizza_types
	select * from pizzas
	select * from order_details

	select top 5 pizza_types.name, sum(order_details.quantity) Total_Orders from pizza_types
	join pizzas on
	pizza_types.pizza_type_id = pizzas.pizza_type_id
	join order_details on
	pizzas.pizza_id = order_details.pizza_id
	group by pizza_types.name
	order by Total_Orders desc

--Join the necessary tables to find the total quantity of each pizza category ordered

	select pizza_types.category, sum(order_details.quantity) Order_Count from pizza_types
	join pizzas on
	pizzas.pizza_type_id = pizza_types.pizza_type_id
	join order_details on
	order_details.pizza_id = pizzas.pizza_id
	group by pizza_types.category
	order by Order_Count desc

--Determine the distribution of orders by hour of the day

	select DATEPART(hour, time) Hour, COUNT(order_id) Order_Count from orders
	group by DATEPART(hour, time)
	order by Hour asc

--Join relevant tables to find the category wise distribution of pizzas
	
	select category, COUNT(name) from  pizza_types
	group by category

--Group the orders by date and calculate the average number of pizzas ordered per day
	
	select  date ,sum(order_id) from orders
	group by date

--Determine the top 3 most ordered pizza types based on revenue
	
	select * from order_details
	select * from orders
	select * from pizza_types
	select * from pizzas

	select  top 3 pizza_types.name, sum(quantity * price) Total_Sales from order_details
	join pizzas on
	order_details.pizza_id = pizzas.pizza_id
	join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
	group by pizza_types.name
	order by Total_Sales desc

--Calculate the percentage contribution of each pizza type to total revenue
	
	select pizza_types.category, round((SUM(quantity * price)) / (select round(sum(order_details.quantity * pizzas.price),2) Total_Sales 
	from dbo.order_details
	join dbo.pizzas
	on order_details.pizza_id = pizzas.pizza_id)*100,2)
	Revenue from order_details
	join pizzas pizzas on
	order_details.pizza_id = pizzas.pizza_id
	join pizza_types on
	pizza_types.pizza_type_id = pizzas.pizza_type_id
	group by pizza_types.category
	order by Revenue desc

--Analyse the cumulative revenue generated over the time

	select orders.date, sum(order_details.quantity * pizzas.price) as Revenue from order_details
	join pizzas on pizzas.pizza_id = order_details.pizza_id
	join orders on orders.order_id = order_details.order_id
	group by orders.date
	
	select Month, SUM(revenue) over (order by month) Cum_Revenue from
		(select datename(month,orders.date) [Month], sum(order_details.quantity * pizzas.price) as Revenue from order_details
		join pizzas on pizzas.pizza_id = order_details.pizza_id
		join orders on orders.order_id = order_details.order_id
		group by datename(month,orders.date)) sales

--Determine the top 3 most ordered pizzas based on revenue for each pizza category
		
	select category, name, revenue, rnk from
		(select category, name, Revenue,
		RANK() over(partition by category order by revenue) rnk
		from
		(select pizza_types.category, name, sum(order_details.quantity * pizzas.price) Revenue from pizza_types
		join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id 
		join order_details on order_details.pizza_id = pizzas.pizza_id
		group by pizza_types.category, name) A) B
	where rnk <= 3


drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup
(userid integer,
gold_signup_date date); 

INSERT INTO goldusers_signup
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

drop table if exists users;
CREATE TABLE users
(userid integer,
signup_date date); 

INSERT INTO users
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

drop table if exists sales;
CREATE TABLE sales
(userid integer,
created_date date,
product_id integer); 

INSERT INTO sales 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);


drop table if exists product;
CREATE TABLE product
(product_id integer,
product_name text,
price integer);

INSERT INTO product
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

1.What is the total amount each customer spent on Zomato?

select a.userid, sum(b.price) as total_amt_spent
from sales a
join product b
on a.product_id=b.product_id
group by a.userid

2.How many days has each customer visited Zomato?

select userid, count(distinct created_date)
from sales
group by userid

3.What was the first product purchased by each customer ?

select a.*
from
	(select *, 
	rank()over(partition by userid order by created_date) rnk
	from sales) a
where a.rnk = 1

4.what is the most purchased item on the menu and how many times was it purchased by all customer?

select userid, count(product_id) from sales where product_id =
	(select top 1 product_id
	from sales
	group by product_id
	order by count(product_id) desc)
group by userid

5.which item was the most popular for each customer?

select * from 
	(
	select *, rank () over(partition by userid order by cnt desc) as rnk
	from
		(select userid, product_id, count(product_id) as cnt
		from sales
		group by userid, product_id) a 
	) b
where rnk = 1

6.which item was purchased first by the customer after they became a member?
--select * from sales;
--select * from goldusers_signup;
select * from
	(
	select *, rank () over(partition by userid order by created_date) as rnk
	from
		(select a.userid, a.created_date, a.product_id, b.gold_signup_date
		from sales a
		inner join goldusers_signup b
		on a.userid = b.userid
		and created_date >= gold_signup_date) a 
	) b
where rnk = 1

7.which item was purchased just before the customer became a member?

select * from
	(
	select *, rank () over(partition by userid order by created_date desc) as rnk
	from
		(select a.userid, a.created_date, a.product_id, b.gold_signup_date
		from sales a
		inner join goldusers_signup b
		on a.userid = b.userid
		and created_date <= gold_signup_date) a 
	) b
where rnk = 1

8.what is the total orders and amount spent for each member before they became a member?
--select * from product;
select userid, count(created_date) as total_orders, sum(price) as amount
from
	(
	select c.*, d.price from
		(select a.userid, a.created_date, a.product_id, b.gold_signup_date
				from sales a
				inner join goldusers_signup b
				on a.userid = b.userid
				and created_date <= gold_signup_date ) c
		join product d
		on c.product_id = d.product_id
	) d
group by userid

9.calculate points collected by customer :product 1 = 5p, product 2 = 5p, product = 1

--select * from sales;
--select * from product;
 with RNK as
(
	 select product_id, sum(total_points) as total_point_earned from
	 (
		select e.*, amount/points as total_points
		from
			(
			select d.*, 
			case when product_id = 1 then 5
				 when product_id = 2 then 2
				 when product_id = 3 then 5
				 else 0 
			end as points 
			from
				(select c.userid, c.product_id, sum(c.price) as amount 
				from
					(select a.userid, a.product_id, b.price 
					from sales a join product b on a.product_id =b.product_id) c
				group by c.userid, c.product_id
				) d 
			) e
	 ) f
 group by product_id 
),
--and which product most points have been given till now

PRODUCT_MOST_POINT as
(
 select *, rank () over(order by total_point_earned desc) as rnk
 from RNK
)

select * from PRODUCT_MOST_POINT
where rnk = 1

11. rnk all the transaction of the customer

select *, rank () over (partition by userid order by created_date) as rnk
from sales

12.rnk all the transaction for each member whenever they are zomato gold member for every one non gold
member transaction for mark as NA

with RNK as
(
select a.userid, a.created_date, a.product_id, b.gold_signup_date
		from sales a
		left join goldusers_signup b
		on a.userid = b.userid
		and created_date >= gold_signup_date
),

NA as

(select *, cast((case when gold_signup_date is null then 0
		  else rank () over (partition by userid order by created_date desc)
		  end) as varchar)
		  as rnk
from RNK )

select *, case when rnk = 0 then 'NA'
		  else rnk 
		  end
from NA
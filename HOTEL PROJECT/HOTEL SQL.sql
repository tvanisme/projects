with Hotels as
(
select * from dbo.[2018]
union
select * from dbo.[2019]
union
select * from dbo.[2020]
)

select *
from Hotels a
left join dbo.market_segment b
on a.market_segment = b.market_segment
left join dbo.meal_cost c
on a.meal = c.meal


select arrival_date_year, hotel,
round(sum((stays_in_weekend_nights + stays_in_week_nights)*adr),2) as revenue
from Hotels
group by arrival_date_year, hotel


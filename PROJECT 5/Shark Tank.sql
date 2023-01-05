select * from data

--total episodes

select count(distinct epno) from data
select max(epno) from data

--total brand

select count(distinct brand) from data

--brand converted

select cast(sum(a.converted_not_converted) as float)/cast(count(*) as float) 
from
(select amountinvestedlakhs, 
	case when amountinvestedlakhs > 0 then 1 else 0
	end
	as converted_not_converted
from data) a

--total male

select sum(male) from data

--total female

select sum(female) from data

--gender ratio

select sum(female)/sum(male) from data

--total amount invested

select sum(amountinvestedlakhs) from data

--avg equity taken

select avg(a.equitytakenp) from
(select equitytakenp from data
where equitytakenp > 0) a

--highest deal taken

select max(amountinvestedlakhs) from data

--highest equity taken

select max(equitytakenp) from data

--startups having at least a woman

select sum(a.female_count)
  from
(select female, 
	case when female > 0 then 1 else 0 
	end
	as female_count
from data) a

-- 

--select * from data
select sum(b.female_count) 
from
(select 
	case when a.female > 0 then 1 else 0 end
	as female_count, a.*
from 
(select * from data 
where deal != 'No Deal') a ) b

--avg team members

select avg(teammembers) from data

--avg amount invested per deal

select avg(a.amountinvestedlakhs) as amount_invested_per_deal
from
(select * from data 
where deal != 'No Deal') a 

--avg age group of contestants

select avgage, count(avgage) from data
group by avgage
order by 2 desc 

--location group of contestants

select location, count(location) from data
group by location
order by 2 desc 

--sector group of contestants

select sector, count(sector) from data
group by sector
order by 2 desc 

--partner deal

select partners, count(partners) from data
where partners != '-'
group by partners
order by 2 desc

--making the matrix

select 'Ashnee' as keyy, count(ashneeramountinvested) from data
where ashneeramountinvested is not null

select 'Ashnee'as keyy, count(ashneeramountinvested) from data
where ashneeramountinvested is not null and ashneeramountinvested !=0

select 'Ashnee'as keyy, sum(c.ashneeramountinvested), avg(c.ashneerequitytakenp)
from
(select * from data
where ashneeramountinvested is not null
and ashneeramountinvested != 0) c

--
select
	m.keyy, 
	m.total_deals_present,
	m.total_deals, 
	n.total_amount_invested,
	n.avg_equity_taken
from
	(
	select 
		a.keyy, 
		a.total_deals_present, 
		b.total_deals
	from
		(
		select 'Ashnee' as keyy, count(ashneeramountinvested) as total_deals_present from data
		where ashneeramountinvested is not null
		) a
		inner join
		(
		select 'Ashnee'as keyy, count(ashneeramountinvested) as total_deals from data
		where ashneeramountinvested is not null and ashneeramountinvested !=0
		) b	on a.keyy = b.keyy
	) m

	inner join

	(
		select 
			'Ashnee'as keyy, 
			sum(c.ashneeramountinvested) as total_amount_invested,
			avg(c.ashneerequitytakenp) as avg_equity_taken
		from
		(
			select * from data
			where ashneeramountinvested is not null
			and ashneeramountinvested != 0
		) c 
	) n on m.keyy = n.keyy
--which is the startup in which the highest amount has been invested in each domain/sector

select a.* 
from
(select brand, amountinvestedlakhs, sector,
rank() over(partition by sector order by amountinvestedlakhs desc) rnk
from data) a
where rnk =1
------------

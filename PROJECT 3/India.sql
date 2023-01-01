select * from data1
select * from data2

--number of rows into our data
select count(*) from data1
select count(*) from data2

--dataset for jharkhand and bihar
select * from data1
where state in ('jharkhand','bihar')

--population of India
select sum(population) as Population from data2

--avg growth 
select state, avg(growth)*100 as avg_growth from data1
group by state

--avg sex ratio
select state, round(avg(sex_ratio),0) as avg_sex_ratio from data1
group by state
order by 2 desc

--avg literacy rate
select state, round(avg(literacy),0) as avg_literacy from data1
group by state
having round(avg(literacy),0)>90
order by 2 desc

-- top 3 state showing highest growth ratio
select top 3 state, avg(growth)*100 as avg_growth from data1
group by state
order by 2 desc

--bottom 3 state showing lowest sex ratio
select top 3 state, round(avg(sex_ratio),0) as avg_sex_ratio from data1
group by state
order by 2 asc

-- top and bottom 3 states in literacy state
drop table if exists #topstate
create table #topstate
(
state nvarchar (200),
topstate float)

insert into #topstate
select state, round(avg(literacy),0) from data1
group by state

select top 3 * from #topstate
order by 2 desc

drop table if exists #bottomstate
create table #bottomstate
(
state nvarchar (200),
bottomstate float)

insert into #bottomstate
select state, round(avg(literacy),0) from data1
group by state

select top 3 * from #bottomstate
order by 2 asc

--Use Union

select * from (select top 3 * from #topstate
order by 2 desc) a

union 

select * from (select top 3 * from #bottomstate
order by 2 asc) b

-- State starting with letter a 

select distinct state from data1
where state like 'a%'

-- Joining both table 
---Total Male vs Female

--CTE
with GENDER as
( select a.district, a.state, a.sex_ratio/1000 as sex_ratio, b.population 
from data1 a
inner join data2 b
on a.district = b.district
),

TOTAL_GENDER as
(
select district,state, round(population/(sex_ratio+1),0) as males,
		round((population*sex_ratio)/(sex_ratio+1),0) as female
from GENDER 
)
select state, sum(males) as Total_Males, sum(female) as Total_Females
from TOTAL_GENDER
group by state

---Total literacy rate

with LITERACY as
(
select a.district, a.state, a.literacy/100 as literacy_ratio, b.population
from data1 a
inner join data2 b
on a.district = b.district
),

TOTAL_LITERACY_ILLITERACY as
(
select district, state, round(literacy_ratio*population,0) as literate_people,
round(population*(1-literacy_ratio),0) as illiterate_people
from LITERACY 
)
select state, sum(literate_people) as Total_literate_people,
			  sum(illiterate_people) as Total_illiterate_people
from TOTAL_LITERACY_ILLITERACY
group by state 

--population previous census

with POPULATION_CENSUS as
(select a.district, a.state, a.growth, round(b.population/(1+a.growth),0) as previous_census_population,
b.population as current_census_population 
from data1 a
inner join data2 b
on a.district = b.district
),

TOTAL_CURRENT_POPULATION as
(
select state, sum(previous_census_population) as previous_census_population ,
sum(current_census_population) as current_census_population
from POPULATION_CENSUS
group by state
)
select sum(previous_census_population) previous_census_population,
sum(current_census_population) as current_census_population
from TOTAL_CURRENT_POPULATION


--population vs area 

---population

with POPULATION_CENSUS as
(select a.district, a.state, a.growth, round(b.population/(1+a.growth),0) as previous_census_population,
b.population as current_census_population 
from data1 a
inner join data2 b
on a.district = b.district
),

TOTAL_CURRENT_POPULATION as
(
select state, sum(previous_census_population) as previous_census_population ,
sum(current_census_population) as current_census_population
from POPULATION_CENSUS
group by state
)
select sum(previous_census_population) previous_census_population,
sum(current_census_population) as current_census_population
from TOTAL_CURRENT_POPULATION

---area 

select as keyy ,sum(area_km2) as total_area
from data2

--output top 3 district from each state with highest literacy rate

with RNK as
(
select district, state, literacy, 
		rank()over(partition by state order by literacy desc) as rnk 
from data1
)
select district, state, literacy,rnk
from RNK
where rnk in (1,2,3)
order by state


create database PortfolioProject
select * from CovidDeath
where continent is not null
order by 3,4

select * from CovidVaccine
order by 3,4

--Select Data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from CovidDeath
order by 1,2

--Looking at Total_cases, total_deaths
--Shows likelihood of dying if you contract covid in United States
select location, date, total_cases, total_deaths , (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeath
where location like '%states%'
order by 1,2

--Looking at Total_cases, population
--Shows what percentage of population got Covid
select location, date, total_cases, population , (total_cases/population)*100 as PercentPopulation
from CovidDeath
order by 1,2

--Looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount ,
max((total_cases/population))*100 as PercentPopulationInfected
from CovidDeath
group by location, population
order by PercentPopulationInfected desc

--Showing location with highest death count per population
select top 10 location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeath
where continent is not null
group by location
order by TotalDeathCount desc

--Showing continents with the highest death count 
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeath
where continent is not null
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
select sum(new_cases) as Totalnewcases, sum(cast(new_deaths as int)) as TotalnewDeath,
sum(cast(new_deaths as int))/sum(new_cases)*100 as NewDeathpercentage
from CovidDeath
where continent is not null
order by 1,2

--Looking at Total population vs Vaccinations
select a.location, a.continent, a.date, a.population, b.new_vaccinations,
sum(cast(b.new_vaccinations as bigint)) over ( partition by a.location order by a.location,a.date) as RollingPeopleVaccinated
from CovidDeath as a
join CovidVaccine as b
on a.location = b.location
and a.date = b.date
where a.continent is not null
order by 1,3

--USE CTE
With PopvsVac as
(select a.location, a.continent, a.date, a.population, b.new_vaccinations,
sum(cast(b.new_vaccinations as bigint)) over ( partition by a.location order by a.location,a.date) as RollingPeopleVaccinated
from CovidDeath as a
join CovidVaccine as b
on a.location = b.location
and a.date = b.date
where a.continent is not null
)

select location, continent, date, population, new_vaccinations, RollingPeopleVaccinated,
(RollingPeopleVaccinated/population)*100 as PercentPopVac
from PopvsVac

-- TEMP TABLE
drop table if exists #PercentPopVac
create table #PercentPopVac
(location varchar (50),
continent varchar (50),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into #PercentPopVac
select a.location, a.continent, a.date, a.population, b.new_vaccinations,
sum(cast(b.new_vaccinations as bigint)) over ( partition by a.location order by a.location,a.date) as RollingPeopleVaccinated
from CovidDeath as a
join CovidVaccine as b
on a.location = b.location
and a.date = b.date
where a.continent is not null

select location, continent, date, population, new_vaccinations, RollingPeopleVaccinated,
(RollingPeopleVaccinated/population)*100 as PercentPopVac
from #PercentPopVac


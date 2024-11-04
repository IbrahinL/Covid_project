select * 
from potfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--select * 
--from potfolioProject..CovidVaccination$
--order by 3,4

--select data that we atr going to be using
select location, date, total_cases, new_cases, total_deaths, population
from potfolioProject..CovidDeaths$
order by 1,2

-- Looking at total cases v total deaths
-- showing tha likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as percentagedeath
from potfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

-- looking at total cases v population
-- Shows what percentage of population got Covid
select location, date, population, total_cases, (total_cases/population) * 100 as percentcases
from potfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

--looking at countries with Highest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCounct, MAX((total_cases/population))*100 as populationinfectedpercentage
from potfolioProject..CovidDeaths$
-- where location like '%state%'
group by location, population
order by populationinfectedpercentage desc

-- showing countries with highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from potfolioProject..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc

-- Lets break it down by continent

-- showing continents with the highest deaths count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from potfolioProject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc


-- gobal numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast
  (new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From potfolioProject..CovidDeaths$
where continent is not null
--Group By date
order by 1,2


-- Looking at total population vs Vaccinations
-- Use CTE
with Pop_vs_vac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date)
as Rolling_People_Vaccinated
from potfolioProject..CovidDeaths$ dea
join potfolioProject..CovidVaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100
from Pop_vs_vac



-- the bottom 4 queries is what I used for the data visualization for "Covid_project"

--1)
-- gobal numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast
  (new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From potfolioProject..CovidDeaths$
where continent is not null
--Group By date
order by 1,2

--2)
-- we take these out as they are not included in the above queries
-- and want to stay consistent
-- European Union is part of Europe
-- I Excluded High-income countries, Upper-middle-income-countries, European union (27)
-- Lower-middle-income-countries, and Low-income countries

select location, SUM(cast(new_deaths as int)) as TotalDeathCount
from potfolioProject..CovidDeaths$
where continent is null
and location not in ('World', 'European Union', 'International')
Group by location
Order by TotalDeathCount desc
--3)
--looking at countries with Highest infection rate compared to population

select location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as population_infected_percentage
from potfolioProject..CovidDeaths$
group by location, population
order by population_infected_percentage desc

--4
select location, population,date, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Percentage_Population_Infected
from potfolioProject..CovidDeaths$
group by location, population, date
order by Percentage_Population_Infected desc
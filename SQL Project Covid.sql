
Select location, date, total_cases, new_cases, total_deaths, population
From Project.dbo.CovidDeaths
Order by 1,2

-- Looking at total cases vs total deaths
-- Likelihood of dying if you contract Covid in 2021 on Colombia.
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
From Project.dbo.CovidDeaths
Where location like '%colombia%'
Where continent is not null
Order by 1,2

-- Looking at total cases vs Population
-- Showa what percentage of population got Covid
Select location, date, total_cases, population, (total_cases/population)*100 as Cases_percentage
From Project.dbo.CovidDeaths
Where location like '%colombia%'
Where continent is not null
Order by 1,2

-- Looking at countries with highest infection rate compared to population
Select location, population, max(total_cases) as Highest_Infection, 
Max((total_cases/population))*100 as Infected_percentage
From Project.dbo.CovidDeaths
Where continent is not null
Group by location, population
Order by Infected_percentage desc

-- Looking at countries with highest death count
Select location,max(cast(total_deaths as int)) as Death_Count
From Project.dbo.CovidDeaths
Where continent is not null
Group by location
Order by Death_Count desc


-- BY CONTINENT

-- Looking at continents the death count
Create view DeathCount_Continent as
Select location,max(cast(total_deaths as int)) as Death_Count
From Project.dbo.CovidDeaths
Where continent is null
Group by location
Order by Death_Count desc

-- Showing continents by highest infection
Create view InfectedPercetage_continent as
Select location, population, max(total_cases) as Highest_Infection, 
Max((total_cases/population))*100 as Infected_percentage
From Project.dbo.CovidDeaths
Where continent is null
Group by location, population
--Order by Infected_percentage desc

-- Global Numbers
Create view DeathPercetage_Global as
Select date, SUM(new_cases) as Total_cases,SUM(cast(new_deaths as int)) as Total_deaths,
(SUM(cast(new_deaths as int))/ SUM(new_cases))*100 as Death_Percentage
From Project..CovidDeaths
Where continent is not null
Group By date
--Order by 1,2

-- Total Population vs Vaccinations
With CTE_RollingPeopleVaccinated (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated) as
(
Select deat.continent, deat.location, deat.date, deat.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) Over (Partition by deat.location order by deat.location,
	deat.date) as RollingPeopleVaccinated
From Project..CovidDeaths as deat
Join Project..CovidVaccinations as vac
	On deat.location = vac.location
	and deat.date = vac.date
Where deat.continent is not null
)

Select*, (RollingPeopleVaccinated/Population)*100
From CTE_RollingPeopleVaccinated

-- Creating view to store data
Create View PeopleVaccinated as
Select deat.continent, deat.location, deat.date, deat.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) Over (Partition by deat.location order by deat.location,
	deat.date) as RollingPeopleVaccinated
From Project..CovidDeaths as deat
Join Project..CovidVaccinations as vac
	On deat.location = vac.location
	and deat.date = vac.date
Where deat.continent is not null

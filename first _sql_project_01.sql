--looking at total deaths vs total cases
--shows the likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
FROM CovidDeaths$
where location like '%states%'
ORDER BY 1,2

--looking at total cases vs population
--shows the percentage of the population that has covid 
SELECT location, date, population, total_cases, (total_cases/population)*100 as Cases_Percentage
FROM [PORTFOLIO PROJECT]..CovidDeaths$
WHERE location like '%states&'
ORDER BY 1,2

SELECT *
FROM CovidDeaths$

--looking at countries with highest infection rates as compared to the population

SELECT location, population, max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationAffected
FROM CovidDeaths$
--WHERE location like '%states&'
GROUP BY location, population
ORDER BY PercentPopulationAffected desc



--This is showing the countries with the highest death count per population

SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths$
--WHERE location like '%states&'
WHERE continent is not null
GROUP BY location, population
ORDER BY TotalDeathCount desc




--lets break things down by continent
--CORRECT SYNTAX COPY AND AMEND IN ALL PREVIOUS CODES IE ADD CONTINENT/LOCATION IN THE SELECT CLAUSE
--add continent to select and groupby

SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths$
--WHERE location like '%states&'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc


--Showing the continents with the highest death count
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths$
--WHERE location like '%states&'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--global numbers
SELECT date, sum(new_cases), sum(cast(new_deaths as int)), sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
FROM CovidDeaths$
WHERE continent is not null
group by date
order by 1,2

SELECT sum(new_cases), sum(cast(new_deaths as int)), sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
FROM CovidDeaths$
WHERE continent is not null
--group by date
order by 1,2 


--looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as rollingCountVacc
FROM CovidDeaths$ AS dea
JOIN CovidVaccinations$  AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

--USE CTE
WITH PopvsVac (continent, location, date, population, New_vaccinations, rollingCountvacc)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as rollingCountVacc
FROM CovidDeaths$ AS dea
JOIN CovidVaccinations$  AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT *, (rollingCountVacc/population)*100
from PopvsVac


--Temptable


create table #percentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar (255),
Date datetime,
population numeric,
New_vaccinations numeric, 
RollingCountVacc numeric 
)

DROP TABLE IF EXISTS #percentPopulationVaccinated
insert into #percentPopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as rollingCountVacc
FROM CovidDeaths$ AS dea
JOIN CovidVaccinations$  AS vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent is not null
--order by 2,3

SELECT *, (rollingCountVacc/population)*100
from #percentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALISATIONS
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as rollingCountVacc
FROM CovidDeaths$ AS dea
JOIN CovidVaccinations$  AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3


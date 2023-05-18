SELECT location, date, Total_cases, New_cases, total_deaths, Population
FROM CovidDeaths$
ORDER BY 1, 2


--Looking at the total cases vs Total deaths In Nigeria
--Shows the likelihood of an infected person dying of covid in Nigeria

SELECT location, date, total_cases, total_deaths, (total_deaths/ total_cases)*100 as DeathPercentage
FROM CovidDeaths$
WHERE location like '%nigeria%'
ORDER BY 1, 2


--Looking at the total cases vs the poupulation
--Shows what percentage of the population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as InfectionRate
FROM CovidDeaths$
WHERE location like '%nigeria%'
ORDER BY 1, 2



--Looking at countries with highest infection rate compared to population

SELECT location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths$
WHERE location is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


--Showing countries with highest death count per population
SELECT location, population, max(cast(total_deaths as int)) as TotalDeathCount, max((total_deaths/population))*100 as PercentPopulationDeath
FROM CovidDeaths$
WHERE location is not null
GROUP BY location, population
ORDER BY PercentPopulationDeath desc



--Showing continents with the highest death count

SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount, max((total_deaths/population))*100 as PercentPopulationDeath
FROM CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY PercentPopulationDeath desc


--Global Numbers

SELECT date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)), SUM(cast(new_deaths as int))/sum(new_cases)*100 as deathercentage
FROM CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT sum(new_cases) as total_cases, sum(cast(new_deaths as int)), SUM(cast(new_deaths as int))/sum(new_cases)*100 as deathercentage
FROM CovidDeaths$
--WHERE continent is not null
--GROUP BY date
ORDER BY 1,2



--Looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date)
 as RollingPeopleVaccinated
FROM CovidDeaths$ AS Dea
JOIN CovidVaccinations$ as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths$ AS Dea
JOIN CovidVaccinations$ as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT*, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths$ AS Dea
JOIN CovidVaccinations$ as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *,(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths$ AS Dea
JOIN CovidVaccinations$ as vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null

SELECT *,(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR VISUALISATION LATER

CREATE VIEW PercentPopulationVaccinated2 as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths$ AS Dea
JOIN CovidVaccinations$ as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated2
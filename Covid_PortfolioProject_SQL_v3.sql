SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent is not NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

-- Select Data that we are using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
WHERE continent is not NULL
ORDER BY 1,2

-- Looking at the total cases vs total deaths, shows likelihood of dying from covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%states%' AND continent is not null
ORDER BY 1,2

-- Looking at total cases vs population, shows percentage of people who got covid

SELECT location, date, total_cases, total_deaths, (total_cases/population)*100 AS CasePercentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Looking at countries with highest death count per population

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- BY CONTINENTS
-- Looking at continents with highest death count per population

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) as total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
-- WHERE location like '%states%' AND 
WHERE continent is not null
-- GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CAST(v.new_vaccinations as INT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ d
JOIN PortfolioProject..CovidVaccinations$ v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE

WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CAST(v.new_vaccinations as INT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ d
JOIN PortfolioProject..CovidVaccinations$ v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL
-- ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population) * 100 as RollingVaccinationPercent
FROM PopVsVac


-- USING TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CAST(v.new_vaccinations as INT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ d
JOIN PortfolioProject..CovidVaccinations$ v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL
-- ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population) * 100 as RollingVaccinationPercent
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CAST(v.new_vaccinations as INT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ d
JOIN PortfolioProject..CovidVaccinations$ v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL
-- ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated

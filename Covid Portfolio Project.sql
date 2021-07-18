SELECT * 
FROM PortfolioProject..CovidDeaths WHERE continent IS NOT NULL
ORDER BY 3,4

--SQL Data exploration
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Total cases vs total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathRate
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Total cases vs population
SELECT location, date, population, total_cases, (total_cases/population)*100 AS CasesEstimation
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Countries with highest infection rate
SELECT location, population, MAX(total_cases) AS MaxInfectionCount, MAX((total_cases/population))*100 AS PercentInfectionCount
FROM PortfolioProject..CovidDeaths
GROUP BY population, location
ORDER BY PercentInfectionCount DESC


-- Highest Death count per continent
SELECT continent, MAX(CAST(total_deaths AS int)) AS MaxDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY MaxDeathCount DESC


-- Highest Death count per location
SELECT location, MAX(CAST(total_deaths AS int)) AS MaxDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY MaxDeathCount DESC

-- Global numbers
SELECT SUM(new_cases) AS totalcases, SUM(CAST(new_deaths AS int)) AS totaldeaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercent
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- total population vs Covid vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingCountVaccinated
, (RollingCountVaccinated/population)*100 AS VaccinatedPercent
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--use CTE

WITH popvsvac (continent, location, date, Population, new_vaccinations, RollingCountVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingCountVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT * , (RollingCountVaccinated/Population)*100
FROM popvsvac

--TEMP Table
DROP TABLE if exists #PercentPeopleVaccinated
CREATE TABLE #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingCountVaccinated numeric
)
INSERT INTO #PercentPeopleVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingCountVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
SELECT * , (RollingCountVaccinated/Population)*100
FROM #PercentPeopleVaccinated

--Creating view for visualization
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingCountVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
SELECT * FROM PercentPopulationVaccinated
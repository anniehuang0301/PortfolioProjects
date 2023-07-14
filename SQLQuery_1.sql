SELECT *
from portfolio..CovidDeaths
ORDER BY 3,4

SELECT *
FROM portfolio..CovidVaccinations
order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolio..CovidDeaths
order by 1,2

SELECT location, date, total_cases, total_deaths, (cast(total_deaths as float) * 100 / total_cases) AS DeathPercentage
from portfolio..CovidDeaths
where location like '%states%'
order by 1,2

SELECT location, date, total_cases, population, (cast(total_cases as float) * 100 / population) AS PercentPopulationInfected
from portfolio..CovidDeaths
order by 1,2

SELECT location, max(total_cases) as HighestInfectionCount, population, (max(cast(total_cases as float)) / population)*100 AS PercentPopulationInfected
from portfolio..CovidDeaths
Group by location, population
order by PercentPopulationInfected DESC

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
from portfolio..CovidDeaths
WHERE continent IS not NULL
Group by location
order by TotalDeathCount DESC

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
from portfolio..CovidDeaths
WHERE continent IS NULL
Group by location
order by TotalDeathCount DESC

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from portfolio..CovidDeaths
WHERE continent IS not NULL
Group by continent
order by TotalDeathCount DESC

SELECT SUM(cast(new_cases as int)) as total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths as float))/SUM(cast(new_cases as int))*100 as DeathPercentage
FROM portfolio..CovidDeaths
WHERE continent is not NULL
ORDER by 1,2

WITH PopvsVac(continent,location,date,population,new_vaccinations, RollingPeopleVaccinated)
AS
(
    SELECT dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM portfolio..CovidDeaths as dea
JOIN portfolio..CovidVaccinations AS vac 
ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent is not NULL
)

SELECT *, (cast(RollingPeopleVaccinated as float)/population)*100
from PopvsVac


DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    continent NVARCHAR(255),
    LOCATION NVARCHAR(255),
    DATE DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
)

INSERT into #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM portfolio..CovidDeaths as dea
JOIN portfolio..CovidVaccinations AS vac 
ON dea.location=vac.location and dea.date=vac.date
--WHERE dea.continent is not NULL

SELECT*, (cast(RollingPeopleVaccinated as float)/population)*100
FROM #PercentPopulationVaccinated


CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM portfolio..CovidDeaths as dea
JOIN portfolio..CovidVaccinations AS vac 
ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent is not NULL

SELECT *
From PercentPopulationVaccinated
------The aim of this project is to analyze the COVID-19 dataset and to later visualize it in Tableau. 
------The link to the visualization is here https://public.tableau.com/app/profile/bt4661/viz/COVID19dashboard_16268484332440/Dashboard1

SELECT * 
FROM covideaths
WHERE continent IS NOT NULL 
order by 1,2;

SELECT location,date, total_cases,new_cases,total_deaths,population FROM covideaths
order by 1,2;

--Looking at total cases vs total deaths
--% of affected people dying from COVID-19
SELECT location,date, total_cases,new_cases,total_deaths, (total_deaths/total_cases)*100 as deathpercentage
FROM covideaths
WHERE location ILIKE '%states%'
order by 1,2;

--Looking at total cases vs population
--Shows what percentage of population got affected by COVID
SELECT location,population,total_cases,(total_cases/population)*100 as percentpopulationinfected
FROM covideaths
order by percentpopulationinfected;

--Looking at countries with highest infection rate vs population
SELECT location,population,MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as percentpopulationinfected
FROM covideaths
GROUP BY location,population
order by PercentPopulationInfected DESC NULLS LAST;

--Showing countries with highest death count per population
SELECT location, MAX(Total_deaths) AS TotalDeathCount
FROM covideaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC NULLS LAST;

--LET'S break things down by continents
--Showing continents with the highest death counts
SELECT continent, MAX(Total_deaths) AS TotalDeathCount
FROM covideaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC NULLS LAST;

SELECT location, MAX(Total_deaths) AS TotalDeathCount
FROM covideaths
WHERE continent IS NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC NULLS LAST;

--Global numbers
SELECT date, SUM(new_cases) AS Total_cases, SUM(new_deaths) AS Total_deaths
FROM covideaths
WHERE continent IS NULL
GROUP BY date
order by 1,2 NULLS LAST;

SELECT SUM(new_cases) AS Total_cases, SUM(new_deaths) AS Total_deaths
, SUM(new_deaths)/SUM(NULLIF(new_cases,0))AS DeathPercentage
FROM covideaths
WHERE continent IS NOT NULL
order by 1,2 NULLS LAST;

--------------Covid vaccinations table
--OVER(PARTITION BY CD.location ORDER BY  CD.location, CD.date) for obtaining rolling count
SELECT CD.location, CD.continent, CD.date, CD.population, CV.new_vaccinations,
SUM(CV.new_vaccinations) OVER(PARTITION BY CD.location ORDER BY  CD.location, CD.date) AS RollingPeopleVaccinated
FROM covideaths AS CD
INNER JOIN covidvaccinations AS CV
ON CD.location=CV.location 
AND CD.date=CV.date
WHERE CD.continent IS  NOT NULL
ORDER BY 1, 2

--Use CTE
SELECT CD.location, CD.continent, CD.date, CD.population, CV.new_vaccinations,
SUM(CV.new_vaccinations) OVER(PARTITION BY CD.location ORDER BY  CD.location, CD.date) AS RollingPeopleVaccinated
FROM covideaths AS CD
INNER JOIN covidvaccinations AS CV
ON CD.location=CV.location 
AND CD.date=CV.date
WHERE CD.continent IS  NOT NULL
ORDER BY 1, 2

WITH PopVsVac(location, continent, date, population, new_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT CD.location, CD.continent, CD.date, CD.population, CV.new_vaccinations,
SUM(CV.new_vaccinations) OVER(PARTITION BY CD.location ORDER BY  CD.location, CD.date) AS RollingPeopleVaccinated
FROM covideaths AS CD
INNER JOIN covidvaccinations AS CV
ON CD.location=CV.location 
AND CD.date=CV.date
WHERE CD.continent IS  NOT NULL
)
SELECT *, (popvsvac.RollingPeopleVaccinated/popvsvac.population) FROM PopVsVac

--TEMP table
DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated(
	Location VARCHAR(100),
	Continent VARCHAR(100),
	Date DATE,
	Population NUMERIC,
	New_vaccinations NUMERIC,
	RollingPeopleVaccinated NUMERIC
)

INSERT INTO  PercentPopulationVaccinated
SELECT CD.location, CD.continent, CAST(CD.date AS DATE), CD.population, CV.new_vaccinations,
SUM(CV.new_vaccinations) OVER(PARTITION BY CD.location ORDER BY  CD.location, CD.date) AS RollingPeopleVaccinated
FROM covideaths AS CD
INNER JOIN covidvaccinations AS CV
ON CD.location=CV.location 
AND CD.date=CV.date
WHERE CD.continent IS  NOT NULL

SELECT *,(PercentPopulationVaccinated.RollingPeopleVaccinated/PercentPopulationVaccinated.population) 
FROM PercentPopulationVaccinated

--Creating VIEWS to store data for later visualization
CREATE VIEW PercentPopVac AS
SELECT CD.location, CD.continent, CAST(CD.date AS DATE), CD.population, CV.new_vaccinations,
SUM(CV.new_vaccinations) OVER(PARTITION BY CD.location ORDER BY  CD.location, CD.date) AS RollingPeopleVaccinated
FROM covideaths AS CD
INNER JOIN covidvaccinations AS CV
ON CD.location=CV.location 
AND CD.date=CV.date
WHERE CD.continent IS NOT NULL

SELECT * FROM PercentPopVac

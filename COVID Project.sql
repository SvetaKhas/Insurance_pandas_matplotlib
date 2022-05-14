---Look at data. Found an issue with data: world, income brackets as well as continents should not have been
---set up as locations. Get rid of those by filering to data where continent is not NULL.
SELECT *
FROM PortfolioProject..['owid-covid-deaths thru 5#11#22$']
WHERE Continent IS NOT NULL
ORDER BY 3,4

SELECT * FROM PortfolioProject..['owid-covid-vaccinations thru 5#$']


-- Select data to be used
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..['owid-covid-deaths thru 5#11#22$']
WHERE Continent IS NOT NULL
ORDER BY 1,2

-- Total cases vs Total deaths
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as "Death Percentage"
FROM PortfolioProject..['owid-covid-deaths thru 5#11#22$']
WHERE Continent IS NOT NULL
ORDER BY 1,2

-- Total cases vs Total deaths
-- Shows likelihood of dying if you get covid in your country
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as "Death Percentage"
FROM PortfolioProject..['owid-covid-deaths thru 5#11#22$']
WHERE location like 'United States' AND Continent IS NOT NULL
ORDER BY 1,2

-- Total cases vs Population. What % of population had covid?
SELECT location, date, total_cases,population, (total_cases/population)*100 as "% of Population Infected"
FROM PortfolioProject..['owid-covid-deaths thru 5#11#22$']
WHERE location like 'United States' AND Continent IS NOT NULL
ORDER BY 1,2

-- Let's see with countries with highest infection rates
SELECT location, max(total_cases) as HighestInfectionCount,population, max((total_cases/population)*100) as "PercentInfected"
FROM PortfolioProject..['owid-covid-deaths thru 5#11#22$']
WHERE Continent IS NOT NULL
GROUP BY population,location
ORDER BY "PercentInfected" DESC

-- Let's see with countries with highest death counts. 
SELECT location, max(cast(total_deaths as int)) as DeathCount
FROM PortfolioProject..['owid-covid-deaths thru 5#11#22$']
WHERE Continent IS NOT NULL
GROUP BY location
ORDER BY DeathCount DESC

-- See continent break down of death count
SELECT continent,  sum(cast(new_deaths as int)) as DeathCount
FROM PortfolioProject..['owid-covid-deaths thru 5#11#22$']
WHERE continent IS NOT NULL 
GROUP BY continent
HAVING sum(cast(total_deaths as int)) IS NOT NULL
ORDER BY 2 DESC 

-- Worldwide numbers
SELECT location, max(total_cases) as TotalCases,max(population) as WorldPopulation, max(cast(total_deaths as int)) as TotaDeaths, max(cast(total_deaths as int))/max(population)*100 as DeathRate
FROM PortfolioProject..['owid-covid-deaths thru 5#11#22$']
WHERE location='World'
GROUP BY location
ORDER BY 1,2


--Join Deaths and Vaccination tables. Add rolling total vaccinations.
SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations
,SUM(CONVERT(BIGINT,vax.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as RollingTotalVaccinations
FROM PortfolioProject..['owid-covid-deaths thru 5#11#22$'] death
JOIN PortfolioProject..['owid-covid-vaccinations thru 5#$'] vax
 ON death.location=vax.location
 AND death.date=vax.date
WHERE death.continent IS NOT NULL 
ORDER BY 2,3


-- USE CTE
WITH Vaxrate (Continent,Location, Date, Population, NewVaccinations,RollingTotalVaccinations)
AS 
(
SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations
,SUM(CONVERT(BIGINT,vax.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as RollingTotalVaccinations
FROM PortfolioProject..['owid-covid-deaths thru 5#11#22$'] death
JOIN PortfolioProject..['owid-covid-vaccinations thru 5#$'] vax
 ON death.location=vax.location
 AND death.date=vax.date
WHERE death.continent IS NOT NULL 
)
SELECT *,RollingTotalVaccinations/Population as RollingVaccinated
FROM VaxRate


-- Temp table to view rolling vaccination rates
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations
,SUM(CONVERT(BIGINT,vax.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as RollingTotalVaccinations
FROM PortfolioProject..['owid-covid-deaths thru 5#11#22$'] death
JOIN PortfolioProject..['owid-covid-vaccinations thru 5#$'] vax
 ON death.location=vax.location
 AND death.date=vax.date
WHERE death.continent IS NOT NULL 


SELECT *, RollingVaccinated/Population as RollingVacinationRate
FROM #PercentPopulationVaccinated

-- Create view to store data for later visualizations
CREATE VIEW PercentPopVaccinated AS
SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations
,SUM(CONVERT(BIGINT,vax.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as RollingTotalVaccinations
FROM PortfolioProject..['owid-covid-deaths thru 5#11#22$'] death
JOIN PortfolioProject..['owid-covid-vaccinations thru 5#$'] vax
 ON death.location=vax.location
 AND death.date=vax.date
WHERE death.continent IS NOT NULL


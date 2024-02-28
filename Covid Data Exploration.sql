SELECT *
From Project1..CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4

--SELECT *
--From Project1..CovidVaccinations
-- WHERE continent is not NULL
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Project1..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2

-- Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
FROM Project1..CovidDeaths
WHERE location like '%Australia%' and continent is not NULL
ORDER BY 1,2


-- Total Cases vs Population

Select location, date, population, total_cases,  (cast(total_cases as float)/cast(population as float))*100 as CasePercentage
FROM Project1..CovidDeaths
-- WHERE location like '%Australia%'
WHERE continent is not NULL
ORDER BY 1,2


-- Countries with highest infection rate in terms of population

Select location, population, MAX(total_cases) as HighestInfectionCount,  (MAX(total_cases)/population)*100 as CasePercentage
FROM Project1..CovidDeaths
-- WHERE location like '%Australia%'
WHERE continent is not NULL
GROUP BY location, population
ORDER BY CasePercentage DESC


-- Countries with the highest death in terms of population

Select location, MAX(cast (total_deaths as int)) as TotalDeathCounts
FROM Project1..CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCounts DESC



-- Continents with death count in terms of population

Select continent, MAX(cast (total_deaths as int)) as TotalDeathCounts
FROM Project1..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCounts DESC


-- GLOBAL Numbers

Select SUM(new_cases) as TotalCases, SUM(new_deaths), SUM(new_deaths)/SUM(new_cases)*100
FROM Project1..CovidDeaths
WHERE continent is not NULL
--GROUP BY date
ORDER BY 1,2


-- Total Population vs Vaccination

SELECT de.continent, de.location, de.date, de.population, vc.new_vaccinations, 
SUM(CONVERT (float, vc.new_vaccinations)) OVER(Partition by de.location ORDER BY de.location, de.date) as TotalPeopleVaccinated
FROM Project1..CovidDeaths de
JOIN Project1..CovidVaccinations vc
	ON de.location = vc.location
	AND de.date = vc.date
WHERE de.continent is not NULL
ORDER BY 2,3


-- USING CTE 

WITH PopnVsVac (Continent, location, date, population, new_vaccinations, TotalPeopleVaccinated)
as
(
SELECT de.continent, de.location, de.date, de.population, vc.new_vaccinations, 
SUM(CONVERT (float, vc.new_vaccinations)) OVER(Partition by de.location ORDER BY de.location, de.date) as TotalPeopleVaccinated
FROM Project1..CovidDeaths de
JOIN Project1..CovidVaccinations vc
	ON de.location = vc.location
	AND de.date = vc.date
WHERE de.continent is not NULL
)

SELECT *, (TotalPeopleVaccinated/Population)*100 VaccinationRate
FROM PopnVsVac	


-- Temp Table

DROP TABLE IF exists #VaccinatedPopulationPercent
CREATE TABLE #VaccinatedPopulationPercent
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
TotalPeopleVaccinated numeric
)

INSERT INTO #VaccinatedPopulationPercent
SELECT de.continent, de.location, de.date, de.population, vc.new_vaccinations, 
SUM(CONVERT (float, vc.new_vaccinations)) OVER(Partition by de.location ORDER BY de.location, de.date) as TotalPeopleVaccinated
FROM Project1..CovidDeaths de
JOIN Project1..CovidVaccinations vc
	ON de.location = vc.location
	AND de.date = vc.date
WHERE de.continent is not NULL
ORDER BY 2,3

SELECT *, (TotalPeopleVaccinated/Population)*100 VaccinationRate
FROM #VaccinatedPopulationPercent	
ORDER BY 2,3


-- Creating view

CREATE View VaccinatedPopulationPercent as
SELECT de.continent, de.location, de.date, de.population, vc.new_vaccinations, 
SUM(CONVERT (float, vc.new_vaccinations)) OVER(Partition by de.location ORDER BY de.location, de.date) as TotalPeopleVaccinated
FROM Project1..CovidDeaths de
JOIN Project1..CovidVaccinations vc
	ON de.location = vc.location
	AND de.date = vc.date
WHERE de.continent is not NULL

CREATE VIEW TotalDeathCounts as 
Select location, MAX(cast (total_deaths as int)) as TotalDeathCounts
FROM Project1..CovidDeaths
WHERE continent is not NULL
GROUP BY location


SELECT *
FROM TotalDeathCounts
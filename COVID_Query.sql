
-- Total Cases Vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as 'Death Percentage'
FROM Portfolio_Project..deaths
WHERE location LIKE '%states'
ORDER BY location, date
;

-- Total Cases vs Population

SELECT location, date, total_cases, population, (total_cases/population)* 100 as 'Percentage with Covid'
FROM Portfolio_Project..deaths
WHERE location LIKE '%states'
ORDER BY location, date
;

-- What countries have the highest infection rates?

SELECT location, population, MAX(total_cases) as 'Highest Total Cases', MAX((total_cases/population)* 100) as 'Maximimum Covid Rate'
FROM Portfolio_Project..deaths
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY 'Maximimum Covid Rate' DESC
;

-- Countries with highest death count by population

SELECT location, population, MAX(total_deaths) as 'Total Death Count', MAX((total_deaths/population)* 100) as 'Total Deaths Proportion'
FROM Portfolio_Project..deaths
WHERE continent IS NOT NULL
--WHERE location LIKE %states%
GROUP BY Location, Population
ORDER BY 'Total Deaths Proportion' DESC
;

SELECT continent, MAX(cast(total_deaths as int)) as 'Total Death Count'
FROM Portfolio_Project..deaths
WHERE continent IS NOT NULL
--WHERE location LIKE %states%
GROUP BY continent
ORDER BY 'Total Death Count' DESC
;

--GLOBAL NUMBERS

--Global numbers by date

SELECT date as Date, SUM(new_cases) as 'New Cases', SUM(cast(new_deaths as int)) as 'New Deaths', 
SUM(New_deaths)/SUM(New_Cases) * 100 as 'Death Percentage'--, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM Portfolio_Project..deaths
--WHERE location LIKE %states%
WHERE continent IS NOT NULL
GROUP BY date 
ORDER BY date
;

--Total Global Numbers

SELECT SUM(new_cases) as 'New Cases', SUM(cast(new_deaths as int)) as 'New Deaths', 
SUM(New_deaths)/SUM(New_Cases) * 100 as 'Death Percentage'--, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM Portfolio_Project..deaths
--WHERE location LIKE %states%
WHERE continent IS NOT NULL
;

--Total Population v. Vaccinations

SELECT d.continent, d.location, d.date, d.population, cast(v.new_vaccinations as bigint) as 'New Vaccinations'
, SUM(cast(v.new_vaccinations as bigint)) OVER (Partition by d.Location ORDER BY d.location,
d.date) as 'Rolling Vacc. Count'
FROM Portfolio_Project..deaths as d
JOIN Portfolio_Project..vaccinations as v
	ON d.location = v.location
	AND d.date=v.date
WHERE d.continent IS NOT NULL
ORDER BY d.continent, d.location, d.date
;

-- Use CTE

WITH PopvVac (continent, location, date, population, New_Vacc, Rolling_Vacc_Count) 
as
(
SELECT d.continent, d.location, d.date, d.population, cast(v.new_vaccinations as bigint) as New_Vacc,
SUM(cast(v.new_vaccinations as bigint)) OVER (Partition by d.Location ORDER BY d.location, d.date) as Rolling_Vacc_Count
--,('Rolling_Vacc_Count'/population) * 100 as 'Vacc. Count by Pop.'
FROM Portfolio_Project..deaths as d
JOIN Portfolio_Project..vaccinations as v
	ON d.location = v.location
	AND d.date=v.date
WHERE d.continent IS NOT NULL
--ORDER BY d.continent, d.location
)
SELECT *, (Rolling_Vacc_Count/population) * 100 as 'Rolling Vacc. Pct'
FROM PopvVac
;

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_Vacc_Count numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, cast(v.new_vaccinations as bigint) as New_Vacc,
SUM(cast(v.new_vaccinations as bigint)) OVER (Partition by d.Location ORDER BY d.location, d.date) as Rolling_Vacc_Count
--,('Rolling_Vacc_Count'/population) * 100 as 'Vacc. Count by Pop.'
FROM Portfolio_Project..deaths as d
JOIN Portfolio_Project..vaccinations as v
	ON d.location = v.location
	AND d.date=v.date
WHERE d.continent IS NOT NULL
--ORDER BY d.continent, d.location

SELECT *, (Rolling_Vacc_Count/population)*100 as Rolling_Vacc_Pct
FROM #PercentPopulationVaccinated
;


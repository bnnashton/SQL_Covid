--Total Global Numbers

SELECT SUM(new_cases) as "New Cases", SUM(cast(new_deaths as int)) as "New Deaths", 
SUM(New_deaths)/SUM(New_Cases) * 100 as "Death Percentage"--, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM Portfolio_Project..deaths
--WHERE location LIKE %states%
WHERE continent IS NOT NULL
ORDER BY 1, 2
;

--2.

SELECT Location, SUM(cast(new_deaths as int)) as "Total Death Count"
FROM Portfolio_Project..deaths
--WHERE location LIKE %states%
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY "Total Death Count" DESC
;

--3. 

SELECT Location, Population, MAX(total_cases) as "Highest Infection Count", MAX((total_cases/population)* 100) as "Percent Pop. Infected"
FROM Portfolio_Project..deaths
WHERE continent IS NOT NULL
--WHERE location LIKE %states%
GROUP BY Location, Population
ORDER BY "Percent Pop. Infected" DESC
;

--4.

SELECT Location, Population, Date, MAX(total_cases) as "Highest Total Cases", MAX((total_cases/population)* 100) as "Maximimum Covid Rate"
FROM Portfolio_Project..deaths
WHERE continent IS NOT NULL
GROUP BY Location, Population, date
ORDER BY 'Maximimum Covid Rate' DESC
;
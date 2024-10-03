-- COVID WORLD DATA Till April 2021

SELECT *
 FROM PortfolioProject..CovidDeaths
 Where continent is not null
 ORDER BY 1,2 

 -- Looking at the total cases vs total deaths

 SELECT location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 FROM PortfolioProject..CovidDeaths
 WHERE location like '%nepal%'
 ORDER BY 1,2

 -- Looking at the Total Cases vs Population

 SELECT location,date, total_cases, population, FORMAT((total_cases/population)*100, 'N2')  as PercentageofPopThatGotCovid
 FROM PortfolioProject..CovidDeaths
 WHERE location like '%nepal%'
 ORDER BY 1,2

 -- Looking at Counties with highest death

 SELECT location, MAX(cast(total_deaths as int)) as TotalDeaths
 FROM PortfolioProject..CovidDeaths
 Where continent is not null
 GROUP BY location
 ORDER BY TotalDeaths DESC

 -- Let's break things down by continent

 -- Showing continents with the highest death count per population

 SELECT continent, MAX(cast(total_deaths as int)) as TotalDeaths
	FROM PortfolioProject..CovidDeaths
	Where continent is not null
	GROUP BY continent
 ORDER BY TotalDeaths DESC

 -- Global Numbers (Country Wise)

 SELECT location, SUM(new_cases) as NEW_CASES, SUM(cast(new_deaths as int)) as NEW_DEATHS
 FROM PortfolioProject..CovidDeaths
 --WHERE location like '%states%'
 WHERE continent is not null
 GROUP BY location
 ORDER BY 1,2

 -- Show the country which has the most vaccinated patients

SELECT continent as Continent, MAX(cast(people_fully_vaccinated as decimal)) as TotalVaccinated
 FROM PortfolioProject..CovidVaccination
 WHERE continent is not null
 GROUP BY continent
 ORDER BY TotalVaccinated DESC

 -- Joining Table to compare vaccination with population

 -- Total population VS vaccination

 SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations, SUM(cast(vacs.new_vaccinations AS int)) OVER (Partition BY deaths.location ORDER BY deaths.location, deaths.date) as RollingPeopleVaccinated
  FROM PortfolioProject..CovidDeaths deaths
  JOIN PortfolioProject..CovidVaccination vacs
   ON deaths.date = vacs.date
   AND deaths.location = vacs.location
   WHERE deaths.continent IS NOT NULL
   ORDER BY 2,3

   -- USE CTE

WITH PopsvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
   AS
   (
    SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations, SUM(cast(vacs.new_vaccinations AS int)) OVER (Partition BY deaths.location ORDER BY deaths.location, deaths.date) as RollingPeopleVaccinated
  FROM PortfolioProject..CovidDeaths deaths
  JOIN PortfolioProject..CovidVaccination vacs
   ON deaths.date = vacs.date
   AND deaths.location = vacs.location
   WHERE deaths.continent IS NOT NULL
   )

SELECT *, (RollingPeopleVaccinated/Population)*100
 FROM PopsvsVac
 ORDER BY 2,3

 -- TEMP Table

 DROP TABLE if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 ( 
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

Insert into #PercentPopulationVaccinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations, SUM(cast(vacs.new_vaccinations AS int)) OVER (Partition BY deaths.location ORDER BY deaths.location, deaths.date) as RollingPeopleVaccinated
   FROM PortfolioProject..CovidDeaths deaths
    JOIN PortfolioProject..CovidVaccination vacs
     ON deaths.date = vacs.date
      AND deaths.location = vacs.location
     WHERE deaths.continent IS NOT NULL

SELECT MAX(RollingPeopleVaccinated)
 FROM #PercentPopulationVaccinated

-- Creating VIEW

CREATE VIEW PercentPopulationVaccinated AS
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations, SUM(cast(vacs.new_vaccinations AS int)) OVER (Partition BY deaths.location ORDER BY deaths.location, deaths.date) as RollingPeopleVaccinated
   FROM PortfolioProject..CovidDeaths deaths
    JOIN PortfolioProject..CovidVaccination vacs
     ON deaths.date = vacs.date
      AND deaths.location = vacs.location
     WHERE deaths.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated


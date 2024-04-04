SELECT * FROM PortolioProjet..covidDeaths
ORDER BY 3,4

--SELECT * FROM PortolioProjet..covidVaccination
--ORDER BY 3,4

--SELECT location, date, total_cases, new_cases, total_deaths, population_density
--FROM PortolioProjet..covidDeaths
--ORDER BY 1,2


-- Total case vs total deaths percentage

SELECT location, date, population, total_cases,total_deaths, (CAST(total_deaths AS FLOAT ) /total_cases) * 100 As deathPercentage
FROM PortolioProjet..covidDeaths
WHERE location LIKE '%state%' AND continent IS NOT NULL
ORDER BY 1,2

--Countrises with highest infection rate copare to popualtion

SELECT location, population, Max(total_cases) AS max , Max(total_cases / population ) * 100 As PercentageInfection
FROM PortolioProjet..covidDeaths
GROUP BY location, population
ORDER BY PercentageInfection DESC

-- Countries with highest Death count per population 

SELECT location, population, Max(Cast(total_deaths AS float)) AS total_Deaths,  Max(cast(total_deaths   AS FLOAT)/population )*100 AS PercentageDeath
FROM PortolioProjet..covidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentageDeath DESC

-- BREAKING THINGS DOWN BY CONTINENT
-- continent with highest death count per population

SELECT continent,  Max(Cast(total_deaths AS float)) AS total_Deaths,  Max(cast(total_deaths   AS FLOAT)/population )*100 AS PercentageDeath
FROM PortolioProjet..covidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_Deaths DESC



-- GLOBAL NUMBERS 

SELECT SUM(new_cases) as total_cases, SUM(CAST(total_deaths AS float)) AS total_deaths, SUM(cast(total_deaths AS float))/SUM(new_cases) *100 AS PercentageDeath
FROM PortolioProjet..CovidDeaths 
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2
	
-- Total population vs vaccination 
 
 SELECT  dea.continent, dea.location, dea.date, dea.population, CAST(vac.new_vaccinations AS FLOAT) AS new_vaccinations , SUM(CAST(vac.new_vaccinations AS FLOAT) )
 OVER (PARTITION BY dea.location ORDER BY dea.date) AS rollingPeopleVaccination 
 --, (rollingPeopleVaccination /population)* 100
 FROM PortolioProjet..CovidDeaths AS dea
 JOIN PortolioProjet..CovidVaccinations AS vac
 ON dea.date = vac.date AND dea.location= vac.location
 WHERE dea.continent IS NOT NULL
 ORDER BY 2,3

-- CTE -- Using CTE to perform Calculation on Partition By in previous query
WITH popvsvacc (continent,location,date,population,new_vaccination,rollingPeopleVaccination)
as ( 
SELECT  dea.continent, dea.location, dea.date, dea.population, CAST(vac.new_vaccinations AS FLOAT) AS new_vaccinations , SUM(CAST(vac.new_vaccinations AS FLOAT) )
 OVER (PARTITION BY dea.location ORDER BY dea.date) AS rollingPeopleVaccination 
 --, (rollingPeopleVaccination /population)* 100
 FROM PortolioProjet..CovidDeaths AS dea
 JOIN PortolioProjet..CovidVaccinations AS vac
 ON dea.date = vac.date AND dea.location= vac.location
 WHERE dea.continent IS NOT NULL
 )
 SELECT *, (rollingPeopleVaccination /population)* 100
 FROM popvsvacc 


 -- TEMP TABLE : - Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortolioProjet..covidDeaths dea
Join PortolioProjet..covidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortolioProjet..covidDeaths dea
Join PortolioProjet..covidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * from PercentPopulationVaccinated
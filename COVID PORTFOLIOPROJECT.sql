SELECT *
FROM PORTFOLIO_PROJECT.dbo.coviddeaths
where continent is not null
ORDER BY 3,4


--SELECT *
--FROM PORTFOLIO_PROJECT.dbo.covidvaccinations
--ORDER BY 3,4
---------------------------------------------------------------------------------------------------------

--select data that we are going to be using

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PORTFOLIO_PROJECT.dbo.coviddeaths
ORDER BY 1,2

---------------------------------------------------------------------------------------------------------

--looking at toatal cases vs total deaths

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PORTFOLIO_PROJECT.dbo.coviddeaths
WHERE location like '%INDIA%'
ORDER BY 1,2

---------------------------------------------------------------------------------------------------------

--looking at total cases vs population

SELECT location,date,population,total_cases,(total_cases/population)*100 as percent_populationinfected
FROM PORTFOLIO_PROJECT.dbo.coviddeaths
WHERE location like '%INDIA%'
ORDER BY 1,2

----------------------------------------------------------------------------------------------------

--looking at countries with highest infection rate compared to population

SELECT location,population,MAX(Total_cases)as highinfectioncount,MAX((total_cases/population)*100) as percent_populationinfected
FROM PORTFOLIO_PROJECT.dbo.coviddeaths
--WHERE location like '%INDIA%'
GROUP BY location,population
ORDER BY percent_populationinfected desc

------------------------------------------------------------------------------------------------------

--showing countries with highest death count per population


SELECT location,population,MAX(cast(total_deaths as int))as total_deathcount,max(total_deaths/population)*100 as percent_deathcount
FROM PORTFOLIO_PROJECT.dbo.coviddeaths
--WHERE location like '%INDIA%'
where continent is not null
GROUP BY location,population
ORDER BY total_deathcount desc

-----------------------------------------------------------------------------------------------------
--LET'S BREAK THINGS DOWN BY CONTINENT
--showing continents with the highest death count per population


SELECT continent,population,MAX(cast(total_deaths as int))as total_deathcount
FROM PORTFOLIO_PROJECT.dbo.coviddeaths
--WHERE location like '%INDIA%'
where continent is not null
GROUP BY continent,population
ORDER BY total_deathcount desc

-------------------------------------------------------------------------------------------------

--GLOBAL NUMBERS


SELECT date,sum(total_cases)as total_cases,sum(cast(total_deaths as int)) as total_death,sum(cast(total_deaths as int))/sum(total_cases)*100 as deathpercentage
FROM PORTFOLIO_PROJECT.dbo.coviddeaths
--WHERE location like '%INDIA%'
where continent is not null
GROUP BY date
ORDER BY deathpercentage desc

-------------------------------------------------------------------------------------------------

--looking at total population vs vaccination
		------------------------
--CTE


with popvsvac(continent,location,date,population,new_vaccinations,Rollingpeoplevaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations))over (partition by dea.location order by dea.location,dea.date)
as Rollingpeoplevaccinated
FROM PORTFOLIO_PROJECT..coviddeaths dea
JOIN PORTFOLIO_PROJECT..covidvaccination vac
	on dea.location=vac.location and
	dea.date=vac.date
where dea.continent is not  null
)
SELECT *,(Rollingpeoplevaccinated/population)*100
FROM popvsvac

----------------------------------------------------------------------------------------

--TEMP TABLE
Drop table if exists #percentpopulationvaccinated
CREATE TABLE #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)
INSERT INTO #percentpopulationvaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations))over (partition by dea.location order by dea.location,dea.date)
as Rollingpeoplevaccinated
FROM PORTFOLIO_PROJECT..coviddeaths dea
JOIN PORTFOLIO_PROJECT..covidvaccination vac
	on dea.location=vac.location and
	dea.date=vac.date
where dea.continent is not  null
--order by 2,3
SELECT *,(Rollingpeoplevaccinated/population)*100
FROM #percentpopulationvaccinated

-------------------------------------------------------------------------------------------------

--creating view to store data for later visulization

Create view percentpopulationvaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations))over (partition by dea.location order by dea.location,dea.date)
as Rollingpeoplevaccinated
FROM PORTFOLIO_PROJECT..coviddeaths dea
JOIN PORTFOLIO_PROJECT..covidvaccination vac
	on dea.location=vac.location and
	dea.date=vac.date
where dea.continent is not  null
--order by 2,3

SELECT *
FROM percentpopulationvaccinated


--Exploratory data analysis using SQL

--Total cases and total death for Ethiopia

SELECT location,date,total_cases,total_deaths,ROUND((total_deaths/total_cases)*100,2) AS death_rate
FROM CovidDeaths
WHERE location='Ethiopia'

--now looking for the total death to total population

select location,date,total_cases,population,ROUND((total_cases/population)*100,3)
from CovidDeaths
-- for specific country in ethiopia
WHERE location='Ethiopia'

--looking for the highest covid cases per population

SELECT location,population,Max(total_cases) AS highestInfectionCount,MAX(ROUND((total_cases/population)*100,2)) as cases_per_population
FROM CovidDeaths
GROUP BY location,population
ORDER BY cases_per_population DESC

--looking for the highest death count per polulation

SELECT location,MAX(CAST(total_deaths AS INT)) AS totaldeathcount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY totaldeathcount DESC

--LET SEE THE DEATH COUNT BY CONTINENT

SELECT LOCATION,MAX(CAST(total_deaths as int)) as totalDeathCount
FROM CovidDeaths
WHERE CONTINENT IS NULL
group by LOCATION
order by totalDeathCount DESC

--- CHECKING the continent and location for the right excution of the total death count from the coviddeath table

SELECT *
FROM CovidDeaths

--looking for the total new cases and new deaths per day

select date,sum(new_cases) as totalNewCase,sum(cast(new_deaths as int)) as totalNewCase,sum(cast(new_deaths as int))/sum(new_cases) as DeathPercentage
from dbo.CovidDeaths
where continent is not null
group by date
order by 1,2

-- only the death and new cases

select sum(new_cases) as totalNewCase,sum(cast(new_deaths as int)) as totalNewCase,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from dbo.CovidDeaths
where continent is not null
--group by date
order by 1,2

--joining the covidDeaths and CovidVaccination tables

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations--,vac.total_vaccinations
from covidDeaths AS dea
join covidVaccinations as vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3

--using Window function of partition by to sum the new vaccination using location

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.date) as RollingVaccination
--RollingVaccination/vac.new_vaccinations
from covidDeaths AS dea
join covidVaccinations as vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--group by dea.location
order by 2,3

--USE CTEs

with Popvsvac(continent,location,date,population,new_vaccination,RollingVaccination)
as
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.date) as RollingVaccination
--RollingVaccination/vac.new_vaccinations
from covidDeaths AS dea
join covidVaccinations as vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--group by dea.location
--order by 2,3
)
select location,MAX(ROUND(RollingVaccination/population*100,3)) AS Vaccinationvspopulation
from Popvsvac
GROUP BY location
order by Vaccinationvspopulation DESC

--Creating Temporary table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingVaccination numeric)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.date) as RollingVaccination
--RollingVaccination/vac.new_vaccinations
from covidDeaths AS dea
join covidVaccinations as vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null

select *,(RollingVaccination/population)
from #PercentPopulationVaccinated
order by location 

-- creating view table for further later visualization

create view PercentPopulationVaccinated 
as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.date) as RollingVaccination
--RollingVaccination/vac.new_vaccinations
from covidDeaths AS dea
join covidVaccinations as vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--group by dea.location
--order by 2,3

Select *
from PercentPopulationVaccinated 

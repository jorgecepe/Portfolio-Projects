
--SELECT top(100) *
--from  CovidDeaths


--SELECT top(100) *
--from  CovidVaccinations 


select  location, date, total_cases, new_cases,total_deaths, population

from CovidDeaths
order by 1,2

-- actualizar tipo de dato que venia como string varchar

	--ALTER TABLE CovidDeaths
	--ALTER COLUMN total_cases float(3)

	--ALTER TABLE CovidDeaths
	--ALTER COLUMN total_deaths float(3)

	--ALTER TABLE CovidDeaths
	--ALTER COLUMN new_cases float(3)

	
	ALTER TABLE CovidVaccinations
	ALTER COLUMN new_vaccinations float(3)

	
	ALTER TABLE CovidDeaths
	ALTER COLUMN new_deaths float(3)

-- cambiar los "0" por null para evitar errores div by zero


	--UPDATE CovidDeaths SET new_deaths=NULL WHERE new_deaths=0
	--UPDATE CovidDeaths SET new_cases=NULL WHERE new_cases=0


-- preparacion de la tabla y formatos para poder generar calculos numericos 

	--ALTER TABLE CovidDeaths 
	--ALTER COLUMN date SET DATA TYPE date
	--      USING to_date(date, 'mm-dd-yyyy')

	--ALTER TABLE CovidVaccinations 
	--ALTER COLUMN date SET DATA TYPE date
	--      USING to_date(date, 'mm-dd-yyyy')

	--ALTER TABLE CovidVaccinations
	--ADD new_date DATE;

	--ALTER TABLE CovidVaccinations
	--DROP COLUMN date

	--EXEC sp_rename 'CovidVaccinations.new_date', 'date', 'COLUMN';
	
	--select date from CovidVaccinations

	
-- Looking at total cases vs total deaths
-- shows liklihood of dying if you get covid 

select  location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location = 'United States'
order by 1,2

-- Looking at total cases vs population
-- shows % of population got covid

select  location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentage
from CovidDeaths
where location = 'United States'
order by 1,2

--- lookint at countires with the highes infgection rate compared to population

select  location, population, MAX(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfected
from CovidDeaths
--where location = 'United States'
group by location, population
order by 4 desc 


--- lookint at countires with the highest death count per population

select  continent, location, population, MAX(total_deaths) as HighestDeaths, max((total_deaths/population))*100 as PercentagePopDead
from CovidDeaths
where continent != ''
group by continent, location, population
order by 4 desc 

select * from CovidDeaths

-- LETS BREAK IT UP BY CONTINENT

select  location, MAX(total_deaths) as HighestDeaths, max((total_deaths/population))*100 as PercentagePopDead
from CovidDeaths
where continent = ''
group by location
order by 3 desc 

-- by continent v2

select  continent, MAX(total_deaths) as HighestDeaths, max((total_deaths/population))*100 as PercentagePopDead
from CovidDeaths
where continent != ''
group by continent
order by 3 desc 

-- Global numbers


select  
	sum(new_cases) as total_cases, 
	sum(new_deaths) as total_deaths, 
	(sum(new_deaths)/
		sum(new_cases))*100 as DeathPercentage
from CovidDeaths
where continent !=''
--group by date
order by 1,2

-- Vacunas

-- joining tables

-- total population vs vaccinatios

--cte
with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as 

(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent !=''
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 as PercentagePopVaccinated from PopVsVac


-- temp table

create table #percentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)



insert into #percentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent !=''
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 as PercentagePopVaccinated 
from #percentPopulationVaccinated


-- Creating View to store data for later visualizations

create view  percentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent !=''
--order by 2,3
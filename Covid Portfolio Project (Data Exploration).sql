

select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4;

--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4;



-- select data that we'll use
select location, 
		date, 
		total_cases, 
		new_cases, 
		total_deaths,
		population
from PortfolioProject..CovidDeaths
order by 1,2;


-- looking at total cases vs total deaths
-- show likelyhood of dying if you contract covid in your country
select location, 
		date, 
		total_cases, 
		total_deaths, 
		(total_deaths/total_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2;

select location, 
		date, 
		total_cases, 
		total_deaths, 
		(total_deaths/total_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths
where location like '%azer%'
order by 1,2;



-- looking at total cases vs population (what percentage of population got covid)
select location, 
		date, 
		total_cases, 
		population, 
		(total_cases/population)*100 as deathpercentage
from PortfolioProject..CovidDeaths
--where location like '%azer%'
order by 1,2;


--looking at countries with the highest  infection rate compared population

select location, 
		population, 
		max(total_cases) as highestinfectioncount,  
		max((total_cases/population))*100 as percentpopulationinfected
from PortfolioProject..CovidDeaths
--where location like '%azer%'
group by location, 
		population
order by percentpopulationinfected desc;


--showing countries with highest death count per population
select location,  
		max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
--where location like '%azer%'
where continent is not null
group by location
order by totaldeathcount desc;



--LET'S BREAK THINGS DOWN BY CONTINENT


--showing continents with highest death count per population
select continent,  
		max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
--where location like '%azer%'
where continent is not null
group by continent
order by totaldeathcount desc;



--GLOBAL NUMBERS

select date, 
		sum(new_cases)
from PortfolioProject..CovidDeaths
--where location like '%azer%'
where continent is not null
group by date
order by 1,2;


select date, 
		sum(new_cases), 
		sum(cast(new_deaths as int))
from PortfolioProject..CovidDeaths
--where location like '%azer%'
where continent is not null
group by date
order by 1,2;


select date, 
		sum(new_cases) as total_cases, 
		sum(cast(new_deaths as int)) as total_deaths, 
		sum(cast(new_deaths as int)) /  sum(new_cases) * 100 as deathpercentage
from PortfolioProject..CovidDeaths
--where location like '%azer%'
where continent is not null
group by date
order by 1,2;



select  sum(new_cases) as total_cases, 
		sum(cast(new_deaths as int)) as total_deaths, 
		sum(cast(new_deaths as int)) /  sum(new_cases) * 100 as deathpercentage
from PortfolioProject..CovidDeaths
--where location like '%azer%'
where continent is not null
--group by date
order by 1,2;



--total population vs vaccinations
select dea.continent,
		dea.location,
		dea.date,
		dea.population, 
		vac.new_vaccinations,
		sum(cast(isnull(vac.new_vaccinations,0) as bigint)) over (partition by dea.location order by dea.location, dea.date) as peoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac 
	on vac.location = dea.location 
	and vac.date = dea.date
where dea.continent is not null
order by  2, 3;



--USING CTE (COMMON TABLE EXPRESSIONS)
WITH PopvsVac  (Continent, Location, Date, Population, New_vaccinations, Peoplevaccinated)
as 
(
select dea.continent,
		dea.location,
		dea.date,
		dea.population, 
		vac.new_vaccinations,
		sum(cast(isnull(vac.new_vaccinations,0) as bigint)) over (partition by dea.location order by dea.location, dea.date) as peoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac 
	on vac.location = dea.location 
	and vac.date = dea.date
where dea.continent is not null
--order by  2, 3
)
select * , Peoplevaccinated/Population * 100
from PopvsVac;


--TEMP TABLE

--drop table if exists #percentpopulationvaccinated;

Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Peoplevaccinated numeric
);

insert into #PercentPopulationVaccinated
select dea.continent,
		dea.location,
		dea.date,
		dea.population, 
		vac.new_vaccinations,
		sum(cast(isnull(vac.new_vaccinations,0) as bigint)) over (partition by dea.location order by dea.location, dea.date) as peoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac 
	on vac.location = dea.location 
	and vac.date = dea.date
where dea.continent is not null
--order by  2, 3
;

select * , 
		Peoplevaccinated/Population * 100
from #PercentPopulationVaccinated;




--CREATING VIEW

Create view PercentPopulationVaccinated
as 
select dea.continent,
		dea.location,
		dea.date,
		dea.population, 
		vac.new_vaccinations,
		sum(cast(isnull(vac.new_vaccinations,0) as bigint)) over (partition by dea.location order by dea.location, dea.date) as peoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac 
	on vac.location = dea.location 
	and vac.date = dea.date
where dea.continent is not null;


select *
from PercentPopulationVaccinated;
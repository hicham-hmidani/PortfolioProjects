select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2 

select *
From PortfolioProject..CovidVaccination
where continent is not null
order by 3,4 

--select the data that we are going to using

select Location,date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2 

--Loking at total cases vs total deaths
-- shows liklehood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like 'Morocco'
and continent is not null
order by 1,2

--loking at total cases vs population 
--shows what percentage of population got covid
select Location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Look at contries with highest Infection rate compared to Population 

select Location,Population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PrecentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like 'Morocco'
group by Location,Population
order by PrecentPopulationInfected desc

-- Showing countries with highest death count per population

select Location,Max(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProject ..CovidDeaths
where continent is not null
Group by Location
order by TotalDeathsCount desc

--Let's Break things down by continent 

-- Showing contients with the highest death count per population 

select continent,Max(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProject ..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathsCount desc

--Globals Numbers

select  SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as 
DeathPercentag
from PortfolioProject..CovidDeaths
where continent is not null
--Group by date
order by 1,2

--Looking at Population vs Vaccinations
with PopvsVac (Continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as (
select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
,SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
  On dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null
  --Order by 2,3
)

select *,(RollingPeopleVaccinated/population)*100
from PopvsVac

--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
,SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
  On dea.location=vac.location
  and dea.date=vac.date
--where dea.continent is not null
  --Order by 2,3

select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--converting view to store for later visualizations

Create View PercentPopulationVaccinateddd as 
select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
,SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
  On dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null


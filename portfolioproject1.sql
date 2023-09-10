select *
from CovidDeaths$


select * 
from CovidVaccinations$


select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
where location = 'kenya';

--comparing total_cases vs total_deaths in kenya

select location,date,total_cases,total_deaths,(total_deaths/total_cases)* 100 as death_percentage
from CovidDeaths$
where location = 'kenya' 
order by death_percentage desc;

select location,date,total_cases,population,(total_cases/population)* 100 as death_percentage
from CovidDeaths$
where location = 'kenya' 
order by death_percentage desc;

select location, (sum(total_cases)/population) * 100 as population_percentage
from CovidDeaths$
group by location,population
order by population_percentage desc

---- Countries with Highest Infection Rate compared to Population

select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths$
Group by Location, Population
order by PercentPopulationInfected desc;

-- Countries with Highest Death Count per Population
select location, max(cast(total_deaths as int)) as totaldeathcount
from CovidDeaths$
where continent is not null
group by location
order by totaldeathcount desc

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths$
Where continent is not null 
Group by continent
order by TotalDeathCount desc


--GLOBALLY
Select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths$
where continent is not null 
Group By date
order by 1,2


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths$
where continent is not null 
order by 1,2


--JOINING TWO TABLES
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


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
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




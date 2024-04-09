--Covid-19 Data Exploration 2020-2024
select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4
;


--Total Cases Vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where location = 'Iran'
and continent is not null
order by location , date
;


--Total Cases Vs Population
select location, date, total_cases, population, (total_cases/population)*100 as infection_rate
from PortfolioProject..CovidDeaths
where location = 'Iran'
order by 1 , 2
;

--Countries With Highest Infection Rate Compared To Population
select location, population, max(total_cases) as highest_infection_count, max((total_cases/population))*100 As infection_rate
from PortfolioProject..CovidDeaths
group by location , population
order by infection_rate desc
;

--Countries With Highest Death Count Per Population
select location, max(total_deaths) as total_deaths_count
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by total_deaths_count desc
;

--Continents With Highest Death Count
select continent, max(total_deaths) as total_deaths_count
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by total_deaths_count desc
;

--Continents With Highest Death Count Per Population
select continent, max(total_deaths) as total_deaths_count
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by total_deaths_count desc
;

--Continents With Highest Death Count Per Population
select continent,max(population) as max_population , max((total_deaths / population))*100 as death_rate_per_population
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by death_rate_per_population desc
;

--Global Numbers
SET ARITHABORT ON

select 
	date,
	SUM(new_cases) as total_cases,
	SUM(new_deaths) as total_deaths,
	SUM(new_deaths)/SUM(new_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where continent is not null and new_deaths != 0
group by date 
order by 1,2
;


--Total Population Vs Vaccinations
with PopvsVac as (
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(ISNULL(vac.new_vaccinations, 0) AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

select * , (rolling_people_vaccinated / population)*100 as VaccinationRate
from PopvsVac
order by location , date
;


-- Using Temp Table To Perform Calculation On Partition By In previous Query
Drop Table if Exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric, 
rolling_people_vaccinated numeric
)
insert into #PercentPopulationVaccinated
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(ISNULL(vac.new_vaccinations, 0) AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

select * , (rolling_people_vaccinated / population)*100 as VaccinationRate
from #PercentPopulationVaccinated
;


--Creating View To Store Data For Later Visualizations
CREATE VIEW myview_PercentPopulationVaccinated AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(ISNULL(vac.new_vaccinations, 0) AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

CREATE VIEW myview_PercentPopulationVaccinated AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(ISNULL(vac.new_vaccinations, 0) AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

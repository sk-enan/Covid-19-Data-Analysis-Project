Select *
From CovidDeaths
Where continent is not null
order by 3,4

Select *
From CovidVaccinations
Where continent is not null
order by 3,4


-- Shows likelihood of dying if you contract covid in Australia

Select Location, date_, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100, 5) as DeathPercentage
From CovidDeaths
Where location like 'Australia'
and continent is not null
order by 1,2

-- Shows what percentage of population got covid

Select Location, date_, Population, total_cases, ROUND((total_cases/population)*100, 5) as PercentPopulationInfected
From CovidDeaths
Where location like 'Australia'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, ROUND(MAX((total_cases/population))*100, 5) as PercentPopulationInfected
From CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

Select Location, MAX(Total_deaths) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Breaking Down by Continent
--Showing continents with the highest death count per population

Select continent, MAX(Total_deaths) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
Where continent is not null
order by 1,2

--Looking at Total Population vs Vaccinations
--Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date_, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date_) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location
and dea.date_ = vac.date_
where dea.continent is not null
order by 2,3

--Using CTE to perform Calculation on Partition By in previous query

With popvsVac (Continent, Location, Date_, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date_, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date_) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location
and dea.date_ = vac.date_
where dea.continent is not null
)
Select *
From popvsVac


--TEMP TABLE

CREATE TABLE PercentPopulationVaccinated (
  Continent NVARCHAR2(255),
  Location NVARCHAR2(255),
  Date_ DATE,
  Population NUMBER,
  New_vaccinations NUMBER,
  RollingPeopleVaccinated NUMBER
);

INSERT INTO PercentPopulationVaccinated
SELECT
  dea.continent,
  dea.location,
  dea.date_,
  dea.population,
  vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date_) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac ON dea.location = vac.location AND dea.date_ = vac.date_;

-- Select data from the table
SELECT *
FROM PercentPopulationVaccinated;














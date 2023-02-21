use covid_info

select * 
from covid_info..['Covid deaths']
where continent is not null
order by 3,4;

select * 
from covid_info..['Covid vaccinations']
order by 3,4;

--Selecting info of interest

select Location, date,total_cases,new_cases,total_deaths,population 
from covid_info..['Covid deaths']
where continent is not null
order by 1,2;

---Comparing total cases vs total deaths
---Likelihood of dying if you contracted covid19 in your country
select Location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 as
PercentDeaths
from covid_info..['Covid deaths']
WHERE location like '%Canada%'
and continent is not null
order by 1,2;

---comparing population vs total cases
select Location, date,total_cases,population, (total_cases/population)*100 as 
CasesPerPopulation
from covid_info..['Covid deaths']
WHERE location like '%united states%'
order by 1,2;

---countries with highest rate of infection compared to population
select Location, population, MAX(total_cases) as HighestInfxnCount, 
MAX((total_cases/population))*100 as CasesPerPopulation
from covid_info..['Covid deaths']
---WHERE location like '%united states%'
where continent is not null
GROUP BY location,population
order by CasesPerPopulation desc;

---Showing countries with highest deathcounts per population
select Location, MAX(cast(total_deaths as int)) as HighestDeathCount
from covid_info..['Covid deaths']
---WHERE location like '%united states%'
where continent is not null
GROUP BY location
order by HighestDeathCount desc;

---showing continents with highest death counts.
select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
from covid_info..['Covid deaths']
---WHERE location like '%united states%'
where continent is not null
GROUP BY continent
order by HighestDeathCount desc;

---Drilling down by continent
select continent, population, MAX(total_cases) as HighestInfxnCount, 
MAX((total_cases/population))*100 as CasesPerPopulation
from covid_info..['Covid deaths']
---WHERE location like '%north america%'
where continent is not null
GROUP BY continent,population
order by CasesPerPopulation desc;

---GLOBAL CASES

select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int))as TotalDeaths,
Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPerPopln
from covid_info..['Covid deaths']
---WHERE location like '%united states%'
WHERE continent is not null
Group by date
order by 1,2;

select * from covid_info..['Covid deaths']


---Joining both tables on loc and date.
Select * 
From covid_info..['Covid deaths'] dea 
Join covid_info..['Covid vaccinations'] vac
on dea.location = vac.location
and dea.date = vac.date


---Looking at Total Population vs Vaccinations.

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
From covid_info..['Covid deaths'] dea 
Join covid_info..['Covid vaccinations'] vac
on dea.location = vac.location
and dea.date = vac.date
order by 2,3

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as numeric)) OVER (Partition by dea.location
ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From covid_info..['Covid deaths'] dea 
Join covid_info..['Covid vaccinations'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

---USE CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, 
RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as numeric)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From covid_info..['Covid deaths'] dea 
Join covid_info..['Covid vaccinations'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
---and dea.location like '%nigeria%'
---order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentofPoplnVaccinated
from PopvsVac

---TEMP TABLE
Drop Table if exists #PercentofPoplnVaccinated
Create Table #PercentofPoplnVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentofPoplnVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as numeric)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From covid_info..['Covid deaths'] dea 
Join covid_info..['Covid vaccinations'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
---and dea.location like '%nigeria%'
---order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 as PercentofPoplnVaccinated
from #PercentofPoplnVaccinated

---Creating views
Create View RollingPoplnVaccinated as 

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as numeric)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From covid_info..['Covid deaths'] dea 
Join covid_info..['Covid vaccinations'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null



Select * from RollingPoplnVaccinated

use covid_info
Select * from covid_info..['Covid deaths']

---Looking at popln vs fully vaccinated vs gdp

Select dea.continent, dea.location, dea.date, dea.population, vac.people_fully_vaccinated, 
vac.gdp_per_capita, vac.human_development_index,
 SUM(people_fully_vaccinated/population) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) as perppln_vaccd


From covid_info..['Covid deaths'] dea 
Join covid_info..['Covid vaccinations'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

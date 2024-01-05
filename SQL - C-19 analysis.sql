select *
from PortfolioProject..CovidDeaths
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--select data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- looking at total cases vs total deaths
-- Prawdopodobieñstwo œmierci w Polsce po zara¿eniu C-19
select location, date, total_cases, total_deaths, round((cast(total_deaths as float)/cast(total_cases as float))*100,2) as DeathPercentage
from PortfolioProject..CovidDeaths
where location like 'poland' and continent is not null
order by 1,2

--Total cases vs population
--Jaki procent populacji kraju przesz³o C-19
select location, date, total_cases, population, round((cast(total_cases as float)/cast(population as float))*100,5) as InfectedPercentage
from PortfolioProject..CovidDeaths
where location like 'poland' and continent is not null
order by 1,2

--Jaki kraj ma najwy¿szy stosunek zara¿eñ do populacji?
select location, population, max(convert(float, total_cases)) as HighestInfectionCount, round(max(convert(float, total_cases))/convert(float, population)*100,2) as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc

--Kraje z najwieksz¹ œmiertelnoœci¹ na populacje
select location, max(convert(float, total_deaths)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--Podzial na kontynenty
--Ilosc zgonow na kontynencie i procent calosci
select location, max(convert(float, total_deaths)) as TotalDeathCount, round(max(convert(float, total_deaths))/(select max(convert(float, total_deaths)) from PortfolioProject..CovidDeaths where location like '%world%')*100,2) as PercentDeathByContinent --max(convert(float, total_deaths))/convert(float, total_deaths) as TotalDeathPercentage
from PortfolioProject..CovidDeaths
where continent is null and location not like '%income%' and location not like '%union%' and location not like '%world%'
group by location
order by TotalDeathCount desc

--GLOBAL

select SUM(convert(float,new_cases)) as NewCases, SUM(convert(float,new_deaths)) as NewDeaths, round(SUM(convert(float,new_deaths))/SUM(convert(float,new_cases))*100,4) as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as PeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

--CTE
WITH PopVsVac(continent, location, date, population, new_vaccinations, PeopleVaccinated)
as
(
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as PeopleVaccinated
	from PortfolioProject..CovidDeaths as dea
	join PortfolioProject..CovidVaccinations as vac on dea.location = vac.location and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
)
select *, (PeopleVaccinated/population)*100 as PercentPopulationVaccinated
from PopVsVac

--Create view to store data for later visu

Create view PercentPopulationVaccinated as 
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as PeopleVaccinated
	from PortfolioProject..CovidDeaths as dea
	join PortfolioProject..CovidVaccinations as vac on dea.location = vac.location and dea.date = vac.date
	where dea.continent is not null

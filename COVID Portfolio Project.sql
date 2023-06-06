use [Portfolio Project]

select *
from CovidDeaths
--order by 3,4

--select *
--from CovidVaccinations
--order by 3,4

--odabir podataka koje ću koristiti

select Location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..CovidDeaths
where continent IS NOT NULL
order by 1,2

-- usporedba total_case vs. total_deaths
-- pokazuje vjerojatnost smrti u slučaju zaraze u određenoj državi

select Location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as PostotakSmrtnosti
from [Portfolio Project]..CovidDeaths
where Location like '%croat%' and total_deaths IS NOT NULL
order by 1,2

-- usporedba total_cases vs. population
-- pokazuje postotak zaraženih u ukupnoj populaciji određene države

select Location, date, total_cases, population, (total_cases/population)*100 as UdioZaraženih
from [Portfolio Project]..CovidDeaths
where Location like '%croat%'
order by 1,2


-- države sa najvećom stopom zaraze u populaciji

select Location, population, MAX(total_cases) as NajvišeZaraženih, MAX((total_cases/population))*100 as PostotakZaraženih
from [Portfolio Project]..CovidDeaths
where continent IS NOT NULL
group by Location, population
order by 4 desc

-- prikaz zemalja sa najviše umrlih od zaraze

select Location, MAX(cast(total_deaths as int)) as 'UkupanBrojUmrlih'
from [Portfolio Project]..CovidDeaths
where continent IS NOT NULL
group by Location, population
order by 2 desc

-- prikaz broja umrlih prema kontinentima 

select continent, MAX(cast(total_deaths as int)) as 'UkupanBrojUmrlih'
from [Portfolio Project]..CovidDeaths
where continent IS NOT NULL
group by continent
order by 2 desc

-- prikaz kontinenata po postotku umrlih u odnosu na broj stanovnika

select continent,  MAX(total_cases) as NajvišeZaraženih, MAX((total_cases/population))*100 as PostotakZaraženih
from [Portfolio Project]..CovidDeaths
where continent IS NOT NULL
group by continent
order by 3 desc

-- globalne brojke

select --date
		sum(new_cases)as 'Novi slučajevi' 
	    ,sum(cast(new_deaths as int)) 'BrojUmrlihDnevno' 
	    ,(sum(cast(new_deaths as int))/sum(new_cases))*100 as 'PostotakSmrtnost'
from [Portfolio Project]..CovidDeaths
where continent IS NOT NULL
--group by date
order by 1,2

-- globalne brojke po određenom datumu

select date
	   ,sum(new_cases)as 'Novi slučajevi' 
	   ,sum(cast(new_deaths as int)) 'BrojUmrlihDnevno' 
	   ,(sum(cast(new_deaths as int))/sum(new_cases))*100 as 'PostotakSmrtnost'
from [Portfolio Project]..CovidDeaths
where continent IS NOT NULL
group by date
order by 1,2


--Pregled: Ukupna populacija vs. procijepljenost

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(cast(vac.new_vaccinations as int)) OVER 
	(Partition by dea.location Order by dea.location, dea.date) as ZbrojCijepljenihOsoba
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- cte

With PopvsCij (Continent, Location, date, population, new_vaccinations, ZbrojCijepljenih)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(cast(vac.new_vaccinations as int)) OVER 
	(Partition by dea.location Order by dea.location, dea.date) as ZbrojCijepljenihOsoba
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (ZbrojCijepljenih/Population)*100 as Procijepljenost
from PopvsCij

-- temp table

drop table if exists #PostotakProcijepljenosti
Create table #PostotakProcijepljenosti
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
ZbrojCijepljenihOsoba numeric
)

Insert into #PostotakProcijepljenosti
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(cast(vac.new_vaccinations as int)) OVER 
	(Partition by dea.location Order by dea.location, dea.date) as ZbrojCijepljenihOsoba
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

select * 
from #PostotakProcijepljenosti

-- kreiranje Pogleda za izradu vizualizacije

Create View PostotakProcijepljenosti as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(cast(vac.new_vaccinations as int)) OVER 
	(Partition by dea.location Order by dea.location, dea.date) as ZbrojCijepljenihOsoba
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from PostotakProcijepljenosti

-- kreiranranje pogleda Ukupna populacija vs. Procijepljenost

Create View UkPopvsProc as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(cast(vac.new_vaccinations as int)) OVER 
	(Partition by dea.location Order by dea.location, dea.date) as ZbrojCijepljenihOsoba
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from UkPopvsProc

 SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidDeaths
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Total Cases VS Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage 
FROM PortfolioProject..CovidDeaths
WHERE location like '%States%'
ORDER BY 1,2

-- Total Cases VS Population

SELECT location, date, population, total_cases, (total_cases/population)*100 as percent_infected
FROM PortfolioProject..CovidDeaths
WHERE location like '%States%'
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as percent_population_infected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY percent_population_infected desc

-- Countries with Highest Death Count compared to Population

SELECT location, MAX(CAST(total_deaths as int)) as highest_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is not Null
GROUP BY location
ORDER BY highest_death_count desc

-- Continent with the Highest Death Count

SELECT continent, MAX(CAST(total_deaths as int)) as highest_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is not Null
GROUP BY continent
ORDER BY highest_death_count desc

-- Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS float)) as total_deaths, SUM(CAST(new_deaths AS float))/SUM(new_cases)*100 as death_percentage 
FROM PortfolioProject..CovidDeaths
WHERE continent is not Null
--GROUP BY date
ORDER BY 1,2

-- Total Population VS Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
    on dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not Null
ORDER BY 2,3

-- Use CTE

WITH Pop_VS_Vac (Continent, Location, Date, Population, New_Vaccination, rolling_people_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
    on dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not Null
)
SELECT*, (rolling_people_vaccinated/Population)*100 AS percent_people_vaccinated
FROM Pop_VS_Vac
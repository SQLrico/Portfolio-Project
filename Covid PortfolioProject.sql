CREATE TABLE CovidDeaths (
	iso_code VARCHAR(15),
	continent VARCHAR(15),
	location VARCHAR(40),
	date DATE,
	population BIGINT,
	total_cases INT,
	new_cases INT,
	new_cases_smoothed NUMERIC,
	total_deaths INT,
	new_deaths INT,
	new_deaths_smoothed NUMERIC,
	total_cases_per_million NUMERIC,
	new_cases_per_million NUMERIC,
	new_cases_smoothed_per_million NUMERIC,
	total_deaths_per_million NUMERIC,
	new_deaths_per_million NUMERIC,
	new_deaths_smoothed_per_million NUMERIC,
	reproduction_rate NUMERIC,
	icu_patients INT,
	icu_patients_per_million NUMERIC,
	hosp_patients INT,
	hosp_patients_per_million NUMERIC,
	weekly_icu_admissions NUMERIC,
	weekly_icu_admissions_per_million NUMERIC,
	weekly_hosp_admissions NUMERIC,
	weekly_hosp_admissions_per_million NUMERIC
);

CREATE TABLE covidvaccinations (
	iso_code VARCHAR(15),
	continent VARCHAR(15),
	location VARCHAR(40),
	date DATE,
	new_tests INT,
	total_tests INT,
	total_tests_per_thousand NUMERIC,
	new_tests_per_thousand NUMERIC,
	new_tests_smoothed INT,
	new_tests_smoothed_per_thousand NUMERIC,
	positive_rate NUMERIC,
	tests_per_case NUMERIC,
	tests_units VARCHAR (40),
	total_vaccinations INT,
	people_vaccinated INT,
	people_fully_vaccinated INT,
	new_vaccinations INT,
	new_vaccinations_smoothed INT,
	total_vaccinations_per_hundred NUMERIC,
	people_vaccinated_per_hundred NUMERIC,
	people_fully_vaccinated_per_hundred NUMERIC,
	new_vaccinations_smoothed_per_million INT,
	stringency_index NUMERIC,
	population_density NUMERIC,
	median_age NUMERIC,
	aged_65_older NUMERIC,
	aged_70_older NUMERIC,
	gdp_per_capita NUMERIC,
	extreme_poverty NUMERIC,
	cardiovasc_death_rate NUMERIC,
	diabetes_prevalence NUMERIC,
	female_smokers NUMERIC,
	male_smokers NUMERIC,
	handwashing_facilities NUMERIC,
	hospital_beds_per_thousand NUMERIC,
	life_expectancy NUMERIC,
	human_development_index NUMERIC
);


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths::numeric/total_cases)*100 as death_percentage
FROM coviddeaths
WHERE location = 'United States'
ORDER BY 1,2

-- Looking at the Total Cases vs Population
-- Shows what percentage of population contracted covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as death_percentage
FROM coviddeaths
WHERE location = 'United States'
ORDER BY 1,2

-- Looking at countries with the highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases * 1.0)/population)*100 as percent_of_population_infected
FROM coviddeaths
--WHERE location = 'United States'
GROUP BY location, population
ORDER BY percent_of_population_infected DESC;

-- Showing countries with highest death count per population

SELECT location, MAX(total_deaths::int) AS total_death_count
FROM coviddeaths
WHERE continent IS NOT null
GROUP BY location
ORDER BY total_death_count DESC;

-- Showing continents with the highest death count per population

SELECT continent, MAX(total_deaths) AS total_death_count
FROM coviddeaths
WHERE continent IS NOT null
GROUP BY continent
ORDER BY total_death_count DESC;

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths * 1.0) / SUM(new_cases) * 100 AS case_percentage
FROM coviddeaths
WHERE continent IS NOT null
GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations

SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated,
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
ORDER BY 2, 3;

-- Use CTE

WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS (
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
)

SELECT *, ((rolling_people_vaccinated * 1.0) / population) * 100
FROM pop_vs_vac



-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null;

SELECT *
FROM PercentPopulationVaccinated;

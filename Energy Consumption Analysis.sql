-- create a database
create database energydb2;

-- use energy database
use energydb2;

-- create tables country(central table), consumption,production, emission, gdp, population

-- create table country
CREATE TABLE country (
    CID INT AUTO_INCREMENT PRIMARY KEY,
    Country VARCHAR(100) UNIQUE
);

-- create table emission
create table emission(
	country varchar(100),
    energy_type varchar(50),
    year int,
    emission int,
    per_capita_emission double
);

-- create population table
create table population(
	countries varchar(100), 
    year int,
    value double
);

-- create table production
create table production(
	country varchar(100),
    energy varchar(50),
    year int,
    production int
);

-- create table gdp3
create table gdp_3(
	country varchar(100),
    year int,
    value double
);

-- create table consumption
create table consumption(
	country varchar(100),
    energy varchar(50),
    year int,
    consumption int
);

SELECT DISTINCT country
FROM emission
WHERE country NOT IN (SELECT Country FROM country);

-- removing extra spaces 
update emission
set country = trim(country);

select distinct e.country
from emission as e
left join country c
on e.country= c.country
where c.country is null;


-- add missing countries to the country table from remaining tables
ALTER TABLE country
MODIFY CID INT AUTO_INCREMENT;

-- insert missing values from emission
insert into country(country)
select distinct country
from emission 
where country not in (select country from country);

-- insert missing values from production
insert into country(country)
select distinct country
from production
where country not in (select country from country);

-- insert missing values from consumption
insert into country(country)
select distinct country
from consumption
where country not in (select country from country);

-- insert missing values from gdp_3
insert into country(country)
select distinct country
from gdp_3
where country not in (select country from country);

-- insert missing values from population
insert into country(country)
select distinct countries
from population
where countries not in (select country from country);

SELECT DISTINCT country
FROM emission
WHERE country NOT IN (SELECT Country FROM country);

-- Adding foreign keys

-- add fk to emission
alter table emission
add constraint fk_emission
foreign key (country)
references country(country);

-- add fk to production
alter table production 
add constraint fk_production
foreign key (country)
references country(country);

-- add fk to consumption
alter table consumption
add constraint fk_consumption
foreign key (country)
references country(country);

-- add fk to gdp
alter table gdp_3
add constraint fk_constraint
foreign key (country)
references country(country);

-- add population
alter table population
add constraint fk_population
foreign key (countries)
references country(country);

select * from country;
select * from consumption;
select * from emission;
select * from gdp_3;
select * from production;
select * from population;


-- DATA ANALYSIS 
-- General and comparitive analysis

-- What is the total emission per country for the most recent year available?
select country, sum(emission) as total_emission
from emission 
where year = (select max(year) from emission)
group by country
order by total_emission desc;
-- “Data is ordered in descending order to clearly identify major emitting economies.”

-- what are the top 5 countries by GDP in the most recent year?
select country,year, value as gdp from gdp_3 
where year=(select max(year) from gdp_3)
order by value desc
limit 5;

-- compare energy production and consumption by country and year
select p.country,p.year,
	sum(p.production) as total_production, 
    sum(c.consumption) as total_consumption
from production as p
join consumption as c
	on p.country = c.country
	and p.year=c.year
group by p.country,p.year
order by p.year desc,p.country;

-- Which energy types contribute most to emissions across all countries? 
select energy_type,sum(emission) as total_emission from emission group by energy_type order by total_emission desc;

-- Trend Analysis Over Time 
-- How have global emissions changed year over year? 
select year,sum(emission) as global_emission from emission group by year order by year;
-- What is the trend in GDP for each country over the given years? 
select country,year ,sum(value) as gdp from gdp_3 group by country,year order by country,year;
-- How has population growth affected total emissions in each country? 
select p.countries as country,p.year,p.value as population,sum(e.emission) as total_emission
from population as p
join emission as e
	on p.countries = e.country
	and p.year=e.year
group by p.countries,p.year,p.value
order by p.countries,p.year;

-- Has energy consumption increased or decreased over the years for major  economies? 
select distinct country,value from gdp_3 where year=(select max(year) from gdp_3) order by value desc limit 5;

select country,year,sum(consumption) as total_consumption 
from consumption 
where country in("China","United states","India","Japan","Germany")
group by country,year 
order by country;




-- What is the average yearly change in emissions per capita for each country?
select country,
       avg(yearly_change) as avg_yearly_change
from (
    select country,
           year,
           per_capita_emission -
           lag(per_capita_emission)
               over (partition by country order by year) as yearly_change 
    from emission
) as t
where yearly_change is not null
group by country
order by country;


-- Ratio & Per Capita Analysis 

-- What is the emission-to-GDP ratio for each country by year? 
select e.country,
	   e.year,
       sum(e.emission) as total_emission,
       g.value as gdp,
       sum(e.emission)/g.value as emission_gdp_ratio
from emission as e
join gdp_3 as g
	on e.country=g.country
    and e.year=g.year
group by e.country,e.year,g.value
order by e.country,e.year;

-- What is the energy consumption per capita for each country over the last decade? 
select c.country,c.year, sum(c.consumption) as total_consumption,
p.value as population,
sum(c.consumption)/NULLIF(p.value,0) as consumption_per_capita
from consumption as c
join population as p
	on c.country=p.countries
	and c.year=p.year
where c.year >=(select max(year) from consumption)-9
group by c.country,c.year,p.value
order by c.country,c.year;

-- How does energy production per capita vary across countries? 
select pr.country,pr.year, sum(pr.production) as total_production,
	   po.value as population,
sum(pr.production)/NULLIF(po.value,0) as production_per_capita
from production as pr
join population as po
	on pr.country=po.countries
	and pr.year=po.year
where pr.year=(select max(year) from production)
group by pr.country,pr.year,po.value
order by production_per_capita desc;

-- Which countries have the highest energy consumption relative to GDP? 
select c.country,c.year, sum(c.consumption) as total_consumption,
	g.value as gdp,
	sum(c.consumption)/NULLIF(g.value,0) as consumption_to_gdp_ratio
from consumption as c
join gdp_3 as g
	on c.country=g.country
	and c.year=g.year
where c.year =(select max(year) from consumption)
group by c.country,c.year,g.value
order by consumption_to_gdp_ratio desc;

-- What is the correlation between GDP growth and energy production growth?
select t.country,t.year,t.gdp_growth,t.production_growth
from (
		select country,
			   year,
               value - lag(value) over (partition by country order by year) as gdp_growth,
			   total_production-
               lag(total_production)
               over (partition by country order by year) as production_growth
		from(
			SELECT g.country,
               g.year,
               g.value,
               SUM(p.production) AS total_production
        FROM gdp_3 as g
        JOIN production p
            ON g.country = p.country
            AND g.year = p.year
        GROUP BY g.country, g.year, g.value
    ) x
) t
WHERE t.gdp_growth IS NOT NULL
ORDER BY t.country, t.year;
			
            
            
-- Global Comparisons 
-- What are the top 10 countries by population and how do their emissions compare? 
select p.countries as country,
	   p.value as population,
       sum(e.emission) as total_emission
from population as p
join emission as e
on p.countries = e.country
and p.year = e.year
where p.year = (select max(year) from population)
group by p.countries,p.value
order by population desc limit 10;

-- Which countries have improved (reduced) their per capita emissions the most over the last decade? 
select country,
	   max(case when year= max_year then per_capita_emission end)-
       max(case when year = max_year - 9 then per_capita_emission end)
       as change_in_per_capita
from (
	 select country,
			year,
            per_capita_emission,
            max(year) over() as max_year 
	from emission
) t
where year in(max_year,max_year-9)
group by country
having change_in_per_capita is not null
order by change_in_per_capita asc;
-- What is the global share (%) of emissions by country? 
select country,
	   sum(emission) as total_emission,
       sum(emission)*100.0/
       (
			select sum(emission) from emission
            where year=(select max(year) from emission))
            as global_share_percent
from emission
where year=(select max(year) from emission)
group by country
order by global_share_percent desc;

-- What is the global average GDP, emission, and population by year?
select 
		g.year,
        avg(g.value) as avg_gdp,
        avg(e.total_emission) as avg_emission,
        avg(p.value) as avg_population
from gdp_3 as g
join (
	select country,year,sum(emission) as total_emission
    from emission
    group by country,year) as e
on g.country = e.country
and g.year=e.year
join population as p
on g.country = p.countries
and g.year = p.year
group by g.year
order by g.year;



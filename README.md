# Global Energy Consumption Analysis (SQL)

## Overview
This project analyzes global energy production, consumption, emissions, GDP, and population data using SQL. The objective is to explore global energy trends, understand the relationship between economic growth and energy usage, and identify major contributors to global emissions.

The analysis was performed using a relational database structure that enables efficient querying and comparison across multiple countries and years.

---

## Dataset
The dataset includes the following information:

- Energy consumption
- Energy production
- Carbon emissions
- GDP (economic output)
- Population statistics
- Country information

These datasets were imported from CSV files into a MySQL database for analysis.

---

## Database Schema
The database consists of **six tables** connected through foreign key relationships.

### Tables

**Country (Master Table)**  
Stores unique country names and acts as the central reference table.

**Emission**  
Contains emission data by energy type and year, including per capita emissions.

**Production**  
Stores energy production data by country and year.

**Consumption**  
Stores energy consumption data by country and year.

**GDP**  
Stores yearly GDP values for each country.

**Population**  
Stores yearly population statistics for each country.

All tables are linked to the **Country table**, ensuring data consistency and enabling multi-table analysis.

---

## Key Analysis Questions

1. What are the **top 5 countries by GDP in the most recent year**?
2. How have **global emissions changed year over year**?
3. Which **energy types contribute most to emissions** across countries?
4. Has **energy consumption increased or decreased over time for major economies**?
5. What is the **global share of emissions by country**?
6. What is the **global average GDP, emissions, and population by year**?

---

## Key Insights

- **China contributes the largest share of global emissions**, followed by the United States and India.
- **Coal remains the largest contributor to global emissions**, showing continued dependence on fossil fuels.
- Global emissions show a **steady increasing trend**, reflecting industrial growth and rising energy demand.
- Economic growth is strongly associated with **higher energy consumption and emissions**.
- A small number of countries contribute **a significant share of global emissions**.

---

## Example SQL Queries

### Top 5 Countries by GDP (Latest Year)

```sql
SELECT country, year, value AS gdp
FROM gdp_3
WHERE year = (SELECT MAX(year) FROM gdp_3)
ORDER BY value DESC
LIMIT 5;
```

### Global Emissions Trend Over Time

```sql
SELECT year, SUM(emission) AS global_emission
FROM emission
GROUP BY year
ORDER BY year;
```

### Energy Production vs Consumption by Country

```sql
SELECT p.country, p.year,
       SUM(p.production) AS total_production,
       SUM(c.consumption) AS total_consumption
FROM production AS p
JOIN consumption AS c
ON p.country = c.country
AND p.year = c.year
GROUP BY p.country, p.year
ORDER BY p.year DESC, p.country;
```

### Energy Types Contributing Most to Emissions

```sql
SELECT energy_type, SUM(emission) AS total_emission
FROM emission
GROUP BY energy_type
ORDER BY total_emission DESC;
```

### Global Emission Share by Country

```sql
SELECT country,
       SUM(emission) AS total_emission,
       SUM(emission) * 100.0 /
       (SELECT SUM(emission)
        FROM emission
        WHERE year = (SELECT MAX(year) FROM emission))
       AS global_share_percent
FROM emission
WHERE year = (SELECT MAX(year) FROM emission)
GROUP BY country
ORDER BY global_share_percent DESC;
```

---

## SQL Concepts Used

- Database creation and schema design
- Primary and foreign key relationships
- Data cleaning
- Multi-table joins
- Subqueries
- Aggregate functions (SUM, AVG)
- Window functions
- Trend analysis
- Ratio and per capita calculations

---

## Tools Used

- MySQL  
- SQL  
- Data Analysis  

---

## Repository Contents

- SQL queries file  
- Dataset files (CSV)  
- ER diagram  
- Project presentation explaining analysis and insights  

---

## Project Preview

<img width="1617" height="996" alt="Screenshot 2026-03-06 213449" src="https://github.com/user-attachments/assets/d5d82119-e3d9-41b4-bef9-c6f0475de12f" />

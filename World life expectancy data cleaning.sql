#Part 1: Cleaning Data
Select *						
From world_life_expectancy;
------------------------------------------------------ # Removing Duplicates
#Looking for duplicates
Select country, year, concat(country, year), count(concat(country, year))
From world_life_expectancy
Group by Country, year, concat(country, year)
Having count(concat(country, year)) > 1
# R = found some
;
#Need to find Row IDS for the duplicates
Select *
From (Select row_id,
concat(country, year),
row_number() over(partition by concat(country, year) order by concat(country, year)) as row_num
From world_life_expectancy) as row_table
Where row_num > 1
# R = found row_ids
;
# Delete Duplicates 
Delete from world_life_expectancy
where Row_ID in (
		Select Row_ID
From (Select row_id,
	  concat(country, year),
	  row_number() over(partition by concat(country, year) order by concat(country, year)) as row_num
	  From world_life_expectancy) as row_table
Where row_num > 1
;

------------------------------------------------------ # Standardizing Data
# Need to fill in missing values for status column
select *						
from world_life_expectancy;

select Distinct country						
from world_life_expectancy
where status = 'developing'
;
#update column
Update world_life_expectancy
set status = 'developing'
where country in (
				select Distinct country						
				from world_life_expectancy
				where status = 'developing');
# R = Didnt work need a different way

# Use a join query
Update world_life_expectancy t1
Join world_life_expectancy t2
	on t1.country = t2.country
set t1.status = 'Developing'
where t1.status = ''
and t2.status <> ''
and t2.status = 'Developing'
;
Update world_life_expectancy t1
Join world_life_expectancy t2
	on t1.country = t2.country
set t1.status = 'Developed'
where t1.status = ''
and t2.status <> ''
and t2.status = 'Developed'
;
#R = missing information added
-----------------
# Need to fix missing values in life expectancy column
select country, year, `Life expectancy`					
from world_life_expectancy
where `Life expectancy` = ''
# R = 2 empty values
; 
# need to self join to get the average of the year before and after to populate missing value
select t1.country, t1.year, t1.`Life expectancy`,
		t2.country, t2.year, t2.`Life expectancy`,
        t3.country, t3.year, t3.`Life expectancy`,
        round((t2.`Life expectancy` + t3.`Life expectancy`) / 2,1)
from world_life_expectancy as t1
join world_life_expectancy as t2
	on t1.country = t2.country
    and t1.Year = t2.Year - 1
join world_life_expectancy as t3
	on t1.country = t3.country
    and t1.Year = t3.Year + 1
    # R = Found the right calculation for the missing value
;
#Time to update
Update world_life_expectancy as t1
join world_life_expectancy as t2
	on t1.country = t2.country
    and t1.Year = t2.Year - 1
join world_life_expectancy as t3
	on t1.country = t3.country
    and t1.Year = t3.Year + 1
set t1.`Life expectancy` = round((t2.`Life expectancy` + t3.`Life expectancy`) / 2,1)
where t1.`Life expectancy` = ''
;
# R = Updated Values
# DATA CLEANING FINISHED
---------------------------------------------------------------------------------------------------------------
# Part 2: Analyzing the data
Select *						
From world_life_expectancy;

Select status, count(country)
from world_life_expectancy
group by status
# R = Amout of developing countries are almost 5x the devloped countries
;
# Analyzing life excpectancy between countries using minimum and maximum
Select country, 
min(`Life expectancy`), 
max(`Life expectancy`),
round(max(`Life expectancy`) - min(`Life expectancy`),2) as Life_increase_15_years
From world_life_expectancy
group by country
having max(`Life expectancy`) <> 0
	and min(`Life expectancy`) <> 0
order by Life_increase_15_years desc
# R = African countries have biggest increase in life expectancy
;
# Finding average life expectancy each year
Select year, round(avg(`Life expectancy`),2) as avg_life
from world_life_expectancy
group by year
order by year desc
# R = average life expectancy goes up evry year by about 0.7 years
;
# Finding correlation between life expectancy and GDP
Select Country, 
round(AVG(`Life expectancy`),2) as avg_Life, 
round(AVG(GDP),0) as avg_GDP
From world_life_expectancy
Group By country
order by avg_gdp desc
# R = Positive Correlation between GDP and life expectancy
;
# Finding correlation between life expectancy and BMI
Select Country, 
round(AVG(`Life expectancy`),2) as avg_Life, 
round(AVG(BMI),0) as avg_BMI
From world_life_expectancy
where (`Life expectancy`) <> 0
Group by country
order by avg_BMI desc
# R = Negative Correlation between BMI and life expectancy
;
# Vizualizing Adult Mortality
Select country,
year,
`Life expectancy`,
`Adult Mortality`,
Sum(`Adult Mortality`) over( order by year) as Roll_total
From world_life_expectancy
;
# END OF PROJECT









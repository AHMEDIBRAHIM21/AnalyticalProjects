## Part 1: Cleaning Data
SELECT *
FROM us_income.ushouseholdincome
;
SELECT * 
FROM us_income.ushouseholdincome_statistics;
------------------------------------------------------------------------------------------ #Removing Duplicates
# Fixing column name
Alter table us_income.ushouseholdincome_statistics rename column `ï»¿id` to `id`
;
# Checking for duplicates
SELECT id, count(id)
FROM us_income.ushouseholdincome
group by id
having count(id) > 1
# R = Found 6 duplicates
;

SELECT id, count(id)
FROM us_income.ushouseholdincome_statistics
group by id
having count(id) > 1
# R = No duplicates in this table
;
#Removing duplicates
Select *
From ( Select row_id,
		id,
		row_number() over(partition by id order by id) as row_num
		From us_income. ushouseholdincome) as duplicates
Where row_num > 1
;
Delete From ushouseholdincome
where row_id IN ( Select row_id
				From ( Select row_id,
						id,
						row_number() over(partition by id order by id) as row_num
						From us_income. ushouseholdincome) as duplicates
				Where row_num > 1)
# R = No more duplicates
;
----------------------------------------------------------------------- # Standardizing Data
# Found some misspelled state names
SELECT *
FROM ushouseholdincome
;
SELECT distinct state_name, count(state_name)
FROM ushouseholdincome
group by state_name
;
Update ushouseholdincome
Set state_name = 'Georgia'
Where state_name = 'georia'
;
Update ushouseholdincome
Set state_name = 'Alabama'
Where state_name = 'alabama'
# R = Fixed spelling mistakes
;
#looking for empty values
SELECT row_id, county, city, place
FROM ushouseholdincome
where place = ''
;
Update ushouseholdincome
set place = 'Autauga'
where county = 'Autauga County'
;
# Looing for misspelled names in type
SELECT type, count(type)
FROM ushouseholdincome
group by type
# R = Found 2 misselled words
;
Update ushouseholdincome
set type = 'CDP'
where type = 'CPD'
;
Update ushouseholdincome
set type = 'Borough'
where type = 'Boroughs'
# Names corrected
;
------------------------------------------------------------------------------------------
# Part 2: Analyzing Data
SELECT *
FROM us_income.ushouseholdincome
;

# What to find the top 10 portion of land and water by states
SELECT state_name, sum(aland), sum(awater)
FROM us_income.ushouseholdincome
group by state_name
order by 2 desc
limit 10
;
SELECT state_name, sum(aland), sum(awater)
FROM us_income.ushouseholdincome
group by state_name
order by 3 desc
limit 10
;

# Now I want to combine the data
SELECT *
FROM ushouseholdincome u
Join ushouseholdincome_statistics us
	Using(id)
    Where mean <> 0
;
# I am looking for the average household income by states
SELECT u.State_Name, round(Avg(us.Mean),0) as avg_mean, round(Avg(us.Median),0) as avg_median
FROM ushouseholdincome u
Join ushouseholdincome_statistics us
	Using(id)
Where mean <> 0
Group By u.State_Name
order by 2 desc
limit 10
# R = The majority of the top 10 household income states are on the east
;
SELECT u.type, count(type) num_of_type, round(Avg(us.Mean),0) as avg_mean, round(Avg(us.Median),0) as avg_median
FROM ushouseholdincome u
Join ushouseholdincome_statistics us
	Using(id)
Where mean <> 0
Group By u.type
Having count(type) > 100
order by 3 desc
# R = Places that are City or Town have the lowest average household income
# R = Places that are Borough or Track have the highest average household income
;
# I am looking for the average household income by cities
SELECT u.state_name, u.city, round(Avg(us.Mean),0) as avg_mean 
FROM ushouseholdincome u
Join ushouseholdincome_statistics us
	Using(id)
Where mean <> 0
Group By u.state_name, u.city
order by 3 desc
# R = The cities with the most avg household income are on the east coast
;

# Project Complete








-- 1. GLOBAL SITUATION
-- G_Q1 - According to the World Bank, what was the total forest area of the world in 1990?
-- G_Q2 - As of 2016, the most recent year for which data was available, what had that number fallen to?
-- G_Q3 - As of 2016, the most recent year for which data was available, what was the loss in absolute terms?
-- G_Q4- As of 2016, the most recent year for which data was available, what was the loss in percentage terms?
-- G_Q5 - The forest area lost over this time period is slightly more than the entire land area of which country listed for the year 2016?
-- G_Q6 - What was the entire land area of that country listed for the year 2016?
WITH t0 AS (
    SELECT 
        "year", 
        ROUND(SUM(forest_area_sq_km::numeric), 2) AS sum_forest_area_sq_km
    FROM 
        forestation f
    WHERE 1=1
        and "year" IN (1990, 2016)
        and country_name = 'World'
    GROUP BY 
        "year"
),
t1 AS (
    SELECT 
        MAX(CASE WHEN "year" = 1990 THEN sum_forest_area_sq_km END) AS sum_forest_area_sq_km_1990,
        MAX(CASE WHEN "year" = 2016 THEN sum_forest_area_sq_km END) AS sum_forest_area_sq_km_2016
    FROM 
        t0
)
,t2 as (
SELECT 
    sum_forest_area_sq_km_1990,
    sum_forest_area_sq_km_2016,
    sum_forest_area_sq_km_1990 - sum_forest_area_sq_km_2016 AS forest_area_lost_1990_to_2016_sq_km,
    round(((sum_forest_area_sq_km_1990 - sum_forest_area_sq_km_2016)/sum_forest_area_sq_km_1990*100)::numeric,2) as forest_area_lost_1990_to_2016_perc
FROM 
    t1
)
,t3 as (
select 
sum_forest_area_sq_km_1990,
sum_forest_area_sq_km_2016,
forest_area_lost_1990_to_2016_sq_km,
forest_area_lost_1990_to_2016_perc,
f2.country_name as country_eq_name,
round(f2.total_area_sq_km,2) as country_eq_total_area_sq_km
from t2
join forestation f2 on t2.forest_area_lost_1990_to_2016_sq_km >= f2.total_area_sq_km
                      and f2."year" = 2016
order by f2.total_area_sq_km desc
limit 1
)
select 
sum_forest_area_sq_km_1990 as G_Q1,
sum_forest_area_sq_km_2016 as G_Q2,
forest_area_lost_1990_to_2016_sq_km as G_Q3,
forest_area_lost_1990_to_2016_perc as G_Q4,
country_eq_name as G_Q5,
country_eq_total_area_sq_km as G_Q6
from t3;

-- 2. REGIONAL OUTLOOK
-- R_Q1 - In 2016, what was the percent of the total land area of the world designated as forest?
-- R_Q2 - Which region had the highest relative forestation in 2016?
-- R_Q3 - What was the percentage of forestation for the region with the highest relative forestation in 2016?
-- R_Q4 - Which region had the lowest relative forestation in 2016?
-- R_Q5 - What was the percentage of forestation for the region with the lowest relative forestation in 2016?
-- R_Q6 - In 1990, what was the percent of the total land area of the world designated as forest?
-- R_Q7 - Which region had the highest relative forestation in 1990?
-- R_Q8 - What was the percentage of forestation for the region with the highest relative forestation in 1990?
-- R_Q9 - Which region had the lowest relative forestation in 1990?
-- R_Q10 - What was the percentage of forestation for the region with the lowest relative forestation in 1990?
-- R_Q11 - Which regions of the world decreased in percent forest area from 1990 to 2016?
-- R_Q12 - By how much did each of these regions decrease in percentage terms from 1990 to 2016?
-- R_Q13 - What was the initial percentage of forest area for each of these regions in 1990?
-- R_Q14 - What was the final percentage of forest area for each of these regions in 2016?
-- R_Q15 - Did all other regions increase in forest area over this time period?
-- R_Q16 - What was the impact of the decrease in these two regions on the overall percent forest area of the world from 1990 to 2016?
-- R_Q17 - What was the percent forest area of the world in 1990?
-- R_Q18 - What was the percent forest area of the world in 2016?

-- Le precedenti domande trovano risposta nei dati tabellari della seguente query

with 
t1 as (
select 
f1.region,
round((sum(f1.forest_area_sq_km)/sum(f1.total_area_sq_km)*100)::numeric,2) as forest_percentage_in_1990
from forestation f1
where f1."year" = 1990
group by f1.region
)
,t2 as (
select
f2.region,
round((sum(f2.forest_area_sq_km)/sum(f2.total_area_sq_km)*100)::numeric,2) as forest_percentage_in_2016
from forestation f2
where f2."year" = 2016
group by f2.region
)
select 
t1.region,
t1.forest_percentage_in_1990,
t2.forest_percentage_in_2016
from t1
join t2 on t1.region = t2.region
order by 2 desc,3 desc
;

-- 3. COUNTRY-LEVEL DETAIL
-- 3.A. SUCCESS STORIES
-- 3.B.	LARGEST CONCERNS
-- 3.C.	QUARTILES
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
-- 2_Q1 - Figure 2.1: Country Details Forest Area Change Percentage, 1990 & 2016:
with 
t1 as (
select 
f1.region,
f1.country_name,
round((sum(f1.forest_area_sq_km)/sum(f1.total_area_sq_km)*100)::numeric,2) as forest_percentage_in_1990
from forestation f1
where f1."year" = 1990
group by f1.region,f1.country_name
)
,t2 as (
select
f2.region,
f2.country_name,
round((sum(f2.forest_area_sq_km)/sum(f2.total_area_sq_km)*100)::numeric,2) as forest_percentage_in_2016
from forestation f2
where f2."year" = 2016
group by f2.region,f2.country_name
)
select 
t1.country_name,
t2.forest_percentage_in_2016 - t1.forest_percentage_in_1990 as forest_area_change_in_perc
from t1
join t2 on t1.region = t2.region
          and t1.country_name = t2.country_name
order by 2 desc;

-- 2_Q2 - Table 2.1: Percent Forest Area by Region, 1990 & 2016
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
t2.forest_percentage_in_2016,
t2.forest_percentage_in_2016 - t1.forest_percentage_in_1990 as forest_area_change_in_perc
from t1
join t2 on t1.region = t2.region
order by 2 desc,3 desc
;

-- 3. COUNTRY-LEVEL DETAIL
-- 3.A. SUCCESS STORIES
-- 3_A_Q1 Top 5 Increase in Forest Area by Country, 1990 & 2016
with 
t1 as (
select 
f1.region,
f1.country_name,
round(sum(f1.forest_area_sq_km::numeric),2) as forest_area_in_1990
from forestation f1
where f1."year" = 1990
group by f1.region,f1.country_name
)
,t2 as (
select 
f2.region,
f2.country_name,
round(sum(f2.total_area_sq_km),2) as total_area_sq_km_in_2016,
round(sum(f2.forest_area_sq_km::numeric),2) as forest_area_in_2016
from forestation f2
where f2."year" = 2016
group by f2.region,f2.country_name
)
select 
t1.region,
t1.country_name,
t2.total_area_sq_km_in_2016,
t2.forest_area_in_2016-t1.forest_area_in_1990 as forest_area_change
from t1
join t2 on t1.region = t2.region
and t1.country_name = t2.country_name
where t2.forest_area_in_2016-t1.forest_area_in_1990 > 0
and t1.region <> 'World'
order by 4 desc
limit 5;
-- 3_A_Q2 Top 5 Increase in Forest Area percentage by Country, 1990 & 2016
with 
t1 as (
select 
f1.region,
f1.country_name,
round(sum(f1.forest_area_sq_km::numeric),2) as forest_area_in_1990
from forestation f1
where f1."year" = 1990
group by f1.region,f1.country_name
)
,t2 as (
select 
f2.region,
f2.country_name,
round(sum(f2.total_area_sq_km),2) as total_area_sq_km_in_2016,
round(sum(f2.forest_area_sq_km::numeric),2) as forest_area_in_2016
from forestation f2
where f2."year" = 2016
group by f2.region,f2.country_name
)
select 
t1.region,
t1.country_name,
t2.total_area_sq_km_in_2016,
round((1-(t1.forest_area_in_1990/t2.forest_area_in_2016))*100) as abs_forest_area_change
from t1
join t2 on t1.region = t2.region
and t1.country_name = t2.country_name
where 1=1
and t2.forest_area_in_2016 > t1.forest_area_in_1990
and t1.region <> 'World'
order by 4 desc
limit 5;

-- 3.B.	LARGEST CONCERNS
-- 3_B_Q1 Top 5 Increase in Forest Area by Country, 1990 & 2016
with 
t1 as (
select 
f1.region,
f1.country_name,
round(sum(f1.forest_area_sq_km::numeric),2) as forest_area_in_1990
from forestation f1
where f1."year" = 1990
group by f1.region,f1.country_name
)
,t2 as (
select 
f2.region,
f2.country_name,
round(sum(f2.total_area_sq_km),2) as total_area_sq_km_in_2016,
round(sum(f2.forest_area_sq_km::numeric),2) as forest_area_in_2016
from forestation f2
where f2."year" = 2016
group by f2.region,f2.country_name
)
select 
t1.region,
t1.country_name,
t2.total_area_sq_km_in_2016,
abs(t2.forest_area_in_2016-t1.forest_area_in_1990) as abs_forest_area_change
from t1
join t2 on t1.region = t2.region
and t1.country_name = t2.country_name
where t2.forest_area_in_2016 < t1.forest_area_in_1990
and t1.region <> 'World'
order by 4 desc 
limit 3;
-- 3_B_Q2 Top 5 Increase in Forest Area percentage by Country, 1990 & 2016
with 
t1 as (
select 
f1.region,
f1.country_name,
round(sum(f1.forest_area_sq_km::numeric),2) as forest_area_in_1990
from forestation f1
where f1."year" = 1990
group by f1.region,f1.country_name
)
,t2 as (
select 
f2.region,
f2.country_name,
round(sum(f2.total_area_sq_km),2) as total_area_sq_km_in_2016,
round(sum(f2.forest_area_sq_km::numeric),2) as forest_area_in_2016
from forestation f2
where f2."year" = 2016
group by f2.region,f2.country_name
)
select 
t1.region,
t1.country_name,
t2.total_area_sq_km_in_2016,
round((1-(t2.forest_area_in_2016/t1.forest_area_in_1990))*100) as abs_forest_area_change
from t1
join t2 on t1.region = t2.region
and t1.country_name = t2.country_name
where 1=1
and t2.forest_area_in_2016 < t1.forest_area_in_1990
and t1.region <> 'World'
order by 4 desc
limit 5;
-- 3.C.	QUARTILES
-- 3_C_Q1 Table 3.5: Count of Countries Grouped by Forestation Percent Quartiles, 2016
-- 3_C_Q2 Table 3.6: Top Quartile Countries, 2016
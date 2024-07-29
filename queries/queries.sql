-- 1. GLOBAL SITUATION
-- G_Q1 - According to the World Bank, what was the total forest area of the world in 1990?
-- G_Q2 - As of 2016, the most recent year for which data was available, what had that number fallen to?
-- G_Q3 - As of 2016, the most recent year for which data was available, what was the loss in absolute terms?
-- G_Q4 - As of 2016, the most recent year for which data was available, what was the loss in percentage terms?
-- G_Q5 - The forest area lost over this time period is slightly more than the entire land area of which country listed for the year 2016?
-- G_Q6 - What was the entire land area of that country listed for the year 2016?

SELECT Round(f1.forest_area_sq_km :: numeric, 2) AS forest_area_sq_km_1990,
       Round(f2.forest_area_sq_km :: numeric, 2) AS forest_area_sq_km_2016,
       Round(Abs(f2.forest_area_sq_km - f1.forest_area_sq_km):: numeric, 2) AS forest_area_sq_km_lost,
       Round((Abs(f2.forest_area_sq_km - f1.forest_area_sq_km)/ f1.forest_area_sq_km * 100):: numeric, 2) AS forest_area_pct_lost
FROM forestation f1
JOIN forestation f2 ON f1.country_code = f2.country_code
AND f1.country_name = f2.country_name
WHERE 1 = 1
  AND f1.country_name = 'World'
  AND f1."year" = 1990
  AND f2."year" = 2016;


SELECT country_name,
       Round(total_area_sq_km, 2) AS total_area_sq_km
FROM forestation f
WHERE 1 = 1
  AND "year" = 2016
  AND total_area_sq_km <=
    (SELECT Max(Round(Abs(f2.forest_area_sq_km - f1.forest_area_sq_km) :: NUMERIC, 2))
     FROM forestation f1
     JOIN forestation f2 ON f1.country_code = f2.country_code
     AND f1.country_name = f2.country_name
     WHERE 1 = 1
       AND f1.country_name = 'World'
       AND f1."year" = 1990
       AND f2."year" = 2016)
ORDER BY total_area_sq_km DESC
LIMIT 1;

-- 2. REGIONAL OUTLOOK
-- 2_Q1 - Figure 2.1: Country Details Forest Area Change Percentage, 1990 & 2016:

SELECT f1.country_name,
       Round(100 - (SUM(f1.forest_area_sq_km) / SUM(f2.forest_area_sq_km) * 100) :: NUMERIC, 2) AS forest_area_change_in_perc
FROM forestation f1
JOIN forestation f2 ON f1.country_code = f2.country_code
AND f1.country_name = f2.country_name
WHERE 1 = 1
  AND f1.country_name <> 'World'
  AND f1."year" = 1990
  AND f2."year" = 2016
GROUP BY f1.country_name
ORDER BY 2 DESC;

-- 2_Q2 - Table 2.1: Percent Forest Area by Region, 1990 & 2016

SELECT f1.region,
       Round((SUM(f1.forest_area_sq_km) / SUM(f1.total_area_sq_km) * 100) :: NUMERIC, 2) AS forest_percentage_in_1990,
       Round((SUM(f2.forest_area_sq_km) / SUM(f2.total_area_sq_km) * 100) :: NUMERIC, 2) AS forest_percentage_in_2016,
       Round((SUM(f2.forest_area_sq_km) / SUM(f2.total_area_sq_km) * 100) :: NUMERIC, 2) - Round((SUM(f1.forest_area_sq_km) / SUM(f1.total_area_sq_km) * 100) :: NUMERIC, 2) AS forest_area_change_in_perc
FROM forestation f1
JOIN forestation f2 ON f1.country_code = f2.country_code
AND f1.country_name = f2.country_name
WHERE 1 = 1
  AND f1."year" = 1990
  AND f2."year" = 2016
GROUP BY f1.region
ORDER BY 2 DESC;

-- 3. COUNTRY-LEVEL DETAIL
-- 3.A. SUCCESS STORIES
-- 3_A_Q1 - Table 3.1: Top 5 Increase in Forest Area by Country, 1990 & 2016

SELECT f1.region,
       f1.country_name,
       round(sum(f2.total_area_sq_km):: numeric, 2) AS total_area_sq_km_2016,
       Round(Abs(sum(f2.forest_area_sq_km) - sum(f1.forest_area_sq_km)) :: NUMERIC, 2) AS forest_area_change_sqkm
FROM forestation f1
JOIN forestation f2 ON f1.country_code = f2.country_code
AND f1.country_name = f2.country_name
AND f2.forest_area_sq_km >= f1.forest_area_sq_km
WHERE 1 = 1
  AND f1.country_name <> 'World'
  AND f1."year" = 1990
  AND f2."year" = 2016
GROUP BY f1.country_name,
         f1.region
ORDER BY 4 DESC
LIMIT 5;

-- 3_A_Q2 - Table 3.2: Top 5 Increase in Forest Area percentage by Country, 1990 & 2016

SELECT f1.region,
       f1.country_name,
       round(sum(f2.total_area_sq_km):: numeric, 2) AS total_area_sq_km_2016,
       Round(Abs((1 - sum(f2.forest_area_sq_km)/ sum(f1.forest_area_sq_km))* 100) :: NUMERIC, 0) AS forest_area_change_sqkm
FROM forestation f1
JOIN forestation f2 ON f1.country_code = f2.country_code
AND f1.country_name = f2.country_name
AND f2.forest_area_sq_km >= f1.forest_area_sq_km
WHERE 1 = 1
  AND f1.country_name <> 'World'
  AND f1."year" = 1990
  AND f2."year" = 2016
GROUP BY f1.region,
         f1.country_name
ORDER BY 4 DESC
LIMIT 5;

-- 3.B. LARGEST CONCERNS
-- 3_B_Q1 - Table 3.3: Top 3 Amount Decrease in Forest Area by Country, 1990 & 2016

SELECT f1.region,
       f1.country_name,
       round(sum(f2.total_area_sq_km):: numeric, 2) AS total_area_sq_km_2016,
       Round(Abs(sum(f2.forest_area_sq_km)- sum(f1.forest_area_sq_km)) :: NUMERIC, 0) AS forest_area_change_sqkm
FROM forestation f1
JOIN forestation f2 ON f1.country_code = f2.country_code
AND f1.country_name = f2.country_name
AND f2.forest_area_sq_km <= f1.forest_area_sq_km
WHERE 1 = 1
  AND f1.country_name <> 'World'
  AND f1."year" = 1990
  AND f2."year" = 2016
GROUP BY f1.region,
         f1.country_name
ORDER BY 4 DESC
LIMIT 3;

-- 3_B_Q2 - Table 3.4: Top 5 Percent Decrease in Forest Area by Country, 1990 & 2016

SELECT f1.region,
       f1.country_name,
       round(sum(f2.total_area_sq_km):: numeric, 2) AS total_area_sq_km_2016,
       Round(Abs((1 - sum(f2.forest_area_sq_km)/ sum(f1.forest_area_sq_km))* 100) :: NUMERIC, 0) AS forest_area_change_sqkm
FROM forestation f1
JOIN forestation f2 ON f1.country_code = f2.country_code
AND f1.country_name = f2.country_name
AND f2.forest_area_sq_km <= f1.forest_area_sq_km
WHERE 1 = 1
  AND f1.country_name <> 'World'
  AND f1."year" = 1990
  AND f2."year" = 2016
GROUP BY f1.region,
         f1.country_name
ORDER BY 4 DESC
LIMIT 5;

-- 3.C. QUARTILES
-- 3_C_Q1 - Table 3.5: Count of Countries Grouped by Forestation Percent Quartiles, 2016

SELECT FLOOR( f.perc_land_designed_as_forest_sq_km/25)+1 AS quartile,
       count(*)
FROM forestation f
WHERE f."year" = 2016
  AND f.country_name <> 'World'
  AND perc_land_designed_as_forest_sq_km IS NOT NULL
GROUP BY 1
ORDER BY 1;


-- 3_C_Q2 - Table 3.6: Top Quartile Countries, 2016

SELECT region,
       country_name,
       ROUND(sum(perc_land_designed_as_forest_sq_km):: numeric, 2) AS pct_designated_as_forest
FROM forestation f
WHERE f."year" = 2016
  AND f.country_name <> 'World'
  AND perc_land_designed_as_forest_sq_km IS NOT NULL
  AND ROUND(perc_land_designed_as_forest_sq_km :: numeric, 2) BETWEEN 75 AND 100
GROUP BY 1,
         2
ORDER BY 3 DESC;
-- 1. GLOBAL SITUATION
-- G_Q1 - According to the World Bank, what was the total forest area of the world in 1990?
-- G_Q2 - As of 2016, the most recent year for which data was available, what had that number fallen to?
-- G_Q3 - As of 2016, the most recent year for which data was available, what was the loss in absolute terms?
-- G_Q4 - As of 2016, the most recent year for which data was available, what was the loss in percentage terms?
-- G_Q5 - The forest area lost over this time period is slightly more than the entire land area of which country listed for the year 2016?
-- G_Q6 - What was the entire land area of that country listed for the year 2016?

WITH t0 AS (
    SELECT 
        "year", 
        ROUND(SUM(forest_area_sq_km::numeric), 2) AS sum_forest_area_sq_km
    FROM 
        forestation f
    WHERE 
        "year" IN (1990, 2016)
        AND country_name = 'World'
    GROUP BY 
        "year"
),
t1 AS (
    SELECT 
        MAX(CASE WHEN "year" = 1990 THEN sum_forest_area_sq_km END) AS sum_forest_area_sq_km_1990,
        MAX(CASE WHEN "year" = 2016 THEN sum_forest_area_sq_km END) AS sum_forest_area_sq_km_2016
    FROM 
        t0
),
t2 AS (
    SELECT 
        sum_forest_area_sq_km_1990,
        sum_forest_area_sq_km_2016,
        sum_forest_area_sq_km_1990 - sum_forest_area_sq_km_2016 AS forest_area_lost_1990_to_2016_sq_km,
        ROUND(((sum_forest_area_sq_km_1990 - sum_forest_area_sq_km_2016)/sum_forest_area_sq_km_1990*100)::numeric, 2) AS forest_area_lost_1990_to_2016_perc
    FROM 
        t1
),
t3 AS (
    SELECT 
        sum_forest_area_sq_km_1990,
        sum_forest_area_sq_km_2016,
        forest_area_lost_1990_to_2016_sq_km,
        forest_area_lost_1990_to_2016_perc,
        f2.country_name AS country_eq_name,
        ROUND(f2.total_area_sq_km, 2) AS country_eq_total_area_sq_km
    FROM 
        t2
    JOIN 
        forestation f2 
    ON 
        t2.forest_area_lost_1990_to_2016_sq_km >= f2.total_area_sq_km
        AND f2."year" = 2016
    ORDER BY 
        f2.total_area_sq_km DESC
    LIMIT 1
)
SELECT 
    sum_forest_area_sq_km_1990 AS G_Q1,
    sum_forest_area_sq_km_2016 AS G_Q2,
    forest_area_lost_1990_to_2016_sq_km AS G_Q3,
    forest_area_lost_1990_to_2016_perc AS G_Q4,
    country_eq_name AS G_Q5,
    country_eq_total_area_sq_km AS G_Q6
FROM 
    t3;

-- 2. REGIONAL OUTLOOK
-- 2_Q1 - Figure 2.1: Country Details Forest Area Change Percentage, 1990 & 2016:
WITH t1 AS (
    SELECT 
        f1.region,
        f1.country_name,
        ROUND((SUM(f1.forest_area_sq_km)/SUM(f1.total_area_sq_km)*100)::numeric, 2) AS forest_percentage_in_1990
    FROM 
        forestation f1
    WHERE 
        f1."year" = 1990
    GROUP BY 
        f1.region, f1.country_name
),
t2 AS (
    SELECT
        f2.region,
        f2.country_name,
        ROUND((SUM(f2.forest_area_sq_km)/SUM(f2.total_area_sq_km)*100)::numeric, 2) AS forest_percentage_in_2016
    FROM 
        forestation f2
    WHERE 
        f2."year" = 2016
    GROUP BY 
        f2.region, f2.country_name
)
SELECT 
    t1.country_name,
    t2.forest_percentage_in_2016 - t1.forest_percentage_in_1990 AS forest_area_change_in_perc
FROM 
    t1
JOIN 
    t2 
ON 
    t1.region = t2.region
    AND t1.country_name = t2.country_name
ORDER BY 
    2 DESC;

-- 2_Q2 - Table 2.1: Percent Forest Area by Region, 1990 & 2016
WITH t1 AS (
    SELECT 
        f1.region,
        ROUND((SUM(f1.forest_area_sq_km)/SUM(f1.total_area_sq_km)*100)::numeric, 2) AS forest_percentage_in_1990
    FROM 
        forestation f1
    WHERE 
        f1."year" = 1990
    GROUP BY 
        f1.region
),
t2 AS (
    SELECT
        f2.region,
        ROUND((SUM(f2.forest_area_sq_km)/SUM(f2.total_area_sq_km)*100)::numeric, 2) AS forest_percentage_in_2016
    FROM 
        forestation f2
    WHERE 
        f2."year" = 2016
    GROUP BY 
        f2.region
)
SELECT 
    t1.region,
    t1.forest_percentage_in_1990,
    t2.forest_percentage_in_2016,
    t2.forest_percentage_in_2016 - t1.forest_percentage_in_1990 AS forest_area_change_in_perc
FROM 
    t1
JOIN 
    t2 
ON 
    t1.region = t2.region
ORDER BY 
    2 DESC, 3 DESC;

-- 3. COUNTRY-LEVEL DETAIL
-- 3.A. SUCCESS STORIES
-- 3_A_Q1 Top 5 Increase in Forest Area by Country, 1990 & 2016
WITH t1 AS (
    SELECT 
        f1.region,
        f1.country_name,
        ROUND(SUM(f1.forest_area_sq_km::numeric), 2) AS forest_area_in_1990
    FROM 
        forestation f1
    WHERE 
        f1."year" = 1990
    GROUP BY 
        f1.region, f1.country_name
),
t2 AS (
    SELECT 
        f2.region,
        f2.country_name,
        ROUND(SUM(f2.total_area_sq_km), 2) AS total_area_sq_km_in_2016,
        ROUND(SUM(f2.forest_area_sq_km::numeric), 2) AS forest_area_in_2016
    FROM 
        forestation f2
    WHERE 
        f2."year" = 2016
    GROUP BY 
        f2.region, f2.country_name
)
SELECT 
    t1.region,
    t1.country_name,
    t2.total_area_sq_km_in_2016,
    t2.forest_area_in_2016 - t1.forest_area_in_1990 AS forest_area_change
FROM 
    t1
JOIN 
    t2 
ON 
    t1.region = t2.region
    AND t1.country_name = t2.country_name
WHERE 
    t2.forest_area_in_2016 - t1.forest_area_in_1990 > 0
    AND t1.region <> 'World'
ORDER BY 
    4 DESC
LIMIT 5;

-- 3_A_Q2 Top 5 Increase in Forest Area percentage by Country, 1990 & 2016
WITH t1 AS (
    SELECT 
        f1.region,
        f1.country_name,
        ROUND(SUM(f1.forest_area_sq_km::numeric), 2) AS forest_area_in_1990
    FROM 
        forestation f1
    WHERE 
        f1."year" = 1990
    GROUP BY 
        f1.region, f1.country_name
),
t2 AS (
    SELECT 
        f2.region,
        f2.country_name,
        ROUND(SUM(f2.total_area_sq_km), 2) AS total_area_sq_km_in_2016,
        ROUND(SUM(f2.forest_area_sq_km::numeric), 2) AS forest_area_in_2016
    FROM 
        forestation f2
    WHERE 
        f2."year" = 2016
    GROUP BY 
        f2.region, f2.country_name
)
SELECT 
    t1.region,
    t1.country_name,
    t2.total_area_sq_km_in_2016,
    ROUND((1 - (t1.forest_area_in_1990 / t2.forest_area_in_2016)) * 100) AS abs_forest_area_change
FROM 
    t1
JOIN 
    t2 
ON 
    t1.region = t2.region
    AND t1.country_name = t2.country_name
WHERE 
    t2.forest_area_in_2016 > t1.forest_area_in_1990
    AND t1.region <> 'World'
ORDER BY 
    4 DESC
LIMIT 5;

-- 3.B. LARGEST CONCERNS
-- 3_B_Q1 Top 5 Increase in Forest Area by Country, 1990 & 2016
WITH t1 AS (
    SELECT 
        f1.region,
        f1.country_name,
        ROUND(SUM(f1.forest_area_sq_km::numeric), 2) AS forest_area_in_1990
    FROM 
        forestation f1
    WHERE 
        f1."year" = 1990
    GROUP BY 
        f1.region, f1.country_name
),
t2 AS (
    SELECT 
        f2.region,
        f2.country_name,
        ROUND(SUM(f2.total_area_sq_km), 2) AS total_area_sq_km_in_2016,
        ROUND(SUM(f2.forest_area_sq_km::numeric), 2) AS forest_area_in_2016
    FROM 
        forestation f2
    WHERE 
        f2."year" = 2016
    GROUP BY 
        f2.region, f2.country_name
)
SELECT 
    t1.region,
    t1.country_name,
    t2.total_area_sq_km_in_2016,
    ABS(t2.forest_area_in_2016 - t1.forest_area_in_1990) AS abs_forest_area_change
FROM 
    t1
JOIN 
    t2 
ON 
    t1.region = t2.region
    AND t1.country_name = t2.country_name
WHERE 
    t2.forest_area_in_2016 < t1.forest_area_in_1990
    AND t1.region <> 'World'
ORDER BY 
    4 DESC 
LIMIT 3;

-- 3_B_Q2 Top 5 Increase in Forest Area percentage by Country, 1990 & 2016
WITH t1 AS (
    SELECT 
        f1.region,
        f1.country_name,
        ROUND(SUM(f1.forest_area_sq_km::numeric), 2) AS forest_area_in_1990
    FROM 
        forestation f1
    WHERE 
        f1."year" = 1990
    GROUP BY 
        f1.region, f1.country_name
),
t2 AS (
    SELECT 
        f2.region,
        f2.country_name,
        ROUND(SUM(f2.total_area_sq_km), 2) AS total_area_sq_km_in_2016,
        ROUND(SUM(f2.forest_area_sq_km::numeric), 2) AS forest_area_in_2016
    FROM 
        forestation f2
    WHERE 
        f2."year" = 2016
    GROUP BY 
        f2.region, f2.country_name
)
SELECT 
    t1.region,
    t1.country_name,
    t2.total_area_sq_km_in_2016,
    ROUND((1 - (t2.forest_area_in_2016 / t1.forest_area_in_1990)) * 100) AS abs_forest_area_change
FROM 
    t1
JOIN 
    t2 
ON 
    t1.region = t2.region
    AND t1.country_name = t2.country_name
WHERE 
    t2.forest_area_in_2016 < t1.forest_area_in_1990
    AND t1.region <> 'World'
ORDER BY 
    4 DESC
LIMIT 5;

-- 3.C. QUARTILES
-- 3_C_Q1 Table 3.5: Count of Countries Grouped by Forestation Percent Quartiles, 2016
WITH t0 AS (
    SELECT 
        country_name,
        region,
        perc_land_designed_as_forest_sq_km,
        CASE
            WHEN ROUND(perc_land_designed_as_forest_sq_km::numeric, 2) BETWEEN 75 AND 100 THEN 4
            WHEN ROUND(perc_land_designed_as_forest_sq_km::numeric, 2) BETWEEN 50 AND 75 THEN 3
            WHEN ROUND(perc_land_designed_as_forest_sq_km::numeric, 2) BETWEEN 25 AND 50 THEN 2
            WHEN ROUND(perc_land_designed_as_forest_sq_km::numeric, 2) BETWEEN 0 AND 25 THEN 1
        END AS quartile
    FROM 
        forestation f 
    WHERE  
        f."year" = 2016
        AND f.country_name <> 'World'
        AND perc_land_designed_as_forest_sq_km IS NOT NULL
)
SELECT 
    quartile,
    COUNT(*) AS number_of_countries
FROM 
    t0
GROUP BY 
    quartile
ORDER BY 
    quartile ASC;

-- 3_C_Q2 Table 3.6: Top Quartile Countries, 2016
WITH t0 AS (
    SELECT 
        country_name,
        region,
        perc_land_designed_as_forest_sq_km,
        CASE
            WHEN ROUND(perc_land_designed_as_forest_sq_km::numeric, 2) BETWEEN 75 AND 100 THEN 4
            WHEN ROUND(perc_land_designed_as_forest_sq_km::numeric, 2) BETWEEN 50 AND 75 THEN 3
            WHEN ROUND(perc_land_designed_as_forest_sq_km::numeric, 2) BETWEEN 25 AND 50 THEN 2
            WHEN ROUND(perc_land_designed_as_forest_sq_km::numeric, 2) BETWEEN 0 AND 25 THEN 1
        END AS quartile
    FROM 
        forestation f 
    WHERE  
        f."year" = 2016
        AND f.country_name <> 'World'
        AND perc_land_designed_as_forest_sq_km IS NOT NULL
)
SELECT 
    region,
    country_name,
    ROUND(perc_land_designed_as_forest_sq_km::numeric, 2) AS pct_designated_as_forest
FROM 
    t0
WHERE 
    quartile = 4
ORDER BY 
    3 DESC;

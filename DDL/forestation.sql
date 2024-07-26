CREATE OR REPLACE VIEW forestation AS
WITH t0 AS (
    SELECT
        r.country_name,
        r.country_code,
        r.region,
        r.income_group,
        la.year,
        la.total_area_sq_mi::numeric * 2.59 AS total_area_sq_km,
        fa.forest_area_sqkm AS forest_area_sq_km
    FROM
        regions r
    JOIN
        land_area la ON r.country_code = la.country_code
        AND COALESCE(la.total_area_sq_mi, 0::double precision) <> 0::double precision
    JOIN
        forest_area fa ON la.country_code = fa.country_code
        AND la.year = fa.year
        AND fa.forest_area_sqkm IS NOT NULL
)
SELECT
    country_name,
    country_code,
    region,
    income_group,
    year,
    total_area_sq_km,
    forest_area_sq_km,
    forest_area_sq_km / total_area_sq_km::double precision * 100::double precision AS perc_land_designed_as_forest_sq_km
FROM
    t0;

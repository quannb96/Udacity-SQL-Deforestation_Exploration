CREATE VIEW
    forestation AS
SELECT
    forest_area.country_code,
    forest_area.country_name,
    forest_area.year,
    forest_area.forest_area_sqkm,
    land_area.total_area_sq_mi * 2.59 AS total_area_sqkm,
    regions.region,
    regions.income_group,
    (forest_area.forest_area_sqkm / (land_area.total_area_sq_mi * 2.59)) * 100 AS forest_percent
FROM
    forest_area
    JOIN land_area ON forest_area.country_code = land_area.country_code
    AND forest_area.year = land_area.year
    JOIN regions ON forest_area.country_code = regions.country_code;

-- Select all of forestation view:
SELECT
    *
FROM
    forestation

--  ========= Part1 =========
--  a. What was the total forest area (in sq km) of the world in 1990?
SELECT
    SUM(forest_area_sqkm) AS total_forest_area_1990
FROM
    forest_area
WHERE
    country_name = 'World'
    AND year = 1990;
-- Output: total_forest_area_1990: 41282694.9

-- b. What was the total forest area (in sq km) of the world in 2016?
SELECT
    SUM(forest_area_sqkm) AS total_forest_area_2016
FROM
    forest_area
WHERE
    country_name = 'World'
    AND year = 2016;
-- Output: total_forest_area_2016: 39958245.9

-- c. What was the change (in sq km) in the forest area of the world from 1990 to 2016?
SELECT
    (
        SELECT
            SUM(forest_area_sqkm)
        FROM
            forest_area
        WHERE
            country_name = 'World'
            AND year = 2016
    ) - (
        SELECT
            SUM(forest_area_sqkm)
        FROM
            forest_area
        WHERE
            country_name = 'World'
            AND year = 1990
    ) AS forest_area_change_sqkm;
-- Output: forest_area_change_sqkm: -1324449

-- d. What was the percent change in forest area of the world between 1990 and 2016?
SELECT
    (
        (
            SELECT
                SUM(forest_area_sqkm)
            FROM
                forest_area
            WHERE
                country_name = 'World'
                AND year = 2016
        ) - (
            SELECT
                SUM(forest_area_sqkm)
            FROM
                forest_area
            WHERE
                country_name = 'World'
                AND year = 1990
        )
    ) / (
        SELECT
            SUM(forest_area_sqkm)
        FROM
            forest_area
        WHERE
            country_name = 'World'
            AND year = 1990
    ) * 100 AS percent_change_forest_area;
-- Output: percent_change_forest_area: -3.20824258980244

-- e. What was the percent change in forest area of the world between 1990 and 2016?
SELECT DISTINCT
    country_name,
    total_area_sqkm AS total_area_sqkm
FROM
    forestation
WHERE
    total_area_sqkm >= (
        SELECT
            ABS(
                (
                    SELECT
                        SUM(forest_area_sqkm)
                    FROM
                        forestation
                    WHERE
                        year = 1990
                        AND country_name = 'World'
                ) - (
                    SELECT
                        SUM(forest_area_sqkm)
                    FROM
                        forestation
                    WHERE
                        year = 2016
                        AND country_name = 'World'
                )
            )
    )
ORDER BY
    total_area_sqkm
LIMIT
    1;
-- Ouput: country_name	total_area_sqkm
--        Mongolia	    1553560.0107999998

--  ========= Part 2 =========
-- a. What was the percent forest of the entire world in 2016? Which region had the 
--HIGHEST percent forest in 2016, and which had the LOWEST, to 2 decimal places?
SELECT 
    region,
    ROUND(CAST((
        SELECT SUM(forest_area_sqkm) 
        FROM forestation 
        WHERE region = sub.region AND year = 2016
    ) / (
        SELECT SUM(total_area_sqkm) 
        FROM forestation 
        WHERE region = sub.region AND year = 2016
    ) * 100 AS numeric), 2) AS forest_percent
FROM 
    forestation AS sub
WHERE 
    year = 2016
GROUP BY 
    region
ORDER BY 
    region;
-- Output:      region	                forest_percent
--         East Asia & Pacific	            26.36
--         Europe & Central Asia	        38.04
--         Latin America & Caribbean	    46.16
--         Middle East & North Africa       2.07
--         North America	                36.04
--         South Asia	                    17.51
--         Sub-Saharan Africa	            28.79
--         World	                        31.38

-- b. What was the percent forest of the entire world in 1990? Which region had the 
--HIGHEST percent forest in 1990, and which had the LOWEST, to 2 decimal places?
SELECT 
    region,
    ROUND(CAST((
        SELECT SUM(forest_area_sqkm) 
        FROM forestation 
        WHERE region = sub.region AND year = 1990
    ) / (
        SELECT SUM(total_area_sqkm) 
        FROM forestation 
        WHERE region = sub.region AND year = 1990
    ) * 100 AS numeric), 2) AS forest_percent
FROM 
    forestation AS sub
WHERE 
    year = 1990
GROUP BY 
    region
ORDER BY 
    region;
-- Output:          region	                forest_percent
--              East Asia & Pacific	            25.78
--              Europe & Central Asia	        37.28
--              Latin America & Caribbean	    51.03
--              Middle East & North Africa	    1.78
--              North America	                35.65
--              South Asia	                    16.51
--              Sub-Saharan Africa	            30.67
--              World	                        32.42
-- c. Based on the table you created, which regions of the world DECREASED in forest area from 1990 to 2016?
SELECT 
    sub.region,
    ROUND(CAST((
        SELECT SUM(forest_area_sqkm) 
        FROM forestation 
        WHERE region = sub.region AND year = 2016
    ) / (
        SELECT SUM(total_area_sqkm) 
        FROM forestation 
        WHERE region = sub.region AND year = 2016
    ) * 100 AS numeric), 2) AS forest_percent_2016,
    ROUND(CAST((
        SELECT SUM(forest_area_sqkm) 
        FROM forestation 
        WHERE region = sub.region AND year = 1990
    ) / (
        SELECT SUM(total_area_sqkm) 
        FROM forestation 
        WHERE region = sub.region AND year = 1990
    ) * 100 AS numeric), 2) AS forest_percent_1990
FROM 
    (
        SELECT 
            region
        FROM 
            forestation 
        GROUP BY 
            region
    ) AS sub
ORDER BY 
    sub.region;
-- Output:      region	                forest_percent_2016	    forest_percent_1990
--          East Asia & Pacific	                26.36	                25.78
--          Europe & Central Asia	            38.04	                37.28
--          Latin America & Caribbean	        46.16	                51.03
--          Middle East & North Africa	        2.07	                1.78
--          North America	                    36.04	                35.65
--          South Asia	                        17.51	                16.51
--          Sub-Saharan Africa	                28.79	                30.67
--          World                               31.38                   32.42

--  ========= Part 3 =========
-- SUCCESS STORIES
SELECT 
    f1.country_name,
    f1.region,
    f1.forest_area_sqkm AS forest_area_1990,
    f2.forest_area_sqkm AS forest_area_2016,
    ROUND((f2.forest_area_sqkm - f1.forest_area_sqkm)::NUMERIC, 2) AS change
FROM 
    forestation AS f1
JOIN 
    forestation AS f2 ON f1.country_code = f2.country_code
WHERE 
    f1.year = 1990
    AND f2.year = 2016
    AND f1.country_name NOT LIKE 'World'
    AND f1.forest_area_sqkm IS NOT NULL
    AND f2.forest_area_sqkm IS NOT NULL
ORDER BY 
    change DESC
LIMIT 
    2;
-- Output: 
        -- country_name,region,forest_area_1990,forest_area_2016,change
        -- China,East Asia & Pacific,1571405.938,2098635,527229.06
        -- United States,North America,3024500,3103700,79200.00
        -- India,South Asia,639390,708603.9844,69213.98
        -- Russian Federation,Europe & Central Asia,8089500,8148895,59395.00
        -- Vietnam,East Asia & Pacific,93630,149020,55390.00


-- a. Which 5 countries saw the largest amount decrease in forest area from 1990 to 2016? 
--What was the difference in forest area for each?
SELECT 
    f1.country_name,
    f1.region,
    f1.forest_area_sqkm AS forest_area_1990,
    f2.forest_area_sqkm AS forest_area_2016,
    ROUND((f2.forest_area_sqkm - f1.forest_area_sqkm)::NUMERIC, 2) AS change
FROM 
    forestation AS f1
JOIN 
    forestation AS f2 ON f1.country_code = f2.country_code
WHERE 
    f1.year = 1990
    AND f2.year = 2016
    AND f1.country_name NOT LIKE 'World'
    AND f1.forest_area_sqkm IS NOT NULL
    AND f2.forest_area_sqkm IS NOT NULL
ORDER BY 
    change ASC
LIMIT 
    5;
-- Output:  
-- country_name	        region	                forest_area_1990	forest_area_2016	change
-- Brazil          Latin America & Caribbean	5467050	            4925540	            -541510.00
-- Indonesia       East Asia & Pacific	        1185450	            903256.0156	        -282193.98
-- Myanmar         East Asia & Pacific	        392180	            284945.9961	        -107234.00
-- Nigeria         Sub-Saharan Africa	        172340	            65833.99902	        -106506.00
-- Tanzania        Sub-Saharan Africa	        559200	            456880	            -102320.00

-- b. Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016? What was the percent change to 2 decimal places for each?
SELECT 
    f1.country_name,
    f1.region,
    f1.forest_area_sqkm AS forest_area_1990,
    f2.forest_area_sqkm AS forest_area_2016,
    ROUND(CAST(((f2.forest_area_sqkm - f1.forest_area_sqkm) / f1.forest_area_sqkm) * 100 AS numeric), 2) AS change_prc
FROM 
    forestation AS f1
JOIN 
    forestation AS f2 ON f1.country_code = f2.country_code
WHERE 
    f1.year = 1990
    AND f2.year = 2016
    AND f2.forest_area_sqkm < f1.forest_area_sqkm
ORDER BY 
    change_prc
LIMIT 
    5;
-- Output: 
        -- country_name,region,forest_area_1990,forest_area_2016,change_prc
        -- Togo,Sub-Saharan Africa,6850,1681.999969,-75.45
        -- Nigeria,Sub-Saharan Africa,172340,65833.99902,-61.80
        -- Uganda,Sub-Saharan Africa,47510,19418.00049,-59.13
        -- Mauritania,Sub-Saharan Africa,4150,2210,-46.75
        -- Honduras,Latin America & Caribbean,81360,44720,-45.03

-- c. If countries were grouped by percent forestation in quartiles, which group had the most countries in it in 2016?
SELECT 
    CASE 
        WHEN forest_percent < 25 THEN '0-25%' 
        WHEN forest_percent >= 25 AND forest_percent < 50 THEN '25-50%' 
        WHEN forest_percent >= 50 AND forest_percent < 75 THEN '50-75%' 
        ELSE '75-100%' 
    END AS quartile,
    COUNT(country_name) AS count
FROM 
    forestation
WHERE 
    year = 2016
    AND forest_percent IS NOT NULL
GROUP BY 
    quartile
ORDER BY 
    quartile DESC;
-- Output: 
        -- quartile,count
        -- 75-100%,9
        -- 50-75%,38
        -- 25-50%,73
        -- 0-25%,85

-- d. List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016.
SELECT 
    f.country_name,
    f.region,
    f.forest_percent AS percent
FROM 
    forestation AS f
JOIN 
    (
        SELECT 
            country_code
        FROM 
            forestation
        WHERE 
            year = 2016
            AND forest_percent > 75
    ) AS q4 ON f.country_code = q4.country_code
WHERE 
    f.year = 2016
ORDER BY 
    percent DESC;
-- Output:
        -- country_name,region,percent
        -- Suriname,Latin America & Caribbean,98.2576939676578
        -- "Micronesia, Fed. Sts.",East Asia & Pacific,91.85723907152479
        -- Gabon,Sub-Saharan Africa,90.0376418700565
        -- Seychelles,Sub-Saharan Africa,88.41113673857889
        -- Palau,East Asia & Pacific,87.60680854912036
        -- American Samoa,East Asia & Pacific,87.5000875000875
        -- Guyana,Latin America & Caribbean,83.90144891106817
        -- Lao PDR,East Asia & Pacific,82.10823176408609
        -- Solomon Islands,East Asia & Pacific,77.86351779450665

-- e. How many countries had a percent forestation higher than the United States in 2016?
SELECT 
    COUNT(country_name) AS countries_count
FROM 
    forestation
WHERE 
    year = 2016
    AND forest_percent > (
        SELECT 
            forest_percent
        FROM 
            forestation
        WHERE 
            country_name = 'United States'
            AND year = 2016
    );

-- Midcourse Capstone: Analytics SQL
-- Open this file in DataGrip after connecting to the PostgreSQL database
-- (host: localhost  port: 5432  database: postgres  user: postgres  password: postgres)
-- Run each step one at a time (Ctrl+Enter on the current statement)

-- ============================================================
-- Step 1: Verify your tables loaded correctly
-- ============================================================
SELECT COUNT(*) AS launch_count FROM launch_events;
SELECT COUNT(*) AS weather_rows FROM site_weather;


-- ============================================================
-- Step 2: Preview each table
-- ============================================================
SELECT * FROM launch_events;
SELECT * FROM site_weather  LIMIT 5;


-- ============================================================
-- Step 3: Normalize launch_events
-- ============================================================
-- Break the flat launch_events table into three tables:
--   dim_agency    (agency_id, agency_name, country, agency_type)
--   dim_site      (site_id, site_name, country)
--   fact_launches (launch_id, mission_name, launch_date, site_id,
--                  agency_id, rocket_type, destination, mission_type,
--                  outcome, payload_kg, crew_size)


-- 3a: Create dim_agency  — done for you, study this pattern
CREATE TABLE dim_agency AS
SELECT
    ROW_NUMBER() OVER (ORDER BY agency) AS agency_id,
    agency AS agency_name,
    CASE agency
        WHEN 'Spacex'    THEN 'United States'
        WHEN 'Nasa'      THEN 'United States'
        WHEN 'Esa'       THEN 'Europe'
        WHEN 'Isro'      THEN 'India'
        WHEN 'Roscosmos' THEN 'Russia'
        ELSE 'Unknown'
    END AS country,
    CASE agency
        WHEN 'Spacex' THEN 'Private'
        ELSE 'Government'
    END AS agency_type
FROM (SELECT DISTINCT agency FROM launch_events) t;

SELECT * FROM dim_agency;


-- 3b: Create dim_site
-- Columns: site_id, site_name, country
-- Follow the same pattern as 3a above.
-- Sites: Kennedy Space Center (US), Cape Canaveral SFS (US),
--        Vandenberg SFB (US), Baikonur Cosmodrome (Kazakhstan),
--        Guiana Space Centre (French Guiana), Satish Dhawan (India)

-- YOUR CODE HERE
CREATE TABLE dim_site AS
SELECT
    ROW_NUMBER() OVER (ORDER BY launch_site),
    launch_site AS site_name,
    CASE launch_site
        WHEN 'Kennedy Space Center'    THEN 'United States'
        WHEN 'Cape Canaveral SFS'      THEN 'United States'
        WHEN 'Vandenberg SFB'      THEN 'United States'
        WHEN 'Baikonur Cosmodrome'       THEN 'Kazakhstan'
        WHEN 'Guiana Space Centre'      THEN 'French Guiana'
        WHEN 'Satish Dhawan' THEN 'India'
        ELSE 'Unknown'
    END AS country
FROM (SELECT DISTINCT launch_site FROM launch_events) t;
select row_number AS site_id, site_name, dim_site.country FROM dim_site;


-- 3c: Create fact_launches
-- Replace agency and launch_site with foreign key IDs from dim_agency and dim_site.

-- YOUR CODE HERE


SELECT * FROM dim_agency;
SELECT * FROM fact_launches LIMIT 5;


-- 3d: Spot-check — confirm foreign keys resolve correctly
SELECT f.mission_name, a.agency_name, s.site_name, f.launch_date, f.outcome
FROM fact_launches f
JOIN dim_agency a ON f.agency_id = a.agency_id
JOIN dim_site   s ON f.site_id   = s.site_id
LIMIT 10;


-- ============================================================
-- Step 4: Your Analytics Questions
-- ============================================================
-- Now that your data is normalized, write at least THREE queries
-- that answer interesting questions about space launches and
-- launch-site weather.
--
-- For each query:
--   1. Write a CREATE TABLE ... AS SELECT that stores your result.
--   2. Follow it with a SELECT * to display the result.
--   3. Name your table something descriptive (e.g. my_crew_summary).
--
-- Pick any questions from the list below, or invent your own:
--
--   A. Which agency has the best launch success rate?
--   B. How many launches went to each destination?
--   C. Which launch site has the most weather-favorable days?
--        (favorable = no precipitation AND wind_speed_mph <= 30)
--   D. What were the weather conditions on each actual launch day?
--        (join fact_launches to site_weather on site_name AND date)
--   E. How do crewed vs. robotic missions compare in payload and destination?
--   F. Which rocket type has been used most, and with what success rate?
--   G. How has the number of launches trended year over year?
--   H. Do launches in poor weather (high wind or precipitation) have
--        worse outcomes than launches on favorable days?
--   I. Which agency sends the most crew to space?
-- ============================================================



-- Analytics Query 1
-- Question: Which agency has the best launch success rate?
-- YOUR CODE HERE
SELECT agency,
    COUNT(outcome) AS successcount
FROM launch_events
GROUP BY agency
ORDER BY successcount DESC;

-- Analytics Query 2
-- Question:How many launches went to each destination?
-- YOUR CODE HERE
SELECT destination,
    COUNT(launch_id) AS launchcount
FROM launch_events
GROUP BY destination
ORDER BY launchcount DESC;

-- Analytics Query 3
-- Question: How do crewed vs. robotic missions compare in payload and destination
-- YOUR CODE HERE
SELECT avg(payload_kg) AS payload,
    case
    when crew_size = 0 then 'robotic'
    when crew_size > 0 then 'crewed'
end as crew_mission
FROM launch_events
GROUP BY crew_mission
ORDER BY payload DESC;

SELECT destination, avg(payload_kg) AS payload,
    case
    when crew_size = 0 then 'robotic'
    when crew_size > 0 then 'crewed'
end as crew_mission
FROM launch_events
GROUP BY crew_mission, destination
ORDER BY payload DESC;
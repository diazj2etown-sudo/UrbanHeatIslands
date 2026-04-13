-- Final Capstone: Analytics SQL
-- Open this file in DataGrip after connecting to the PostgreSQL database
-- (host: localhost  port: 5432  database: postgres  user: postgres  password: postgres)
-- Run each step one at a time (Ctrl+Enter on the current statement)

-- ============================================================
-- Step 1: Verify your tables loaded correctly
-- ============================================================
SELECT COUNT(*) AS "STATION" FROM harrisburgclimate;
SELECT COUNT(*) FROM lebanonclimate;
SELECT COUNT(*) FROM census2000;
SELECT COUNT(*) AS "Label (Grouping)" FROM census2010;
SELECT COUNT(*) AS "Label (Grouping)" FROM census2020;

-- ============================================================
-- Step 2: Preview each table
-- ============================================================
SELECT * FROM harrisburgclimate LIMIT 5;
SELECT * FROM lebanonclimate LIMIT 5;
SELECT * FROM census2010  LIMIT 5;


-- ============================================================
-- Step 3: Normalize launch_events
-- ============================================================
-- Break the flat launch_events table into three tables:
--   dim_agency    (agency_id, agency_name, country, agency_type)
--   dim_site      (site_id, site_name, country)
--   fact_launches (launch_id, mission_name, launch_date, site_id,
--                  agency_id, rocket_type, destination, mission_type,
--                  outcome, payload_kg, crew_size)





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
-- Questions to cover to address main questions
--
--   Past averages in temperatures compared to new maximum temperature?
--   How much greater anomalies on heat islands when compared to county averages?
--   Which city has higher temperatures on average?
--   Which city has higher amounts of communities of color on average?
--   how are maximum temperatures changing over time
-- ============================================================



-- Analytics Query 1
-- Question: Averages in temperatures compared to maximum temperature, finding anomalies for each city?

SELECT agency,
    COUNT(outcome) AS successcount
FROM launch_events
GROUP BY agency
ORDER BY successcount DESC;

-- Analytics Query 2
-- Question: How much greater anomalies on heat islands when compared to county averages?

SELECT destination,
    COUNT(launch_id) AS launchcount
FROM launch_events
GROUP BY destination
ORDER BY launchcount DESC;

-- Analytics Query 3
-- Question: Which city has higher temperatures on average?
-- YOUR CODE HERE
SELECT avg(payload_kg) AS payload,
    case
    when crew_size = 0 then 'robotic'
    when crew_size > 0 then 'crewed'
end as crew_mission
FROM launch_events
GROUP BY crew_mission
ORDER BY payload DESC;


-- Analytics Query 4
-- Question: Which city has higher amounts of communities of color on average?
-- YOUR CODE HERE
SELECT destination, avg(payload_kg) AS payload,
    case
    when crew_size = 0 then 'robotic'
    when crew_size > 0 then 'crewed'
end as crew_mission
FROM launch_events
GROUP BY crew_mission, destination
ORDER BY payload DESC;
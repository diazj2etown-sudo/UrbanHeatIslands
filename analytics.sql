-- Final Capstone: Analytics SQL
-- Open this file in DataGrip after connecting to the PostgreSQL database
-- (host: localhost  port: 5432  database: postgres  user: postgres  password: postgres)
-- Run each step one at a time (Ctrl+Enter on the current statement)

-- ============================================================
-- Verify your tables loaded correctly
-- ============================================================
SELECT COUNT(*) AS "STATION" FROM harrisburgclimate;
SELECT COUNT(*) FROM lebanonclimate;
SELECT COUNT(*) FROM census2000;


-- ============================================================
-- Preview each table
-- ============================================================
SELECT * FROM harrisburgclimate LIMIT 5;
SELECT * FROM lebanonclimate LIMIT 5;
SELECT * FROM census2010;
SELECT * FROM census2020;
SELECT * FROM census2000;
-- ============================================================
-- Analytics Questions
-- ============================================================






-- ============================================================
-- Analytics Questions
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
--   Averages in temperatures compared to maximum temperature, finding anomalies for each city?
--   Which city has higher temperatures on average?
--   Which city has higher amounts of communities of color, does this change over time?
-- ============================================================



-- Analytics Query 1
-- Question: Averages in temperatures compared to maximum temperature, finding anomalies for each city?
Create Table Anomalies AS
SELECT Max(h."MLY-TMIN-NORMAL") - Avg(h."MLY-TMIN-NORMAL") as Harrisburg, Max(lebanonclimate."MLY-TMIN-NORMAL") - Avg(lebanonclimate."MLY-TMIN-NORMAL") as Lebanon
FROM harrisburgclimate, lebanonclimate
JOIN harrisburgclimate h on lebanonclimate.day = h.day;
SELECT * FROM Anomalies;


-- Analytics Query 2
-- Question: Which city has higher temperatures on average?
-- YOUR CODE HERE
Create TABLE Hightempcomp AS
SELECT Max(h."MLY-TMIN-NORMAL") as maxharrisburg,
Max(lebanonclimate."MLY-TMIN-NORMAL") as maxlebanon
FROM harrisburgclimate, lebanonclimate
JOIN harrisburgclimate h on lebanonclimate.day = h.day;
SELECT * FROM Hightempcomp;
-- Analytics Query 3
-- Question: Which city has higher amounts of communities of color?
-- YOUR CODE HERE
CREATE TABLE CommunityofColor2000 AS
SELECT
    C."Black", C."Native", C."Asian", C."PacificIslander", C."Other", C."Mixed", (C."Black" + C."Asian" + C."Mixed" + C."Other" + C."Native" + C."PacificIslander") AS total
FROM Census2000 C;
SELECT * FROM CommunityofColor2000;
CREATE TABLE CommunityofColor2010 AS
SELECT
    C."Black", C."Native", C."Asian", C."PacificIslander", C."Other", C."Mixed", (C."Black" + C."Asian" + C."Mixed" + C."Other" + C."Native" + C."PacificIslander") AS total
FROM Census2010 C;
SELECT * FROM CommunityofColor2010;

CREATE TABLE CommunityofColornow AS
SELECT
    C."Black", C."Native", C."Asian", C."PacificIslander", C."Other", C."Mixed", (C."Black" + C."Asian" + C."Mixed" + C."Other" + C."Native" + C."PacificIslander") AS total
FROM Census2020 C;
SELECT * FROM CommunityofColorNow;

-- does this change over time?
CREATE TABLE CommunityChange AS
WITH T2020 AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) as rn
    FROM Census2020
),
T2000 AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) as rn
    FROM public.communityofcolor2000
)
SELECT
    (T2020."Black" - T2000."Black") AS NewBlackpop,
    (T2020."Native" - T2000."Native") AS NewNativepop,
    (T2020."Asian" - T2000."Asian") AS NewAsianpop,
    (T2020."PacificIslander" - T2000."PacificIslander") AS NewPacificIslanders,
    (T2020."Other" - T2000."Other") AS NewOtherRaces,
    (T2020."Mixed" - T2000."Mixed") AS NewMixedRace
FROM T2020
JOIN T2000 ON T2020.rn = T2000.rn;


SELECT * FROM CommunityChange
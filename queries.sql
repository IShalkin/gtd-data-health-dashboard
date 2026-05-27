-- ===========================================================================
-- Czechitas · Snowflake Data-Quality Workshop
-- Schema: COURSES.SCH_TEROR  ·  Hlavní tabulka: TEROR_FULLDATA
-- Sedm agregátů, které řídí dashboard. Každý blok = jedna sekce v HTML.
-- ===========================================================================

-- 1) POKRYTÍ — sec 01
--    Roční počty událostí a zabitých. Všimni si, že ROK 1993 v datech CHYBÍ.
SELECT IYEAR    AS year,
       COUNT(*) AS events,
       SUM(NKILL) AS killed,
       SUM(NWOUND) AS wounded,
       COUNT(DISTINCT COUNTRY_TXT) AS countries
FROM TEROR_FULLDATA
GROUP BY IYEAR
ORDER BY IYEAR;

-- 2) KVALITA DAT — sec 02
--    Procenta NULL/Unknown po dekádách. Pohled na to, jak se měnil
--    kódovací standard GTD: před 2000 chybí MOTIVE/SUMMARY skoro všude.
WITH d AS (SELECT (FLOOR(IYEAR/10)*10) AS decade, * FROM TEROR_FULLDATA)
SELECT decade,
       COUNT(*) AS total,
       ROUND(100.0 * SUM(CASE WHEN MOTIVE   IS NULL THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_motive_null,
       ROUND(100.0 * SUM(CASE WHEN SUMMARY  IS NULL THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_summary_null,
       ROUND(100.0 * SUM(CASE WHEN LATITUDE IS NULL THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_lat_null,
       ROUND(100.0 * SUM(CASE WHEN NKILL    IS NULL THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_nkill_null,
       ROUND(100.0 * SUM(CASE WHEN GNAME = 'Unknown'                THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_gname_unknown,
       ROUND(100.0 * SUM(CASE WHEN DOUBTTERR = 1                    THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_doubtterr,
       ROUND(100.0 * SUM(CASE WHEN CITY IS NULL OR CITY = 'Unknown' THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_city_unknown
FROM d
GROUP BY decade
ORDER BY decade;

-- 3a) ROZLOŽENÍ — top 15 zemí (sec 03a)
SELECT COUNTRY_TXT AS country,
       COUNT(*)    AS events,
       SUM(NKILL)  AS killed
FROM TEROR_FULLDATA
GROUP BY COUNTRY_TXT
ORDER BY events DESC
LIMIT 15;

-- 3b) ROZLOŽENÍ — typ útoku (sec 03b)
SELECT ATTACKTYPE1_TXT AS attack,
       COUNT(*)        AS events
FROM TEROR_FULLDATA
WHERE ATTACKTYPE1_TXT IS NOT NULL
GROUP BY ATTACKTYPE1_TXT
ORDER BY events DESC;

-- 3c) ROZLOŽENÍ — typ zbraně (sec 03c)
--     Dlouhý ocas: 4 řády od výbušnin (103k) po radiologické (13).
SELECT WEAPTYPE1_TXT AS weapon,
       COUNT(*)      AS events
FROM TEROR_FULLDATA
WHERE WEAPTYPE1_TXT IS NOT NULL
GROUP BY WEAPTYPE1_TXT
ORDER BY events DESC;

-- 4) REGIONY — sec 04
--    Bublina = zabití, barva = smrtnost (zabití/událost).
SELECT REGION_TXT AS region,
       COUNT(*)   AS events,
       SUM(NKILL) AS killed
FROM TEROR_FULLDATA
WHERE REGION_TXT IS NOT NULL
GROUP BY REGION_TXT
ORDER BY events DESC;

-- ===========================================================================
-- 5) AUDIT INTEGRITY — sec 05
-- ===========================================================================

-- 5a) Duplicitní číselník zemí.
--     COUNTRY_DIRTYDATA má 408 řádků, ale jen 204 unikátních jmen — každá
--     země je tam DVAKRÁT. Naivní JOIN tím zdvojnásobí počet faktů.
SELECT
  (SELECT COUNT(*)         FROM COUNTRY_DIRTYDATA)                            AS total_rows,
  (SELECT COUNT(DISTINCT NAME) FROM COUNTRY_DIRTYDATA)                        AS distinct_names,
  (SELECT COUNT(*) FROM (SELECT NAME FROM COUNTRY_DIRTYDATA
                          GROUP BY NAME HAVING COUNT(*) > 1)) AS names_duplicated;

-- 5b) Pachatel = 'Unknown' — sentinel string, ne NULL.
--     Při filtraci skupin nezapomeň: WHERE GNAME != 'Unknown' AND GNAME IS NOT NULL.
SELECT GNAME, COUNT(*) AS events, SUM(NKILL) AS killed
FROM TEROR_FULLDATA
WHERE GNAME IS NOT NULL AND GNAME != 'Unknown'
GROUP BY GNAME
ORDER BY events DESC
LIMIT 10;

-- 5c) Snapshot drift — kolik tabulek se tváří, že obsahují totéž?
SELECT 'TEROR'          AS source, COUNT(*) AS n FROM TEROR
UNION ALL
SELECT 'TEROR2'         AS source, COUNT(*) AS n FROM TEROR2
UNION ALL
SELECT 'TEROR2_OLD'     AS source, COUNT(*) AS n FROM TEROR2_OLD
UNION ALL
SELECT 'TEROR_FULLDATA' AS source, COUNT(*) AS n FROM TEROR_FULLDATA;

-- 5d) Špatný typ pro souřadnice.
--     LATITUDE / LONGITUDE jsou VARCHAR(255), ne FLOAT — řazení je
--     lexikografické ('10' < '2'), aritmetika selže.
--     Fix v query: přetypovat.
SELECT MIN(LATITUDE::FLOAT)  AS lat_min,
       MAX(LATITUDE::FLOAT)  AS lat_max,
       MIN(LONGITUDE::FLOAT) AS lon_min,
       MAX(LONGITUDE::FLOAT) AS lon_max
FROM TEROR_FULLDATA
WHERE LATITUDE IS NOT NULL;

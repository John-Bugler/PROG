WITH RECURSIVE generate_series(value) AS (
  SELECT 1
  UNION ALL
  SELECT value + 1 FROM generate_series
   WHERE value + 1 <= 100
)
SELECT 
  FLOOR(RAND()*1000+1) AS "číslo",
  UPPER(LEFT(REPLACE(UUID(),'-',''),10)) AS "řetězec",
  DATE_ADD(CURRENT_DATE, INTERVAL FLOOR(RAND()*-1000+1) DAY ) AS "datum"
FROM generate_series;

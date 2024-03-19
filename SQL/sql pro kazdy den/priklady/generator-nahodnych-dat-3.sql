WITH generate_series(value) AS (
  SELECT 1
  UNION ALL
  SELECT value + 1 FROM generate_series
   WHERE value + 1 <= 100
)
SELECT 
  CAST(CRYPT_GEN_RANDOM(1) As INT) AS "číslo",
  LEFT(REPLACE(NEWID(),'-',''),10) AS "řetězec",
  DATEADD(day, CAST(CRYPT_GEN_RANDOM(1) As INT)*-1, CONVERT (DATE, CURRENT_TIMESTAMP)) AS "datum"
FROM generate_series;

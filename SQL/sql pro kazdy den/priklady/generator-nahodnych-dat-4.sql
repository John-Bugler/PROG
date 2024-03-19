WITH RECURSIVE generate_series(value) AS (
  SELECT 1
  UNION ALL
  SELECT value + 1 FROM generate_series
   WHERE value + 1 <= 100
)
SELECT 
  ABS(RANDOM()%1000) AS "číslo",
  HEX(RANDOMBLOB(5)) AS "řetězec",
  DATE(DATE(), '-'||ABS(RANDOM()%1000)||' day') AS "datum"
FROM generate_series;

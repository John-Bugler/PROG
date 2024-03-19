SELECT
  CAST(RANDOM()*1000+1 AS INT) AS "číslo",
  UPPER(LEFT(MD5(RANDOM()::text),10)) AS "řetězec",
  CURRENT_DATE - CAST(RANDOM()*1000+1 AS INT) AS "datum"
FROM generate_series(1,100);

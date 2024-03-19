WITH zakaznici AS (
  SELECT ROW_NUMBER() OVER (ORDER BY celkem DESC) AS rn, *
    FROM prodej
)
SELECT * FROM zakaznici
  WHERE rn = 2;  -- Druhý nejvyšší obrat

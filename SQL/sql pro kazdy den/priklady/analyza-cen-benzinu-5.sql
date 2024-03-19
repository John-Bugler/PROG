WITH min_max AS (
	SELECT MIN(price_eur) AS price_eur FROM gasoline
	UNION
	SELECT MAX(price_eur) FROM gasoline
)
SELECT *
FROM gasoline g
WHERE EXISTS (
	SELECT *
	FROM min_max
	WHERE price_eur = g.price_eur
)
ORDER BY g.price_eur
;
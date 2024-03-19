WITH avg_price AS (
	SELECT ROUND(AVG(price_eur),2) AS avg_price_rounded
	FROM gasoline
)
SELECT *
FROM gasoline g CROSS JOIN avg_price ap
WHERE g.price_eur < ap.avg_price_rounded
;
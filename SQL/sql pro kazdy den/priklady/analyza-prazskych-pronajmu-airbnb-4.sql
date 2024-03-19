SELECT neighbourhood, 
    COUNT(price) AS "Počet ubytování",
    CAST(AVG(price) AS INTEGER) AS "Průměrná cena"
FROM "airbnb-prague-listings"
WHERE last_review > '2021-10-01'
    AND neighbourhood LIKE 'Praha%'
GROUP BY neighbourhood
HAVING "Počet ubytování" > 10
ORDER BY "Průměrná cena" DESC
LIMIT 5
;

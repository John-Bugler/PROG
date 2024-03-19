WITH airbnb AS (
    SELECT minimum_nights,
        CASE 
            WHEN minimum_nights < 30 THEN 'Krátkodobý pronájem' 
            ELSE 'Dlouhodobý pronájem' 
        END AS Typ
    FROM "airbnb-prague-listings"
)
SELECT Typ, COUNT(*) AS "Počet"
FROM airbnb
GROUP BY Typ
ORDER BY "Počet" DESC
;

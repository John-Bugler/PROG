WITH airbnb AS (
    SELECT room_type, COUNT(*) AS "Počet"
    FROM "airbnb-prague-listings"
    GROUP BY room_type
    ORDER BY 2 DESC
)
SELECT *, ROUND(((0.0+"počet")/SUM("počet") OVER()) * 100, 2) || '%' AS "Podíl"
FROM airbnb
;

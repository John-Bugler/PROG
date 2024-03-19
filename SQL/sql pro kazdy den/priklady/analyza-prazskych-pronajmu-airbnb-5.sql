WITH airbnb AS (
    SELECT DISTINCT host_name || ' (' || host_id || ')' AS "Hostitel", 
        calculated_host_listings_count,
        CASE calculated_host_listings_count WHEN 1 THEN 'Jedno' ELSE 'Více' END AS "Počet ubytování"
    FROM "airbnb-prague-listings"
)
SELECT "Počet ubytování", COUNT(*) AS "Počet"
FROM airbnb
GROUP BY "Počet ubytování"
;

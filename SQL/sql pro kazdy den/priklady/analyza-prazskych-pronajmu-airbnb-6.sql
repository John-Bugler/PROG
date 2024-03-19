SELECT host_name || ' (' || host_id || ')' AS "Hostitel", 
    calculated_host_listings_count, 
    CAST(AVG(price) AS INTEGER) AS "Průměrná cena/noc"
FROM "airbnb-prague-listings"
GROUP BY Hostitel, calculated_host_listings_count
ORDER BY calculated_host_listings_count DESC
LIMIT 5
;

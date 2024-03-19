SELECT nazev, prodano_licenci,
    CASE
        WHEN prodano_licenci > 200 THEN '⭐️⭐️⭐️'
        WHEN prodano_licenci > 100 THEN '👍👍'
        WHEN prodano_licenci BETWEEN 1 AND 100 THEN '😐'
        ELSE '💣'
    END AS "Prodejnost"
FROM kurzy
ORDER BY prodano_licenci DESC
;

SELECT nazev, cena,
    CASE WHEN cena < 3500
        THEN 'Do 3500 Kč'
        ELSE 'Nad 3500 Kč'
    END AS "Relativní cena"
  FROM kurzy
  ORDER BY "Relativní cena",
    nazev
;

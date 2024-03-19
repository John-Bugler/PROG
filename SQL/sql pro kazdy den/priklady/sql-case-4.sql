SELECT nazev,
    CASE v_prodeji
        WHEN 0 
        THEN 'Nelze zakoupit'
        ELSE 'Lze zakoupit'
    END AS "V prodeji",
    CASE WHEN cena < 3500
        THEN 'Do 3500 Kč'
        ELSE 'Nad 3500 Kč'
    END AS "Relativní cena"
  FROM kurzy
;

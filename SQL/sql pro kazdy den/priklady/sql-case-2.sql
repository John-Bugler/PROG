SELECT nazev, v_prodeji,
    CASE v_prodeji
        WHEN 0 
        THEN 'Nelze zakoupit'
        ELSE 'Lze zakoupit'
    END AS "V prodeji"
  FROM kurzy
;

SELECT COUNT(*) AS "počet"
    FROM titanic
    WHERE age BETWEEN 50 AND 70
        AND pclass = 1
;

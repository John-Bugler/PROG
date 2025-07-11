WITH ValidValuo AS (
    SELECT *
    FROM dbo.Valuo_data
    WHERE cislo_vkladu IN (
        SELECT cislo_vkladu
        FROM dbo.Valuo_data
        GROUP BY cislo_vkladu
        HAVING 
            -- právì 1 hlavní budova
            SUM(CASE WHEN nemovitost = 'budova' AND typ IN (
                'rodinný dùm', 'objekt k bydlení', 'zemìdìlská usedlost') THEN 1 ELSE 0 END) = 1
            -- žádné jiné budovy mimo garáž, jiná stavba
            AND SUM(CASE WHEN nemovitost = 'budova' AND typ NOT IN (
                'rodinný dùm', 'objekt k bydlení', 'zemìdìlská usedlost', 'garáž', 'jiná stavba') THEN 1 ELSE 0 END) = 0
            -- alespoò jedna parcela
            AND SUM(CASE WHEN nemovitost = 'parcela' THEN 1 ELSE 0 END) >= 1
            -- žádná chyba v GPS
            AND SUM(CASE WHEN GPS_API_info = 'ERR' THEN 1 ELSE 0 END) = 0
    )
),
NemovitostCounts AS (
    SELECT cislo_vkladu,
           COUNT(*) AS NemovitostCount
    FROM dbo.Valuo_data
    GROUP BY cislo_vkladu
)
SELECT 
    V.*,
    K.kat_uzemi,
    K.upper_zoning_id,
    K.parcel_number,
    K.gml_id,
    K.areaValue_m2,
    K.beginLifespanVersion,
    K.endLifespanVersion,
    K.geometry,
    K.inspire_localId,
    K.inspire_namespace,
    K.label,
    K.nationalCadastralReference,
    K.refPoint_x,
    K.refPoint_y,
    K.refPoint_lon,
    K.refPoint_lat,
    K.validFrom,
    K.administrativeUnit_href,
    K.administrativeUnit_title,
    K.zoning_href,
    K.zoning_title,
    K.id_valuo,

    -- Výpoèet JC jen pro hlavní budovu
    CASE 
        WHEN V.nemovitost = 'budova' AND V.typ IN ('rodinný dùm', 'objekt k bydlení', 'zemìdìlská usedlost')
        THEN CAST(ROUND(V.cenovy_udaj / NULLIF(V.plocha, 0), 0) AS DECIMAL(38,0))
        ELSE NULL
    END AS JC,

    NC.NemovitostCount AS [#NEM]

FROM ValidValuo AS V
LEFT JOIN dbo.KN_parcel_data AS K ON K.id_valuo = V.id
LEFT JOIN NemovitostCounts AS NC ON NC.cislo_vkladu = V.cislo_vkladu
WHERE 1=1
      AND V.cislo_vkladu = 'V-1718/2024-209'






WITH ValidValuo AS (
    SELECT *
    FROM dbo.Valuo_data
    WHERE cislo_vkladu IN (
        SELECT cislo_vkladu
        FROM dbo.Valuo_data
        GROUP BY cislo_vkladu
        HAVING COUNT(*) <= 2    -- pocet samostatnych zaznamu (nemovitosti) v ramci jednoho V - cisla vkladu
           AND MAX(typ) = N'garáž'
    )
),
KN_one AS (
    SELECT
        K.*,
        ROW_NUMBER() OVER (
            PARTITION BY K.id_valuo
            ORDER BY K.parcel_number, K.gml_id
        ) AS rn
    FROM dbo.KN_parcel_data AS K
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
    CAST(
         ROUND(V.cenovy_udaj / NULLIF(SUM(V.plocha) OVER (PARTITION BY V.cislo_vkladu), 0), 0)
         AS DECIMAL(38,0)
    ) AS JC
FROM ValidValuo AS V
LEFT JOIN KN_one AS K
    ON K.id_valuo = V.id
   AND K.rn = 1
WHERE V.plocha > 0
  AND V.cenovy_udaj <> 0
  --AND V.cislo_vkladu = N'V-49615/2023-101'
  AND V.kat_uzemi IN (N'Nové Město')
  --AND V.adresa LIKE N'%Senovážné%'



  /*

  DECLARE @pocet_garazi int = 1;  -- ← nastavte 1, 2, 3, ...

WITH Vklady AS (
    SELECT
        cislo_vkladu,
        COUNT(*)                                         AS total_cnt,
        SUM(CASE WHEN typ = N'garáž' THEN 1 ELSE 0 END) AS garaz_cnt
    FROM dbo.Valuo_data
    WHERE cislo_vkladu IS NOT NULL
    GROUP BY cislo_vkladu
    HAVING
        -- 1) v tomto vkladu jsou výhradně garáže
        COUNT(*) = SUM(CASE WHEN typ = N'garáž' THEN 1 ELSE 0 END)
        -- 2) přesně @pocet_garazi záznamů
        AND SUM(CASE WHEN typ = N'garáž' THEN 1 ELSE 0 END) = @pocet_garazi
),
ValidValuo AS (
    SELECT V.*
    FROM dbo.Valuo_data AS V
    JOIN Vklady AS S ON S.cislo_vkladu = V.cislo_vkladu
    WHERE V.typ = N'garáž'               -- volitelné, zde už to stejně platí
),
KN_one AS (
    SELECT
        K.*,
        ROW_NUMBER() OVER (
            PARTITION BY K.id_valuo
            ORDER BY K.parcel_number, K.gml_id
        ) AS rn
    FROM dbo.KN_parcel_data AS K
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
    CAST(ROUND(
        V.cenovy_udaj / NULLIF(SUM(V.plocha) OVER (PARTITION BY V.cislo_vkladu), 0), 0
    ) AS DECIMAL(38,0)) AS JC
FROM ValidValuo AS V
LEFT JOIN KN_one AS K
    ON K.id_valuo = V.id
   AND K.rn = 1
WHERE V.plocha > 0
  AND V.cenovy_udaj <> 0
  AND V.kat_uzemi IN (N'Nové Město');
--  AND V.adresa LIKE N'%Senovážné%';



  */
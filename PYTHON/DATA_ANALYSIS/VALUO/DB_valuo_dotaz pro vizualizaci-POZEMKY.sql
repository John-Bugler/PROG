WITH ValidValuo AS (
    SELECT *
    FROM dbo.Valuo_data
    WHERE cislo_vkladu IN (
        SELECT cislo_vkladu
        FROM dbo.Valuo_data
        GROUP BY cislo_vkladu
        HAVING COUNT(*) = COUNT(CASE WHEN nemovitost = 'parcela' THEN 1 END)
           AND COUNT(CASE WHEN GPS_API_info = 'ERR' THEN 1 END) = 0
    )
),
ParcelCounts AS (
    SELECT V.cislo_vkladu,
           COUNT(DISTINCT V.adresa) AS ParcelCount
    FROM dbo.Valuo_data V
    LEFT JOIN dbo.KN_parcel_data K
        ON K.id_valuo = V.id
    GROUP BY V.cislo_vkladu
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
    -- V�po�et JC: cenovy_udaj d�leno sou�tem plochy pro dan� cislo_vkladu,
    -- d�len� chr�n�no proti d�len� nulou, v�sledek je zaokrouhlen na 0 desetinn�ch m�st
    -- a p�eveden na DECIMAL(38,0) (tj. bez zbyte�n�ch nul za desetinnou ��rkou).
    CAST(
         ROUND(V.cenovy_udaj / NULLIF(SUM(V.plocha) OVER (PARTITION BY V.cislo_vkladu), 0), 0)
         AS DECIMAL(38,0)
    ) AS JC,
    PC.ParcelCount AS [#PARCEL]
FROM ValidValuo AS V
LEFT JOIN dbo.KN_parcel_data AS K
    ON K.id_valuo = V.id
LEFT JOIN ParcelCounts AS PC
    ON PC.cislo_vkladu = V.cislo_vkladu
WHERE 1 = 1


      and V.cislo_vkladu = 'V-24071/2023-101'

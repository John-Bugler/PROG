

WITH
-- 1) CTE pro validn� z�znamy typu 'parcela' bez chyby v GPS_API_info
ValidValuo AS (
    SELECT
        V.*
    FROM
        dbo.Valuo_data AS V
    WHERE
        V.nemovitost = 'parcela'
        AND NOT EXISTS (
            SELECT 1
            FROM dbo.Valuo_data AS V2
            WHERE
                V2.cislo_vkladu = V.cislo_vkladu
                AND (
                    V2.nemovitost <> 'parcela'
                    OR V2.GPS_API_info = 'ERR'
                )
        )
),

-- 2) CTE, kter� pro ka�d� cislo_vkladu vypo��t� celkovou plochu v�ech parcel
SumArea AS (
    SELECT
        cislo_vkladu,
        SUM(plocha) AS SUM_PLOCHA
    FROM
        ValidValuo
    GROUP BY
        cislo_vkladu
),

-- 3) CTE, kter� spo��t� po�et DISTINCT adres (parcel) pro ka�d� cislo_vkladu
ParcelCounts AS (
    SELECT
        V.cislo_vkladu,
        COUNT(DISTINCT V.adresa) AS ParcelCount
    FROM
        ValidValuo AS V
        LEFT JOIN dbo.KN_parcel_data AS K
            ON K.id_valuo = V.id
    GROUP BY
        V.cislo_vkladu
)

-- 4) Hlavn� SELECT � ke �validn�m� z�znam�m p�ipoj�me SUM_PLOCHA, ParcelCount a dal�� tabulky
SELECT
    V.id                           AS id_valuo,
    U.id                           AS id_up,
    V.cislo_vkladu,
    V.rok,
    V.mesic,
    V.datum_podani,
    V.listina,
    PC.ParcelCount                  AS [#PARCEL],
    SA.SUM_PLOCHA                   AS SUM_PARCEL_RIZENI,
    V.okres,
    V.kat_uzemi                     AS KU_Valuo,
    K.zoning_title                  AS KU_KN,
    K.upper_zoning_id,               --AS kod_ku,
    K.administrativeUnit_title      AS lokalita,
    V.nemovitost,
    --U.*,
    U.POPIS_Z,
	V.typ,
    K.parcel_number,
    V.plocha,
    V.cenovy_udaj,
    -- V�po�et pr�m�rn� jednotkov� ceny (zaokrouhlen�) bez window funkc�:
    CAST(
      ROUND(
        V.cenovy_udaj 
        / NULLIF(SA.SUM_PLOCHA, 0),
        0
      ) 
      AS DECIMAL(38,0)
    )                               AS JC,
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
    K.administrativeUnit_title     AS adminUnitTitle,
    K.zoning_href,
    K.zoning_title                  AS zoningTitleUP,
    K.id_valuo,
    K.id_UP_FVU_data
FROM
    ValidValuo AS V

    INNER JOIN SumArea AS SA
        ON SA.cislo_vkladu = V.cislo_vkladu

    LEFT JOIN ParcelCounts AS PC
        ON PC.cislo_vkladu = V.cislo_vkladu

    LEFT JOIN dbo.KN_parcel_data AS K
        ON K.id_valuo = V.id

    LEFT JOIN dbo.UP_FVU_data AS U
        ON U.id = K.id_UP_FVU_data

WHERE 1=1
    -- Filtrujeme pouze z�znamy, kde pr�m�rn� jednotkov� cena > 0:
    AND CAST(
      ROUND(
        V.cenovy_udaj 
        / NULLIF(SA.SUM_PLOCHA, 0),
        0
      ) 
      AS DECIMAL(38,0)
    ) > 999

    AND CAST(
      ROUND(
        V.cenovy_udaj 
        / NULLIF(SA.SUM_PLOCHA, 0),
        0
      ) 
      AS DECIMAL(38,0)
    ) < 10000


    -- A z�rove� jen pro �Hlavn� m�sto Praha�
    AND V.okres = 'Hlavn� m�sto Praha'
	--AND V.kat_uzemi in ('P�snice', 'Kunratice', 'Libu�', 'Kr�')
    -- A nakonec pouze ur�it� k�dy v U.POPIS_Z:
    AND (
           U.POPIS_Z LIKE '%DH%'
        OR U.POPIS_Z LIKE '%OP%'
        OR U.POPIS_Z LIKE '%ZMK%'
        OR U.POPIS_Z LIKE '%IZ%'
        OR U.POPIS_Z LIKE 'S[0-9]'
    );

WITH MainProperty AS (
    SELECT 
        cislo_vkladu,
        -- Podle priority: pokud je aspoò jedna budova, vezmeme maximální plochu budovy,
        -- jinak pokud je aspoò jedna jednotka, použijeme prùmìrnou plochu jednotek,
        -- jinak (pouze parcely) použijeme prùmìrnou plochu parcel.
        CASE 
            WHEN COUNT(CASE WHEN nemovitost = 'budova' THEN 1 END) > 0 
                THEN MAX(CASE WHEN nemovitost = 'budova' THEN plocha END)
            WHEN COUNT(CASE WHEN nemovitost = 'jednotka' THEN 1 END) > 0 
                THEN AVG(CASE WHEN nemovitost = 'jednotka' THEN plocha END)
            ELSE 
                AVG(CASE WHEN nemovitost = 'parcela' THEN plocha END)
        END AS main_area,
        -- Cenový údaj je ve všech øádcích stejné, takže mùžeme vzít napøíklad MAX.
        MAX(cenovy_udaj) AS cenovy_udaj
    FROM [valuo].[dbo].[valuo_data]
    GROUP BY cislo_vkladu
)
SELECT 
    vd.*,
    -- Pro bezpeènost ochráníme dìlení nulou.
    CASE 
        WHEN mp.main_area IS NOT NULL AND mp.main_area <> 0 
            THEN mp.cenovy_udaj / mp.main_area 
        ELSE NULL 
    END AS JC
FROM [valuo].[dbo].[valuo_data] vd
INNER JOIN MainProperty mp
    ON vd.cislo_vkladu = mp.cislo_vkladu
WHERE vd.LAT IS NOT NULL 
  AND vd.LON IS NOT NULL;


  select * from [valuo].[dbo].[valuo_data] where LAT < 48.8 and LAT > 52 or LON  < 13 and LAT > 18

  select * from [valuo].[dbo].[valuo_data] WHERE id = 955


/*
UPDATE [valuo].[dbo].[valuo_data] 
SET LAT = 50.0404146, LON = 14.4555090
WHERE id = 16

UPDATE [valuo].[dbo].[valuo_data] 
SET LAT = 50.0404146, LON = 14.4529681
WHERE id = 46

UPDATE [valuo].[dbo].[valuo_data] 
SET LAT = 50.0209971, LON = 14.4527423
WHERE id = 48

*/

select * from [valuo].[dbo].[valuo_data]  where id in (16, 46, 47, 48)
-- Intervaly pro typ 'byt'
DECLARE @byt_price_lower INT = 500000;
DECLARE @byt_price_upper INT = 40000000;
DECLARE @byt_area_lower DECIMAL(10,2) = 15;
DECLARE @byt_area_upper DECIMAL(10,2) = 300;

-- Intervaly pro typ 'ateli�r'
DECLARE @ateli�r_price_lower INT = 400000;
DECLARE @ateli�r_price_upper INT = 20000000;
DECLARE @ateli�r_area_lower DECIMAL(10,2) = 10;
DECLARE @ateli�r_area_upper DECIMAL(10,2) = 200;

-- Intervaly pro typ 'rodinn� d�m'
DECLARE @rodinny_dum_price_lower INT = 1500000;
DECLARE @rodinny_dum_price_upper INT = 300000000;
DECLARE @rodinny_dum_area_lower DECIMAL(10,2) = 50;
DECLARE @rodinny_dum_area_upper DECIMAL(10,2) = 750;

-- Intervaly pro typ 'bytov� d�m'
DECLARE @bytovy_dum_price_lower INT = 1000000;
DECLARE @bytovy_dum_price_upper INT = 400000000;
DECLARE @bytovy_dum_area_lower DECIMAL(10,2) = 100;
DECLARE @bytovy_dum_area_upper DECIMAL(10,2) = 6000;

-- Intervaly pro typ 'gar�'
DECLARE @garaz_price_lower INT = 20000;
DECLARE @garaz_price_upper INT = 50000000;
DECLARE @garaz_area_lower DECIMAL(10,2) = 10;
DECLARE @garaz_area_upper DECIMAL(10,2) = 5000;

-- Intervaly pro typ 'stavba pro rodinnou rekreaci'
DECLARE @stavba_rod_rek_price_lower INT = 100000;
DECLARE @stavba_rod_rek_price_upper INT = 15000000;
DECLARE @stavba_rod_rek_area_lower DECIMAL(10,2) = 20;
DECLARE @stavba_rod_rek_area_upper DECIMAL(10,2) = 350;

-- Intervaly pro typ 'objekt bydlen�'
DECLARE @objekt_bydleni_price_lower INT = 1500000;
DECLARE @objekt_bydleni_price_upper INT = 300000000;
DECLARE @objekt_bydleni_area_lower DECIMAL(10,2) = 50;
DECLARE @objekt_bydleni_area_upper DECIMAL(10,2) = 750;

-- Intervaly pro typ 'jin� stavba'
DECLARE @jina_stavba_price_lower INT = 1000000;
DECLARE @jina_stavba_price_upper INT = 30000000;
DECLARE @jina_stavba_area_lower DECIMAL(10,2) = 20;
DECLARE @jina_stavba_area_upper DECIMAL(10,2) = 150;

-- Intervaly pro typ 'jin� nebytov� prostor'
DECLARE @jiny_nebytovy_prostor_price_lower INT = 300000;
DECLARE @jiny_nebytovy_prostor_price_upper INT = 30000000;
DECLARE @jiny_nebytovy_prostor_area_lower DECIMAL(10,2) = 10;
DECLARE @jiny_nebytovy_prostor_area_upper DECIMAL(10,2) = 150;

-- Intervaly pro typ 'rozestav�n� jednotka'
DECLARE @rozestavena_jednotka_price_lower INT = 300000;
DECLARE @rozestavena_jednotka_price_upper INT = 30000000;
DECLARE @rozestavena_jednotka_area_lower DECIMAL(10,2) = 10;
DECLARE @rozestavena_jednotka_area_upper DECIMAL(10,2) = 350;


-- Hlavn� dotaz � agregace podle cislo_vkladu

WITH main AS (
    SELECT
        -- Unik�tn� ��slo ��zen�
        cislo_vkladu,
        
        -- Z�kladn� �daje � u dan�ho cislo_vkladu p�edpokl�d�me shodn� hodnoty, proto pou��v�me MAX.
        MAX(CAST(listina AS VARCHAR(MAX)))         AS listina,
        MAX(datum_podani)                          AS datum_podani,
        MAX(rok)                                   AS rok,
        MAX(mesic)                                 AS mesic,
        MAX(okres)                                 AS okres,
        MAX(kat_uzemi)                             AS kat_uzemi,
        MAX(CAST(adresa AS VARCHAR(MAX)))          AS adresa,
        MAX(LAT)                                   AS LAT,
        MAX(LON)                                   AS LON,
        MAX(mena)                                  AS mena,
        FLOOR(MAX(cenovy_udaj))                    AS cenovy_udaj,
        

        -- Po�et v�ech nemovitost� v r�mci cislo_vkladu
        COUNT(*)                                   AS [#_NEMOVITOSTI],
        
        SUM(CASE WHEN nemovitost = 'budova'   THEN 1 ELSE 0 END)               AS [#_BUDOVA],
        -- Po�ty pro typy BUDOVA
        SUM(CASE WHEN typ = 'rodinn� d�m'    THEN 1 ELSE 0 END)                AS [#_rodinny_dum],
        SUM(CASE WHEN typ = 'bytov� d�m'     THEN 1 ELSE 0 END)                AS [#_bytovy_dum],
        SUM(CASE WHEN typ = 'stavba pro rodinnou rekreaci' THEN 1 ELSE 0 END)  AS [#_stavba_rod_rek],
        SUM(CASE WHEN typ = 'objekt bydlen�'               THEN 1 ELSE 0 END)  AS [#_objekt_bydleni],
        SUM(CASE WHEN typ = 'jin� stavba'                   THEN 1 ELSE 0 END) AS [#_jina_stavba],
        
        SUM(CASE WHEN nemovitost = 'jednotka'  THEN 1 ELSE 0 END)              AS [#_JEDNOTKA],
        SUM(CASE WHEN typ = 'byt'            THEN 1 ELSE 0 END)                AS [#_byt],
        SUM(CASE WHEN typ = 'ateli�r'        THEN 1 ELSE 0 END)                AS [#_atelier],
        SUM(CASE WHEN typ = 'jin� nebytov� prostor'         THEN 1 ELSE 0 END) AS [#_jiny_nebytovy_prostor],
        SUM(CASE WHEN typ = 'rozestav�n� jednotka'          THEN 1 ELSE 0 END) AS [#_rozestavena_jednotka],
       
        SUM(CASE WHEN typ = 'gar�'         THEN 1 ELSE 0 END)                 AS [#_garaz],
        
        SUM(CASE WHEN nemovitost = 'parcela'   THEN 1 ELSE 0 END) AS [#_PARCELA],
        SUM(CASE WHEN typ = 'zastav�n� plocha a n�dvo��' THEN 1 ELSE 0 END)           AS [#_zastavena_plocha],
        SUM(CASE WHEN typ = 'zahrada' THEN 1 ELSE 0 END)                              AS [#_zahrada],
        SUM(CASE WHEN typ = 'jin� plocha' THEN 1 ELSE 0 END)                          AS [#_jina_plocha],
        SUM(CASE WHEN typ = 'orn� p�da' THEN 1 ELSE 0 END)                            AS [#_orna_puda],
        SUM(CASE WHEN typ = 'zele�' THEN 1 ELSE 0 END)                                AS [#_zelen],
        SUM(CASE WHEN typ = 'ostatn� komunikace' THEN 1 ELSE 0 END)                   AS [#_ostatni_komunikace],
        

        -- Pro budovy
        ROUND(SUM(CASE WHEN typ = 'rodinn� d�m' THEN plocha ELSE 0 END), 2)                  AS A_rodinny_dum,
        ROUND(SUM(CASE WHEN typ = 'bytov� d�m' THEN plocha ELSE 0 END), 2)                   AS A_bytovy_dum,
        ROUND(SUM(CASE WHEN typ = 'stavba pro rodinnou rekreaci' THEN plocha ELSE 0 END), 2) AS A_stavba_rod_rek,
        ROUND(SUM(CASE WHEN typ = 'objekt bydlen�' THEN plocha ELSE 0 END), 2)               AS A_objekt_bydleni,
        ROUND(SUM(CASE WHEN typ = 'jin� stavba' THEN plocha ELSE 0 END), 2)                  AS A_jina_stavba,
        
        -- Pro jednotky
        ROUND(SUM(CASE WHEN typ IN ('byt','ateli�r') THEN plocha ELSE 0 END), 2)              AS A_byt,
        ROUND(SUM(CASE WHEN typ = 'jin� nebytov� prostor' THEN plocha ELSE 0 END), 2)         AS A_jiny_nebytovy_prostor,
        ROUND(SUM(CASE WHEN typ = 'rozestav�n� jednotka' THEN plocha ELSE 0 END), 2)          AS A_rozestavena_jednotka,
        
        ROUND(SUM(CASE WHEN typ = 'gar�' THEN plocha ELSE 0 END), 2)                         AS A_garaz,
        ROUND(SUM(CASE WHEN nemovitost = 'parcela' THEN plocha ELSE 0 END), 2)                AS A_parcela,
        
   
        CASE 
           WHEN SUM(CASE WHEN typ IN ('byt','ateli�r') THEN 1 ELSE 0 END) > 0 
              THEN 'byt/ateli�r'
           WHEN SUM(CASE WHEN typ IN ('jin� nebytov� prostor') THEN 1 ELSE 0 END) > 0 
              THEN 'jin� nebytov� prostor'
           WHEN SUM(CASE WHEN typ IN ('rozestav�n� jednotka') THEN 1 ELSE 0 END) > 0 
              THEN 'rozestav�n� jednotka'
           WHEN SUM(CASE WHEN typ IN ('bytov� d�m') THEN 1 ELSE 0 END) > 0 
              THEN 'bytov� d�m'
           WHEN SUM(CASE WHEN typ IN ('rodinn� d�m') THEN 1 ELSE 0 END) > 0 
              THEN 'rodinn� d�m'
           WHEN SUM(CASE WHEN typ IN ('stavba pro rodinnou rekreaci') THEN 1 ELSE 0 END) > 0 
              THEN 'stavba pro rodinnou rekreaci'
           WHEN SUM(CASE WHEN typ IN ('objekt bydlen�') THEN 1 ELSE 0 END) > 0 
              THEN 'objekt bydlen�'
           WHEN SUM(CASE WHEN typ IN ('jin� stavba') THEN 1 ELSE 0 END) > 0 
              THEN 'jin� stavba'
           WHEN SUM(CASE WHEN typ = 'gar�' THEN 1 ELSE 0 END) > 0 
              THEN 'gar�'
           WHEN SUM(CASE WHEN nemovitost = 'parcela' THEN 1 ELSE 0 END) > 0 
              THEN 'parcela'
           ELSE NULL
        END AS TYP,
        
        CASE 
           WHEN SUM(CASE WHEN typ IN ('byt','ateli�r','jin� nebytov� prostor','rozestav�n� jednotka') THEN 1 ELSE 0 END) > 0 THEN '[m2]'
           WHEN SUM(CASE WHEN typ IN ('rodinn� d�m','stavba pro rodinnou rekreaci','objekt bydlen�','jin� stavba','bytov� d�m') THEN 1 ELSE 0 END) > 0 THEN '[m2]'
           WHEN SUM(CASE WHEN typ = 'gar�' THEN 1 ELSE 0 END) > 0 THEN '[pocet]'
           WHEN SUM(CASE WHEN nemovitost = 'parcela' THEN 1 ELSE 0 END) > 0 THEN '[m2]'
           ELSE NULL
        END AS MJ,
        
        ROUND(
          CASE 
             WHEN SUM(CASE WHEN typ IN ('byt','ateli�r') THEN 1 ELSE 0 END) > 0 
                THEN SUM(CASE WHEN typ IN ('byt','ateli�r') THEN plocha ELSE 0 END)
             WHEN SUM(CASE WHEN typ IN ('jin� nebytov� prostor') THEN 1 ELSE 0 END) > 0 
                THEN SUM(CASE WHEN typ IN ('jin� nebytov� prostor') THEN plocha ELSE 0 END)
             WHEN SUM(CASE WHEN typ IN ('rozestav�n� jednotka') THEN 1 ELSE 0 END) > 0 
                THEN SUM(CASE WHEN typ IN ('rozestav�n� jednotka') THEN plocha ELSE 0 END)
             WHEN SUM(CASE WHEN typ IN ('bytov� d�m') THEN 1 ELSE 0 END) > 0 
                THEN SUM(CASE WHEN typ IN ('bytov� d�m') THEN plocha ELSE 0 END)
             WHEN SUM(CASE WHEN typ IN ('rodinn� d�m') THEN 1 ELSE 0 END) > 0 
                THEN SUM(CASE WHEN typ IN ('rodinn� d�m') THEN plocha ELSE 0 END)
    	     WHEN SUM(CASE WHEN typ IN ('objekt bydlen�') THEN 1 ELSE 0 END) > 0 
                THEN SUM(CASE WHEN typ IN ('objekt bydlen�') THEN plocha ELSE 0 END)
             WHEN SUM(CASE WHEN typ IN ('stavba pro rodinnou rekreaci') THEN 1 ELSE 0 END) > 0 
                THEN SUM(CASE WHEN typ IN ('stavba pro rodinnou rekreaci') THEN plocha ELSE 0 END)
    	     WHEN SUM(CASE WHEN typ IN ('jin� stavba') THEN 1 ELSE 0 END) > 0 
                THEN SUM(CASE WHEN typ IN ('jin� stavba') THEN plocha ELSE 0 END)
             WHEN SUM(CASE WHEN typ = 'gar�' THEN 1 ELSE 0 END) > 0 
                THEN SUM(CASE WHEN typ = 'gar�' THEN 1 ELSE 0 END)
             WHEN SUM(CASE WHEN nemovitost = 'parcela' THEN 1 ELSE 0 END) > 0 
                THEN SUM(CASE WHEN nemovitost = 'parcela' THEN plocha ELSE 0 END)
             ELSE NULL
          END, 2) AS POCET_MJ,
        
        CASE 
          WHEN SUM(CASE WHEN typ IN ('byt','ateli�r') THEN 1 ELSE 0 END) > 0 
             THEN CAST(ROUND(MAX(cenovy_udaj)*1.0 / NULLIF(SUM(CASE WHEN typ IN ('byt','ateli�r') THEN plocha ELSE 0 END), 0), 0) AS INT)
          WHEN SUM(CASE WHEN typ IN ('jin� nebytov� prostor') THEN 1 ELSE 0 END) > 0 
             THEN CAST(ROUND(MAX(cenovy_udaj)*1.0 / NULLIF(SUM(CASE WHEN typ IN ('jin� nebytov� prostor') THEN plocha ELSE 0 END), 0), 0) AS INT)
          WHEN SUM(CASE WHEN typ IN ('rozestav�n� jednotka') THEN 1 ELSE 0 END) > 0 
             THEN CAST(ROUND(MAX(cenovy_udaj)*1.0 / NULLIF(SUM(CASE WHEN typ IN ('rozestav�n� jednotka') THEN plocha ELSE 0 END), 0), 0) AS INT)
          WHEN SUM(CASE WHEN typ IN ('bytov� d�m') THEN 1 ELSE 0 END) > 0 
             THEN CAST(ROUND(MAX(cenovy_udaj)*1.0 / NULLIF(SUM(CASE WHEN typ IN ('bytov� d�m') THEN plocha ELSE 0 END), 0), 0) AS INT)
          WHEN SUM(CASE WHEN typ IN ('rodinn� d�m') THEN 1 ELSE 0 END) > 0 
             THEN CAST(ROUND(MAX(cenovy_udaj)*1.0 / NULLIF(SUM(CASE WHEN typ IN ('rodinn� d�m') THEN plocha ELSE 0 END), 0), 0) AS INT)
          WHEN SUM(CASE WHEN typ IN ('objekt bydlen�') THEN 1 ELSE 0 END) > 0 
             THEN CAST(ROUND(MAX(cenovy_udaj)*1.0 / NULLIF(SUM(CASE WHEN typ IN ('objekt bydlen�') THEN plocha ELSE 0 END), 0), 0) AS INT)
          WHEN SUM(CASE WHEN typ IN ('stavba pro rodinnou rekreaci') THEN 1 ELSE 0 END) > 0 
             THEN CAST(ROUND(MAX(cenovy_udaj)*1.0 / NULLIF(SUM(CASE WHEN typ IN ('stavba pro rodinnou rekreaci') THEN plocha ELSE 0 END), 0), 0) AS INT)
          WHEN SUM(CASE WHEN typ IN ('jin� stavba') THEN 1 ELSE 0 END) > 0 
             THEN CAST(ROUND(MAX(cenovy_udaj)*1.0 / NULLIF(SUM(CASE WHEN typ IN ('jin� stavba') THEN plocha ELSE 0 END), 0), 0) AS INT)
          WHEN SUM(CASE WHEN typ = 'gar�' THEN 1 ELSE 0 END) > 0 
             THEN CAST(ROUND(MAX(cenovy_udaj)*1.0 / NULLIF(SUM(CASE WHEN typ = 'gar�' THEN 1 ELSE 0 END), 0), 0) AS INT)
          WHEN SUM(CASE WHEN nemovitost = 'parcela' THEN 1 ELSE 0 END) > 0 
             THEN CAST(ROUND(MAX(cenovy_udaj)*1.0 / NULLIF(SUM(CASE WHEN nemovitost = 'parcela' THEN plocha ELSE 0 END), 0), 0) AS INT)
          ELSE NULL
        END AS JC
    FROM [valuo].[dbo].[valuo_data]
    GROUP BY cislo_vkladu
    HAVING 
      SUM(CASE WHEN typ IN (
             'byt','ateli�r','rodinn� d�m','bytov� d�m','gar�',
             'stavba pro rodinnou rekreaci','objekt bydlen�','jin� stavba',
             'jin� nebytov� prostor','rozestav�n� jednotka',
             'zastav�n� plocha a n�dvo��','zahrada','jin� plocha','orn� p�da','zele�','ostatn� komunikace'
          ) THEN 1 ELSE 0 END) > 0
      AND MIN(cenovy_udaj) > 0
      AND MIN(plocha) > 0
      -- Filtr pro 'byt'
      AND (
           SUM(CASE WHEN typ = 'byt' THEN 1 ELSE 0 END) = 0 
           OR 
           (MIN(CASE WHEN typ = 'byt' THEN cenovy_udaj END) >= @byt_price_lower 
            AND MAX(CASE WHEN typ = 'byt' THEN cenovy_udaj END) <= @byt_price_upper)
          )
      AND (
           SUM(CASE WHEN typ = 'byt' THEN 1 ELSE 0 END) = 0 
           OR 
           (MIN(CASE WHEN typ = 'byt' THEN plocha END) >= @byt_area_lower 
            AND MAX(CASE WHEN typ = 'byt' THEN plocha END) <= @byt_area_upper)
          )
      -- Filtr pro 'ateli�r'
      AND (
           SUM(CASE WHEN typ = 'ateli�r' THEN 1 ELSE 0 END) = 0 
           OR 
           (MIN(CASE WHEN typ = 'ateli�r' THEN cenovy_udaj END) >= @ateli�r_price_lower 
            AND MAX(CASE WHEN typ = 'ateli�r' THEN cenovy_udaj END) <= @ateli�r_price_upper)
          )
      AND (
           SUM(CASE WHEN typ = 'ateli�r' THEN 1 ELSE 0 END) = 0 
           OR 
           (MIN(CASE WHEN typ = 'ateli�r' THEN plocha END) >= @ateli�r_area_lower 
            AND MAX(CASE WHEN typ = 'ateli�r' THEN plocha END) <= @ateli�r_area_upper)
          )
      -- Filtr pro 'rodinn� d�m'
      AND (
           SUM(CASE WHEN typ = 'rodinn� d�m' THEN 1 ELSE 0 END) = 0 
           OR 
           (MIN(CASE WHEN typ = 'rodinn� d�m' THEN cenovy_udaj END) >= @rodinny_dum_price_lower 
            AND MAX(CASE WHEN typ = 'rodinn� d�m' THEN cenovy_udaj END) <= @rodinny_dum_price_upper)
          )
      AND (
           SUM(CASE WHEN typ = 'rodinn� d�m' THEN 1 ELSE 0 END) = 0 
           OR 
           (MIN(CASE WHEN typ = 'rodinn� d�m' THEN plocha END) >= @rodinny_dum_area_lower 
            AND MAX(CASE WHEN typ = 'rodinn� d�m' THEN plocha END) <= @rodinny_dum_area_upper)
          )
      -- Filtr pro 'bytov� d�m'
      AND (
           SUM(CASE WHEN typ = 'bytov� d�m' THEN 1 ELSE 0 END) = 0 
           OR 
           (MIN(CASE WHEN typ = 'bytov� d�m' THEN cenovy_udaj END) >= @bytovy_dum_price_lower 
            AND MAX(CASE WHEN typ = 'bytov� d�m' THEN cenovy_udaj END) <= @bytovy_dum_price_upper)
          )
      AND (
           SUM(CASE WHEN typ = 'bytov� d�m' THEN 1 ELSE 0 END) = 0 
           OR 
           (MIN(CASE WHEN typ = 'bytov� d�m' THEN plocha END) >= @bytovy_dum_area_lower 
            AND MAX(CASE WHEN typ = 'bytov� d�m' THEN plocha END) <= @bytovy_dum_area_upper)
          )
      -- Filtr pro 'gar�'
      AND (
           SUM(CASE WHEN typ = 'gar�' THEN 1 ELSE 0 END) = 0 
           OR 
           (MIN(CASE WHEN typ = 'gar�' THEN cenovy_udaj END) >= @garaz_price_lower 
            AND MAX(CASE WHEN typ = 'gar�' THEN cenovy_udaj END) <= @garaz_price_upper)
          )
      AND (
           SUM(CASE WHEN typ = 'gar�' THEN 1 ELSE 0 END) = 0 
           OR 
           (MIN(CASE WHEN typ = 'gar�' THEN plocha END) >= @garaz_area_lower 
            AND MAX(CASE WHEN typ = 'gar�' THEN plocha END) <= @garaz_area_upper)
          )
      -- Filtr pro 'stavba pro rodinnou rekreaci'
      AND (
           SUM(CASE WHEN typ = 'stavba pro rodinnou rekreaci' THEN 1 ELSE 0 END) = 0 
           OR 
           (MIN(CASE WHEN typ = 'stavba pro rodinnou rekreaci' THEN cenovy_udaj END) >= @stavba_rod_rek_price_lower 
            AND MAX(CASE WHEN typ = 'stavba pro rodinnou rekreaci' THEN cenovy_udaj END) <= @stavba_rod_rek_price_upper)
          )
      AND (
           SUM(CASE WHEN typ = 'stavba pro rodinnou rekreaci' THEN 1 ELSE 0 END) = 0 
           OR 
           (MIN(CASE WHEN typ = 'stavba pro rodinnou rekreaci' THEN plocha END) >= @stavba_rod_rek_area_lower 
            AND MAX(CASE WHEN typ = 'stavba pro rodinnou rekreaci' THEN plocha END) <= @stavba_rod_rek_area_upper)
          )
      -- Filtr pro 'objekt bydlen�'
      AND (
           SUM(CASE WHEN typ = 'objekt bydlen�' THEN 1 ELSE 0 END) = 0 
           OR 
           (MIN(CASE WHEN typ = 'objekt bydlen�' THEN cenovy_udaj END) >= @objekt_bydleni_price_lower 
            AND MAX(CASE WHEN typ = 'objekt bydlen�' THEN cenovy_udaj END) <= @objekt_bydleni_price_upper)
          )
      AND (
           SUM(CASE WHEN typ = 'objekt bydlen�' THEN 1 ELSE 0 END) = 0 
           OR 
           (MIN(CASE WHEN typ = 'objekt bydlen�' THEN plocha END) >= @objekt_bydleni_area_lower 
            AND MAX(CASE WHEN typ = 'objekt bydlen�' THEN plocha END) <= @objekt_bydleni_area_upper)
          )
      -- Filtr pro 'jin� stavba'
      AND (
           SUM(CASE WHEN typ = 'jin� stavba' THEN 1 ELSE 0 END) = 0 
           OR 
           (MIN(CASE WHEN typ = 'jin� stavba' THEN cenovy_udaj END) >= @jina_stavba_price_lower 
            AND MAX(CASE WHEN typ = 'jin� stavba' THEN cenovy_udaj END) <= @jina_stavba_price_upper)
          )
      AND (
           SUM(CASE WHEN typ = 'jin� stavba' THEN 1 ELSE 0 END) = 0 
           OR 
           (MIN(CASE WHEN typ = 'jin� stavba' THEN plocha END) >= @jina_stavba_area_lower 
            AND MAX(CASE WHEN typ = 'jin� stavba' THEN plocha END) <= @jina_stavba_area_upper)
          )
      -- Filtr pro 'jin� nebytov� prostor'
      AND (
           SUM(CASE WHEN typ = 'jin� nebytov� prostor' THEN 1 ELSE 0 END) = 0 
           OR 
           (MIN(CASE WHEN typ = 'jin� nebytov� prostor' THEN cenovy_udaj END) >= @jiny_nebytovy_prostor_price_lower 
            AND MAX(CASE WHEN typ = 'jin� nebytov� prostor' THEN cenovy_udaj END) <= @jiny_nebytovy_prostor_price_upper)
          )
      AND (
           SUM(CASE WHEN typ = 'jin� nebytov� prostor' THEN 1 ELSE 0 END) = 0 
           OR 
           (MIN(CASE WHEN typ = 'jin� nebytov� prostor' THEN plocha END) >= @jiny_nebytovy_prostor_area_lower 
            AND MAX(CASE WHEN typ = 'jin� nebytov� prostor' THEN plocha END) <= @jiny_nebytovy_prostor_area_upper)
          )
      -- Filtr pro 'rozestav�n� jednotka'
      AND (
           SUM(CASE WHEN typ = 'rozestav�n� jednotka' THEN 1 ELSE 0 END) = 0 
           OR 
           (MIN(CASE WHEN typ = 'rozestav�n� jednotka' THEN cenovy_udaj END) >= @rozestavena_jednotka_price_lower 
            AND MAX(CASE WHEN typ = 'rozestav�n� jednotka' THEN cenovy_udaj END) <= @rozestavena_jednotka_price_upper)
          )
      AND (
           SUM(CASE WHEN typ = 'rozestav�n� jednotka' THEN 1 ELSE 0 END) = 0 
           OR 
           (MIN(CASE WHEN typ = 'rozestav�n� jednotka' THEN plocha END) >= @rozestavena_jednotka_area_lower 
            AND MAX(CASE WHEN typ = 'rozestav�n� jednotka' THEN plocha END) <= @rozestavena_jednotka_area_upper)
          )
)
-- Fin�ln� v�stup � dopln�n� concatenovan�ch sloupc�
SELECT 
    m.*,
    STUFF(
      (SELECT ' || ' + ISNULL(t.typ_plochy, '')
       FROM [valuo].[dbo].[valuo_data] t
       WHERE t.cislo_vkladu = m.cislo_vkladu
       FOR XML PATH(''), TYPE
      ).value('.', 'NVARCHAR(MAX)'), 1, 4, '') AS typ_plochy,
    STUFF(
      (SELECT ' || ' + ISNULL(t.popis, '')
       FROM [valuo].[dbo].[valuo_data] t
       WHERE t.cislo_vkladu = m.cislo_vkladu
       FOR XML PATH(''), TYPE
      ).value('.', 'NVARCHAR(MAX)'), 1, 4, '') AS popis
FROM main m;

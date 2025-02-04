-- Intervaly pro typ 'byt'
DECLARE @byt_price_lower INT = 500000;
DECLARE @byt_price_upper INT = 40000000;
DECLARE @byt_area_lower DECIMAL(10,2) = 15;
DECLARE @byt_area_upper DECIMAL(10,2) = 300;

-- Intervaly pro typ 'ateliér'
DECLARE @ateliér_price_lower INT = 400000;
DECLARE @ateliér_price_upper INT = 20000000;
DECLARE @ateliér_area_lower DECIMAL(10,2) = 10;
DECLARE @ateliér_area_upper DECIMAL(10,2) = 200;

-- Intervaly pro typ 'rodinný dům'
DECLARE @rodinny_dum_price_lower INT = 1500000;
DECLARE @rodinny_dum_price_upper INT = 300000000;
DECLARE @rodinny_dum_area_lower DECIMAL(10,2) = 50;
DECLARE @rodinny_dum_area_upper DECIMAL(10,2) = 750;

-- Intervaly pro typ 'bytový dům'
DECLARE @bytovy_dum_price_lower INT = 1000000;
DECLARE @bytovy_dum_price_upper INT = 400000000;
DECLARE @bytovy_dum_area_lower DECIMAL(10,2) = 100;
DECLARE @bytovy_dum_area_upper DECIMAL(10,2) = 6000;

-- Intervaly pro typ 'garáž'
DECLARE @garaz_price_lower INT = 20000;
DECLARE @garaz_price_upper INT = 50000000;
DECLARE @garaz_area_lower DECIMAL(10,2) = 10;
DECLARE @garaz_area_upper DECIMAL(10,2) = 5000;

-- Intervaly pro typ 'stavba pro rodinnou rekreaci'
DECLARE @stavba_rod_rek_price_lower INT = 100000;
DECLARE @stavba_rod_rek_price_upper INT = 15000000;
DECLARE @stavba_rod_rek_area_lower DECIMAL(10,2) = 20;
DECLARE @stavba_rod_rek_area_upper DECIMAL(10,2) = 350;

-- Intervaly pro typ 'objekt bydlení'
DECLARE @objekt_bydleni_price_lower INT = 1500000;
DECLARE @objekt_bydleni_price_upper INT = 300000000;
DECLARE @objekt_bydleni_area_lower DECIMAL(10,2) = 50;
DECLARE @objekt_bydleni_area_upper DECIMAL(10,2) = 750;

-- Intervaly pro typ 'jiná stavba'
DECLARE @jina_stavba_price_lower INT = 1000000;
DECLARE @jina_stavba_price_upper INT = 30000000;
DECLARE @jina_stavba_area_lower DECIMAL(10,2) = 20;
DECLARE @jina_stavba_area_upper DECIMAL(10,2) = 150;

-- Intervaly pro typ 'jiný nebytový prostor'
DECLARE @jiny_nebytovy_prostor_price_lower INT = 300000;
DECLARE @jiny_nebytovy_prostor_price_upper INT = 30000000;
DECLARE @jiny_nebytovy_prostor_area_lower DECIMAL(10,2) = 10;
DECLARE @jiny_nebytovy_prostor_area_upper DECIMAL(10,2) = 150;

-- Intervaly pro typ 'rozestavěná jednotka'
DECLARE @rozestavena_jednotka_price_lower INT = 300000;
DECLARE @rozestavena_jednotka_price_upper INT = 30000000;
DECLARE @rozestavena_jednotka_area_lower DECIMAL(10,2) = 10;
DECLARE @rozestavena_jednotka_area_upper DECIMAL(10,2) = 350;



SELECT
    -- Unikátní číslo řízení
    cislo_vkladu,
    
    -- Základní údaje – u daného cislo_vkladu předpokládáme shodné hodnoty, proto použijeme MAX.
    MAX(CAST(listina AS VARCHAR(MAX)))         AS listina,        -- Listina (CAST z text na VARCHAR(MAX))
    MAX(datum_podani)                          AS datum_podani,   -- Datum podání
    MAX(rok)                                   AS rok,            -- Rok
    MAX(mesic)                                 AS mesic,          -- Měsíc
    MAX(okres)                                 AS okres,          -- Okres
    MAX(kat_uzemi)                             AS kat_uzemi,      -- Katastrální území
    MAX(CAST(adresa AS VARCHAR(MAX)))          AS adresa,         -- Adresa (CAST z text)
    MAX(LAT)                                   AS LAT,            -- GPS: zeměpisná šířka
    MAX(LON)                                   AS LON,            -- GPS: zeměpisná délka
    MAX(mena)                                  AS mena,           -- Měna
    FLOOR(MAX(cenovy_udaj))                    AS cenovy_udaj,    -- Cena (všech řádků je stejná)


/*   /////////////////////////////////   POCTY   /////////////////////////////////   */    
    -- Počet všech nemovitostí v rámci cislo_vkladu
    COUNT(*)                                   AS [#_NEMOVITOSTI],
    
    -- Počty BUDOV
    SUM(CASE WHEN nemovitost = 'budova'   THEN 1 ELSE 0 END)               AS [#_BUDOVA],
    -- Počty pro typy BUDOVA
	SUM(CASE WHEN typ = 'rodinný dům'    THEN 1 ELSE 0 END)                AS [#_rodinny_dum],
    SUM(CASE WHEN typ = 'bytový dům'     THEN 1 ELSE 0 END)                AS [#_bytovy_dum],
    SUM(CASE WHEN typ = 'stavba pro rodinnou rekreaci' THEN 1 ELSE 0 END)  AS [#_stavba_rod_rek],
    SUM(CASE WHEN typ = 'objekt bydlení'               THEN 1 ELSE 0 END)  AS [#_objekt_bydleni],
    SUM(CASE WHEN typ = 'jiná stavba'                   THEN 1 ELSE 0 END) AS [#_jina_stavba],


    -- Počty JEDNOTEK
    SUM(CASE WHEN nemovitost = 'jednotka'  THEN 1 ELSE 0 END)              AS [#_JEDNOTKA],
    -- Počty pro typy JEDNOTKA
    SUM(CASE WHEN typ = 'byt'            THEN 1 ELSE 0 END)                AS [#_byt],
    SUM(CASE WHEN typ = 'ateliér'        THEN 1 ELSE 0 END)                AS [#_atelier],
    SUM(CASE WHEN typ = 'jiný nebytový prostor'         THEN 1 ELSE 0 END) AS [#_jiny_nebytovy_prostor],
    SUM(CASE WHEN typ = 'rozestavěná jednotka'          THEN 1 ELSE 0 END) AS [#_rozestavena_jednotka],
   
    SUM(CASE WHEN typ = 'garáž'         THEN 1 ELSE 0 END)                 AS [#_garaz],
    


    SUM(CASE WHEN nemovitost = 'parcela'   THEN 1 ELSE 0 END) AS [#_PARCELA],
    SUM(CASE WHEN typ = 'zastavěná plocha a nádvoří' THEN 1 ELSE 0 END)           AS [#_zastavena_plocha],
    SUM(CASE WHEN typ = 'zahrada' THEN 1 ELSE 0 END)                              AS [#_zahrada],
    SUM(CASE WHEN typ = 'jiná plocha' THEN 1 ELSE 0 END)                          AS [#_jina_plocha],
    SUM(CASE WHEN typ = 'orná půda' THEN 1 ELSE 0 END)                            AS [#_orna_puda],
    SUM(CASE WHEN typ = 'zeleň' THEN 1 ELSE 0 END)                                AS [#_zelen],
    SUM(CASE WHEN typ = 'ostatní komunikace' THEN 1 ELSE 0 END)                   AS [#_ostatni_komunikace],

/*   /////////////////////////////////   PLOCHY   /////////////////////////////////   */    
   
    -- BUDOVY
    ROUND(SUM(CASE WHEN typ = 'rodinný dům' THEN plocha ELSE 0 END), 2)                  AS A_rodinny_dum,
    ROUND(SUM(CASE WHEN typ = 'bytový dům' THEN plocha ELSE 0 END), 2)                   AS A_bytovy_dum,
    ROUND(SUM(CASE WHEN typ = 'stavba pro rodinnou rekreaci' THEN plocha ELSE 0 END), 2) AS A_stavba_rod_rek,
    ROUND(SUM(CASE WHEN typ = 'objekt bydlení' THEN plocha ELSE 0 END), 2)               AS A_objekt_bydleni,
    ROUND(SUM(CASE WHEN typ = 'jiná stavba' THEN plocha ELSE 0 END), 2)                  AS A_jina_stavba,

	-- JEDNOTKY
    ROUND(SUM(CASE WHEN typ IN ('byt','ateliér') THEN plocha ELSE 0 END), 2)              AS A_byt,
    ROUND(SUM(CASE WHEN typ = 'jiný nebytový prostor' THEN plocha ELSE 0 END), 2)         AS A_jiny_nebytovy_prostor,
    ROUND(SUM(CASE WHEN typ = 'rozestavěná jednotka' THEN plocha ELSE 0 END), 2)          AS A_rozestavena_jednotka,


    ROUND(SUM(CASE WHEN typ = 'garáž' THEN plocha ELSE 0 END), 2)                         AS A_garaz,
    ROUND(SUM(CASE WHEN nemovitost = 'parcela' THEN plocha ELSE 0 END), 2)                AS A_parcela,	

    -- Sloupec TYP: Určí kategorii (prioritu) použitou pro výpočet JC.
    --    Pro priority:
    --      • Pokud existuje alespoň jeden záznam s typem z Group “A”: (byt, ateliér, jiný nebytový prostor, rozestavěná jednotka) → TYP = 'byt'
    --      • Jinak pokud existuje záznam s typem z Group “B”: (rodinný dům, stavba pro rodinnou rekreaci, objekt bydlení, jiná stavba, bytový dům) → TYP = 'rodinný dům'
    --      • Jinak pokud existuje typ 'garáž' → TYP = 'garáž'
    --      • Jinak pokud existuje parcela → TYP = 'parcela'
    CASE 
       WHEN SUM(CASE WHEN typ IN ('byt','ateliér') THEN 1 ELSE 0 END) > 0 
          THEN 'byt/ateliér'
       WHEN SUM(CASE WHEN typ IN ('jiný nebytový prostor') THEN 1 ELSE 0 END) > 0 
          THEN 'jiný nebytový prostor'
       WHEN SUM(CASE WHEN typ IN ('rozestavěná jednotka') THEN 1 ELSE 0 END) > 0 
          THEN 'rozestavěná jednotka'


       WHEN SUM(CASE WHEN typ IN ('bytový dům') THEN 1 ELSE 0 END) > 0 
          THEN 'bytový dům'
       WHEN SUM(CASE WHEN typ IN ('rodinný dům') THEN 1 ELSE 0 END) > 0 
          THEN 'rodinný dům'
       WHEN SUM(CASE WHEN typ IN ('stavba pro rodinnou rekreaci') THEN 1 ELSE 0 END) > 0 
          THEN 'stavba pro rodinnou rekreaci'
       WHEN SUM(CASE WHEN typ IN ('objekt bydlení') THEN 1 ELSE 0 END) > 0 
          THEN 'objekt bydlení'
       WHEN SUM(CASE WHEN typ IN ('jiná stavba') THEN 1 ELSE 0 END) > 0 
          THEN 'jiná stavba'




       WHEN SUM(CASE WHEN typ = 'garáž' THEN 1 ELSE 0 END) > 0 
          THEN 'garáž'
       WHEN SUM(CASE WHEN nemovitost = 'parcela' THEN 1 ELSE 0 END) > 0 
          THEN 'parcela'
       ELSE NULL
    END AS TYP,
    



    -- Sloupec MJ: Udává jednotkovou míru použitou pro výpočet JC.
    --      [m2] = dělení součtem plochy, [pocet] = dělení počtem (u garáží)
    CASE 
       WHEN SUM(CASE WHEN typ IN ('byt','ateliér','jiný nebytový prostor','rozestavěná jednotka') THEN 1 ELSE 0 END) > 0 THEN '[m2]'
       WHEN SUM(CASE WHEN typ IN ('rodinný dům','stavba pro rodinnou rekreaci','objekt bydlení','jiná stavba','bytový dům') THEN 1 ELSE 0 END) > 0 THEN '[m2]'
       WHEN SUM(CASE WHEN typ = 'garáž' THEN 1 ELSE 0 END) > 0 THEN '[pocet]'
       WHEN SUM(CASE WHEN nemovitost = 'parcela' THEN 1 ELSE 0 END) > 0 THEN '[m2]'
       ELSE NULL
    END AS MJ,
    


    -- Sloupec POCET_MJ: Divisor použitý pro výpočet JC (zaokrouhlený na 2 desetinná místa)
    ROUND(
      CASE 
/*
         WHEN SUM(CASE WHEN typ IN ('byt','ateliér','jiný nebytový prostor','rozestavěná jednotka') THEN 1 ELSE 0 END) > 0 
            THEN SUM(CASE WHEN typ IN ('byt','ateliér','jiný nebytový prostor','rozestavěná jednotka') THEN plocha ELSE 0 END)
*/
         WHEN SUM(CASE WHEN typ IN ('byt','ateliér') THEN 1 ELSE 0 END) > 0 
            THEN SUM(CASE WHEN typ IN ('byt','ateliér') THEN plocha ELSE 0 END)

         WHEN SUM(CASE WHEN typ IN ('jiný nebytový prostor') THEN 1 ELSE 0 END) > 0 
            THEN SUM(CASE WHEN typ IN ('jiný nebytový prostor') THEN plocha ELSE 0 END)

         WHEN SUM(CASE WHEN typ IN ('rozestavěná jednotka') THEN 1 ELSE 0 END) > 0 
            THEN SUM(CASE WHEN typ IN ('rozestavěná jednotka') THEN plocha ELSE 0 END)

/*
         WHEN SUM(CASE WHEN typ IN ('rodinný dům','stavba pro rodinnou rekreaci','objekt bydlení','jiná stavba','bytový dům') THEN 1 ELSE 0 END) > 0 
            THEN SUM(CASE WHEN typ IN ('rodinný dům','stavba pro rodinnou rekreaci','objekt bydlení','jiná stavba','bytový dům') THEN plocha ELSE 0 END)
*/

	     WHEN SUM(CASE WHEN typ IN ('bytový dům') THEN 1 ELSE 0 END) > 0 
            THEN SUM(CASE WHEN typ IN ('bytový dům') THEN plocha ELSE 0 END)

         WHEN SUM(CASE WHEN typ IN ('rodinný dům') THEN 1 ELSE 0 END) > 0 
            THEN SUM(CASE WHEN typ IN ('rodinný dům') THEN plocha ELSE 0 END)

	     WHEN SUM(CASE WHEN typ IN ('objekt bydlení') THEN 1 ELSE 0 END) > 0 
            THEN SUM(CASE WHEN typ IN ('objekt bydlení') THEN plocha ELSE 0 END)

         WHEN SUM(CASE WHEN typ IN ('stavba pro rodinnou rekreaci') THEN 1 ELSE 0 END) > 0 
            THEN SUM(CASE WHEN typ IN ('stavba pro rodinnou rekreaci') THEN plocha ELSE 0 END)

	     WHEN SUM(CASE WHEN typ IN ('jiná stavba') THEN 1 ELSE 0 END) > 0 
            THEN SUM(CASE WHEN typ IN ('jiná stavba') THEN plocha ELSE 0 END)







         WHEN SUM(CASE WHEN typ = 'garáž' THEN 1 ELSE 0 END) > 0 
            THEN SUM(CASE WHEN typ = 'garáž' THEN 1 ELSE 0 END)
         WHEN SUM(CASE WHEN nemovitost = 'parcela' THEN 1 ELSE 0 END) > 0 
            THEN SUM(CASE WHEN nemovitost = 'parcela' THEN plocha ELSE 0 END)
        
		
		
		ELSE NULL
      END, 2) AS POCET_MJ,



    
    -- Výpočet jednotkové ceny (JC):
    --      Cena (cenovy_udaj) dělená příslušným divisorom podle priority.
    --      Výsledek je zaokrouhlen na 0 desetinných míst a převeden na INT.
    CASE 
      WHEN SUM(CASE WHEN typ IN ('byt','ateliér') THEN 1 ELSE 0 END) > 0 
         THEN CAST(ROUND(MAX(cenovy_udaj)*1.0 / NULLIF(SUM(CASE WHEN typ IN ('byt','ateliér') THEN plocha ELSE 0 END), 0), 0) AS INT)

      WHEN SUM(CASE WHEN typ IN ('jiný nebytový prostor') THEN 1 ELSE 0 END) > 0 
         THEN CAST(ROUND(MAX(cenovy_udaj)*1.0 / NULLIF(SUM(CASE WHEN typ IN ('jiný nebytový prostor') THEN plocha ELSE 0 END), 0), 0) AS INT)

      WHEN SUM(CASE WHEN typ IN ('rozestavěná jednotka') THEN 1 ELSE 0 END) > 0 
         THEN CAST(ROUND(MAX(cenovy_udaj)*1.0 / NULLIF(SUM(CASE WHEN typ IN ('rozestavěná jednotka') THEN plocha ELSE 0 END), 0), 0) AS INT)

/*
      WHEN SUM(CASE WHEN typ IN ('byt','ateliér','jiný nebytový prostor','rozestavěná jednotka') THEN 1 ELSE 0 END) > 0 
         THEN CAST(ROUND(MAX(cenovy_udaj)*1.0 / NULLIF(SUM(CASE WHEN typ IN ('byt','ateliér','jiný nebytový prostor','rozestavěná jednotka') THEN plocha ELSE 0 END), 0), 0) AS INT)
*/

	  WHEN SUM(CASE WHEN typ IN ('bytový dům') THEN 1 ELSE 0 END) > 0 
         THEN CAST(ROUND(MAX(cenovy_udaj)*1.0 / NULLIF(SUM(CASE WHEN typ IN ('bytový dům') THEN plocha ELSE 0 END), 0), 0) AS INT)

      WHEN SUM(CASE WHEN typ IN ('rodinný dům') THEN 1 ELSE 0 END) > 0 
         THEN CAST(ROUND(MAX(cenovy_udaj)*1.0 / NULLIF(SUM(CASE WHEN typ IN ('rodinný dům') THEN plocha ELSE 0 END), 0), 0) AS INT)

	  WHEN SUM(CASE WHEN typ IN ('objekt bydlení') THEN 1 ELSE 0 END) > 0 
         THEN CAST(ROUND(MAX(cenovy_udaj)*1.0 / NULLIF(SUM(CASE WHEN typ IN ('objekt bydlení') THEN plocha ELSE 0 END), 0), 0) AS INT)

	  WHEN SUM(CASE WHEN typ IN ('stavba pro rodinnou rekreaci') THEN 1 ELSE 0 END) > 0 
         THEN CAST(ROUND(MAX(cenovy_udaj)*1.0 / NULLIF(SUM(CASE WHEN typ IN ('stavba pro rodinnou rekreaci') THEN plocha ELSE 0 END), 0), 0) AS INT)

	  WHEN SUM(CASE WHEN typ IN ('jiná stavba') THEN 1 ELSE 0 END) > 0 
         THEN CAST(ROUND(MAX(cenovy_udaj)*1.0 / NULLIF(SUM(CASE WHEN typ IN ('jiná stavba') THEN plocha ELSE 0 END), 0), 0) AS INT)


      WHEN SUM(CASE WHEN typ = 'garáž' THEN 1 ELSE 0 END) > 0 
         THEN CAST(ROUND(MAX(cenovy_udaj)*1.0 / NULLIF(SUM(CASE WHEN typ = 'garáž' THEN 1 ELSE 0 END), 0), 0) AS INT)
      WHEN SUM(CASE WHEN nemovitost = 'parcela' THEN 1 ELSE 0 END) > 0 
         THEN CAST(ROUND(MAX(cenovy_udaj)*1.0 / NULLIF(SUM(CASE WHEN nemovitost = 'parcela' THEN plocha ELSE 0 END), 0), 0) AS INT)

      ELSE NULL
    END AS JC

	--typ_plochy,
	--popis

FROM [valuo].[dbo].[valuo_data]

GROUP BY cislo_vkladu

HAVING 
  -- Zajištění existence alespoň jednoho záznamu s některým z požadovaných typů
  SUM(CASE WHEN typ IN (
         'byt','ateliér','rodinný dům','bytový dům','garáž',
         'stavba pro rodinnou rekreaci','objekt bydlení','jiná stavba',
         'jiný nebytový prostor','rozestavěná jednotka'
      ) THEN 1 ELSE 0 END) > 0
  AND MIN(cenovy_udaj) > 0
  AND MIN(plocha) > 0

  -- Filtr pro typ 'byt'
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

  -- Filtr pro typ 'ateliér'
  AND (
       SUM(CASE WHEN typ = 'ateliér' THEN 1 ELSE 0 END) = 0 
       OR 
       (MIN(CASE WHEN typ = 'ateliér' THEN cenovy_udaj END) >= @ateliér_price_lower 
        AND MAX(CASE WHEN typ = 'ateliér' THEN cenovy_udaj END) <= @ateliér_price_upper)
      )
  AND (
       SUM(CASE WHEN typ = 'ateliér' THEN 1 ELSE 0 END) = 0 
       OR 
       (MIN(CASE WHEN typ = 'ateliér' THEN plocha END) >= @ateliér_area_lower 
        AND MAX(CASE WHEN typ = 'ateliér' THEN plocha END) <= @ateliér_area_upper)
      )

  -- Filtr pro typ 'rodinný dům'
  AND (
       SUM(CASE WHEN typ = 'rodinný dům' THEN 1 ELSE 0 END) = 0 
       OR 
       (MIN(CASE WHEN typ = 'rodinný dům' THEN cenovy_udaj END) >= @rodinny_dum_price_lower 
        AND MAX(CASE WHEN typ = 'rodinný dům' THEN cenovy_udaj END) <= @rodinny_dum_price_upper)
      )
  AND (
       SUM(CASE WHEN typ = 'rodinný dům' THEN 1 ELSE 0 END) = 0 
       OR 
       (MIN(CASE WHEN typ = 'rodinný dům' THEN plocha END) >= @rodinny_dum_area_lower 
        AND MAX(CASE WHEN typ = 'rodinný dům' THEN plocha END) <= @rodinny_dum_area_upper)
      )

  -- Filtr pro typ 'bytový dům'
  AND (
       SUM(CASE WHEN typ = 'bytový dům' THEN 1 ELSE 0 END) = 0 
       OR 
       (MIN(CASE WHEN typ = 'bytový dům' THEN cenovy_udaj END) >= @bytovy_dum_price_lower 
        AND MAX(CASE WHEN typ = 'bytový dům' THEN cenovy_udaj END) <= @bytovy_dum_price_upper)
      )
  AND (
       SUM(CASE WHEN typ = 'bytový dům' THEN 1 ELSE 0 END) = 0 
       OR 
       (MIN(CASE WHEN typ = 'bytový dům' THEN plocha END) >= @bytovy_dum_area_lower 
        AND MAX(CASE WHEN typ = 'bytový dům' THEN plocha END) <= @bytovy_dum_area_upper)
      )

  -- Filtr pro typ 'garáž'
  AND (
       SUM(CASE WHEN typ = 'garáž' THEN 1 ELSE 0 END) = 0 
       OR 
       (MIN(CASE WHEN typ = 'garáž' THEN cenovy_udaj END) >= @garaz_price_lower 
        AND MAX(CASE WHEN typ = 'garáž' THEN cenovy_udaj END) <= @garaz_price_upper)
      )
  AND (
       SUM(CASE WHEN typ = 'garáž' THEN 1 ELSE 0 END) = 0 
       OR 
       (MIN(CASE WHEN typ = 'garáž' THEN plocha END) >= @garaz_area_lower 
        AND MAX(CASE WHEN typ = 'garáž' THEN plocha END) <= @garaz_area_upper)
      )

  -- Filtr pro typ 'stavba pro rodinnou rekreaci'
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

  -- Filtr pro typ 'objekt bydlení'
  AND (
       SUM(CASE WHEN typ = 'objekt bydlení' THEN 1 ELSE 0 END) = 0 
       OR 
       (MIN(CASE WHEN typ = 'objekt bydlení' THEN cenovy_udaj END) >= @objekt_bydleni_price_lower 
        AND MAX(CASE WHEN typ = 'objekt bydlení' THEN cenovy_udaj END) <= @objekt_bydleni_price_upper)
      )
  AND (
       SUM(CASE WHEN typ = 'objekt bydlení' THEN 1 ELSE 0 END) = 0 
       OR 
       (MIN(CASE WHEN typ = 'objekt bydlení' THEN plocha END) >= @objekt_bydleni_area_lower 
        AND MAX(CASE WHEN typ = 'objekt bydlení' THEN plocha END) <= @objekt_bydleni_area_upper)
      )

  -- Filtr pro typ 'jiná stavba'
  AND (
       SUM(CASE WHEN typ = 'jiná stavba' THEN 1 ELSE 0 END) = 0 
       OR 
       (MIN(CASE WHEN typ = 'jiná stavba' THEN cenovy_udaj END) >= @jina_stavba_price_lower 
        AND MAX(CASE WHEN typ = 'jiná stavba' THEN cenovy_udaj END) <= @jina_stavba_price_upper)
      )
  AND (
       SUM(CASE WHEN typ = 'jiná stavba' THEN 1 ELSE 0 END) = 0 
       OR 
       (MIN(CASE WHEN typ = 'jiná stavba' THEN plocha END) >= @jina_stavba_area_lower 
        AND MAX(CASE WHEN typ = 'jiná stavba' THEN plocha END) <= @jina_stavba_area_upper)
      )

  -- Filtr pro typ 'jiný nebytový prostor'
  AND (
       SUM(CASE WHEN typ = 'jiný nebytový prostor' THEN 1 ELSE 0 END) = 0 
       OR 
       (MIN(CASE WHEN typ = 'jiný nebytový prostor' THEN cenovy_udaj END) >= @jiny_nebytovy_prostor_price_lower 
        AND MAX(CASE WHEN typ = 'jiný nebytový prostor' THEN cenovy_udaj END) <= @jiny_nebytovy_prostor_price_upper)
      )
  AND (
       SUM(CASE WHEN typ = 'jiný nebytový prostor' THEN 1 ELSE 0 END) = 0 
       OR 
       (MIN(CASE WHEN typ = 'jiný nebytový prostor' THEN plocha END) >= @jiny_nebytovy_prostor_area_lower 
        AND MAX(CASE WHEN typ = 'jiný nebytový prostor' THEN plocha END) <= @jiny_nebytovy_prostor_area_upper)
      )

  -- Filtr pro typ 'rozestavěná jednotka'
  AND (
       SUM(CASE WHEN typ = 'rozestavěná jednotka' THEN 1 ELSE 0 END) = 0 
       OR 
       (MIN(CASE WHEN typ = 'rozestavěná jednotka' THEN cenovy_udaj END) >= @rozestavena_jednotka_price_lower 
        AND MAX(CASE WHEN typ = 'rozestavěná jednotka' THEN cenovy_udaj END) <= @rozestavena_jednotka_price_upper)
      )
  AND (
       SUM(CASE WHEN typ = 'rozestavěná jednotka' THEN 1 ELSE 0 END) = 0 
       OR 
       (MIN(CASE WHEN typ = 'rozestavěná jednotka' THEN plocha END) >= @rozestavena_jednotka_area_lower 
        AND MAX(CASE WHEN typ = 'rozestavěná jednotka' THEN plocha END) <= @rozestavena_jednotka_area_upper)
      );

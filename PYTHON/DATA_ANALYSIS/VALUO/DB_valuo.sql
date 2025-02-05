/*
//////////////////////////   TABULKA   ///////////////////////////////
USE VALUO
--  struktura tabulky dle export filu tahanych z valua
Drop table Valuo_data;
Create table Valuo_data
	(
    id INT IDENTITY(1,1) PRIMARY KEY,
	timestamp datetime2(0) default (sysdatetime()), 
    cislo_vkladu VARCHAR(50) NOT NULL,
    datum_podani DATETIME NOT NULL,
    datum_zplatneni DATETIME NOT NULL,
    listina TEXT NOT NULL,
    nemovitost VARCHAR(50) NOT NULL,
    typ VARCHAR(100) NOT NULL,
    adresa VARCHAR(400) NOT NULL,
    cenovy_udaj DECIMAL(18,2) NOT NULL,
    mena VARCHAR(10) NOT NULL,
    plocha DECIMAL(10,2),
    typ_plochy VARCHAR(300),
    popis VARCHAR(800),
    okres VARCHAR(100) NOT NULL,
    kat_uzemi VARCHAR(100) NOT NULL,
    rok INT NOT NULL,
    mesic INT NOT NULL,
	LAT DECIMAL(9,7),
    LON DECIMAL(9,7)
    
	);
//////////////////////////   TABULKA   ///////////////////////////////
*/


/*

UPDATE [valuo].[dbo].[valuo_data] 
SET LAT = NULL, LON = NULL 
WHERE LAT IS not NULL AND LON IS not NULL;

UPDATE [valuo].[dbo].[valuo_data] 
SET GPS_API_info = 'OK' 
WHERE id BETWEEN 1 AND 1705;
*/






-- Deklarace prom�nn�ch pro dynamick� SQL dotazy


DECLARE @cols NVARCHAR(MAX),       -- Dynamick� seznam let pro PIVOT
        @dynSQL NVARCHAR(MAX),     -- Dynamick� dotaz s PIVOTem
        @staticSQL NVARCHAR(MAX),  -- Statick� dotaz s agregacemi
        @finalSQL NVARCHAR(MAX);   -- Fin�ln� dotaz kombinuj�c� statick� a pivotovan� data

-------------------------------------------------------------
-- 1. Sestaven� seznamu unik�tn�ch rok� jako n�zv� sloupc�
-------------------------------------------------------------
-- Pou�it� STRING_AGG pro SQL Server 2017+
IF (SELECT @@VERSION) LIKE '%2017%' OR (SELECT @@VERSION) LIKE '%2019%' OR (SELECT @@VERSION) LIKE '%2022%'
BEGIN
    SELECT @cols = STRING_AGG(QUOTENAME(CAST(rok AS VARCHAR(4))), ',') 
                   WITHIN GROUP (ORDER BY CAST(rok AS INT) DESC)
    FROM (
        SELECT DISTINCT rok 
        FROM [valuo].[dbo].[valuo_data]
        WHERE nemovitost IS NOT NULL   
          AND typ IS NOT NULL          
          AND cenovy_udaj IS NOT NULL  
          AND plocha IS NOT NULL       
          AND LAT IS NOT NULL          
          AND LON IS NOT NULL
    ) t;
END
ELSE -- Pro star�� verze SQL Serveru (2016 a n�e)
BEGIN
    SELECT @cols = STUFF((
        SELECT ',' + QUOTENAME(CAST(rok AS VARCHAR(4))) 
        FROM (
            SELECT DISTINCT CAST(rok AS INT) AS rok
            FROM [valuo].[dbo].[valuo_data]
            WHERE nemovitost IS NOT NULL   
              AND typ IS NOT NULL          
              AND cenovy_udaj IS NOT NULL  
              AND plocha IS NOT NULL       
              AND LAT IS NOT NULL          
              AND LON IS NOT NULL
        ) t
        ORDER BY rok DESC
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '');
END

-- Kontrola v�stupu
PRINT 'Seznam rok� pro PIVOT: ' + @cols;

-------------------------------------------------------------
-- 2. Sestaven� dynamick�ho dotazu s PIVOTem
-------------------------------------------------------------
SET @dynSQL = '
SELECT ' + @cols + '          -- Dynamicky vytvo�en� sloupce, tj. jednotliv� roky
FROM (
    -- Poddotaz: vyb�r�me rok a cislo_vkladu z tabulky, kde jsou spln�ny podm�nky
    SELECT CAST(rok AS VARCHAR(4)) AS rok, cislo_vkladu
    FROM [valuo].[dbo].[valuo_data]
    WHERE nemovitost IS NOT NULL    
      AND typ IS NOT NULL           
      AND cenovy_udaj IS NOT NULL   
      AND plocha IS NOT NULL        
      AND LAT IS NOT NULL           
      AND LON IS NOT NULL
) AS src
PIVOT (
    COUNT(cislo_vkladu)            
    FOR rok IN (' + @cols + ')     
) AS pvt
';

-------------------------------------------------------------
-- 3. Sestaven� statick�ho dotazu s pevn�mi agregacemi
-------------------------------------------------------------
SET @staticSQL = '
SELECT 
  COUNT(DISTINCT CONCAT(kat_uzemi, ''-'', rok, ''-'', mesic)) AS [#souboru],  
  COUNT(cislo_vkladu) AS [#V],  
  COUNT(DISTINCT cislo_vkladu) AS [#V_unique],  
  COUNT(CASE WHEN LAT IS NOT NULL AND LON IS NOT NULL THEN 1 END) AS [#v_YES_GPS],  
  COUNT(CASE WHEN LAT IS NULL AND LON IS NULL THEN 1 END) AS [#v_NO_GPS],  
  COUNT(DISTINCT CONCAT(LAT, ''-'', LON)) AS [#V_GPS_unique],  
  COUNT(CASE WHEN GPS_API_info = ''ERR'' THEN 1 END) AS [#GPS_API_ERR],  
  COUNT(CASE WHEN adresa <> ''Nezn�m� adresa'' THEN 1 END) AS [#adresa],  
  COUNT(DISTINCT CASE WHEN adresa <> ''Nezn�m� adresa'' THEN adresa END) AS [#adresa_unique],  
  COUNT(CASE WHEN adresa = ''Nezn�m� adresa'' THEN 1 END) AS [#adresa_neznama],  
  COUNT(DISTINCT okres) AS [#okresu],  
  COUNT(DISTINCT CONCAT(okres, ''-'', kat_uzemi)) AS [#kat_uzemi],  
  COUNT(CASE WHEN nemovitost = ''budova'' THEN 1 END) AS [#budova],  
  COUNT(CASE WHEN nemovitost = ''jednotka'' THEN 1 END) AS [#jednotka],  
  COUNT(CASE WHEN nemovitost = ''parcela'' THEN 1 END) AS [#parcela],  
  COUNT(CASE WHEN typ = ''rodinn� d�m'' THEN 1 END) AS [#RD],  
  COUNT(CASE WHEN typ = ''byt'' THEN 1 END) AS [#byt],  
  COUNT(CASE WHEN typ = ''ateli�r'' THEN 1 END) AS [#atelier],  
  COUNT(CASE WHEN typ = ''gar�'' THEN 1 END) AS [#gar�]  
FROM [valuo].[dbo].[valuo_data]
';

-------------------------------------------------------------
-- 4. Sestaven� fin�ln�ho dotazu, kter� spojuje statick� data a pivot data
-------------------------------------------------------------
SET @finalSQL = '
WITH StaticData AS (
' + @staticSQL + '
),
PivotData AS (
' + @dynSQL + '
)
SELECT s.*, p.*
FROM StaticData s
CROSS JOIN PivotData p;
';

-------------------------------------------------------------
-- 5. Spu�t�n� fin�ln�ho dotazu
-------------------------------------------------------------
EXEC sp_executesql @finalSQL;





select 
-- ////////////////////////////////////////      prehled po okresech, kat_uzemi, letech, mesicich
     okres,
     kat_uzemi,
     rok,
     mesic,
     count(cislo_vkladu) as [#v],  -- celkov� po�et z�znam�
     count(case when lat is not null and lon is not null then 1 end) as [#v_gps],  -- po�et z�znam� s gps
     (select count(*) 
      from (
          select distinct lat, lon  
          from valuo_data v
          where v.kat_uzemi = vd.kat_uzemi 
            and v.rok = vd.rok 
            and v.mesic = vd.mesic
            and v.lat is not null 
            and v.lon is not null
      ) as gps_unique
     ) as [#v_gps_unique],  -- po�et unik�tn�ch gps sou�adnic pro danou skupinu

     count(case when nemovitost = 'budova' then 1 end) as [budova],  -- po�et budov
     count(case when nemovitost = 'jednotka' then 1 end) as [jednotka],  -- po�et jednotek
     count(case when nemovitost = 'parcela' then 1 end) as [parcela]  -- po�et parcel
from [valuo].[dbo].[valuo_data] vd
group by
     okres,
     kat_uzemi,
     rok,
     mesic
order by okres, kat_uzemi, rok, mesic desc;
-- ////////////////////////////////////////      prehled po okresech, kat_uzemi, letech, mesicich







select 
/* //////////   cela tabulka   ////////// */ 
     * from [dbo].[Valuo_data]


select 
/* //////////   cela tabulka   ////////// */ 
     * from [dbo].[Valuo_data] 
	 where 1=1
	       and okres = 'Hlavn� m�sto Praha'
		   --and kat_uzemi = 'Bubene�'
	       --and nemovitost = 'budova'
		   and cenovy_udaj >200000000
		



SELECT adresa, LAT, LON FROM Valuo_data WHERE LAT IS NOT NULL AND LON IS NOT NULL
SELECT id, adresa FROM Valuo_data WHERE LAT IS NULL AND LON IS NULL AND (adresa IS NOT NULL AND adresa <> 'Nezn�m� adresa')
SELECT id, adresa FROM Valuo_data WHERE adresa = 'Nezn�m� adresa'


select * from 
(
SELECT 
    v.id,
    v.adresa,
    (
        SELECT COUNT(*)
        FROM Valuo_data AS vd
        WHERE vd.LAT IS NOT NULL
          AND vd.LON IS NOT NULL
          AND vd.adresa = v.adresa
    ) AS duplicita
FROM Valuo_data AS v
WHERE v.LAT IS NULL
  AND v.LON IS NULL
  AND v.adresa IS NOT NULL
  AND v.adresa <> 'Nezn�m� adresa'
 ) as x where duplicita > 0
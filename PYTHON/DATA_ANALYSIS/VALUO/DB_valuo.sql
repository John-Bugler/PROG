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
    adresa TEXT NOT NULL,
    cenovy_udaj DECIMAL(18,2) NOT NULL,
    mena VARCHAR(10) NOT NULL,
    plocha DECIMAL(10,2),
    typ_plochy TEXT,
    popis TEXT,
    okres VARCHAR(100) NOT NULL,
    kat_uzemi VARCHAR(100) NOT NULL,
    rok INT NOT NULL,
    mesic INT NOT NULL,
	LAT DECIMAL(9,7),
    LON DECIMAL(9,7)
 
	);



select * from [dbo].[Valuo_data]

select * from [dbo].[Valuo_data] where LAT <> 0

SELECT CAST(adresa AS NVARCHAR(MAX)) AS adresa, LAT, LON, nemovitost, plocha, mena, cenovy_udaj, cenovy_udaj/plocha as JC
FROM Valuo_data 
WHERE LAT IS NOT NULL AND LON IS NOT NULL AND LAT != 0 AND LON != 0 and nemovitost = 'jednotka' and cenovy_udaj is not null and cenovy_udaj != 0 and plocha > 0 and mena = 'CZK'
GROUP BY CAST(adresa AS NVARCHAR(MAX)), LAT, LON, nemovitost, plocha, mena, cenovy_udaj
order by JC asc
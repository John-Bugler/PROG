/*
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
*/





-- souhrnny prehled DAT
select 
  
  count(distinct concat(kat_uzemi, '-', rok, '-', mesic)) as [#souboru],  -- poèet unikátních kombinací kat_uzemi, rok, mesic = 1 soubor VALUO
  count(cislo_vkladu) as [#v],  -- celkový poèet záznamù
    (select count(*) 
     from (
         select distinct 
             cislo_vkladu, 
             datum_podani, 
             datum_zplatneni, 
             cast(listina as varchar(max)) as listina, 
             nemovitost, 
             typ, 
             cast(adresa as varchar(max)) as adresa, 
             cenovy_udaj, 
             mena, 
             plocha, 
             cast(typ_plochy as varchar(max)) as typ_plochy, 
             cast(popis as varchar(max)) as popis, 
             okres, 
             kat_uzemi, 
             rok, 
             mesic, 
             lat, 
             lon
         from valuo_data
     ) as subquery) as [#v_unique],  -- poèet unikátních záznamù

    count(case when lat is not null and lon is not null then 1 end) as [#v_YES_gps],  -- poèet záznamù s gps
    count(case when lat is null and lon is null then 1 end) as [#v_NO_gps],  -- poèet záznamù s gps

    (select count(*) 
     from (
         select distinct lat, lon  
         from valuo_data 
         where lat is not null and lon is not null
     ) as gps_unique
    ) as [#v_gps_unique],  -- poèet unikátních gps souøadnic

	(select count(*) from valuo_data where adresa <> 'Neznámá adresa') as [#adresa],

    (select count(*) 
     from (
         select distinct adresa  
         from valuo_data 
         where adresa <> 'Neznámá adresa'
     ) as adresa_unique
    ) as [#adresa_unique],

    (select count(*) from valuo_data where adresa = 'Neznámá adresa') as [#adresa_neznama],

	
	count(distinct okres) as [#okresu], 
	count(distinct concat(okres, '-', kat_uzemi)) as [#kat_uzemi], 
	
	
	(select count(*) from valuo_data where nemovitost = 'budova') as [#budova],
    (select count(*) from valuo_data where nemovitost = 'jednotka') as [#jednotka],
	(select count(*) from valuo_data where nemovitost = 'parcela') as [#parcela],

	(select count(*) from valuo_data where typ = 'rodinný dùm') as [#RD],
	(select count(*) from valuo_data where typ = 'byt') as [#byt],
	(select count(*) from valuo_data where typ = 'ateliér') as [#atelier]


from [valuo].[dbo].[valuo_data];

-- prehled po okresech, kat_uzemi, letech, mesicich
select 
     okres,
     kat_uzemi,
     rok,
     mesic,
     count(cislo_vkladu) as [#v],  -- celkový poèet záznamù
     count(case when lat is not null and lon is not null then 1 end) as [#v_gps],  -- poèet záznamù s gps
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
     ) as [#v_gps_unique],  -- poèet unikátních gps souøadnic pro danou skupinu

     count(case when nemovitost = 'budova' then 1 end) as [budova],  -- poèet budov
     count(case when nemovitost = 'jednotka' then 1 end) as [jednotka],  -- poèet jednotek
     count(case when nemovitost = 'parcela' then 1 end) as [parcela]  -- poèet parcel
from [valuo].[dbo].[valuo_data] vd
group by
     okres,
     kat_uzemi,
     rok,
     mesic
order by okres, kat_uzemi, rok, mesic desc;



select * from [dbo].[Valuo_data]


/*

select top 10 
		cast(adresa as nvarchar(max)) as adresa
		, lat
		, lon
		, nemovitost
		, plocha
		, mena
		, cenovy_udaj
		, cenovy_udaj/plocha as jc
from [VALUO].[dbo].[Valuo_data]
where lat is not null and lon is not null 
		and lat != 0 and lon != 0 
		and nemovitost = 'jednotka' 
		and cenovy_udaj is not null 
		and cenovy_udaj != 0 
		and plocha > 0
		and mena = 'czk'
group by cast(adresa as nvarchar(max)), lat, lon, nemovitost, plocha, mena, cenovy_udaj
order by jc asc

*/


/*

UPDATE [valuo].[dbo].[valuo_data] 
SET LAT = NULL, LON = NULL 
WHERE LAT IS not NULL AND LON IS not NULL;

*/

/*
UPDATE [valuo].[dbo].[valuo_data] 
SET GPS_API_info = 'OK' 
WHERE id BETWEEN 1 AND 1705;
*/



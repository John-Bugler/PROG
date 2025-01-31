USE VALUO
--  struktura tabulky dle export filu tahanych z valua
Drop table Valuo_data;
Create table Valuo_data
	(
    id INT IDENTITY(1,1) PRIMARY KEY,
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
    mesic INT NOT NULL
	   
	);





select * from [dbo].[Valuo_data]
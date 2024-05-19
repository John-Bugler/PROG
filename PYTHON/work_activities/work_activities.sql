------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------TABLES------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
/*

USE Reports;
Drop table Work_Activities;
Create table Work_Activities
	(
	ID Int identity(1,1) primary key,
    timestamp datetime2(0) default (sysdatetime()),      -- timestamp ulozeni zaznamu do tabulky
	c_ZP nvarchar(15),    
	ID_activity int,                                     -- id aktivity z python programu 
	start datetime not null,                            
	stop datetime not null,         
	duration numeric(5,3),
    activity nvarchar(200)
	
	);

	
*/
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------TABLES------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

select * from [reports].[dbo].[Work_Activities];




select c_ZP 
       ,(select max(stop) from [reports].[dbo].[Work_Activities] cin where pos.c_ZP = cin.c_ZP) as posudek_dokoncen
	   ,count(id_activity) as pocet_cinnosti
	   ,sum(duration) as doba_zpracovani

from [reports].[dbo].[Work_Activities] pos
group by c_ZP
order by c_ZP desc;


select * from [reports].[dbo].[Work_Activities]
where c_ZP like '042819-2024'
group by activity
order by stop asc;



select 
    c_zp,
    activity as cinnost,
    min(stop) as dokonceni,
    sum(duration) as trvani_cinnosti
from 
    [reports].[dbo].[work_activities]
where 
    c_zp like '042819-2024'
group by 
    c_zp, activity
order by 
    dokonceni asc;

/*
update  [reports].[dbo].[work_activities]
set activity = 'zpracovávání ZP - textová èást'
where id = 3;



*/
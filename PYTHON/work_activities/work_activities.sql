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


select * from [reports].[dbo].[Work_Activities]
where c_zp like '042819-2024'
order by start desc;


/*SUMA PO POSUDCÍCH*/
select c_ZP 
       ,(select max(stop) from [reports].[dbo].[Work_Activities] cin where pos.c_ZP = cin.c_ZP) as posudek_dokoncen
	   ,count(id_activity) as pocet_cinnosti
	   ,sum(duration) as doba_zpracovani

from [reports].[dbo].[Work_Activities] pos
group by c_ZP
order by c_ZP desc;


/*ROZKLAD CINNOSTI (group po cinnostech) ZADANEHO POSUDKU*/
select 
    c_zp,
    activity as cinnost,
    min(start) as zapoceti,
	max(stop) as dokonceni,
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
insert into [reports].[dbo].[work_activities]
(timestamp, ID_activity, start, stop, duration, activity, c_ZP)
values ('2024-05-27 15:25:09.045',1,'2024-05-27 11:15:48.650', '2024-05-27 15:05:02.066', 3.82, 'zpracovávání ZP - analytická èást', '042819-2024')

insert into [reports].[dbo].[work_activities]
(ID_activity, start, stop, duration, activity, c_ZP)
values (1,'2024-05-24 10:00:00.000', '2024-05-24 12:05:08.054', 2.08, 'místní šetøení', '042819-2024')


update  [reports].[dbo].[work_activities]
set 
timestamp = '2024-05-26 15:25:09.045',
start = '2024-05-26 11:15:48.650',
stop = '2024-05-26 15:05:02.066'
where id = 8;


update  [reports].[dbo].[work_activities]
set activity = 'zpracovávání ZP - textová èást'
where id = 3;

delete from [reports].[dbo].[work_activities]
where  id = 10;


*/
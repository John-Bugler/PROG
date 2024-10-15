SELECT name, sid FROM sys.server_principals WHERE name = 'RYZEN5\ijttr';

SELECT name, sid FROM sys.server_principals WHERE name = 'RYZEN9\ijttr';

SELECT @@servername;

EXEC sp_dropserver 'RYZEN5';
EXEC sp_addserver 'RYZEN9', 'local';

--restart SQL Serveru


SELECT session_id, login_name, host_name, status
FROM sys.dm_exec_sessions
WHERE login_name = 'RYZEN5\ijttr';

SELECT @@SPID;


KILL 68;
KILL 109;



SELECT name, type_desc, sid FROM sys.server_principals WHERE name LIKE '%RYZEN5%';
DROP LOGIN [RYZEN5\ijttr];
CREATE LOGIN [RYZEN9\ijttr] FROM WINDOWS;
ALTER SERVER ROLE sysadmin ADD MEMBER [RYZEN9\ijttr];
SELECT name, type_desc, sid FROM sys.server_principals WHERE name LIKE '%RYZEN%';

EXEC sp_helplogins 'RYZEN9\ijttr';



CREATE LOGIN [RYZEN9\ijttr] FROM WINDOWS;
ALTER SERVER ROLE sysadmin ADD MEMBER [RYZEN9\ijttr];

SELECT name, type_desc, is_disabled 
FROM sys.server_principals 
WHERE name = 'RYZEN9\ijttr';



SELECT IS_SRVROLEMEMBER('sysadmin') AS IsSysAdmin;


SELECT session_id, login_name
FROM sys.dm_exec_sessions
WHERE login_name = 'RYZEN5\ijttr';



SELECT dp.name AS UserName, dp.type_desc AS UserType, dp.is_fixed_role
FROM sys.database_principals dp
WHERE dp.name = 'RYZEN5\ijttr';

EXEC sp_configure 'show advanced options', 1;  
GO  
-- To update the currently configured value for advanced options.  
RECONFIGURE;  
GO  
-- To enable the feature.  
EXEC sp_configure 'xp_cmdshell', 1;  
GO  
-- To update the currently configured value for this feature.  
RECONFIGURE;  
GO  


DECLARE @name VARCHAR(50) -- database name  
DECLARE @path VARCHAR(256) -- path for backup files  
DECLARE @fileName VARCHAR(256) -- filename for backup  
DECLARE @fileDate VARCHAR(20) -- used for file name
 
 -- To allow advanced options to be changed.  

-- specify database backup directory
SET @path = 'C:\Backup\'  
declare @cmd nvarchar(1000) = 'mkdir ' + @path
exec master.dbo.xp_cmdshell @cmd , no_output
-- specify filename format
SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112) 
 
DECLARE db_cursor CURSOR READ_ONLY FOR  
SELECT name 
FROM master.sys.databases 
where 1=1

AND state = 0 -- database is online
AND is_in_standby = 0 -- database is not read only for log shipping
and name NOT IN ('tempdb')-- ('master','model','msdb')--)  -- exclude these databases
 
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @name   
 
WHILE @@FETCH_STATUS = 0   
BEGIN   
   SET @fileName = @path + @name + '_' + @fileDate + '.BAK'  
   BACKUP DATABASE @name TO DISK = @fileName  
 
   FETCH NEXT FROM db_cursor INTO @name   
END   

 
CLOSE db_cursor   
DEALLOCATE db_cursor
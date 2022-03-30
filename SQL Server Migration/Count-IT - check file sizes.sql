EXEC sp_MSforeachdb @command1 = N'
USE [?];
SELECT ''?'' AS [Database],
  sys.database_files.name AS [FileName],
  sys.database_files.physical_name AS [FilePath],
  CONVERT(DECIMAL(10,2), sys.database_files.size / 128.0) AS [Filesize MB],
  CONVERT(DECIMAL(10,2), sys.database_files.size / 128.0 - ((sys.database_files.size / 128.0) - CAST(FILEPROPERTY(sys.database_files.name, ''SPACEUSED'') AS int) / 128.0)) AS [Used MB],
  CONVERT(DECIMAL(10,2), sys.database_files.size / 128.0 - CAST(FILEPROPERTY(sys.database_files.name, ''SPACEUSED'') AS int) / 128.0) AS [Free MB],
  CONVERT(DECIMAL(10,2), ((sys.database_files.size / 128.0 - CAST(FILEPROPERTY(sys.database_files.name, ''SPACEUSED'') AS int) / 128.0) / (sys.database_files.size / 128.0)) * 100) AS [Free Percent]
FROM sys.database_files 
LEFT JOIN sys.filegroups ON sys.database_files.data_space_id = sys.filegroups.data_space_id
ORDER BY [FileName] ASC;'
GO

/*

USE [LaundryAutomationTest];
GO

DBCC SHRINKFILE (LaundryAutomation, 7168);
GO

*/
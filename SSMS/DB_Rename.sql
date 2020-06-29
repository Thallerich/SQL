/* Set Database as a Single User */
ALTER DATABASE Wozabal_Klagenfurt SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
--ALTER DATABASE Wozabal_Lenzing_2 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

/* Change Logical File Names */
ALTER DATABASE Wozabal_Klagenfurt MODIFY FILE (NAME=N'Wozabal_Klagenfurt', NEWNAME=N'Salesianer_Klagenfurt');
--ALTER DATABASE Wozabal_Lenzing_2 MODIFY FILE (NAME=N'Wozabal_Lenzing_2', NEWNAME=N'Salesianer_Lenzing_2');
ALTER DATABASE Wozabal_Klagenfurt MODIFY FILE (NAME=N'Wozabal_Klagenfurt_log', NEWNAME=N'Salesianer_Klagenfurt_log');
--ALTER DATABASE Wozabal_Lenzing_2 MODIFY FILE (NAME=N'Wozabal_Lenzing_2_log', NEWNAME=N'Salesianer_Lenzing_2_log');
GO

/* #################################################### */

/* Detach DB */
EXEC master.dbo.sp_detach_db @dbname = N'Wozabal_Klagenfurt';
--EXEC master.dbo.sp_detach_db @dbname = N'Wozabal_Lenzing_2';
GO

/* #################################################### */

-- Rename files now

/* #################################################### */

CREATE DATABASE Salesianer_Klagenfurt ON 
( FILENAME = N'M:\Data01\Salesianer_Klagenfurt.mdf' ),
( FILENAME = N'M:\Log01\Salesianer_Klagenfurt_log.ldf' )
FOR ATTACH;

/*CREATE DATABASE Salesianer_Lenzing_2 ON 
( FILENAME = N'M:\Data01\Salesianer_Lenzing_2.mdf' ),
( FILENAME = N'M:\Log01\Salesianer_Lenzing_2_log.ldf' )
FOR ATTACH;*/

GO

ALTER DATABASE Salesianer_Klagenfurt SET MULTI_USER;
--ALTER DATABASE Salesianer_Lenzing_2 SET MULTI_USER;
GO

/* #################################################### */

SELECT 
  sys.database_files.name AS [FileName],
  sys.database_files.physical_name AS [FilePath],
  CONVERT(DECIMAL(10,2), sys.database_files.size / 128.0) AS [Filesize MB],
  CONVERT(DECIMAL(10,2), sys.database_files.size / 128.0 - ((sys.database_files.size / 128.0) - CAST(FILEPROPERTY(sys.database_files.name, 'SPACEUSED') AS int) / 128.0)) AS [Used MB],
  CONVERT(DECIMAL(10,2), sys.database_files.size / 128.0 - CAST(FILEPROPERTY(sys.database_files.name, 'SPACEUSED') AS int) / 128.0) AS [Free MB],
  CONVERT(DECIMAL(10,2), ((sys.database_files.size / 128.0 - CAST(FILEPROPERTY(sys.database_files.name, 'SPACEUSED') AS int) / 128.0) / (sys.database_files.size / 128.0)) * 100) AS [Free Percent]
FROM sys.database_files 
LEFT JOIN sys.filegroups ON sys.database_files.data_space_id = sys.filegroups.data_space_id
ORDER BY [FileName] ASC;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Check current values                                                                                                      ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT mf.name AS [logical file name], mf.type_desc AS [file type], mf.size * 8 / 1024 AS [configured file size MB], df.size AS [current file size MB]
FROM sys.master_files AS mf
JOIN (
  SELECT df.name, df.type_desc, df.size * 8 / 1024 AS [size]
  FROM tempdb.sys.database_files AS df
) AS df ON df.name = mf.name AND df.type_desc = mf.type_desc
WHERE mf.database_id = DB_ID(N'tempdb');

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Reset configured size                                                                                                     ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

USE [master]
GO

ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N'tempdev', SIZE = 2GB , FILEGROWTH = 1GB )
GO
ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N'temp2', SIZE = 2GB , FILEGROWTH = 1GB )
GO
ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N'temp3', SIZE = 2GB , FILEGROWTH = 1GB )
GO
ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N'temp4', SIZE = 2GB , FILEGROWTH = 1GB )
GO
ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N'templog', SIZE = 1GB , FILEGROWTH = 512MB )
GO
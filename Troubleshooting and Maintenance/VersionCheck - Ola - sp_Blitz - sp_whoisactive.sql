/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Version Check - Ola Hallengren SP's                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

USE [master];

DROP TABLE IF EXISTS ##DBA_SProcs;

CREATE TABLE ##DBA_SProcs (
  DBName             NVARCHAR(100) NULL,
  SProcName          NVARCHAR (50) NULL,
  VersionString      NVARCHAR (50) NULL
);

EXEC sys.sp_MSforeachDB
     @replacechar = N'Ƥ',
     @command1 = N'
USE[Ƥ];

DECLARE @VersionKeyword nvarchar(max) = ''--// Version: '';

INSERT INTO ##DBA_SProcs
SELECT DB_NAME() AS DBName,
       sys.objects.[name] AS SProcName,
       CASE WHEN CHARINDEX(@VersionKeyword,OBJECT_DEFINITION(sys.objects.[object_id])) > 0 THEN SUBSTRING(OBJECT_DEFINITION(sys.objects.[object_id]),CHARINDEX(@VersionKeyword,OBJECT_DEFINITION(sys.objects.[object_id])) + LEN(@VersionKeyword) + 1, 19) END AS VersionString
FROM sys.objects
INNER JOIN sys.schemas ON sys.objects.[schema_id] = sys.schemas.[schema_id]
WHERE sys.schemas.[name] = ''dbo''
  AND sys.objects.[name] IN(''CommandExecute'', ''DatabaseBackup'', ''DatabaseIntegrityCheck'', ''IndexOptimize'');
';

SELECT DISTINCT DBName AS DatabaseName, VersionString AS [Version], [Procs Used] = STUFF((SELECT N' | ' + sp.SProcName FROM ##DBA_SProcs sp ORDER BY sp.SProcName ASC FOR XML PATH(N'')), 1, 3, N'')
FROM ##DBA_SProcs;

DROP TABLE IF EXISTS ##DBA_SProcs;

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Version Check - First Responder Kit and sp_WhoIsActive                                                                    ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

USE [master];

DROP TABLE IF EXISTS ##DBA_SProcs;

CREATE TABLE ##DBA_SProcs (
  DBName             NVARCHAR(100) NULL,
  SProcName          NVARCHAR (50) NULL,
  VersionString      NVARCHAR (50) NULL
);

EXEC sys.sp_MSforeachdb
     @replacechar = N'Ƥ'
    ,@command1 = N'
USE[Ƥ];

INSERT INTO ##DBA_SProcs
SELECT
     DB_NAME() AS DBName,
     SProcName = ROUTINE_NAME,
     REPLACE(REPLACE(REPLACE(
        SUBSTRING(ROUTINE_DEFINITION, CHARINDEX(''T @Version'', ROUTINE_DEFINITION, 1) + 3, 15),
        '''''''', ''''),
        '', @'' , ''''),
        ''Version = '' , '''')
        AS VersionString
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_DEFINITION LIKE ''%sp_Blitz%''
  AND ROUTINE_DEFINITION LIKE ''%T @Version%'';

INSERT INTO ##DBA_SProcs
SELECT
     DB_NAME() AS DBName,
	 ROUTINE_NAME,
     SUBSTRING(
        ROUTINE_DEFINITION,
        CHARINDEX(''Who Is Active? v'', ROUTINE_DEFINITION, 1) + 15,
        7
        ) AS VersionString
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_DEFINITION LIKE ''%sp_WhoIsActive%''
  AND ROUTINE_DEFINITION LIKE ''%Who Is Active? v%'';
';

SELECT DISTINCT DBName AS DatabaseName, VersionString AS [Version], STUFF((SELECT N' | ' + sp.SProcName FROM ##DBA_SProcs sp WHERE sp.DBName = ##DBA_SProcs.DBName AND sp.VersionString = ##DBA_SProcs.VersionString AND sp.SProcName LIKE N'sp@_Blitz%' ESCAPE N'@' ORDER BY sp.SProcName FOR XML PATH(N'')), 1, 3, N'') AS [Procs Used]
FROM ##DBA_SProcs
WHERE SProcName LIKE N'sp@_Blitz%' ESCAPE N'@'

DROP TABLE IF EXISTS ##DBA_SProcs;

GO
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
     @replacechar = N'¬',
     @command1 = N'
USE[¬];

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
     @replacechar = N'¬'
    ,@command1 = N'
USE[¬];

INSERT INTO ##DBA_SProcs
SELECT
     DB_NAME() AS DBName
    ,LTRIM(RTRIM(
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
            SUBSTRING([text], CHARINDEX(''sp_Blitz'', [text], 1), 18)
            ,'']'','''')
            ,''('','''')
            ,CHAR(9)/*Tab*/,'' '')
            ,CHAR(10)/*LF*/,'' '')
            ,CHAR(13)/*CR*/,'' '')
            ,''@He'','''')
            ,''@Ch'','''')
        )) AS SProcName
    ,REPLACE(REPLACE(REPLACE(
        SUBSTRING([text], CHARINDEX(''T @Version'', [text], 1) + 3, 15)
        ,'''''''', '''')
        ,'', @'' , '''')
        ,''Version = '' , '''')
        AS VersionString
FROM sys.syscomments sc
WHERE sc.colid <= 1
  AND sc.[text] LIKE ''%sp_Blitz%''
  AND sc.[text] LIKE ''%T @Version%'';

INSERT INTO ##DBA_SProcs
SELECT
     DB_NAME() AS DBName
    ,''sp_WhoIsActive'' AS SProcName
    ,SUBSTRING(
        [text]
        ,CHARINDEX(''Who Is Active? v'', [text], 1) + 15
        ,7
        ) AS VersionString
FROM sys.syscomments sc
WHERE sc.[text] LIKE ''%sp_WhoIsActive%''
  AND sc.[text] LIKE ''%Who Is Active? v%'';
';

SELECT DISTINCT DBName AS DatabaseName, VersionString AS [Version], STUFF((SELECT N' | ' + sp.SProcName FROM ##DBA_SProcs sp WHERE sp.DBName = ##DBA_SProcs.DBName AND sp.SProcName LIKE N'sp@_Blitz%' ESCAPE N'@' ORDER BY sp.SProcName FOR XML PATH(N'')), 1, 3, N'') AS [Procs Used]
FROM ##DBA_SProcs
WHERE SProcName LIKE N'sp@_Blitz%' ESCAPE N'@'
UNION 
SELECT DISTINCT DBName AS DatabaseName, VersionString AS [Version], STUFF((SELECT N' | ' + sp.SProcName FROM ##DBA_SProcs sp WHERE sp.DBName = ##DBA_SProcs.DBName AND sp.SProcName LIKE N'sp@_WhoIsActive%' ESCAPE N'@' ORDER BY sp.SProcName FOR XML PATH(N'')), 1, 3, N'') AS [Procs Used]
FROM ##DBA_SProcs
WHERE SProcName LIKE N'sp@_WhoIsActive%' ESCAPE N'@';

DROP TABLE IF EXISTS ##DBA_SProcs;

GO
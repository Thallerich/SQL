SET NOCOUNT ON;

-- Zuerst hier die Suchbegriffe eingeben, die in SQL-Feldern gesucht werden sollen
-- Groß-/Klein-Schreibung wird nicht berücksichtigt
DECLARE @search_terms TABLE (search_term VARCHAR(40))

INSERT INTO @search_terms
VALUES ('IsCurrEinzHist');

--Hier ist eine Liste aller Tabellen und SQL-Felder, die bei Bedarf angepasst werden kann.
DECLARE @sql_fields TABLE (id INT, tablename VARCHAR(20), table_id VARCHAR(20), fieldname VARCHAR(40))

INSERT INTO @sql_fields
VALUES (1, 'ARCHJOB', 'ARCHJOB.ID', 'ArchiveSql'), (2, 'ARCHJOB', 'ARCHJOB.ID', 'PreSql'), (3, 'CHARTKO', 'CHARTKO.ID', 'KzDatenSql'), (4, 'CHARTPTY', 'CHARTPTY.ID', 'AuswahlSql'), (5, 'CHARTPTY', 'CHARTPTY.ID', 'SelectSql'), (6, 'CHARTPTY', 'CHARTPTY.ID', 'WhereSql'), (7, 'CHARTSQL', 'CHARTSQL.ID', 'ChartSQL'), (8, 'EXPDEF', 'EXPDEF.ID', 'SqlQuery'), (9, 'IMPDEF', 'IMPDEF.ID', 'SqlQuery'), (10, 'KZDASHCH', 'KZDASHCH.ID', 'DetailSQL'), (11, 'LGAUSSTR', 'LGAUSSTR.ID', 'LgAusStrSQL'), (12, 'LGEINSTR', 'LGEINSTR.ID', 'LgEinStrSQL'), (13, 'LSBCDET', 'LSBCDET.ID', 'LsBCDetSQL'), (14, 'LSKOART', 'LSKOART.ID', 'ArtikelSQL'), (15, 'ORDERBY', 'ORDERBY.ID', 'OrderBy'), (16, 'PATCHART', 'PATCHART.ID', 'BewPatchenSQL'), (17, 'PATCHART', 'PATCHART.ID', 'BkEinmalPatchenSQL'), (18, 'PATCHART', 'PATCHART.ID', 'BkPatchenSQL'), (19, 'PATCHART', 'PATCHART.ID', 'OpPatchenSQL'), (20, 'PATCHART', 'PATCHART.ID', 'TpsPatchenSQL'), (21, 'PATCHART', 'PATCHART.ID', 'TpsPckPatchenSQL'), (22, 'PRODREG', 'PRODREG.ID', 'SQL'), (23, 'PROJTASK', 'PROJTASK.ID', 'AddConditionSQL'
  ), (24, 'PROJTASK', 'PROJTASK.ID', 'CompleteCheckSQL'), (25, 'RECHCHK', 'RECHCHK.ID', 'RechChkSQL'), (26, 'RKOANLAG', 'RKOANLAG.ID', 'SQLSkript'), (27, 'RKOBRIEF', 'RKOBRIEF.ID', 'SqlFilter'), (28, 'RPTREPOR', 'RPTREPOR.ID', 'Template'), (29, 'SDCHINWR', 'SDCHINWR.ID', 'SDCHinwRSQL'), (30, 'SQLCHKCL', 'SQLCHKCL.ID', 'CleanupSQL'), (31, 'TABFIELD', 'TABFIELD.ID', 'WaehleSQL'), (32, 'TABFPROP', 'TABFPROP.ID', 'ConstraintSQL'), (33, 'TABINDEX', 'TABINDEX.ID', 'ConditionSQL'), (34, 'WFPO', 'WFPO.ID', 'BezSQL'), (35, 'WFPO', 'WFPO.ID', 'SqlCode'), (36, 'WEBLISTS', 'WEBLISTS.ID', 'SqlCode'), (37, 'SETTINGS', 'SETTINGS.ID', 'ValueMemo'), (38, 'SYSJOB', 'SYSJOB.ID', 'Skript');

DECLARE @check_sql VARCHAR(max) = '';
DECLARE @id INT;
DECLARE @tablename VARCHAR(40), @table_id VARCHAR(40), @fieldname VARCHAR(40), @search_term VARCHAR(40)

DECLARE search_term_cursor CURSOR
FOR
SELECT *
FROM @search_terms

OPEN search_term_cursor

DECLARE sql_field_cursor CURSOR
FOR
SELECT *
FROM @sql_fields

OPEN sql_field_cursor

FETCH NEXT
FROM sql_field_cursor
INTO @id, @tablename, @table_id, @fieldname

--In verschachtelter Schleife alle SQL-Felder nach allen Suchbegriffen durchforsten und resultierendes Query in @check_sql speichern
WHILE @@FETCH_STATUS = 0
BEGIN
  FETCH NEXT
  FROM search_term_cursor
  INTO @search_term

  WHILE @@FETCH_STATUS = 0
  BEGIN
    SET @check_sql = @check_sql + (
        SELECT DISTINCT 'SELECT ''' + @search_term + ''' SearchTerm, ''' + @tablename + ''' TableName, ' + @table_id + ' TableID, ' + '''' + @fieldname + ''' FieldName' + CHAR(13) + 'FROM ' + @tablename + CHAR(13) + CHAR(10) + 'WHERE UPPER(REPLACE(' + @fieldname + '+ '' ''' + ', ' + ''';''' + ', ' + ''',''' + ')) LIKE + ''% ' + UPPER(@search_term) + ' %''' + CHAR(13) + 'OR UPPER(REPLACE(' + @fieldname + '+ '' ''' + ', ' + ''';''' + ', ' + ''',''' + ')) LIKE + ''%,' + UPPER(@search_term) + ' %''' + CHAR(13) + 'OR UPPER(REPLACE(' + @fieldname + '+ '' ''' + ', ' + ''';''' + ', ' + ''',''' + ')) LIKE + ''% ' + UPPER(@search_term) + ',%''' + CHAR(13) + 'OR UPPER(REPLACE(' + @fieldname + '+ '' ''' + ', ' + ''';''' + ', ' + ''',''' + ')) LIKE + ''%,' + UPPER(@search_term) + ',%''' + CHAR(13) + 'OR UPPER(REPLACE(' + @fieldname + '+ '' ''' + ', ' + ''';''' + ', ' + ''',''' + ')) LIKE + ''%' + UPPER(@search_term) + '%''' + CHAR(13)
        )


    FETCH NEXT
    FROM search_term_cursor
    INTO @search_term

    IF @@FETCH_STATUS = 0
    BEGIN
      SET @check_sql = @check_sql + 'UNION' + CHAR(13)
    END
    ELSE
    BEGIN
      CLOSE search_term_cursor

      DEALLOCATE search_term_cursor

      DECLARE search_term_cursor CURSOR
      FOR
      SELECT *
      FROM @search_terms

      OPEN search_term_cursor
    END
  END

  FETCH NEXT
  FROM sql_field_cursor
  INTO @id, @tablename, @table_id, @fieldname

  IF @@FETCH_STATUS = 0
  BEGIN
    SET @check_sql = @check_sql + 'UNION' + CHAR(13)
  END
END

--Ergebnis dieses Query speichern
DECLARE @check_sql_result TABLE (SearchTerm VARCHAR(40), TableName VARCHAR(20), TableID VARCHAR(20), FieldName VARCHAR(40))

INSERT INTO @check_sql_result
EXEC (@check_sql);

DROP TABLE IF EXISTS #check_sql_result

SELECT *
INTO #check_sql_result
FROM @check_sql_result
  --Ergebnistabelle durchnummerieren

DROP TABLE IF EXISTS #TeileTab;

SELECT ROW_NUMBER() OVER (
    ORDER BY x.Searchterm, x.Tablename
    ) TableNo, x.Searchterm, x.Tablename, x.FieldName
INTO #TeileTab
FROM @check_sql_result x
GROUP BY x.searchterm, x.tablename, x.FieldName;

--Einzelabfragen für jede Tabelle generieren, in denen die Suchbegriffe gefunden wurden
DECLARE @TableNo INT = 1;
DECLARE @LastTab INT = (
    SELECT max(TableNo)
    FROM #teiletab
    )
DECLARE @MySQL VARCHAR(max) = ''

WHILE @TableNo <= @LastTab
BEGIN
  SET @MySQL = @MySQL + (
      SELECT DISTINCT 'SELECT  ''' + tab.SearchTerm + ''' Suchbegriff, ' + tab.TableName + '.*' + CHAR(10) + 'FROM ' + tab.TableName + CHAR(10) + 'WHERE ID IN (SELECT TableID FROM #check_sql_result WHERE TableName = ''' + tab.TableName + ''' AND SearchTerm = ''' + tab.SearchTerm + ''')' + CHAR(10) + 'ORDER BY 1; ' + CHAR(10) + CHAR(10) + CHAR(10) + CHAR(10)
      FROM #teiletab tab, #check_sql_result x
      WHERE tab.TableNo = @TableNo
      )
  SET @TableNo = @TableNo + 1;
END;

IF @MySQL = N''
  PRINT(N'Nothing to do 😊');
ELSE
  EXEC (@MySQL);
DROP TABLE IF EXISTS #TeileSQLs;
GO

SELECT x.*
into #TeileSQLs
FROM
        (
                SELECT
                        'ARCHJOB'    TableName,
                        ARCHJOB.ID   TableID  ,
                        'ArchiveSql' FieldName,
                        ArchiveSql   SQL_mit_Teile
                FROM
                        ARCHJOB
                WHERE
                        UPPER(REPLACE(ArchiveSql+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(ArchiveSql+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(ArchiveSql+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(ArchiveSql+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(ArchiveSql+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR		UPPER(REPLACE(ArchiveSql+ ' ', ';', ',')) LIKE '%TEILELAG%'

                UNION
                
                SELECT
                        'ARCHJOB'  TableName,
                        ARCHJOB.ID TableID  ,
                        'PreSql'   FieldName,
                        PreSql     SQL_mit_Teile
                FROM
                        ARCHJOB
                WHERE
                        UPPER(REPLACE(PreSql+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(PreSql+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(PreSql+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(PreSql+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(PreSql+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(PreSql+ ' ', ';', ',')) LIKE '%TEILELAG%'
             
                UNION
                
                SELECT
                        'CHARTKO'    TableName,
                        CHARTKO.ID   TableID  ,
                        'KzDatenSql' FieldName,
                        KzDatenSql   SQL_mit_Teile
                FROM
                        CHARTKO
                WHERE
                        UPPER(REPLACE(KzDatenSql+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(KzDatenSql+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(KzDatenSql+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(KzDatenSql+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(KzDatenSql+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(KzDatenSql+ ' ', ';', ',')) LIKE '%TEILELAG%'

                UNION
                
                SELECT
                        'CHARTPTY'   TableName,
                        CHARTPTY.ID  TableID  ,
                        'AuswahlSql' FieldName,
                        AuswahlSql   SQL_mit_Teile
                FROM
                        CHARTPTY
                WHERE
                        UPPER(REPLACE(AuswahlSql+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(AuswahlSql+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(AuswahlSql+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(AuswahlSql+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(AuswahlSql+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(AuswahlSql+ ' ', ';', ',')) LIKE '%TEILELAG%'
                
                UNION
                
                SELECT
                        'CHARTPTY'  TableName,
                        CHARTPTY.ID TableID  ,
                        'SelectSql' FieldName,
                        SelectSql   SQL_mit_Teile
                FROM
                        CHARTPTY
                WHERE
                        UPPER(REPLACE(SelectSql+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(SelectSql+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(SelectSql+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(SelectSql+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(SelectSql+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(SelectSql+ ' ', ';', ',')) LIKE '%TEILELAG%'
                
                UNION
                
                SELECT
                        'CHARTPTY'  TableName,
                        CHARTPTY.ID TableID  ,
                        'WhereSql'  FieldName,
                        WhereSql    SQL_mit_Teile
                FROM
                        CHARTPTY
                WHERE
                        UPPER(REPLACE(WhereSql+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(WhereSql+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(WhereSql+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(WhereSql+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(WhereSql+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(WhereSql+ ' ', ';', ',')) LIKE '%TEILELAG%'
                
                UNION
                
                SELECT
                        'CHARTSQL'  TableName,
                        CHARTSQL.ID TableID  ,
                        'ChartSQL'  FieldName,
                        ChartSQL    SQL_mit_Teile
                FROM
                        CHARTSQL
                WHERE
                        UPPER(REPLACE(ChartSQL+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(ChartSQL+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(ChartSQL+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(ChartSQL+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(ChartSQL+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(ChartSQL+ ' ', ';', ',')) LIKE '%TEILELAG%'		
                
                UNION
                
                SELECT
                        'EXPDEF'   TableName,
                        EXPDEF.ID  TableID  ,
                        'SqlQuery' FieldName,
                        SqlQuery   SQL_mit_Teile
                FROM
                        EXPDEF
                WHERE
                        UPPER(REPLACE(SqlQuery+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(SqlQuery+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(SqlQuery+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(SqlQuery+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(SqlQuery+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(SqlQuery+ ' ', ';', ',')) LIKE '%TEILELAG%'
                
                UNION
                
                SELECT
                        'IMPDEF'   TableName,
                        IMPDEF.ID  TableID  ,
                        'SqlQuery' FieldName,
                        SqlQuery   SQL_mit_Teile
                FROM
                        IMPDEF
                WHERE
                        UPPER(REPLACE(SqlQuery+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(SqlQuery+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(SqlQuery+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(SqlQuery+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(SqlQuery+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(SqlQuery+ ' ', ';', ',')) LIKE '%TEILELAG%'
				UNION
                
                SELECT
                        'KZDASHCH'  TableName,
                        KZDASHCH.ID TableID  ,
                        'DetailSQL' FieldName,
                        DetailSQL   SQL_mit_Teile
                FROM
                        KZDASHCH
                WHERE
                        UPPER(REPLACE(DetailSQL+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(DetailSQL+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(DetailSQL+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(DetailSQL+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(DetailSQL+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(DetailSQL+ ' ', ';', ',')) LIKE '%TEILELAG%'
                
                UNION
                
                SELECT
                        'LGAUSSTR'    TableName,
                        LGAUSSTR.ID   TableID  ,
                        'LgAusStrSQL' FieldName,
                        LgAusStrSQL   SQL_mit_Teile
                FROM
                        LGAUSSTR
                WHERE
                        UPPER(REPLACE(LgAusStrSQL+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(LgAusStrSQL+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(LgAusStrSQL+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(LgAusStrSQL+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(LgAusStrSQL+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(LgAusStrSQL+ ' ', ';', ',')) LIKE '%TEILELAG%'
                
                UNION
                
                SELECT
                        'LGEINSTR'    TableName,
                        LGEINSTR.ID   TableID  ,
                        'LgEinStrSQL' FieldName,
                        LgEinStrSQL   SQL_mit_Teile
                FROM
                        LGEINSTR
                WHERE
                        UPPER(REPLACE(LgEinStrSQL+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(LgEinStrSQL+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(LgEinStrSQL+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(LgEinStrSQL+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(LgEinStrSQL+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(LgEinStrSQL+ ' ', ';', ',')) LIKE '%TEILELAG%'
                
                UNION
                
                SELECT
                        'LSBCDET'    TableName,
                        LSBCDET.ID   TableID  ,
                        'LsBCDetSQL' FieldName,
                        LsBCDetSQL   SQL_mit_Teile
                FROM
                        LSBCDET
                WHERE
                        UPPER(REPLACE(LsBCDetSQL+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(LsBCDetSQL+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(LsBCDetSQL+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(LsBCDetSQL+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(LsBCDetSQL+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(LsBCDetSQL+ ' ', ';', ',')) LIKE '%TEILELAG%'
                
                UNION

                SELECT
                        'LSKOART'    TableName,
                        LSKOART.ID   TableID  ,
                        'ArtikelSQL' FieldName,
                        ArtikelSQL   SQL_mit_Teile
                FROM
                        LSKOART
                WHERE
                        UPPER(REPLACE(ArtikelSQL+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(ArtikelSQL+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(ArtikelSQL+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(ArtikelSQL+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(ArtikelSQL+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(ArtikelSQL+ ' ', ';', ',')) LIKE '%TEILELAG%'
                
                UNION
              
                SELECT
                        'ORDERBY'  TableName,
                        ORDERBY.ID TableID  ,
                        'OrderBy'  FieldName,
                        OrderBy    SQL_mit_Teile
                FROM
                        ORDERBY
                WHERE
                        UPPER(REPLACE(OrderBy+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(OrderBy+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(OrderBy+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(OrderBy+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(OrderBy+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(OrderBy+ ' ', ';', ',')) LIKE '%TEILELAG%'
                
                UNION
                
                SELECT
                        'PATCHART'      TableName,
                        PATCHART.ID     TableID  ,
                        'BewPatchenSQL' FieldName,
                        BewPatchenSQL   SQL_mit_Teile
                FROM
                        PATCHART
                WHERE
                        UPPER(REPLACE(BewPatchenSQL+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(BewPatchenSQL+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(BewPatchenSQL+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(BewPatchenSQL+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(BewPatchenSQL+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(BewPatchenSQL+ ' ', ';', ',')) LIKE '%TEILELAG%'
                
                UNION

                SELECT
                        'PATCHART'           TableName,
                        PATCHART.ID          TableID  ,
                        'BkEinmalPatchenSQL' FieldName,
                        BkEinmalPatchenSQL   SQL_mit_Teile
                FROM
                        PATCHART
                WHERE
                        UPPER(REPLACE(BkEinmalPatchenSQL+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(BkEinmalPatchenSQL+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(BkEinmalPatchenSQL+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(BkEinmalPatchenSQL+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(BkEinmalPatchenSQL+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(BkEinmalPatchenSQL+ ' ', ';', ',')) LIKE '%TEILELAG%'
                
                UNION
                
                SELECT
                        'PATCHART'     TableName,
                        PATCHART.ID    TableID  ,
                        'BkPatchenSQL' FieldName,
                        BkPatchenSQL   SQL_mit_Teile
                FROM
                        PATCHART
                WHERE
                        UPPER(REPLACE(BkPatchenSQL+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(BkPatchenSQL+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(BkPatchenSQL+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(BkPatchenSQL+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(BkPatchenSQL+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(BkPatchenSQL+ ' ', ';', ',')) LIKE '%TEILELAG%'
                
                UNION
                
                SELECT
                        'PATCHART'     TableName,
                        PATCHART.ID    TableID  ,
                        'OpPatchenSQL' FieldName,
                        OpPatchenSQL   SQL_mit_Teile
                FROM
                        PATCHART
                WHERE
                        UPPER(REPLACE(OpPatchenSQL+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(OpPatchenSQL+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(OpPatchenSQL+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(OpPatchenSQL+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(OpPatchenSQL+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(OpPatchenSQL+ ' ', ';', ',')) LIKE '%TEILELAG%'
				
                UNION
                
                SELECT
                        'PATCHART'      TableName,
                        PATCHART.ID     TableID  ,
                        'TpsPatchenSQL' FieldName,
                        TpsPatchenSQL   SQL_mit_Teile
                FROM
                        PATCHART
                WHERE
                        UPPER(REPLACE(TpsPatchenSQL+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(TpsPatchenSQL+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(TpsPatchenSQL+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(TpsPatchenSQL+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(TpsPatchenSQL+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(TpsPatchenSQL+ ' ', ';', ',')) LIKE '%TEILELAG%'
                
                UNION
                
                SELECT
                        'PATCHART'         TableName,
                        PATCHART.ID        TableID  ,
                        'TpsPckPatchenSQL' FieldName,
                        TpsPckPatchenSQL   SQL_mit_Teile
                FROM
                        PATCHART
                WHERE
                        UPPER(REPLACE(TpsPckPatchenSQL+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(TpsPckPatchenSQL+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(TpsPckPatchenSQL+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(TpsPckPatchenSQL+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(TpsPckPatchenSQL+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(TpsPckPatchenSQL+ ' ', ';', ',')) LIKE '%TEILELAG%'
                
                UNION
                
                SELECT
                        'PRODREG'  TableName,
                        PRODREG.ID TableID  ,
                        'SQL'      FieldName,
                        SQL        SQL_mit_Teile
                FROM
                        PRODREG
                WHERE
                        UPPER(REPLACE(SQL+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(SQL+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(SQL+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(SQL+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(SQL+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(SQL+ ' ', ';', ',')) LIKE '%TEILELAG%'
                
                UNION
                
                SELECT
                        'PROJTASK'        TableName,
                        PROJTASK.ID       TableID  ,
                        'AddConditionSQL' FieldName,
                        AddConditionSQL   SQL_mit_Teile
                FROM
                        PROJTASK
                WHERE
                        UPPER(REPLACE(AddConditionSQL+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(AddConditionSQL+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(AddConditionSQL+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(AddConditionSQL+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(AddConditionSQL+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(AddConditionSQL+ ' ', ';', ',')) LIKE '%TEILELAG%'
                
                UNION
                
                SELECT
                        'PROJTASK'         TableName,
                        PROJTASK.ID        TableID  ,
                        'CompleteCheckSQL' FieldName,
                        CompleteCheckSQL   SQL_mit_Teile
                FROM
                        PROJTASK
                WHERE
                        UPPER(REPLACE(CompleteCheckSQL+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(CompleteCheckSQL+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(CompleteCheckSQL+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(CompleteCheckSQL+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(CompleteCheckSQL+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(CompleteCheckSQL+ ' ', ';', ',')) LIKE '%TEILELAG%'
                
                UNION
                
                SELECT
                        'RECHCHK'    TableName,
                        RECHCHK.ID   TableID  ,
                        'RechChkSQL' FieldName,
                        RechChkSQL   SQL_mit_Teile
                FROM
                        RECHCHK
                WHERE
                        UPPER(REPLACE(RechChkSQL+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(RechChkSQL+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(RechChkSQL+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(RechChkSQL+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(RechChkSQL+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(RechChkSQL+ ' ', ';', ',')) LIKE '%TEILELAG%'
                
                UNION
                
                SELECT
                        'RKOANLAG'  TableName,
                        RKOANLAG.ID TableID  ,
                        'SQLSkript' FieldName,
                        SQLSkript   SQL_mit_Teile
                FROM
                        RKOANLAG
                WHERE
                        UPPER(REPLACE(SQLSkript+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(SQLSkript+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(SQLSkript+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(SQLSkript+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(SQLSkript+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(SQLSkript+ ' ', ';', ',')) LIKE '%TEILELAG%'
                
                UNION
                
                SELECT
                        'RKOBRIEF'  TableName,
                        RKOBRIEF.ID TableID  ,
                        'SqlFilter' FieldName,
                        SqlFilter   SQL_mit_Teile
                FROM
                        RKOBRIEF
                WHERE
                        UPPER(REPLACE(SqlFilter+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(SqlFilter+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(SqlFilter+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(SqlFilter+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(SqlFilter+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(SqlFilter+ ' ', ';', ',')) LIKE '%TEILELAG%'
                
                UNION
                
                SELECT
                        'RPTREPOR'  TableName,
                        RPTREPOR.ID TableID  ,
                        'Template'  FieldName,
                        Template    SQL_mit_Teile
                FROM
                        RPTREPOR
                WHERE
                        UPPER(REPLACE(Template+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(Template+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(Template+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(Template+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(Template+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(Template+ ' ', ';', ',')) LIKE '%TEILELAG%'
                
                UNION
                
                SELECT
                        'SDCHINWR'    TableName,
                        SDCHINWR.ID   TableID  ,
                        'SDCHinwRSQL' FieldName,
                        SDCHinwRSQL   SQL_mit_Teile
                FROM
                        SDCHINWR
                WHERE
                        UPPER(REPLACE(SDCHinwRSQL+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(SDCHinwRSQL+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(SDCHinwRSQL+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(SDCHinwRSQL+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(SDCHinwRSQL+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(SDCHinwRSQL+ ' ', ';', ',')) LIKE '%TEILELAG%'
                
                UNION
                
                SELECT
                        'SQLCHKCL'   TableName,
                        SQLCHKCL.ID  TableID  ,
                        'CleanupSQL' FieldName,
                        CleanupSQL   SQL_mit_Teile
                FROM
                        SQLCHKCL
                WHERE
                        UPPER(REPLACE(CleanupSQL+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(CleanupSQL+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(CleanupSQL+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(CleanupSQL+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(CleanupSQL+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(CleanupSQL+ ' ', ';', ',')) LIKE '%TEILELAG%'
                
                UNION
                
                SELECT
                        'TABFIELD'  TableName,
                        TABFIELD.ID TableID  ,
                        'WaehleSQL' FieldName,
                        WaehleSQL   SQL_mit_Teile
                FROM
                        TABFIELD
                WHERE
                        UPPER(REPLACE(WaehleSQL+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(WaehleSQL+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(WaehleSQL+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(WaehleSQL+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(WaehleSQL+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(WaehleSQL+ ' ', ';', ',')) LIKE '%TEILELAG%'
                
                UNION
                
                SELECT
                        'TABFPROP'      TableName,
                        TABFPROP.ID     TableID  ,
                        'ConstraintSQL' FieldName,
                        ConstraintSQL   SQL_mit_Teile
                FROM
                        TABFPROP
                WHERE
                        UPPER(REPLACE(ConstraintSQL+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(ConstraintSQL+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(ConstraintSQL+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(ConstraintSQL+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(ConstraintSQL+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(ConstraintSQL+ ' ', ';', ',')) LIKE '%TEILELAG%'
                
                UNION
                
                SELECT
                        'TABINDEX'     TableName,
                        TABINDEX.ID    TableID  ,
                        'ConditionSQL' FieldName,
                        ConditionSQL   SQL_mit_Teile
                FROM
                        TABINDEX
                WHERE
                        UPPER(REPLACE(ConditionSQL+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(ConditionSQL+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(ConditionSQL+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(ConditionSQL+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(ConditionSQL+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(ConditionSQL+ ' ', ';', ',')) LIKE '%TEILELAG%'
                
                UNION
                
                SELECT
                        'WFPO'   TableName,
                        WFPO.ID  TableID  ,
                        'BezSQL' FieldName,
                        BezSQL   SQL_mit_Teile
                FROM
                        WFPO
                WHERE
                        UPPER(REPLACE(BezSQL+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(BezSQL+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(BezSQL+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(BezSQL+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(BezSQL+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(BezSQL+ ' ', ';', ',')) LIKE '%TEILELAG%'
                
                UNION
                
                SELECT
                        'WFPO'    TableName,
                        WFPO.ID   TableID  ,
                        'SqlCode' FieldName,
                        SQLCODE   SQL_mit_Teile
                FROM
                        WFPO
                WHERE
                        UPPER(REPLACE(SQLCODE+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(SQLCODE+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(SQLCODE+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(SQLCODE+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(SQLCODE+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(SQLCODE+ ' ', ';', ',')) LIKE '%TEILELAG%'
				
                UNION
                
                SELECT
                        'WEBLISTS'    TableName,
                        WEBLISTS.ID   TableID  ,
                        'SqlCode' FieldName,
                        SQLCODE   SQL_mit_Teile
                FROM
                        WEBLISTS

				WHERE   UseDownloadServer = 1
				AND		(UPPER(REPLACE(SQLCODE+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(SQLCODE+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(SQLCODE+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(SQLCODE+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(SQLCODE+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(SQLCODE+ ' ', ';', ',')) LIKE '%TEILELAG%')
                
                UNION
				
				SELECT
						'SETTINGS'	   TableName,
						SETTINGS.ID    TableID,
						'ValueMemo'    FieldName,
						ValueMemo	   SQL_mit_Teile
				FROM
						SETTINGS
                WHERE   UPPER(REPLACE(ValueMemo+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(ValueMemo+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(ValueMemo+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(ValueMemo+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(ValueMemo+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(ValueMemo+ ' ', ';', ',')) LIKE '%TEILELAG%'
				
				UNION
                
                SELECT
                        'SYSJOB'    TableName,
                        SYSJOB.ID   TableID  ,
                        'Skript' FieldName,
                        Skript   SQL_mit_Teile
                FROM
                        SYSJOB
						
                WHERE   UPPER(REPLACE(Skript+ ' ', ';', ',')) LIKE '% TEILE %'
 				OR      UPPER(REPLACE(Skript+ ' ', ';', ',')) LIKE '%,TEILE %'
				OR      UPPER(REPLACE(Skript+ ' ', ';', ',')) LIKE '% TEILE,%'
				OR  	UPPER(REPLACE(Skript+ ' ', ';', ',')) LIKE '%,TEILE,%'
				OR      UPPER(REPLACE(Skript+ ' ', ';', ',')) LIKE '%TEILEID%'
				OR 		UPPER(REPLACE(Skript+ ' ', ';', ',')) LIKE '%TEILELAG%') x              

ORDER BY
        TableName,
        TableID;

GO

DROP TABLE IF EXISTS #TeileTab;
GO

select
      ROW_NUMBER() OVER (
      ORDER BY x.tablename) TableNo, x.tablename, x.FieldName
into #TeileTab
from #TeileSQLs x
group by x.tablename,  x.FieldName;

GO

--select * from #TeileSQLs

DECLARE @TableNo INT = 1;
DECLARE @LastTab INT = (SELECT max(TableNo) from #teiletab)
DECLARE @MySQL varchar(max) = ''

WHILE @TableNo <= @LastTab
BEGIN
   SET @MySQL = @MySQL + 
   (SELECT DISTINCT
   'SELECT IIF(UPPER(' + tab.FieldName + ') LIKE ''%TEILEID%'' OR ' + tab.FieldName + ' LIKE ''%TEILELAG%'', ''9.50'', ''9.60'') [Korrektur Erforderlich Zu Version], * FROM ' + tab.TableName + char(10) +
   'WHERE ID IN (SELECT TableID FROM #TeileSQLs WHERE TableName = ''' + tab.TableName + ''')' + char(10) +  
   'ORDER BY 1 ' + char(10) + char(10) +
   '-------------------' + char(10) + char(10) 
   FROM #teiletab tab, #TeileSQLs x 
   WHERE tab.TableNo = @TableNo
   )
   SET @TableNo = @TableNo + 1;
END;


select @MySQL 'Kopieren und einzeln ausführen';


/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

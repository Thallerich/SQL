SELECT OBJECT_NAME(object_id) AS Objekt, definition
FROM sys.sql_modules
WHERE UPPER(definition) LIKE N'%OWS.%'
ORDER BY 1 ASC;


/* OWS: Cleanup Views */
/*
DROP VIEW Salesianer_Archive.sapbw.V_BW_OWS_ArtGru;
DROP VIEW Salesianer_Archive.sapbw.v_BW_OWS_Bereich;
DROP VIEW Salesianer_Archive.sapbw.V_BW_OWS_KDARTI;
DROP VIEW Salesianer_Archive.sapbw.V_BW_OWS_Lieferschein;
DROP VIEW Salesianer_Archive.sapbw.V_BW_OWS_ME;
DROP VIEW Salesianer_Archive.sapbw.V_BW_OWS_Mitarbei;
DROP VIEW Salesianer_Archive.sapbw.V_BW_OWS_Rechnung;
DROP VIEW Salesianer_Archive.sapbw.V_OWS_Konten;
DROP VIEW Salesianer_Archive.sapbw.V_OWS_RECHNUNG;
DROP VIEW Salesianer_Archive.sapbw.v_bw_test_kircju_op;
*/
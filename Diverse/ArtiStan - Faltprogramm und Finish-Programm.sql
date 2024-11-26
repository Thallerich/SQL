/* Artikelliste in Temp-Table importieren (über AdvanTex Query Tool) und hier den Temp-Table-Namen #Clipboard_xxx anpassen */
/* Angenommenes Format:
   ArtikelNr     ArtikelBez           Faltprogramm  Finishprogramm
   125801810000  Endoskopie-Hose      03            F02
   41001000100   *Kasack weiss Gr.0   03            F02
   41001000101   *Kasack weiss Gr.1   03            F02
   41001000102   *Kasack weiss Gr.2   03            F02
   41001000103   *Kasack weiss Gr.3   03            F02
   41001000104   *Kasack weiss Gr.4   03            F02
   41001000105   Kasack weiss Gr.5    03            F02
   41001000106   Kasack weiss Gr.6    03            F02
   41001000107   *Kasack weiss Gr.7   03            F02
   41001000108   *Kasack weiss Gr.8   03            F02
*/

DROP TABLE IF EXISTS #Artikel, #ArtiStan;

SELECT ArtikelNr, Faltprogramm, Finishprogramm
INTO #Artikel
FROM #Clipboard_000162;

SELECT Artikel.ID AS ArtikelID, Standort.ID AS StandortID, FaltProg.ID AS FaltProgID, FinishPr.ID AS FinishPrID
INTO #ArtiStan
FROM #Artikel
JOIN Artikel ON #Artikel.ArtikelNr = Artikel.ArtikelNr
JOIN FaltProg ON #Artikel.Faltprogramm = FaltProg.Programm
JOIN FinishPr ON #Artikel.Finishprogramm = FinishPr.Programm
CROSS JOIN Standort
WHERE Standort.SuchCode = N'INZ';

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE ArtiStan SET FaltProgID = #ArtiStan.FaltProgID, FinishPrID = #ArtiStan.FinishPrID
    FROM #ArtiStan
    WHERE ArtiStan.ArtikelID = #ArtiStan.ArtikelID
      AND ArtiStan.StandortID = #ArtiStan.StandortID
      AND (ArtiStan.FaltProgID != #ArtiStan.FaltProgID OR ArtiStan.FinishPrID != #ArtiStan.FinishPrID);

    INSERT INTO ArtiStan (ArtikelID, StandortID, FaltProgID, FinishPrID, AnlageUserID_, UserID_)
    SELECT #ArtiStan.ArtikelID, #ArtiStan.StandortID, #ArtiStan.FaltProgID, #ArtiStan.FinishPrID, @userid AS AnlageUserID_, @userid AS UserID_
    FROM #ArtiStan
    WHERE NOT EXISTS (
      SELECT ArtiStan.*
      FROM ArtiStan
      WHERE ArtiStan.ArtikelID = #ArtiStan.ArtikelID
        AND ArtiStan.StandortID = #ArtiStan.StandortID
    );
  
  COMMIT;
END TRY
BEGIN CATCH
  DECLARE @Message varchar(MAX) = ERROR_MESSAGE();
  DECLARE @Severity int = ERROR_SEVERITY();
  DECLARE @State smallint = ERROR_STATE();
  
  IF XACT_STATE() != 0
    ROLLBACK TRANSACTION;
  
  RAISERROR(@Message, @Severity, @State) WITH NOWAIT;
END CATCH;
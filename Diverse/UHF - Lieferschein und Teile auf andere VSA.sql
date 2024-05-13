DROP TABLE IF EXISTS #LsPoChange;
DROP TABLE IF EXISTS #EinzTeilMove;
GO

DECLARE @srclsnr int = 52842700;
DECLARE @srcvsaid int = (SELECT LsKo.VsaID FROM LsKo WHERE LsKo.LsNr = @srclsnr);
DECLARE @dstkdnr int = 10006553;
DECLARE @dstvsaid int = (SELECT TOP 1 Vsa.ID FROM Vsa WHERE Vsa.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = @dstkdnr));
DECLARE @dstabteilid int = (SELECT Vsa.AbteilID FROM Vsa WHERE Vsa.ID = @dstvsaid);

SELECT Scans.EinzTeilID
INTO #EinzTeilMove
FROM Scans
JOIN EinzTeil ON Scans.EinzTeilID = EinzTeil.ID
WHERE Scans.LsPoID IN (
    SELECT LsPo.ID
    FROM LsPo
    JOIN LsKo ON LsPo.LsKoID = LsKo.ID
    WHERE LsKo.LsNr = 52842700
  )
  AND EinzTeil.VsaID = @srcvsaid
  AND EinzTeil.LastActionsID IN (2, 102, 120, 129, 130, 136, 137, 154, 173);

SELECT LsPo.ID AS LsPoID, LsPo.KdArtiID, NewKdArti.ID AS NewKdArtiID
INTO #LsPoChange
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN (
  SELECT KdArti.*
  FROM KdArti
  WHERE KdArti.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = @dstkdnr)
) AS NewKdArti ON KdArti.ArtikelID = NewKdArti.ArtikelID AND KdArti.Variante = NewKdArti.Variante
WHERE LsKo.LsNr = @srclsnr;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Lieferschein und codierte Poolteile verschieben                                                                           ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE LsKo SET LsKo.VsaID = @dstvsaid
    WHERE LsKo.LsNr = @srclsnr;

    UPDATE LsPo SET LsPo.AbteilID = @dstabteilid, LsPo.KdArtiID = #LsPoChange.NewKdArtiID
    FROM #LsPoChange
    WHERE LsPo.ID = #LsPoChange.LsPoID;

    UPDATE EinzTeil SET VsaID = @dstvsaid
    WHERE EinzTeil.ID IN (SELECT EinzTeilID FROM #EinzTeilMove);
  
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
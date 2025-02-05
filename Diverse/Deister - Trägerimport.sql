/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ 0,3,16,40,106,112,124,135,143,152                                                                                         ++ */
/* ++                                                                                                                           ++ */
/* ++ Column1 → TNr smallint                                                                                                    ++ */
/* ++ Column2 → PersNr nchar(14)                                                                                                ++ */
/* ++ Column3 → KartenNr nchar(20)                                                                                              ++ */
/* ++ Column5 → KdNr smallint                                                                                                   ++ */
/* ++ Column6 → KsSt nvarchar(50)                                                                                               ++ */
/* ++ Column8 → Indienst nchar(8)                                                                                               ++ */
/* ++ Column9 → Ausdienst nchar(8)                                                                                              ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

DROP TABLE IF EXISTS #ImportTable;
GO

CREATE TABLE #ImportTable (
  VsaID int,
  [Status] char(1) COLLATE Latin1_General_CS_AS,
  Traeger char(8) COLLATE Latin1_General_CS_AS,
  AbteilID int,
  PersNr nvarchar(10) COLLATE Latin1_General_CS_AS,
  Vorname nvarchar(20) COLLATE Latin1_General_CS_AS,
  Nachname nvarchar(40) COLLATE Latin1_General_CS_AS,
  Indienst char(7) COLLATE Latin1_General_CS_AS,
  IndienstDat date,
  Ausdienst char(7) COLLATE Latin1_General_CS_AS,
  AusdienstDat date,
  TraegerID int
);

GO

DECLARE @MaxTraegerNr int = (SELECT MAX(CAST(Traeger.Traeger AS int)) FROM Traeger WHERE Traeger.VsaID = 6119607);
DECLARE @msg nvarchar(max);

SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - Starte Vorbereitung...';
RAISERROR(@msg, 0, 1) WITH NOWAIT;

WITH DeisterBHSTraeger AS (
  SELECT LTRIM(RTRIM(PersNr)) AS PersNr, LTRIM(RTRIM(KartenNr)) AS KartenNr, KdNr, LTRIM(RTRIM(KsSt)) AS KsSt, CONVERT(date, Indienst, 112) AS Indienst, CONVERT(date, Ausdienst, 112) AS Ausdienst
  FROM __DeisterBHS
  WHERE PersNr IS NOT NULL
)
INSERT INTO #ImportTable (VsaID, [Status], Traeger, AbteilID, PersNr, Vorname, Nachname, Indienst, IndienstDat, Ausdienst, AusdienstDat)
SELECT Vsa.ID AS VsaID, IIF(DeisterBHSTraeger.Ausdienst < CAST(GETDATE() AS date), N'I', N'A') AS [Status], @MaxTraegerNr + ROW_NUMBER() OVER (ORDER BY PersNr) AS Traeger, Abteil.ID AS AbteilID, DeisterBHSTraeger.PersNr, N'--' AS Vorname, N'--' AS Nachname, Week.Woche AS Indienst, DeisterBHSTraeger.Indienst AS IndienstDat, IIF(AusWeek.Woche = N'2050/52', NULL, AusWeek.Woche) AS Ausdienst, IIF(DeisterBHSTraeger.Ausdienst = N'9999-12-31', NULL, DeisterBHSTraeger.Ausdienst) AS AusdienstDat
FROM DeisterBHSTraeger
JOIN Kunden ON DeisterBHSTraeger.KdNr = Kunden.KdNr
JOIN Vsa ON Vsa.KundenID = Kunden.ID
JOIN Week ON IIF(DeisterBHSTraeger.Indienst < N'1980-01-01', N'1980-01-01', DeisterBHSTraeger.Indienst) BETWEEN Week.VonDat AND Week.BisDat
JOIN Week AS AusWeek ON IIF(DeisterBHSTraeger.Ausdienst > N'2050-12-31', N'2050-12-31', DeisterBHSTraeger.Ausdienst) BETWEEN AusWeek.VonDat AND AusWeek.BisDat
JOIN Abteil ON Abteil.KundenID = Kunden.ID AND Abteil.Abteilung = ISNULL(DeisterBHSTraeger.KsSt, N'Dummy') COLLATE Latin1_General_CS_AS
WHERE Vsa.RentomatID > 0;

UPDATE #ImportTable SET TraegerID = Traeger.ID
FROM Traeger
WHERE Traeger.VsaID = #ImportTable.VsaID AND Traeger.PersNr = #ImportTable.PersNr;

SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - Vorbereitung abgeschlossen. Beginne mit dem Import...';
RAISERROR(@msg, 0, 1) WITH NOWAIT;

GO

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');
DECLARE @msg nvarchar(max);

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE Traeger SET [Status] = #ImportTable.[Status], Indienst = #ImportTable.Indienst, IndienstDat = #ImportTable.IndienstDat, Ausdienst = #ImportTable.Ausdienst, AusdienstDat = #ImportTable.AusdienstDat, AbteilID = #ImportTable.AbteilID, UserID_ = @userid
    FROM #ImportTable
    WHERE #ImportTable.TraegerID = Traeger.ID
      AND #ImportTable.TraegerID IS NOT NULL
      AND (#ImportTable.Status != Traeger.Status OR #ImportTable.Indienst != Traeger.Indienst OR #ImportTable.IndienstDat != Traeger.IndienstDat OR #ImportTable.Ausdienst != Traeger.Ausdienst OR #ImportTable.AusdienstDat != Traeger.AusdienstDat OR #ImportTable.AbteilID != Traeger.AbteilID);

    SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - ' + CAST(@@ROWCOUNT AS nvarchar) + N' Träger aktualisiert.';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    INSERT INTO Traeger (VsaID, [Status], Traeger, AbteilID, PersNr, Vorname, Nachname, Indienst, IndienstDat, Ausdienst, AusdienstDat, AnlageUserID_, UserID_)
    SELECT VsaID, [Status], Traeger, AbteilID, PersNr, Vorname, Nachname, Indienst, IndienstDat, Ausdienst, AusdienstDat, @userid, @userid
    FROM #ImportTable
    WHERE TraegerID IS NULL;
  
    SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - ' + CAST(@@ROWCOUNT AS nvarchar) + N' Träger neu angelegt.';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

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

SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - Import abgeschlossen.';
RAISERROR(@msg, 0, 1) WITH NOWAIT;

GO

DROP TABLE #ImportTable;
GO
DROP TABLE __DeisterBHS;
GO

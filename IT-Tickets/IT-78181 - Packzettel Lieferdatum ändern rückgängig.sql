DROP TABLE IF EXISTS #AnfKoFix;
GO

CREATE TABLE #AnfKoFix (
  AnfKoID int PRIMARY KEY CLUSTERED,
  FahrtID int DEFAULT -1,
  Memo nvarchar(max),
  Folge int,
  Sonderlieferung bit
);

GO

INSERT INTO #AnfKoFix (AnfKoID, FahrtID, Memo, Folge, Sonderlieferung)
SELECT DISTINCT AnfKo.ID AS AnfKoID, FixedFahrt.ID AS FahrtID, AnfKo.Memo + CHAR(13) + CHAR(10) + N'Lieferdatum von 26.12.2023 (Tour ' + Touren.Tour + N', Fahrt ' + CAST(Fahrt.ID AS nvarchar) + N') auf 27.12.2023 (Tour ' + FixedTour.Tour + N', Fahrt ' + CAST(FixedFahrt.ID AS nvarchar) + N') geändert durch THALST - IT-78181', ISNULL(VsaTour.Folge, 0) AS Folge, CAST(IIF(VsaTour.ID IS NULL, 1, 0) AS bit) AS Sonderlieferung
FROM AnfKo
JOIN Fahrt ON AnfKo.FahrtID = Fahrt.ID
JOIN Touren ON Fahrt.TourenID = Touren.ID
JOIN Touren AS FixedTour ON AnfKo.TourenID = FixedTour.ID
JOIN Fahrt AS FixedFahrt ON FixedFahrt.TourenID = FixedTour.ID AND FixedFahrt.PlanDatum = N'2023-12-27'
LEFT JOIN VsaTour ON VsaTour.VsaID = AnfKo.VsaID AND VsaTour.TourenID = AnfKo.TourenID AND CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum
WHERE AnfKo.LieferDatum = N'2023-12-26'
  AND AnfKo.TourenID != Fahrt.TourenID
  AND AnfKo.Memo LIKE N'Lieferdatum von 27.12.2023 % auf 26.12.2023 % geändert durch KOVACE';

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE AnfKo SET Lieferdatum = N'2023-12-27', Sonderfahrt = #AnfKoFix.Sonderlieferung, FahrtID = #AnfKoFix.FahrtID, Folge = #AnfKoFix.Folge, AnfKo.Memo = #AnfKoFix.Memo
    FROM #AnfKoFix
    WHERE #AnfKoFix.AnfKoID = AnfKo.ID;
  
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

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Diese sind unklar und sollten manuell bearbeitet werden                                                                   ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT KdGf.KurzBez AS Geschäftsbereich, [Zone].Zonencode AS Vertriebszone, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS VsaBezeichnung, AnfKo.AuftragsNr, AnfKo.Lieferdatum, AnfKo.Memo
FROM AnfKo
JOIN Vsa ON AnfKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN Fahrt ON AnfKo.FahrtID = Fahrt.ID
WHERE AnfKo.LieferDatum = N'2023-12-26'
  AND AnfKo.TourenID != Fahrt.TourenID
  AND AnfKo.Memo LIKE N'% geändert durch KOVACE';

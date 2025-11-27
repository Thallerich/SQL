DECLARE @KundenID int = $0$;
DECLARE @EingelesenVon datetime = $1$;
DECLARE @EingelesenBis datetime = $2$;

DROP TABLE IF EXISTS #InScan, #AnfPos;

CREATE TABLE #InScan (
  ScansID bigint PRIMARY KEY,
  EinzTeilID int,
  [DateTime] datetime2
);

CREATE INDEX InScan_EinzTeilID ON #InScan (EinzTeilID);

SELECT AnfPo.ID
INTO #AnfPos
FROM AnfPo
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN Vsa ON AnfKo.VsaID = Vsa.ID
WHERE Vsa.KundenID = @KundenID
  AND AnfKo.Lieferdatum >= @EingelesenVon;

INSERT INTO #InScan (ScansID, EinzTeilID, [DateTime])
SELECT Scans.ID AS ScansID, Scans.EinzTeilID, Scans.[DateTime]
FROM Scans
WHERE Scans.[DateTime] BETWEEN @EingelesenVon AND @EingelesenBis
  AND Scans.Menge = 1
  AND Scans.EinzTeilID IN (
    SELECT DISTINCT Scans.EinzTeilID
    FROM Scans
    WHERE Scans.AnfPoID IN (SELECT ID FROM #AnfPos)
  );

WITH Eingangsscans AS (
  SELECT MAX(Ausgangsscan.ID) AS ScansID_Out, Ausgangsscan.EinzTeilID, Eingangsscan.ScansID AS ScansID_In
  FROM Scans AS Ausgangsscan
  JOIN #InScan AS Eingangsscan ON Ausgangsscan.EinzTeilID = Eingangsscan.EinzTeilID
  WHERE Ausgangsscan.Menge = -1
    AND Ausgangsscan.[DateTime] > Eingangsscan.[DateTime]
  GROUP BY Ausgangsscan.EinzTeilID, Eingangsscan.ScansID
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS [Vsa-Stichwort], Vsa.Bez AS [Vsa-Bezeichnung], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Scans_In.[DateTime] AS [Einlese-Zeitpunkt], ZielNr.ZielNrBez$LAN$ AS [Einlese-Ort], LsKo.LsNr AS [geliefert mit LsNr], LsKo.Datum AS [geliefert am], EINZTEIL.Code AS Chipcode, CAST(IIF(EinzTeil.VsaOwnerID > 0, 1, 0) AS bit) AS [Eigenwäsche?]
FROM Eingangsscans
JOIN EinzTeil ON Eingangsscans.EinzTeilID = EinzTeil.ID
JOIN ArtGroe ON EinzTeil.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Scans AS Scans_Out ON Eingangsscans.ScansID_Out = Scans_Out.ID
JOIN Scans AS Scans_In ON Eingangsscans.ScansID_In = Scans_In.ID
JOIN ZielNr ON Scans_In.ZielNrID = ZielNr.ID
JOIN AnfPo ON Scans_Out.AnfPoID = AnfPo.ID
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN LsKo ON AnfKo.LsKoID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.ID = @KundenID
  AND (($3$ = 1 AND EinzTeil.VsaOwnerID > 0) OR ($3$ = 0));
;
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: prepareData                                                                                                     ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #Pool892e, #ArtikelSelection892e;

DECLARE @sqltext nvarchar(max), @kundenid int;

CREATE TABLE #Pool892e (
  Vertriebszone nchar(15) COLLATE Latin1_General_CS_AS,
  Geschäftsbereich nchar(5) COLLATE Latin1_General_CS_AS,
  Holding nchar(10) COLLATE Latin1_General_CS_AS,
  KdNr int,
  Kunde nchar(20) COLLATE Latin1_General_CS_AS,
  VsaNr int,
  [VSA-Bezeichnung] nvarchar(40) COLLATE Latin1_General_CS_AS,
  ArtikelNr nchar(15) COLLATE Latin1_General_CS_AS,
  Artikelbezeichnung nvarchar(60) COLLATE Latin1_General_CS_AS,
  Größe nchar(12) COLLATE Latin1_General_CS_AS,
  LsNr int,
  Lieferdatum date,
  Code nvarchar(33) COLLATE Latin1_General_CS_AS,
  Code2 nvarchar(33) COLLATE Latin1_General_CS_AS,
  [Zeitpunkt Einlesung] datetime,
  [Zeitpunkt Auslesung] datetime,
  [Ort Auslesung] nvarchar(60) COLLATE Latin1_General_CS_AS,
  Produktion nvarchar(40) COLLATE Latin1_General_CS_AS,
  EinzTeilID int
);

CREATE TABLE #ArtikelSelection892e (
  ArtikelID int
);

SELECT @kundenid = $1$;

INSERT INTO #ArtikelSelection892e (ArtikelID)
SELECT Artikel.ID
FROM Artikel
WHERE Artikel.ID IN ($2$);

SET @sqltext = N'
SELECT [Zone].ZonenCode AS Vertriebszone,
  KdGf.KurzBez AS Geschäftsbereich,
  Holding.Holding,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.VsaNr,
  Vsa.Bez AS [VSA-Bezeichnung],
  Artikel.ArtikelNr, 
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  ArtGroe.Groesse AS Größe,
  EinzTeil.Code,
  EinzTeil.Code2,
  EinzTeil.ID
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN Vsa ON EinzTeil.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
JOIN ArtGroe ON EinzTeil.ArtGroeID = ArtGroe.ID
WHERE EinzHist.PoolFkt = 1
  AND EinzHist.EinzHistTyp = 1
  AND EinzTeil.[Status] = N''Q''
  AND EinzTeil.ArtikelID IN (SELECT ArtikelID FROM #ArtikelSelection892e)
  AND Kunden.ID = @kundenid;
';

INSERT INTO #Pool892e (Vertriebszone, Geschäftsbereich, Holding, KdNr, Kunde, VsaNr, [VSA-Bezeichnung], ArtikelNr, Artikelbezeichnung, Größe, Code, Code2, EinzTeilID)
EXEC sp_executesql @sqltext, N'@kundenid int', @kundenid;

UPDATE #Pool892e SET LsNr = LsKo.LsNr, Lieferdatum = LsKo.Datum, [Zeitpunkt Auslesung] = Scans.[DateTime], [Ort Auslesung] = ZielNr.ZielNrBez$LAN$, Produktion = Standort.Bez
FROM (
  SELECT #Pool892e.EinzTeilID, LastAusleseScanID = (
    SELECT TOP 1 Scans.ID
    FROM Scans
    WHERE Scans.EinzTeilID = #Pool892e.EinzTeilID
      AND Scans.Menge = -1
    ORDER BY Scans.[DateTime] DESC
  )
  FROM #Pool892e
) AS LastAusleseScan
JOIN Scans ON LastAusleseScan.LastAusleseScanID = Scans.ID
JOIN LsPo ON Scans.LsPoID = LsPo.ID
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN ZielNr ON Scans.ZielNrID = ZielNr.ID
JOIN Standort ON ZielNr.ProduktionsID = Standort.ID
WHERE LastAusleseScan.EinzTeilID = #Pool892e.EinzTeilID;

UPDATE #Pool892e SET [Zeitpunkt Einlesung] = (
  SELECT TOP 1 Scans.[DateTime]
  FROM Scans
  WHERE Scans.EinzTeilID = #Pool892e.EinzTeilID
    AND Scans.Menge = 1
  ORDER BY Scans.[DateTime] DESC
);

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: Poolteile mit Ein-Ausgang                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Vertriebszone, Geschäftsbereich, Holding, KdNr, Kunde, VsaNr, [VSA-Bezeichnung], ArtikelNr, Artikelbezeichnung, Größe, LsNr, Lieferdatum, Code, Code2, [Zeitpunkt Einlesung], [Zeitpunkt Auslesung], [Ort Auslesung], Produktion
FROM #Pool892e;
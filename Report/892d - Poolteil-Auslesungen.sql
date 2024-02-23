/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: prepareData                                                                                                     ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #Pool892d;

DECLARE @sqltext nvarchar(max), @startdate datetime2, @enddate datetime2, @kundenid int, @artikelid int;

CREATE TABLE #Pool892d (
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
  Produktion nvarchar(40) COLLATE Latin1_General_CS_AS
);

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
  LsKo.LsNr,
  LsKo.Datum AS Lieferdatum,
  EinzTeil.Code,
  EinzTeil.Code2,
  [Zeitpunkt Einlesung] = (
    SELECT TOP 1 Scans_Eingang.[DateTime]
    FROM Scans AS Scans_Eingang
    WHERE Scans_Eingang.Menge = 1
      AND Scans_Eingang.EinzTeilID = Scans_Ausgang.EinzTeilID
      AND Scans_Eingang.[DateTime] <= Scans_Ausgang.[DateTime]
    ORDER BY Scans_Eingang.[DateTime] DESC
  ),
  Scans_Ausgang.[DateTime] AS [Zeitpunkt Auslesung],
  ZielNr.ZielNrBez$LAN$ AS [Ort Auslesung],
  Standort.Bez AS Produktion
FROM Scans AS Scans_Ausgang
JOIN AnfPo ON Scans_Ausgang.AnfPoID = AnfPo.ID
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN LsKo ON AnfKo.LsKoID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN EinzHist ON Scans_Ausgang.EinzHistID = EinzHist.ID
JOIN EinzTeil ON Scans_Ausgang.EinzTeilID = EinzTeil.ID
JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
JOIN ArtGroe ON EinzTeil.ArtGroeID = ArtGroe.ID
JOIN ZielNr ON Scans_Ausgang.ZielNrID = ZielNr.ID
JOIN Standort ON ZielNr.ProduktionsID = Standort.ID
WHERE Scans_Ausgang.[DateTime] BETWEEN @startdate AND @enddate
  AND EinzHist.PoolFkt = 1
  AND Scans_Ausgang.Menge = -1
  AND Scans_Ausgang.AnfPoID > 0
  AND EinzTeil.ArtikelID = @artikelid
  AND Kunden.ID = @kundenid;
';

SELECT @startdate = $STARTDATE$, @enddate = DATEADD(day, 1, $ENDDATE$), @kundenid = $2$, @artikelid = $3$;

INSERT INTO #Pool892d (Vertriebszone, Geschäftsbereich, Holding, KdNr, Kunde, VsaNr, [VSA-Bezeichnung], ArtikelNr, Artikelbezeichnung, Größe, LsNr, Lieferdatum, Code, Code2, [Zeitpunkt Einlesung], [Zeitpunkt Auslesung], [Ort Auslesung], Produktion)
EXEC sp_executesql @sqltext, N'@startdate datetime2, @enddate datetime2, @kundenid int, @artikelid int', @startdate, @enddate, @kundenid, @artikelid;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: Poolteile-Auslesungen                                                                                           ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Vertriebszone, Geschäftsbereich, Holding, KdNr, Kunde, VsaNr, [VSA-Bezeichnung], ArtikelNr, Artikelbezeichnung, Größe, LsNr, Lieferdatum, Code, Code2, [Zeitpunkt Auslesung], [Ort Auslesung], Produktion
FROM #Pool892d;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: Poolteile-Auslesung mit Einlesung                                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Vertriebszone, Geschäftsbereich, Holding, KdNr, Kunde, VsaNr, [VSA-Bezeichnung], ArtikelNr, Artikelbezeichnung, Größe, LsNr, Lieferdatum, Code, Code2, [Zeitpunkt Einlesung], [Zeitpunkt Auslesung], [Ort Auslesung], Produktion
FROM #Pool892d;
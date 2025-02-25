DROP TABLE IF EXISTS #SterilArtikel, #DetailResult;

DECLARE @verfallparam int = (SELECT CAST(ValueMemo AS int) FROM Settings WHERE Parameter = N'OP_ZU_PACKZETTEL_VOR_ABLAUF') * -1;

SELECT Artikel.ID, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGru.ArtGruBez$LAN$ AS Artikelgruppe
INTO #SterilArtikel
FROM Artikel
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
WHERE Artikel.ID IN (SELECT ArtikelID FROM OPSets)
	AND Artikel.[Status] IN (N'A', N'C', N'D')
	AND ArtGru.[Status] = N'A'
	AND (Bereich.IstOP = 1 OR Bereich.IstReinraum = 1)
	AND ArtGru.Steril = 1;

SELECT OPEtiKo.EtiNr, OPEtiKo.PackZeitpunkt, OPEtiKo.VerfallDatum, CAST(IIF(OPEtiKo.VerfallDatum <= DATEADD(day, @verfallparam, GETDATE()), 1, 0) AS bit) AS IsOld, OPEtiKo.VsaID, Artikel.ArtikelNr, Artikel.Artikelbezeichnung, Artikel.Artikelgruppe
INTO #DetailResult
FROM OPEtiKo
JOIN #SterilArtikel AS Artikel ON OPEtiKo.ArtikelID = Artikel.ID
WHERE OPEtiKo.ProduktionID IN ($1$)
  AND OPEtiKo.Status = N'M'
  AND OPEtiKo.OPLagerID = -1;

/* +++++++++++++++++++++++++++++++++++ Steril-Details ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT #DetailResult.EtiNr, #DetailResult.PackZeitpunkt, #DetailResult.VerfallDatum, #DetailResult.IsOld AS [abgelaufen / nicht mehr lieferbar], IIF(#DetailResult.VsaID = -1, NULL, Kunden.KdNr) AS KdNr, IIF(#DetailResult.VsaID = -1, NULL, Kunden.SuchCode) AS Kunde, IIF(#DetailResult.VsaID = -1, NULL, Vsa.VsaNr) AS [VSA-Nr], IIF(#DetailResult.VsaID = -1, NULL, Vsa.Bez) AS [VSA-Bezeichnung], #DetailResult.ArtikelNr, #DetailResult.Artikelbezeichnung, #DetailResult.Artikelgruppe
FROM #DetailResult
JOIN Vsa ON #DetailResult.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID;

/* +++++++++++++++++++++++++++++++++++ Übersicht +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT #DetailResult.ArtikelNr, #DetailResult.Artikelbezeichnung, COUNT(#DetailResult.EtiNr) AS Steril, SUM(IIF(#DetailResult.IsOld = 1, 1, 0)) AS [davon abgelaufen / nicht mehr lieferbar], SUM(IIF(#DetailResult.IsOld = 1, 0, 1)) AS [lagernd], #DetailResult.Artikelgruppe
FROM #DetailResult
GROUP BY #DetailResult.ArtikelNr, #DetailResult.Artikelbezeichnung, #DetailResult.Artikelgruppe;
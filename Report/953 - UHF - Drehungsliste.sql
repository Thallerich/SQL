SELECT KdGf.KurzBez AS SGF,
  Bereich.BereichBez$LAN$ AS Produktbereich,
  Kunden.KdNr,
  Kunden.SuchCode AS  [Kunde SuchCode],
  Vsa.ID AS VsaID,
  Vsa.Bez AS Vsa,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikel,
  ISNULL(VsaAnf.Bestand, 0) AS Vertragsbestand,
  SUM(IIF(OPTeile.Status = N'Q', 1, 0)) AS [Teile beim Kunden],
  SUM(IIF(OPTeile.Status = N'W' AND OPTeile.RechPoID > 0, 1, 0)) AS [Schwundmarkiert (verrechnet)],
  SUM(IIF(OPTeile.Status = N'W' AND OPTeile.RechPoID < 0, 1, 0)) AS [Schwundmarkiert (nicht verrechnet)],
  SUM(IIF(DATEDIFF(day, OPTeile.LastScanToKunde, GETDATE()) <= 7 AND OPTeile.Status = N'Q', 1, 0)) AS [stark drehend <= 7],
  SUM(IIF(DATEDIFF(day, OPTeile.LastScanToKunde, GETDATE()) > 7 AND DATEDIFF(day, OPTeile.LastScanToKunde, GETDATE()) <= 30 AND OPTeile.Status = N'Q', 1, 0)) AS [schwach drehend <= 30],
  SUM(IIF(DATEDIFF(day, OPTeile.LastScanToKunde, GETDATE()) > 30 AND DATEDIFF(day, OPTeile.LastScanToKunde, GETDATE()) <= 60 AND OPTeile.Status = N'Q', 1, 0)) AS [kaum drehend <= 60],
  SUM(IIF(DATEDIFF(day, OPTeile.LastScanToKunde, GETDATE()) > 60 AND OPTeile.Status = N'Q', 1, 0)) AS [nicht drehend > 60]
FROM OPTeile
JOIN Vsa ON OPTeile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN KdArti ON KdArti.ArtikelID = Artikel.ID AND KdArti.KundenID = Kunden.ID
LEFT JOIN VsaAnf ON VsaAnf.VsaID = Vsa.ID AND VsaAnf.KdArtiID = KdArti.ID
WHERE Kunden.ID = $1$
  AND OPTeile.Status IN (N'Q', N'W')
  AND OPTeile.LastActionsID IN (102, 116, 120, 136)
GROUP BY KdGf.KurzBez, Bereich.BereichBez$LAN$, Kunden.KdNr, Kunden.SuchCode, Vsa.ID, Vsa.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, VsaAnf.Bestand;
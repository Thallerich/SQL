DECLARE @CurrentWeek nchar(7) = (SELECT Week.Woche FROM Week WHERE GETDATE() BETWEEN Week.VonDat AND Week.BisDat);

SELECT Standort.SuchCode AS Produktion, Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Bereich.Bereich, ArtGru.ArtGruBez$LAN$ AS Artikelgruppe, SUM(VsaLeas.Menge) AS Umlaufmenge
FROM VsaLeas
JOIN KdArti ON VsaLeas.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Vsa ON VsaLeas.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN StandBer ON StandBer.StandKonID = Vsa.StandKonID AND StandBer.BereichID = Bereich.ID
JOIN Standort ON StandBer.ProduktionID = Standort.ID
WHERE Standort.ID IN ($2$)
  AND Kunden.Status = N'A'
  AND Vsa.Status = N'A'
  AND @CurrentWeek BETWEEN ISNULL(VsaLeas.InDienst, N'1980/01') AND ISNULL(VsaLeas.AusDienst, N'2099/52')
  AND Bereich.ID IN ($1$)
GROUP BY Standort.SuchCode, Kunden.KdNr, Kunden.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez, Bereich.Bereich, ArtGru.ArtGruBez;
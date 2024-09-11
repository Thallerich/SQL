DECLARE @StartWeek nchar(7) = (SELECT Week.Woche FROM Week WHERE $STARTDATE$ BETWEEN Week.VonDat AND Week.BisDat);
DECLARE @EndWeek nchar(7) = (SELECT Week.Woche FROM Week WHERE $ENDDATE$ BETWEEN Week.VonDat AND Week.BisDat);

SELECT KdNr, Kunde, Produktbereich, Artikelgruppe, Sortiment, ArtikelNr, Artikelbezeichnung, ROUND(AVG(TraeAnz), 0) AS Trägeranzahl, SUM(Menge) AS Umlauf, ROUND(AVG(Menge), 0) AS [Durchschnitt Umlauf], ROUND(SUM(Ruecklauf), 1) AS [Maximale Abgabemenge], SUM(Effektiv) AS [Effektive Abgabemenge], ROUND(IIF(SUM(Ruecklauf) = 0, 0.0, SUM(Effektiv) * 100 / SUM(Ruecklauf)), 2) AS [Quote %]
FROM (
  SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Bereich.BereichBez$LAN$ AS Produktbereich, ArtGru.ArtGruBez$LAN$ AS Artikelgruppe, ProdGru.ProdGruBez$LAN$ AS Sortiment, Wochen.Woche, SUM(TraeArch.Menge) AS Menge, SUM(TraeArch.Effektiv) AS Effektiv, IIF(SUM(TraeArch.Menge) < 3, CAST((SUM(TraeArch.Menge) / 3.0) AS numeric(18, 4)), CAST(((SUM(TraeArch.Menge) - 1) / 2.0) AS numeric(18, 4))) AS Ruecklauf, COUNT(DISTINCT Traeger.ID) AS TraeAnz
  FROM TraeArch
  JOIN TraeArti ON TraeArch.TraeArtiID = TraeArti.ID
  JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
  JOIN Vsa ON Traeger.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
  JOIN Prodgru ON Artikel.ProdgruID = Prodgru.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN Bereich ON KdBer.BereichID = Bereich.ID
  JOIN Wochen ON TraeArch.WochenID = Wochen.ID
  WHERE Kunden.ID IN ($3$)
    AND Wochen.Woche BETWEEN @StartWeek AND @EndWeek
    AND TraeArch.Menge > 0
    AND TraeArch.ApplKdArtiID = -1
  GROUP BY Kunden.KdNr, Kunden.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, Bereich.BereichBez$LAN$, ArtGru.ArtGruBez$LAN$, ProdGru.ProdGruBez$LAN$, Wochen.Woche
) AS Ruecklaufdaten
GROUP BY KdNr, Kunde, Produktbereich, Artikelgruppe, Sortiment, ArtikelNr, Artikelbezeichnung
ORDER BY KdNr, ArtikelNr;
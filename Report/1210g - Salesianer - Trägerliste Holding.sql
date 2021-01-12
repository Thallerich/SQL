WITH Umlaufteile AS (
  SELECT Teile.TraeArtiID, COUNT(Teile.ID) AS Umlaufmenge
  FROM Teile
  WHERE Teile.Status BETWEEN N'Q' AND N'W'
    AND Teile.Einzug IS NULL
  GROUP BY Teile.TraeArtiID
),
Traegerteile AS (
  SELECT Teile.TraeArtiID, MIN(Teile.IndienstDat) AS ArtikelAktiv, MAX(Teile.AusdienstDat) AS ArtikelInaktiv
  FROM Teile
  GROUP BY Teile.TraeArtiID
),
KostenlosTeile AS (
  SELECT Teile.TraeArtiID, COUNT(Teile.ID) AS KostenlosMenge
  FROM Teile
  WHERE Teile.Kostenlos = 1
    AND Teile.Status BETWEEN N'Q' AND N'W'
    AND Teile.Einzug IS NULL
  GROUP BY Teile.TraeArtiID
)
SELECT Holding.Holding AS Kette, Kunden.KdNr, Kunden.SuchCode AS [Kunden-KurzID], Vsa.VsaNr, Vsa.Bez AS VsaBezeichnung, Vsa.Name1 AS VsaName1, Vsa.Name2 AS VsaName2, Vsa.GebaeudeBez, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Traeger.SchrankInfo, Traeger.Traeger AS TrägerNr, Traeger.Nachname, Traeger.Vorname, Traeger.IndienstDat, Traeger.AusdienstDat, Traeger.PersNr, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, Traegerteile.ArtikelAktiv AS [Produkt aktiv], IIF(TraeArti.Menge != 0, NULL, Traegerteile.ArtikelInaktiv) AS [Produkt inaktiv], TraeArti.Menge AS Maximalbestand, Umlaufteile.Umlaufmenge, IIF(Traeger.Status = N'I', N'J', N'N') AS Stilllegung, KostenlosTeile.KostenlosMenge AS [Teile auf Depot]
FROM TraeArti
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Abteil ON Vsa.AbteilID = Abteil.ID
JOIN GroePo ON GroePo.GroeKoID = Artikel.GroeKoID AND GroePo.Groesse = ArtGroe.Groesse
LEFT JOIN Umlaufteile ON Umlaufteile.TraeArtiID = TraeArti.ID
LEFT JOIN KostenlosTeile ON KostenlosTeile.TraeArtiID = TraeArti.ID
LEFT JOIN Traegerteile ON Traegerteile.TraeArtiID = TraeArti.ID
WHERE Holding.ID IN ($1$)
  AND Kunden.ID IN ($2$)
ORDER BY Kette, KdNr, VsaNr, TrägerNr, ArtikelNr, GroePo.Folge;
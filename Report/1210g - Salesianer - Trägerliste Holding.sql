WITH Umlaufteile AS (
  SELECT EinzHist.TraeArtiID, COUNT(EinzHist.ID) AS Umlaufmenge
  FROM EinzTeil
  JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
  WHERE EinzHist.Status BETWEEN N'Q' AND N'W'
    AND EinzHist.Einzug IS NULL
    AND EinzHist.PoolFkt = 0
    AND EinzHist.EinzHistTyp = 1
  GROUP BY EinzHist.TraeArtiID
),
Traegerteile AS (
  SELECT EinzHist.TraeArtiID, MIN(EinzHist.IndienstDat) AS ArtikelAktiv, MAX(EinzHist.AusdienstDat) AS ArtikelInaktiv
  FROM EinzTeil
  JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
  WHERE EinzHist.PoolFkt = 0
    AND EinzHist.EinzHistTyp = 1
  GROUP BY EinzHist.TraeArtiID
),
KostenlosTeile AS (
  SELECT EinzHist.TraeArtiID, COUNT(EinzHist.ID) AS KostenlosMenge
  FROM EinzTeil
  JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
  WHERE EinzHist.Kostenlos = 1
    AND EinzHist.Status BETWEEN N'Q' AND N'W'
    AND EinzHist.Einzug IS NULL
    AND EinzHist.PoolFkt = 0
    AND EinzHist.EinzHistTyp = 1
  GROUP BY EinzHist.TraeArtiID
)
SELECT Holding.Holding AS Kette, Kunden.KdNr, Kunden.SuchCode AS [Kunden-KurzID], Vsa.VsaNr, Vsa.Bez AS VsaBezeichnung, Vsa.Name1 AS VsaName1, Vsa.Name2 AS VsaName2, Vsa.GebaeudeBez, Abteil.Abteilung AS [Abteilung VSA] , Abteil.Bez AS [Stammkostenstelle VSA], Traeger.SchrankInfo, Traeger.Traeger AS TrägerNr, Traeger.Nachname, Traeger.Vorname, Traeger.IndienstDat, Traeger.AusdienstDat, Traeger.PersNr, TraeAbteil.Abteilung AS [Abteilung Träger], TraeAbteil.Bez as [Stammkostenstelle Träger], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, Traegerteile.ArtikelAktiv AS [Produkt aktiv], IIF(TraeArti.Menge != 0, NULL, Traegerteile.ArtikelInaktiv) AS [Produkt inaktiv], TraeArti.Menge AS Maximalbestand, Umlaufteile.Umlaufmenge, IIF(Traeger.Status = N'I', N'J', N'N') AS Stilllegung, KostenlosTeile.KostenlosMenge AS [Teile auf Depot]
FROM TraeArti
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Abteil ON Vsa.AbteilID = Abteil.ID
JOIN Abteil AS TraeAbteil ON Traeger.AbteilID = TraeAbteil.ID
JOIN GroePo ON GroePo.GroeKoID = Artikel.GroeKoID AND GroePo.Groesse = ArtGroe.Groesse
LEFT JOIN Umlaufteile ON Umlaufteile.TraeArtiID = TraeArti.ID
LEFT JOIN KostenlosTeile ON KostenlosTeile.TraeArtiID = TraeArti.ID
LEFT JOIN Traegerteile ON Traegerteile.TraeArtiID = TraeArti.ID
WHERE Holding.ID IN ($1$)
  AND Kunden.ID IN ($2$)
ORDER BY Kette, KdNr, VsaNr, TrägerNr, ArtikelNr, GroePo.Folge;
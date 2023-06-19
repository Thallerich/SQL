WITH Umlaufteile AS (
  SELECT EinzHist.TraeArtiID, COUNT(EinzHist.ID) AS Menge
  FROM EinzHist
  WHERE EinzHist.EinzHistTyp = 1
    AND EinzHist.IsCurrEinzHist = 1
    AND EinzHist.PoolFkt = 0
    AND EinzHist.[Status] BETWEEN N'Q' AND N'W'
    AND EinzHist.Einzug IS NULL
  GROUP BY EinzHist.TraeArtiID
)
SELECT CAST(GETDATE() AS date) AS Auswertungsdatum, Kunden.KdNr, Vsa.VsaNr, Vsa.Bez AS VsaBezeichnung, Vsa.GebaeudeBez AS Abteilung, Vsa.Name2 AS Bereich, Abteil.Bez AS Kostenstelle, Traeger.Traeger AS TrägerNr, Traeger.PersNr AS Personalnummer, Traeger.Vorname, Traeger.Nachname, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, KdArti.VariantBez AS Verrechnungsart, ArtGroe.Groesse AS Größe, TraeArti.Menge AS [Soll-Menge], ISNULL(Umlaufteile.Menge, 0) AS [Ist-Menge]
FROM TraeArti
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Abteil ON Traeger.AbteilID = Abteil.ID
LEFT JOIN Umlaufteile ON Umlaufteile.TraeArtiID = TraeArti.ID
WHERE TraeArti.Menge != 0
  AND Traeger.[Status] != N'I'
  AND Kunden.HoldingID IN (SELECT Holding.ID FROM Holding WHERE Holding.Holding IN (N'VOES', N'VOESAN', N'VOESLE'))
  AND Kunden.[Status] = N'A';
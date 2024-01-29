SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Holding.Holding, Vsa.GebaeudeBez AS Abteilung, Vsa.Name2 AS Bereich, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Traeger.Traeger AS [Träger-Nummer], Traeger.Vorname, Traeger.Nachname, COALESCE(IIF(Vornamen.Geschlecht = N'?', NULL, Vornamen.Geschlecht), Traeger.Geschlecht) AS Geschlecht, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe
FROM TraeArti
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Abteil ON Traeger.AbteilID = Abteil.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
LEFT JOIN Vornamen ON UPPER(Traeger.Vorname) = Vornamen.Vorname
WHERE Traeger.[Status] != N'I'
  AND Vsa.[Status] = N'A'
  AND Kunden.[Status] = N'A'
  AND Holding.Holding IN (N'VOES', N'VOESAN')
  AND TraeArti.Menge > 0
  AND COALESCE(IIF(Vornamen.Geschlecht = '?', NULL, Vornamen.Geschlecht), Traeger.Geschlecht) IN (N'M', N'W')
  AND Traeger.Vorname IS NOT NULL;

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Holding.Holding, Vsa.GebaeudeBez AS Abteilung, Vsa.Name2 AS Bereich, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Traeger.Traeger AS [Träger-Nummer], Traeger.Vorname, Traeger.Nachname, COALESCE(IIF(Vornamen.Geschlecht = N'?', NULL, Vornamen.Geschlecht), Traeger.Geschlecht) AS Geschlecht
FROM Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Abteil ON Traeger.AbteilID = Abteil.ID
LEFT JOIN Vornamen ON UPPER(Traeger.Vorname) = Vornamen.Vorname
WHERE Traeger.[Status] != N'I'
  AND Vsa.[Status] = N'A'
  AND Kunden.[Status] = N'A'
  AND Holding.Holding IN (N'VOES', N'VOESAN')
  AND EXISTS (SELECT TraeArti.ID FROM TraeArti WHERE TraeArti.TraegerID = Traeger.ID AND TraeArti.Menge > 0)
  AND COALESCE(IIF(Vornamen.Geschlecht = '?', NULL, Vornamen.Geschlecht), Traeger.Geschlecht) IN (N'M', N'W')
  AND Traeger.Vorname IS NOT NULL;
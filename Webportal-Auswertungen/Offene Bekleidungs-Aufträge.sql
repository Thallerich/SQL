SELECT Kunden.KdNr, Vsa.VsaNr, Traeger.Traeger, CONCAT(ISNULL(Traeger.Nachname + N', ', N''), Traeger.Vorname) AS [Name], Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, COUNT(EinzHist.ID) AS Menge
FROM EinzHist
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Artikel ON EinzHist.ArtikelID = Artikel.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
WHERE EinzHist.ID = (SELECT EinzTeil.CurrEinzHistID FROM EinzTeil WHERE EinzTeil.ID = EinzHist.EinzTeilID)
  AND EinzHist.[Status] >= N'A'
  AND EinzHist.[Status] < N'Q'
  AND Kunden.KdNr = 294133
GROUP BY Kunden.KdNr, Vsa.VsaNr, Traeger.Traeger, CONCAT(ISNULL(Traeger.Nachname + N', ', N''), Traeger.Vorname), Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse;
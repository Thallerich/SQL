SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS [VSA-Nr], Vsa.Bez AS [VSA-Bezeichnung], Traeger.Traeger AS TrägerNr, Traeger.Vorname, Traeger.Nachname, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, EinzHist.Barcode, EinzHist.Kostenlos, Vsa.ID AS VsaID, Traeger.ID AS TraegerID
FROM EinzHist
JOIN EinzTeil ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN TraeArti ON EinzHist.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN GroePo ON Artikel.GroeKoID = GroePo.GroeKoID AND ArtGroe.Groesse = GroePo.Groesse
WHERE EinzHist.EinzHistTyp = 1
  AND EinzHist.PoolFkt = 0
  AND ISNULL(EinzHist.Ausdienst, N'2099/52') > (SELECT [Week].Woche FROM [Week] WHERE CAST(GETDATE() AS date) BETWEEN [Week].VonDat AND [Week].BisDat)
  AND EinzHist.[Status] BETWEEN N'Q' AND N'W'
  AND EinzHist.Kostenlos = 1
  AND Kunden.ID = $ID$
ORDER BY [VSA-Nr], Nachname, TrägerNr, ArtikelNr, GroePo.Folge;
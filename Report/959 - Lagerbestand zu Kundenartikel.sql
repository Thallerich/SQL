SELECT Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  ArtGroe.Groesse AS Größe,
  Standort.Bez AS [Lager-Standort],
  Lagerart.LagerartBez$LAN$ AS Lagerart,
  Bestand.Bestand,
  Bestand.Reserviert,
  Bestand.InBestReserv + Bestand.InBestUnreserv AS Bestellt,
  Bestand.Umlauf,
  [Lagerbestand gebraucht vom Kunden] = (
    SELECT COUNT(EinzHist.ID)
    FROM EinzTeil
    JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
    JOIN Lagerart ON EinzHist.LagerArtID = Lagerart.ID
    WHERE EinzHist.EinzHistTyp = 2
      AND EinzHist.[Status] < N'XI'
      AND EinzHist.ArtGroeID = Bestand.ArtGroeID
      AND EinzHist.LagerArtID = Bestand.LagerArtID
      AND Lagerart.Neuwertig = 0
      AND EinzHist.KundenID = $1$
  )
FROM Bestand
JOIN Lagerart ON Bestand.LagerartID = Lagerart.ID
JOIN Standort ON Lagerart.LagerID = Standort.ID
JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
WHERE Lagerart.IstAnfLager = 0
  AND Standort.ID IN ($2$)
  AND Artikel.ID IN (
    SELECT KdArti.ArtikelID
    FROM KdArti
    WHERE KdArti.KundenID = $1$
      AND KdArti.Status = N'A'
  )
  AND (Bestand.Bestand > 0 OR Bestand.Reserviert > 0 OR Bestand.InBestReserv + Bestand.InBestUnreserv > 0);
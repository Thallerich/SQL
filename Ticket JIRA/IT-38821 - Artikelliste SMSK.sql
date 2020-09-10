WITH ArtikelImBestand AS (
  SELECT DISTINCT ArtGroe.ArtikelID
  FROM Bestand
  JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
  JOIN Lagerart ON Bestand.LagerartID = Lagerart.ID
  JOIN Standort AS Lager ON Lagerart.LagerID = Lager.ID
  WHERE Lager.SuchCode = N'SMSK'
    AND (Bestand.Bestand != 0 OR Bestand.BestandUrsprung != 0 OR Bestand.InBestReserv != 0 OR Bestand.InBestUnreserv != 0)
),
ArtikelKundenverwendung AS (
  SELECT DISTINCT KdArti.ArtikelID
  FROM KdArti
  JOIN Kunden ON KdArti.KundenID = Kunden.ID
  JOIN Firma ON Kunden.FirmaID = Firma.ID
  WHERE Firma.SuchCode = N'SMSK'
    AND KdArti.Status = N'A'
)
SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS [Artikelbezeichnung deutsch], Artikel.ArtikelBez4 AS [Artikelbezeichnung slowakisch]
FROM Artikel
WHERE Artikel.ID IN (
    SELECT ArtikelID FROM ArtikelImBestand
  )
  OR Artikel.ID IN (
    SELECT ArtikelID FROM ArtikelKundenverwendung
  );
SELECT
  Werk = Lager.SuchCode,
  Monat = FORMAT(DATEADD(month, -1, GETDATE()), 'MM.yyyy'),
  [Sammelmat.] = Artikel.ArtikelNr,
  [Sammelmaterial Kurztext] = Artikel.ArtikelBez,
  Material = CONCAT(Artikel.ArtikelNr, N'-' + IIF(ArtGroe.Groesse = N'-', NULL, ArtGroe.Groesse)),
  Materialkurztext = CONCAT(Artikel.ArtikelBez, N', Größe ' + IIF(ArtGroe.Groesse = N'-', NULL, ArtGroe.Groesse)),
  Endbestand = Bestand.Bestand
FROM Bestand
JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Lagerart ON Bestand.LagerArtID = Lagerart.ID
JOIN Standort AS Lager ON Lagerart.LagerID = Lager.ID
WHERE Lagerart.FirmaID = (SELECT ID FROM Firma WHERE SuchCode = N'SMSL')
  AND Lagerart.Neuwertig = 1
  AND Bestand.Bestand > 0 /* TODO: temporary - remove later to also show zero stock materials which had movements */
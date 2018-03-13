SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse, Bestand.Minimum, Bestand.Maximum, ArtGroe.Liefertage AS [stat. ermittelte Lieferzeit], Bestand.EntnahmeJahr AS [Jahressumme Neuware], LagerArt.LagerArtBez AS Lagerart
FROM Artikel, ArtGroe, Bestand, LagerArt
WHERE Artikel.ID IN (
    SELECT DISTINCT KdArti.ArtikelID
    FROM KdArti, Kunden
    WHERE KdArti.KundenID = Kunden.ID
      AND Kunden.ID = $ID$
  )
  AND ArtGroe.ArtikelID = Artikel.ID
  AND Bestand.ArtGroeID = ArtGroe.ID
  AND Bestand.LagerArtID = LagerArt.ID
  AND LagerArt.SichtbarID IN ($SICHTBARIDS$)
  AND LagerArt.MinMax = 1
  AND Artikel.BereichID = 100
ORDER BY Artikel.ArtikelNr, ArtGroe.Groesse;
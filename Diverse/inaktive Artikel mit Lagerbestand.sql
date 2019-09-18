WITH Artikelstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'ARTIKEL')
)
SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Artikelstatus.StatusBez AS Artikelstatus, ArtGroe.Groesse AS Größe, Standort.Bez AS Lagerstandort, LagerOrt.Lagerort, LagerArt.LagerArtBez AS Lagerart, BestOrt.Bestand
FROM BestOrt
JOIN Bestand ON BestOrt.BestandID = Bestand.ID
JOIN LagerOrt ON BestOrt.LagerOrtID = LagerOrt.ID
JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Artikelstatus ON Artikel.Status = Artikelstatus.Status
JOIN LagerArt ON Bestand.LagerArtID = LagerArt.ID
JOIN Standort ON LagerArt.LagerID = Standort.ID
WHERE BestOrt.Bestand > 0
  AND LagerArt.IstAnfLager = 0
  AND Artikel.Status = N'I'
  AND Standort.SuchCode = N'WOLE';
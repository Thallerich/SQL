SELECT N'|' + x.ArtikelNr + IIF(x.Groesse = N'-', N'', N'-' + x.Groesse) + N'|' + Lagerstandort + N'|' + CAST(Bestand AS nvarchar(10)) + N'|' AS DataRow
FROM (
  SELECT Bereich.Bereich, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse, Standort.SuchCode AS Lagerstandort, SUM(Bestand.Bestand) AS Bestand
  FROM Bestand
  JOIN LagerArt ON Bestand.LagerArtID = LagerArt.ID
  JOIN Standort ON LagerArt.LagerID = Standort.ID
  JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
  JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
  JOIN Bereich ON Artikel.BereichID = Bereich.ID
  WHERE LagerArt.Neuwertig = 1
  GROUP BY Bereich.Bereich, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, Standort.SuchCode
) AS x;
SELECT N'|' + x.ArtikelNr + N'-' + x.Groesse + N'|' + Lagerstandort + N'|N|' + CAST(Bestand AS nvarchar(10)) + N'|' AS DataRow
FROM (
  SELECT Bereich.Bereich, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse, Standort.SuchCode AS Lagerstandort, SUM(Bestand.Bestand) AS Bestand
  FROM Bestand
  JOIN LagerArt ON Bestand.LagerArtID = LagerArt.ID
  JOIN Standort ON LagerArt.LagerID = Standort.ID
  JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
  JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
  JOIN Bereich ON Artikel.BereichID = Bereich.ID
  WHERE LagerArt.LagerArt IN (N'NHW/200', N'NHW/310', N'NHW/320')
    AND Bereich.Bereich IN (N'HW', N'FR')
  GROUP BY Bereich.Bereich, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, Standort.SuchCode
) AS x;
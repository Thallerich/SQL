USE Salesianer;
GO

SELECT -1 AS BestOrtID, Bestand.ID AS BestandID, Bestand.Bestand, ME.MeBez, Bestand.InBestReserv, Bestand.InBestUnreserv, Bestand.Reserviert, Lagerort.Lagerort, Artikel.ArtikelNr, Artikel.ArtikelBez, Lagerart.Lagerart, Lagerart.LagerartBez, ArtGroe.Groesse, ArtGroe.Ehemals, 0 AS Inventurmenge
FROM Bestand
JOIN LagerArt ON Bestand.LagerArtID = LagerArt.ID
JOIN Standort ON LagerArt.LagerID = Standort.ID
JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN ME ON Artikel.MeID = ME.ID
LEFT JOIN BestOrt ON BestOrt.BestandID = Bestand.ID AND BestOrt.Stamm = 1
LEFT JOIN Lagerort ON BestOrt.LagerOrtID = Lagerort.ID
WHERE LagerArt.Neuwertig = 1
  AND ((Lagerart.Lagerart LIKE N'%HFN%' AND Bestand.Bestand = 0) OR Bestand.Bestand != 0)
  AND Artikel.ArtikelNr IN (SELECT v_bw_hawamaterial.material COLLATE Latin1_General_CS_AS FROM Salesianer_Archive.sapbw.v_bw_hawamaterial)
  AND Standort.SuchCode IN ('GRAZ');

GO

SELECT Bereich.Bereich, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse, Standort.SuchCode AS Lagerstandort, Lagerart.Lagerart, Lagerart.LagerartBez AS Lagerartbezeichnung, SUM(Bestand.Bestand) AS Bestand
FROM Bestand
JOIN LagerArt ON Bestand.LagerArtID = LagerArt.ID
JOIN Standort ON LagerArt.LagerID = Standort.ID
JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
WHERE LagerArt.Neuwertig = 1
  AND ((Lagerart.Lagerart LIKE N'%HFN%' AND Bestand.Bestand = 0) OR Bestand.Bestand != 0)
  AND Artikel.ArtikelNr IN (SELECT v_bw_hawamaterial.material COLLATE Latin1_General_CS_AS FROM Salesianer_Archive.sapbw.v_bw_hawamaterial)
  --AND Standort.SuchCode IN ('MATT','LEOG','SMS','ARNO','SCHI','GRAZ')
GROUP BY Bereich.Bereich, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, Standort.SuchCode, Lagerart.Lagerart, Lagerart.LagerartBez
ORDER BY Lagerstandort, ArtikelNr;

GO
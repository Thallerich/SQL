SELECT RTRIM(Artikel.ArtikelNr) + N'-' + RTRIM(ArtGroe.Groesse) AS Material, Artikel.ArtikelBez AS Materialkurztext, Standort.SuchCode AS Werk, IIF(Lagerart.Neuwertig = 1, N'N', N'G') AS Charge, ME.IsoCode AS BME, SUM(Bestand.Bestand) AS Lagerbestand
FROM Bestand
JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN ME ON Artikel.MEID = ME.ID
JOIN Lagerart ON Bestand.LagerArtID = Lagerart.ID
JOIN Standort ON Lagerart.LagerID = Standort.ID
WHERE Standort.SuchCode = N'BUDA'
GROUP BY RTRIM(Artikel.ArtikelNr) + N'-' + RTRIM(ArtGroe.Groesse), Artikel.ArtikelBez, Standort.SuchCode, IIF(Lagerart.Neuwertig = 1, N'N', N'G'), ME.IsoCode;
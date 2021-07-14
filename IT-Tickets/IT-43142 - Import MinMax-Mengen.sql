/* 
GO
 
ALTER TABLE __MinMax_WOLI_20210107 ADD Lagerart nchar(8) COLLATE Latin1_General_CS_AS;
ALTER TABLE __MinMax_WOLI_20210107 ALTER COLUMN ArtikelNr nchar(15) COLLATE Latin1_General_CS_AS;
ALTER TABLE __MinMax_WOLI_20210107 ALTER COLUMN Groesse nchar(12) COLLATE Latin1_General_CS_AS;

GO

UPDATE __MinMax_WOLI_20210107 SET Lagerart = N'WOLIBKNU' WHERE Lagerart IS NULL;

GO
 */

UPDATE Bestand SET Bestand.Minimum = __MinMax_WOLI_20210107.Minimum, Bestand.Maximum = __MinMax_WOLI_20210107.Maximum
FROM __MinMax_WOLI_20210107
JOIN Artikel ON __MinMax_WOLI_20210107.ArtikelNr = Artikel.ArtikelNr COLLATE Latin1_General_CS_AS
JOIN ArtGroe ON __MinMax_WOLI_20210107.Groesse = ArtGroe.Groesse COLLATE Latin1_General_CS_AS AND ArtGroe.ArtikelID = Artikel.ID
JOIN Lagerart ON __MinMax_WOLI_20210107.Lagerart = Lagerart.Lagerart COLLATE Latin1_General_CS_AS
JOIN Bestand ON Bestand.ArtGroeID = ArtGroe.ID AND Bestand.LagerArtID = Lagerart.ID;
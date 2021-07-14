-- Create Backup Table first
/* 
CREATE TABLE Salesianer_Archive.dbo.OPTeile_Code2_removed (
  ID int,
  Code varchar(33) COLLATE Latin1_General_CS_AS,
  Code2 varchar(33) COLLATE Latin1_General_CS_AS,
  ArtGroeID int,
  ArtikelID int,
  Erstwoche varchar(7) COLLATE Latin1_General_CS_AS
);
 */

UPDATE OPTeile SET Code2 = NULL
OUTPUT deleted.ID, deleted.Code, deleted.Code2, deleted.ArtGroeID, deleted.ArtikelID, deleted.Erstwoche
INTO Salesianer_Archive.dbo.OPTeile_Code2_removed
FROM OPTeile
JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
WHERE ArtGru.SetArtikel = 1
  AND Bereich.Bereich = N'ST'
  AND OPTeile.Code2 IS NOT NULL
  AND Artikel.ArtikelNr != N'129820000000';
ALTER TABLE __OPSetArtiChange ALTER COLUMN Setartikel nchar(15) COLLATE Latin1_General_CS_AS;
ALTER TABLE __OPSetArtiChange ALTER COLUMN InhaltAktuell nchar(15) COLLATE Latin1_General_CS_AS;
ALTER TABLE __OPSetArtiChange ALTER COLUMN InhaltNeu nchar(15) COLLATE Latin1_General_CS_AS;
ALTER TABLE __OPSetArtiChange ALTER COLUMN ErsatzNeu nchar(15) COLLATE Latin1_General_CS_AS;

GO

WITH SetArtiChange AS (
  SELECT DISTINCT Setartikel.ID AS SetartikelID, InhaltAktuell.ID AS InhaltAktuellID, InhaltNeu.ID AS InhaltNeuID, ErsatzNeu.ID AS ErsatzNeuID
  FROM Salesianer.dbo.__OPSetArtiChange
  JOIN Artikel AS Setartikel ON __OPSetArtiChange.Setartikel = Setartikel.ArtikelNr
  JOIN Artikel AS InhaltAktuell ON __OPSetArtiChange.InhaltAktuell = InhaltAktuell.ArtikelNr
  JOIN Artikel AS InhaltNeu ON __OPSetArtiChange.InhaltNeu = InhaltNeu.ArtikelNr
  JOIN Artikel AS ErsatzNeu ON __OPSetArtiChange.ErsatzNeu = ErsatzNeu.ArtikelNr
)
UPDATE OPSets SET Artikel1ID = SetArtiChange.InhaltNeuID, Artikel3ID = SetArtiChange.ErsatzNeuID
FROM OPSets
JOIN SetArtiChange ON OPSets.ArtikelID = SetArtiChange.SetartikelID AND OPSets.Artikel1ID = SetArtiChange.InhaltAktuellID
WHERE OPSets.Artikel2ID > 0
  AND OPSets.Artikel2ID != SetArtiChange.ErsatzNeuID;

GO

WITH SetArtiChange AS (
  SELECT DISTINCT Setartikel.ID AS SetartikelID, InhaltAktuell.ID AS InhaltAktuellID, InhaltNeu.ID AS InhaltNeuID, ErsatzNeu.ID AS ErsatzNeuID
  FROM Salesianer.dbo.__OPSetArtiChange
  JOIN Artikel AS Setartikel ON __OPSetArtiChange.Setartikel = Setartikel.ArtikelNr
  JOIN Artikel AS InhaltAktuell ON __OPSetArtiChange.InhaltAktuell = InhaltAktuell.ArtikelNr
  JOIN Artikel AS InhaltNeu ON __OPSetArtiChange.InhaltNeu = InhaltNeu.ArtikelNr
  JOIN Artikel AS ErsatzNeu ON __OPSetArtiChange.ErsatzNeu = ErsatzNeu.ArtikelNr
)
UPDATE OPSets SET Artikel1ID = SetArtiChange.InhaltNeuID, Artikel2ID = SetArtiChange.ErsatzNeuID
FROM OPSets
JOIN SetArtiChange ON OPSets.ArtikelID = SetArtiChange.SetartikelID AND OPSets.Artikel1ID = SetArtiChange.InhaltAktuellID
WHERE OPSets.Artikel2ID < 0;

GO

DROP TABLE __OPSetArtiChange;

GO
/* 
ALTER TABLE __ErsatzSAWR ALTER COLUMN Setartikelnummer nchar(15) COLLATE Latin1_General_CS_AS;
ALTER TABLE __ErsatzSAWR ALTER COLUMN InhaltArtikelnummer nchar(15) COLLATE Latin1_General_CS_AS;
ALTER TABLE __ErsatzSAWR ALTER COLUMN Ersatzartikelnummer nchar(15) COLLATE Latin1_General_CS_AS;
 */

WITH SetArtiChange AS (
  SELECT DISTINCT Setartikel.ID AS SetartikelID, InhaltAktuell.ID AS InhaltAktuellID, ErsatzNeu.ID AS ErsatzNeuID, __ErsatzSAWR.[Position], __ErsatzSAWR.Menge
  FROM Salesianer.dbo.__ErsatzSAWR
  JOIN Artikel AS Setartikel ON __ErsatzSAWR.Setartikelnummer = Setartikel.ArtikelNr
  JOIN Artikel AS InhaltAktuell ON __ErsatzSAWR.InhaltArtikelnummer = InhaltAktuell.ArtikelNr
  JOIN Artikel AS ErsatzNeu ON __ErsatzSAWR.Ersatzartikelnummer = ErsatzNeu.ArtikelNr
)
UPDATE OPSets SET Artikel2ID = SetArtiChange.ErsatzNeuID
FROM OPSets
JOIN SetArtiChange ON OPSets.ArtikelID = SetArtiChange.SetartikelID AND OPSets.Artikel1ID = SetArtiChange.InhaltAktuellID AND OPSets.[Position] = SetArtiChange.[Position] AND OPSets.Menge = SetArtiChange.Menge
WHERE OPSets.Artikel2ID = -1
  AND NOT EXISTS (
    SELECT o.*
    FROM OPSets o
    WHERE o.ID = OPSets.ID
      AND (o.Artikel1ID = SetArtiChange.ErsatzNeuID OR o.Artikel2ID = SetArtiChange.ErsatzNeuID OR o.Artikel3ID = SetArtiChange.ErsatzNeuID OR o.Artikel4ID = SetArtiChange.ErsatzNeuID)
  )
  AND OPSets.Artikel2ID != SetArtiChange.ErsatzNeuID;

GO

WITH SetArtiChange AS (
  SELECT DISTINCT Setartikel.ID AS SetartikelID, InhaltAktuell.ID AS InhaltAktuellID, ErsatzNeu.ID AS ErsatzNeuID, __ErsatzSAWR.[Position], __ErsatzSAWR.Menge
  FROM Salesianer.dbo.__ErsatzSAWR
  JOIN Artikel AS Setartikel ON __ErsatzSAWR.Setartikelnummer = Setartikel.ArtikelNr
  JOIN Artikel AS InhaltAktuell ON __ErsatzSAWR.InhaltArtikelnummer = InhaltAktuell.ArtikelNr
  JOIN Artikel AS ErsatzNeu ON __ErsatzSAWR.Ersatzartikelnummer = ErsatzNeu.ArtikelNr
)
UPDATE OPSets SET Artikel3ID = SetArtiChange.ErsatzNeuID
FROM OPSets
JOIN SetArtiChange ON OPSets.ArtikelID = SetArtiChange.SetartikelID AND OPSets.Artikel1ID = SetArtiChange.InhaltAktuellID AND OPSets.[Position] = SetArtiChange.[Position] AND OPSets.Menge = SetArtiChange.Menge
WHERE OPSets.Artikel3ID = -1
  AND NOT EXISTS (
    SELECT o.*
    FROM OPSets o
    WHERE o.ID = OPSets.ID
      AND (o.Artikel1ID = SetArtiChange.ErsatzNeuID OR o.Artikel2ID = SetArtiChange.ErsatzNeuID OR o.Artikel3ID = SetArtiChange.ErsatzNeuID OR o.Artikel4ID = SetArtiChange.ErsatzNeuID)
  )
  AND OPSets.Artikel2ID != SetArtiChange.ErsatzNeuID;

GO

WITH SetArtiChange AS (
  SELECT DISTINCT Setartikel.ID AS SetartikelID, InhaltAktuell.ID AS InhaltAktuellID, ErsatzNeu.ID AS ErsatzNeuID, __ErsatzSAWR.[Position], __ErsatzSAWR.Menge
  FROM Salesianer.dbo.__ErsatzSAWR
  JOIN Artikel AS Setartikel ON __ErsatzSAWR.Setartikelnummer = Setartikel.ArtikelNr
  JOIN Artikel AS InhaltAktuell ON __ErsatzSAWR.InhaltArtikelnummer = InhaltAktuell.ArtikelNr
  JOIN Artikel AS ErsatzNeu ON __ErsatzSAWR.Ersatzartikelnummer = ErsatzNeu.ArtikelNr
)
UPDATE OPSets SET Artikel4ID = SetArtiChange.ErsatzNeuID
FROM OPSets
JOIN SetArtiChange ON OPSets.ArtikelID = SetArtiChange.SetartikelID AND OPSets.Artikel1ID = SetArtiChange.InhaltAktuellID AND OPSets.[Position] = SetArtiChange.[Position] AND OPSets.Menge = SetArtiChange.Menge
WHERE OPSets.Artikel4ID = -1
  AND NOT EXISTS (
    SELECT o.*
    FROM OPSets o
    WHERE o.ID = OPSets.ID
      AND (o.Artikel1ID = SetArtiChange.ErsatzNeuID OR o.Artikel2ID = SetArtiChange.ErsatzNeuID OR o.Artikel3ID = SetArtiChange.ErsatzNeuID OR o.Artikel4ID = SetArtiChange.ErsatzNeuID)
  )
  AND OPSets.Artikel2ID != SetArtiChange.ErsatzNeuID;

GO

DROP TABLE __ErsatzSAWR;

GO
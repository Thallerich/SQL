CREATE TABLE __LiefSMZL_20211210 (
  ArtikelID int,
  ArtikelNr nchar(15) COLLATE Latin1_General_CS_AS,
  LiefID int,
  EKPreis money,
  EKPreisSeit date,
  EKPreisWaeID int
);

GO

DECLARE @LiefID int = (SELECT Lief.ID FROM Lief WHERE Lief.LiefNr = 100);

UPDATE Artikel SET LiefID = @LiefID
OUTPUT deleted.ID, deleted.ArtikelNr, deleted.LiefID, deleted.EkPreis, deleted.EkPreisSeit, deleted.EkPreisWaeID
INTO __LiefSMZL_20211210 (ArtikelID, ArtikelNr, LiefID, EKPreis, EKPreisSeit, EKPreisWaeID)
WHERE Artikel.LiefID != @LiefID
  AND Artikel.ArtiTypeID = 1
  AND NOT EXISTS (
    SELECT OPSets.*
    FROM OPSets
    WHERE OPSets.ArtikelID = Artikel.ID
  );

GO

SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Lief.LiefNr, Lief.Name1 AS Lieferant, __LiefSMZL_20211210.EkPreis, Wae.IsoCode
FROM __LiefSMZL_20211210
JOIN Artikel ON __LiefSMZL_20211210.ArtikelID = Artikel.ID
JOIN Lief ON __LiefSMZL_20211210.LiefID = Lief.ID
JOIN Wae ON __LiefSMZL_20211210.EKPreisWaeID = Wae.ID;

GO
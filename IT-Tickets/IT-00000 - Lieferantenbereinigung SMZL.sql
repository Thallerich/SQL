DECLARE @SMZLLief int = (SELECT ID FROM Lief WHERE LiefNr = 100);
DECLARE @InternLief int = (SELECT ID FROM Lief WHERE LiefNr = 250);

DECLARE @ABSProduct TABLE (
  ProductCode nchar(15) COLLATE Latin1_General_CS_AS
);

DECLARE @ArtikelOnlySMZL TABLE (
  ArtikelID int
);

DECLARE @ArtikelSMZLAlternative TABLE (
  ArtikelID int
);

DECLARE @ArtikelSMZLMain TABLE (
  ArtikelID int
);

INSERT INTO @ABSProduct
EXEC (N'SELECT * FROM OPENQUERY(ABS, N''SELECT CODE FROM product'');') AT [SVATWMENADVMIG1.SAL.CO.AT\ADVANTEX];

INSERT INTO @ArtikelOnlySMZL
SELECT Artikel.ID
FROM Artikel
WHERE EXISTS (
    SELECT ArtiLief.*
    FROM ArtiLief
    WHERE ArtiLief.ArtikelID = Artikel.ID
      AND ArtiLief.LiefID = @SMZLLief
  )
  AND NOT EXISTS (
    SELECT ArtiLief.*
    FROM ArtiLief
    WHERE ArtiLief.ArtikelID = Artikel.ID
      AND ArtiLief.LiefID != @SMZLLief
  )
  AND Artikel.ArtikelNr NOT IN (SELECT ProductCode FROM @ABSProduct);

INSERT INTO @ArtikelSMZLAlternative
SELECT Artikel.ID
FROM Artikel
WHERE EXISTS (
    SELECT ArtiLief.*
    FROM ArtiLief
    WHERE ArtiLief.ArtikelID = Artikel.ID
      AND ArtiLief.LiefID = @SMZLLief
  )
  AND EXISTS (
    SELECT ArtiLief.*
    FROM ArtiLief
    WHERE ArtiLief.ArtikelID = Artikel.ID
      AND ArtiLief.LiefID != @SMZLLief
  )
  AND Artikel.LiefID != @SMZLLief
  AND Artikel.ArtikelNr NOT IN (SELECT ProductCode FROM @ABSProduct);

INSERT INTO @ArtikelSMZLMain
SELECT Artikel.ID
FROM Artikel
WHERE EXISTS (
    SELECT ArtiLief.*
    FROM ArtiLief
    WHERE ArtiLief.ArtikelID = Artikel.ID
      AND ArtiLief.LiefID = @SMZLLief
  )
  AND EXISTS (
    SELECT ArtiLief.*
    FROM ArtiLief
    WHERE ArtiLief.ArtikelID = Artikel.ID
      AND ArtiLief.LiefID != @SMZLLief
  )
  AND Artikel.LiefID = @SMZLLief
  AND Artikel.ArtikelNr NOT IN (SELECT ProductCode FROM @ABSProduct);

UPDATE Artikel SET LiefID = @InternLief
WHERE ID IN (SELECT ArtikelID FROM @ArtikelOnlySMZL);
UPDATE ArtiLief SET LiefID = @InternLief
WHERE ArtikelID IN (SELECT ArtikelID FROM @ArtikelOnlySMZL);

DELETE FROM ArtiLief WHERE ArtikelID IN (SELECT ArtikelID FROM @ArtikelSMZLAlternative) AND LiefID = @SMZLLief;

UPDATE Artikel SET LiefID = @InternLief
WHERE ID IN (SELECT ArtikelID FROM @ArtikelSMZLMain);
MERGE ArtiLief
USING (
  SELECT ArtikelID
  FROM @ArtikelSMZLMain
) AS source (ArtikelID) ON source.ArtikelID = ArtiLief.ArtikelID
WHEN NOT MATCHED THEN
  INSERT (ArtikelID, LiefID) VALUES (source.ArtikelID, @InternLief);
DELETE FROM ArtiLief WHERE ArtikelID IN (SELECT ArtikelID FROM @ArtikelSMZLMain) AND LiefID = @SMZLLief;

SELECT N'OnlySMZL' AS Art, Artikel.ArtikelNr, Artikel.ArtikelBez
FROM @ArtikelOnlySMZL a
JOIN Artikel ON a.ArtikelID = Artikel.ID;

SELECT N'SMZLAlternative' AS Art, Artikel.ArtikelNr, Artikel.ArtikelBez
FROM @ArtikelSMZLAlternative a
JOIN Artikel ON a.ArtikelID = Artikel.ID;

SELECT N'SMZLMain' AS Art, Artikel.ArtikelNr, Artikel.ArtikelBez
FROM @ArtikelSMZLMain a
JOIN Artikel ON a.ArtikelID = Artikel.ID;
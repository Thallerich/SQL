/*
  DROP TABLE IF EXISTS Wozabal.dbo.__WJTeile;
*/

/*
  Table WJTeile: Chipcode, Bekleidungstyp, Größe, Länge, Bereich
  Table WJMapping: ArtikelBezAutomat, Größe, Länge, ArtikelBez, ArtikelNr, Groesse
*/

/*
  USE Wozabal_Test; EXEC sp_columns '__WJTeile';
  TRUNCATE TABLE Wozabal.dbo.__WJTeile;
  SELECT * FROM Wozabal.dbo.__WJTeile;
  SELECT * FROM Wozabal.dbo.__WJMapping;
  UPDATE Wozabal.dbo.__WJTeile SET Bereich = 1 WHERE Bereich IS NULL;

  SELECT * FROM Wozabal.dbo.__WJMapping WHERE ArtikelBezAutomat = N'Kasack grau AK';
  INSERT INTO Wozabal.dbo.__WJMapping VALUES (N'Kasack grau AK', N'62', N'N', N'Kasack Bozen grau //', N'203258101166', N'62-N');

  UPDATE Wozabal.dbo.__WJMapping SET ArtikelNr = N'141505983700' WHERE ArtikelNr = N'141505003700   ';
  UPDATE Wozabal.dbo.__WJMapping SET ArtikelNr = N'141505983701' WHERE ArtikelNr = N'141505003701   ';
  UPDATE Wozabal.dbo.__WJMapping SET ArtikelNr = N'141505983702' WHERE ArtikelNr = N'141505003702   ';
  UPDATE Wozabal.dbo.__WJMapping SET ArtikelNr = N'141505983703' WHERE ArtikelNr = N'141505003703   ';
  UPDATE Wozabal.dbo.__WJMapping SET ArtikelNr = N'141505983704' WHERE ArtikelNr = N'141505003704   ';
  UPDATE Wozabal.dbo.__WJMapping SET ArtikelNr = N'141505983705' WHERE ArtikelNr = N'141505003705   ';
  UPDATE Wozabal.dbo.__WJMapping SET ArtikelNr = N'141505983706' WHERE ArtikelNr = N'141505003706   ';
  UPDATE Wozabal.dbo.__WJMapping SET ArtikelNr = N'141505983707' WHERE ArtikelNr = N'141505003707   ';

  UPDATE Wozabal.dbo.__WJMapping SET ArtikelNr = N'141005983700' WHERE ArtikelNr = N'141005003700   ';
  UPDATE Wozabal.dbo.__WJMapping SET ArtikelNr = N'141005983701' WHERE ArtikelNr = N'141005003701   ';
  UPDATE Wozabal.dbo.__WJMapping SET ArtikelNr = N'141005983702' WHERE ArtikelNr = N'141005003702   ';
  UPDATE Wozabal.dbo.__WJMapping SET ArtikelNr = N'141005983703' WHERE ArtikelNr = N'141005003703   ';
  UPDATE Wozabal.dbo.__WJMapping SET ArtikelNr = N'141005983704' WHERE ArtikelNr = N'141005003704   ';
  UPDATE Wozabal.dbo.__WJMapping SET ArtikelNr = N'141005983705' WHERE ArtikelNr = N'141005003705   ';
  UPDATE Wozabal.dbo.__WJMapping SET ArtikelNr = N'141005983706' WHERE ArtikelNr = N'141005003706   ';
  UPDATE Wozabal.dbo.__WJMapping SET ArtikelNr = N'141005983707' WHERE ArtikelNr = N'141005003707   ';

  UPDATE Wozabal.dbo.__WJMapping SET Groesse = N'-' WHERE ArtikelBezAutomat = N'Bandzugh- blau';
  UPDATE Wozabal.dbo.__WJMapping SET Groesse = N'-' WHERE ArtikelBezAutomat = N'OP-HEMD BLAU';

  SELECT WJTeile.*
  FROM Wozabal.dbo.__WJTeile AS WJTeile
  LEFT OUTER JOIN Wozabal.dbo.__WJMapping AS WJMapping
    ON WJMapping.ArtikelBezAutomat = WJTeile.Bekleidungstyp
      AND ISNULL(WJTeile.Größe, '') = ISNULL(WJMapping.Größe, '')
      AND ISNULL(WJTeile.Länge, '') = ISNULL(WJMapping.Länge, '')
  WHERE WJMapping.ArtikelNr IS NULL;
*/

USE Wozabal
GO

DROP TABLE IF EXISTS #TmpWJ;

SELECT WJTeile.Chipcode, WJMapping.ArtikelNr, WJMapping.ArtikelBez, WJMapping.Groesse, WJTeile.Bereich
INTO #TmpWJ
FROM dbo.__WJTeile AS WJTeile, dbo.__WJMapping AS WJMapping
WHERE WJTeile.Bekleidungstyp = WJMapping.ArtikelBezAutomat
  AND ISNULL(WJTeile.Größe, '') = ISNULL(WJMapping.Größe, '')
  AND ISNULL(WJTeile.Länge, '') = ISNULL(WJMapping.Länge, '');

/* Check auf fehlende Kundenartikel
SELECT DISTINCT WJ.ArtikelNr, WJ.ArtikelBez
FROM #TmpWJ AS WJ
LEFT OUTER JOIN (
  SELECT Artikel.ArtikelNr, Artikel.ArtikelBez
  FROM KdArti, Artikel, Kunden
  WHERE KdArti.ArtikelID = Artikel.ID
    AND KdArti.KundenID = Kunden.ID
    AND Kunden.KdNr = 25005
) x ON x.ArtikelNr = WJ.ArtikelNr
WHERE x.ArtikelNr IS NULL
ORDER BY WJ.ArtikelBez;
*/

-- Bereits vorhandene Teile um * erweitern
/*
UPDATE Teile SET Teile.Barcode = RTRIM(Teile.Barcode) + '*', RentomatChip = NULL
WHERE Teile.Barcode IN (SELECT Chipcode COLLATE Latin1_General_CS_AS FROM #TmpWJ)
AND Teile.TraegerID NOT IN (8073238, 8073240);
*/

DECLARE @Bereich1 TABLE (Barcode nvarchar(33));

BEGIN TRANSACTION
  INSERT INTO TraeArti (VsaID, TraegerID, ArtGroeID, KdArtiID, Anlage_, Update_, AnlageUser_, User_)
  SELECT DISTINCT 6104051 AS VsaID, 8073238 AS TraegerID, ArtGroe.ID AS ArtGroeID, KdArti.ID AS KdArtiID, GETDATE() AS Anlage_, GETDATE() AS Update_, N'STHA' AS AnlageUser_, N'STHA' AS User_
  FROM #TmpWJ AS WJ, Artikel, KdArti, Kunden, ArtGroe
  WHERE UPPER(WJ.ArtikelNr) = UPPER(Artikel.ArtikelNr)
    AND KdArti.ArtikelID = Artikel.ID
    AND KdArti.KundenID = Kunden.ID
    AND ArtGroe.ArtikelID = Artikel.ID
    AND UPPER(ArtGroe.Groesse) = UPPER(WJ.Groesse)
    AND Kunden.KdNr = 25005
    AND WJ.Bereich = 1
    AND NOT EXISTS (SELECT TraeArti.* FROM TraeArti, KdArti, Artikel, ArtGroe WHERE TraeArti.KdArtiID = KdArti.ID AND KdArti.ArtikelID = Artikel.ID AND TraeArti.ArtGroeID = ArtGroe.ID AND UPPER(Artikel.ArtikelNr) = UPPER(WJ.ArtikelNr) COLLATE Latin1_General_CS_AS AND UPPER(ArtGroe.Groesse) = UPPER(WJ.Groesse) COLLATE Latin1_General_CS_AS AND TraeArti.TraegerID = 8073238);
    
  INSERT INTO Teile (Barcode, Status, VsaID, TraegerID, TraeArtiID, KdArtiID, ArtikelID, ArtGroeID, Entnommen, PatchDatum, Erstwoche, ErstDatum, Indienst, IndienstDat, RentomatChip, Anlage_, Update_, AnlageUser_, User_)
  OUTPUT INSERTED.Barcode INTO @Bereich1
  SELECT DISTINCT WJ.Chipcode AS Barcode, N'Q' AS Status, 6104051 AS VsaID, 8073238 AS TraegerID, TraeArti.ID AS TraeArtiID, KdArti.ID AS KdArtiID, Artikel.ID AS ArtikelID, ArtGroe.ID AS ArtGroeID, CONVERT(bit, 1) AS Entnommen, CONVERT(date, N'1980-01-01') AS PatchDatum, N'1980/01' AS ErstWoche, CONVERT(date, N'1980-01-01') AS ErstDatum, N'1980/01' AS Indienst, CONVERT(date, N'1980-01-01') AS IndienstDat, WJ.Chipcode AS RentomatChip, GETDATE() AS Anlage_, GETDATE() AS Update_, N'STHA' AS AnlageUser_, N'STHA' AS User_
  FROM #TmpWJ AS WJ, Artikel, KdArti, TraeArti, Kunden, ArtGroe
  WHERE UPPER(WJ.ArtikelNr) = UPPER(Artikel.ArtikelNr)
    AND KdArti.ArtikelID = Artikel.ID
    AND KdArti.KundenID = Kunden.ID
    AND TraeArti.KdArtiID = KdArti.ID
    AND TraeArti.ArtGroeID = ArtGroe.ID
    AND UPPER(ArtGroe.Groesse) = UPPER(WJ.Groesse)
    AND TraeArti.TraegerID = 8073238
    AND Kunden.KdNr = 25005
    AND WJ.Bereich = 1
    AND NOT EXISTS (SELECT Teile.* FROM Teile WHERE Teile.Barcode = WJ.Chipcode COLLATE Latin1_General_CS_AS); 
COMMIT;

SELECT N'Bereich1' AS Bereich, COUNT(*) AnzInserted FROM @Bereich1;
GO

DECLARE @Bereich2 TABLE (Barcode nvarchar(33));

BEGIN TRANSACTION
  INSERT INTO TraeArti (VsaID, TraegerID, ArtGroeID, KdArtiID, Anlage_, Update_, AnlageUser_, User_)
  SELECT DISTINCT 6104052 AS VsaID, 8073240 AS TraegerID, ArtGroe.ID AS ArtGroeID, KdArti.ID AS KdArtiID, GETDATE() AS Anlage_, GETDATE() AS Update_, N'STHA' AS AnlageUser_, N'STHA' AS User_
  FROM #TmpWJ AS WJ, Artikel, KdArti, Kunden, ArtGroe
  WHERE UPPER(WJ.ArtikelNr) = UPPER(Artikel.ArtikelNr)
    AND KdArti.ArtikelID = Artikel.ID
    AND KdArti.KundenID = Kunden.ID
    AND ArtGroe.ArtikelID = Artikel.ID
    AND UPPER(ArtGroe.Groesse) = UPPER(WJ.Groesse)
    AND Kunden.KdNr = 25005
    AND WJ.Bereich = 2
    AND NOT EXISTS (SELECT TraeArti.* FROM TraeArti, KdArti, Artikel, ArtGroe WHERE TraeArti.KdArtiID = KdArti.ID AND KdArti.ArtikelID = Artikel.ID AND TraeArti.ArtGroeID = ArtGroe.ID AND UPPER(Artikel.ArtikelNr) = UPPER(WJ.ArtikelNr) COLLATE Latin1_General_CS_AS AND UPPER(ArtGroe.Groesse) = UPPER(WJ.Groesse) COLLATE Latin1_General_CS_AS AND TraeArti.TraegerID = 8073240);

  INSERT INTO Teile (Barcode, Status, VsaID, TraegerID, TraeArtiID, KdArtiID, ArtikelID, ArtGroeID, Entnommen, PatchDatum, Erstwoche, ErstDatum, Indienst, IndienstDat, RentomatChip, Anlage_, Update_, AnlageUser_, User_)
  OUTPUT INSERTED.Barcode INTO @Bereich2
  SELECT DISTINCT WJ.Chipcode AS Barcode, N'Q' AS Status, 6104052 AS VsaID, 8073240 AS TraegerID, TraeArti.ID AS TraeArtiID, KdArti.ID AS KdArtiID, Artikel.ID AS ArtikelID, ArtGroe.ID AS ArtGroeID, CONVERT(bit, 1) AS Entnommen, CONVERT(date, N'1980-01-01') AS PatchDatum, N'1980/01' AS ErstWoche, CONVERT(date, N'1980-01-01') AS ErstDatum, N'1980/01' AS Indienst, CONVERT(date, N'1980-01-01') AS IndienstDat, WJ.Chipcode AS RentomatChip, GETDATE() AS Anlage_, GETDATE() AS Update_, N'STHA' AS AnlageUser_, N'STHA' AS User_
  FROM #TmpWJ AS WJ, Artikel, KdArti, TraeArti, Kunden, ArtGroe
  WHERE UPPER(WJ.ArtikelNr) = UPPER(Artikel.ArtikelNr)
    AND KdArti.ArtikelID = Artikel.ID
    AND KdArti.KundenID = Kunden.ID
    AND TraeArti.KdArtiID = KdArti.ID
    AND TraeArti.ArtGroeID = ArtGroe.ID
    AND UPPER(ArtGroe.Groesse) = UPPER(WJ.Groesse)
    AND TraeArti.TraegerID = 8073240
    AND Kunden.KdNr = 25005
    AND WJ.Bereich = 2
    AND NOT EXISTS (SELECT Teile.* FROM Teile WHERE Teile.Barcode = WJ.Chipcode COLLATE Latin1_General_CS_AS); 
COMMIT;

SELECT N'Bereich2' AS Bereich, COUNT(*) AnzInserted FROM @Bereich2;
GO
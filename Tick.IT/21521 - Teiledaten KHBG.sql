USE Wozabal
GO

DECLARE RwTeile CURSOR FOR
  SELECT OPTeile.ID AS OPTeileID
  FROM OPTeile
  JOIN Vsa ON OPTeile.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
  JOIN Bereich ON Artikel.BereichID = Bereich.ID
  JOIN Holding ON Kunden.HoldingID = Holding.ID
  WHERE Holding.Holding LIKE N'KHBG%'
  AND OPTeile.Status < N'Z'
  AND OPTeile.RechPoID < 0
  AND Bereich.Bereich <> N'OP';

DECLARE @AddCondition nvarchar(max);
DECLARE @RwConfigID integer;
DECLARE @RwArt integer = 1;
DECLARE @SetAusdRestwert bit = 0;

DECLARE @RwTeileID integer;

OPEN RwTeile;

FETCH NEXT FROM RwTeile
INTO @RwTeileID;

WHILE @@FETCH_STATUS = 0
BEGIN
  SET @AddCondition = N'OPTeile.ID = ' + CAST(@RwTeileID AS varchar);
  SET @RwConfigID = (SELECT Kunden.RwPoolTeileConfigID FROM OPTeile JOIN Vsa ON OPTeile.VsaID = Vsa.ID JOIN Kunden ON Vsa.KundenID = Kunden.ID WHERE OPTeile.ID = @RwTeileID)
  
  EXECUTE procOPTeileCalculateRestWerte @AddCondition, @RwConfigID, @RwArt, @SetAusdRestwert;

  FETCH NEXT FROM RwTeile
  INTO @RwTeileID;
END

CLOSE RwTeile;
DEALLOCATE RwTeile;

SELECT OPTeile.Code AS Chipcode, Status.StatusBez AS Teilestatus, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Bereich.BereichBez AS Produktbereich, Kunden.KdNr, Kunden.SuchCode AS Kunde, OPTeile.RestwertInfo AS RestwertAktuell, OPTeile.EkGrundAkt AS [EK-Preis aktuell], OPTeile.AlterInfo AS [Alter in Wochen], FORMAT(OPTeile.LastScanTime, 'G', 'de-AT') AS [zuletzt gesehen]
FROM OPTeile
JOIN Vsa ON OPTeile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Status ON OPTeile.Status = Status.Status AND Status.Tabelle = N'OPTEILE'
WHERE Holding.Holding LIKE N'KHBG%'
AND OPTeile.Status < N'Z'
AND OPTeile.RechPoID < 0
AND Bereich.Bereich <> N'OP';

GO
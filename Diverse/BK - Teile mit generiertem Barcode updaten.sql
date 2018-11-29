DROP TABLE IF EXISTS #TeileUpdate;
GO

SET NOCOUNT ON;

DECLARE @TeileID int;
DECLARE @UebernahmeCode nvarchar(33);
DECLARE @Barcode varchar(33);

DECLARE @cursorend bit = 0;

DECLARE curTeile CURSOR FOR
SELECT Teile.ID AS TeileID, Teile.Barcode AS UebernahmeCode
FROM Teile
JOIN Vsa ON Teile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.KdNr IN (11100, 11101, 11102, 13430, 19021, 19055, 19056, 19057, 19058, 19059)
  AND Teile.AltenheimModus = 0
  AND Teile.AnlageUserID_ = 9245;

DECLARE curBarcode CURSOR FOR
SELECT Teile.Barcode
FROM Wozabal_Test.dbo.Teile
WHERE Teile.TraeArtiID = 20470314
  AND Teile.AnlageUserID_ = 9245;

CREATE TABLE #TeileUpdate (
  TeileID int,
  Barcode varchar(33),
  UebernahmeCode nvarchar(33)
);

OPEN curTeile;
OPEN curBarcode;

FETCH NEXT FROM curTeile INTO @TeileID, @UebernahmeCode;
IF @@FETCH_STATUS <> 0 SET @cursorend = 1;
FETCH NEXT FROM curBarcode INTO @Barcode;
IF @@FETCH_STATUS <> 0 SET @cursorend = 1;

WHILE @cursorend = 0
BEGIN
  INSERT INTO #TeileUpdate VALUES (@TeileID, @Barcode, @UebernahmeCode);

  FETCH NEXT FROM curTeile INTO @TeileID, @UebernahmeCode;
  IF @@FETCH_STATUS <> 0 SET @cursorend = 1;
  FETCH NEXT FROM curBarcode INTO @Barcode;
  IF @@FETCH_STATUS <> 0 SET @cursorend = 1;
END;

CLOSE curTeile;
CLOSE curBarcode;

DEALLOCATE curTeile;
DEALLOCATE curBarcode;

SET NOCOUNT OFF;

UPDATE Teile SET Teile.Barcode = TeileUpdate.Barcode, Teile.UebernahmeCode = Teile.Barcode
FROM Teile
JOIN #TeileUpdate AS TeileUpdate ON TeileUpdate.TeileID = Teile.ID;

GO
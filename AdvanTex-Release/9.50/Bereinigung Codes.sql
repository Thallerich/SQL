DROP TABLE IF EXISTS #t;
GO

SELECT TeileLag.ID TeileLagID, TeileLag.Status TeileLagStatus, Teile.ID TeileID, Teile.Status TeileStatus, Teile.RentomatChip, Teile.Barcode TeileBarcode, TeileLag.Barcode TeileLagBarcode
INTO #t
FROM TeileLag, Teile 
WHERE Teile.RentomatChip = TeileLag.Code2;

delete from #t where TeileBarcode = TeileLagBarcode;

GO

-- SELECT * FROM #t

UPDATE TeileLag SET Code2 = NULL
WHERE ID IN (
  SELECT TeileLagID
  FROM #t 
  WHERE TeileStatus < 'X' 
  AND TeileStatus > 'K')

-- xxx TempTable neu aufbauen xxx

UPDATE TeileLag SET Code2 = NULL
WHERE ID IN (
  SELECT TeileLagID 
  FROM #t 
  WHERE TeileLagStatus = 'Y')  

-- xxx TempTable neu aufbauen xxx
  
UPDATE Teile
SET RentomatChip = NULL   
WHERE ID IN (
  SELECT TeileID 
  FROM #t 
  WHERE TeileLagStatus = 'Z'
  AND TeileStatus = 'Z');  
 
UPDATE TeileLag
SET Code2 = NULL   
WHERE ID IN (
  SELECT TeileLagID 
  FROM #t 
  WHERE TeileLagStatus = 'Z'
  AND TeileStatus = 'Z')

-- xxx TempTable neu aufbauen xxx
 
UPDATE Teile SET RentomatChip = NULL
WHERE ID IN (
  SELECT TeileID
  FROM #t 
  WHERE TeileStatus <= 'K')

-- xxx TempTable neu aufbauen xxx
  
UPDATE Teile SET RentomatChip = NULL
WHERE ID IN (
  SELECT TeileID
  FROM #t 
  WHERE TeileStatus in ('X','XM','Y'))
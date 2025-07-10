SET NOCOUNT ON;

DECLARE @RequestXML nvarchar(max);
DECLARE @XMLHandle int;
DECLARE @MinLagerBewID int = (SELECT CAST(ValueMemo AS int) FROM Settings WHERE Parameter = 'LAST_LAGERBEWID_TO_SAP');

/* DROP TABLE #StockTransaction; */
IF OBJECT_ID(N'tempdb..#StockTransaction') IS NULL
  CREATE TABLE #StockTransaction (
    TransactionID int
  );
ELSE
  TRUNCATE TABLE #StockTransaction;

INSERT INTO #StockTransaction (TransactionID)
SELECT CAST(SUBSTRING(HTTPRequest, CHARINDEX(N'<TransactionID>', HTTPRequest, 1) + 15, 8) AS int) AS TransactionID
FROM SalExLog
WHERE SalExLog.FunctionName = N'StockTransaction'
  AND SalExLog.Anlage_ > CAST(N'2022-04-01 00:00:00' AS datetime2);

IF OBJECT_ID(N'dbo.__LagerBewManuell') IS NULL
  CREATE TABLE __LagerBewManuell (
    ID int PRIMARY KEY
  );
ELSE
  TRUNCATE TABLE __LagerBewManuell;

INSERT INTO __LagerBewManuell (ID)
SELECT LagerBew.ID
FROM LagerBew, Bestand, LagerArt, Standort, LgBewCod, Firma
WHERE LagerBew.BestandID = Bestand.ID
  AND Bestand.LagerArtID = LagerArt.ID
  AND LagerArt.LagerID = Standort.ID
  AND LagerBew.LgBewCodID = LgBewCod.ID
  AND Lagerart.FirmaID = Firma.ID
  AND (Firma.SuchCode = N'FA14' OR Firma.SuchCode = N'BUDA')
  AND (LagerArt.ArtiTypeID = 1 OR (Lagerart.ArtiTypeID = 3 AND (Standort.SuchCode = N'SMZL' OR Firma.SuchCode = N'BUDA')))
  AND LgBewCod.Code != N'IN??'
  AND LagerBew.Differenz != 0
  AND LagerBew.ID <= @MinLagerBewID
  AND LagerBew.Zeitpunkt > CAST(N'2022-04-25 00:00:00' AS datetime2)
  AND LagerBew.AnlageUserID_ != (SELECT ID FROM Mitarbei WHERE UserName = N'ADVSUP')
  AND Standort.SuchCode = N'SMZL'
  AND LagerBew.ID NOT IN (
    SELECT TransactionID FROM #StockTransaction
  );

SELECT COUNT(*) FROM __LagerBewManuell;
SELECT COUNT(*) FROM #StockTransaction;
SELECT @MinLagerBewID;

-- UPDATE Settings SET ValueMemo = N'1' WHERE Parameter = N'LAST_LAGERBEWID_TO_SAP';
-- UPDATE Settings SET ValueMemo = N'29905890' WHERE Parameter = N'LAST_LAGERBEWID_TO_SAP';

-- DROP TABLE __LagerBewManuell;
-- DROP TABLE __LagerBewToSAP;
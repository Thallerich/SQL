DROP TABLE IF EXISTS _LagerBewBUDARetransfer;
GO

DECLARE @StockTransaction TABLE (
  ID int PRIMARY KEY NOT NULL
);

/* Liste der SAP-seitig fehlenden ID's */
INSERT INTO @StockTransaction (ID)
VALUES (29744453), (27377224), (27780493), (27852699), (27852702), (27852703), (27852704), (27852707), (27852708), (28057892), (28171740), (28452692), (28684839), (29206965), (27376064), (27376250), (27382673), (27376490), (27376552), (27622351), (27622354), (28113089), (28684843), (27376127), (27781506), (27781507), (27818176), (27818271), (27822937), (27379670), (27808693), (27844425), (27844428), (27377006), (27382268), (30570514), (27382216), (27377011), (28123836), (27377062), (27381970), (27381822), (27380220), (27379154), (27375193), (27381018), (27376147), (27377482), (27622339), (27622342), (27382084), (27382126), (28113090), (29040131), (27375570), (27376046), (27377856), (27382052), (27377238), (27374302), (27379274), (27378608), (27380062), (27382893);

/* Initialisierungsbuchungen auswerten */

/* SELECT [@StockTransaction].ID AS StockTransactionID, LagerBew.Zeitpunkt, Lagerart.Lagerart, Lagerart.LagerartBez AS [Lagerart-Bezeichnung], LgBewCod.Code, LgBewCod.LgBewCodBez AS Lagerbewegungscode, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, LagerBew.BestandNeu - LagerBew.Differenz AS [Bestand alt], LagerBew.Differenz, LagerBew.BestandNeu AS [Bestand neu]
FROM @StockTransaction
JOIN LagerBew ON [@StockTransaction].ID = LagerBew.ID
JOIN Bestand ON LagerBew.BestandID = Bestand.ID
JOIN Lagerart ON Bestand.LagerartID = Lagerart.ID
JOIN Standort AS Lager ON Lagerart.LagerID = Lager.ID
JOIN LgBewCod ON LagerBew.LgBewCodID = LgBewCod.ID
JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
WHERE LgBewCod.Code = N'IN??'; */

/* Alle anderen Buchungen auswerten */

/* SELECT [@StockTransaction].ID AS StockTransactionID, LagerBew.Zeitpunkt, Lagerart.Lagerart, Lagerart.LagerartBez AS [Lagerart-Bezeichnung], LgBewCod.Code, LgBewCod.LgBewCodBez AS Lagerbewegungscode, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, LagerBew.BestandNeu - LagerBew.Differenz AS [Bestand alt], LagerBew.Differenz, LagerBew.BestandNeu AS [Bestand neu]
FROM @StockTransaction
JOIN LagerBew ON [@StockTransaction].ID = LagerBew.ID
JOIN Bestand ON LagerBew.BestandID = Bestand.ID
JOIN Lagerart ON Bestand.LagerartID = Lagerart.ID
JOIN Standort AS Lager ON Lagerart.LagerID = Lager.ID
JOIN LgBewCod ON LagerBew.LgBewCodID = LgBewCod.ID
JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
WHERE LgBewCod.Code != N'IN??'
ORDER BY Zeitpunkt DESC;

/* Check Schnittstellen-Log zu fehlenden ID's */

/* SELECT CAST(SUBSTRING(HTTPRequest, CHARINDEX(N'<TransactionID>', HTTPRequest, 1) + 15, 8) AS int) AS TransactionID, SalExLog.Anlage_ AS [Zeitpunkt Übertragung an SAP], SalExLog.HTTPRequest, SalExlog.ResponseSuccessful, SalExLog.ResponseReturnDescriptio
FROM SalExLog
WHERE SalExLog.FunctionName = N'StockTransaction'
  AND SalExlog.Anlage_ > N'2022-03-11 00:00:00'
  AND CAST(SUBSTRING(HTTPRequest, CHARINDEX(N'<TransactionID>', HTTPRequest, 1) + 15, 8) AS int) IN (SELECT ID FROM @StockTransaction); */

/* Fehlerhafte ID's zur nochmaligen Übertragung in Hilfstabelle - Modulaufruf AdvanTex zur Übertragung: SAPSENDSTOCKTRANSACTION;-1;__LagerBewHW;0;_LagerBewBUDARetransfer */

/* SELECT DISTINCT CAST(SUBSTRING(HTTPRequest, CHARINDEX(N'<TransactionID>', HTTPRequest, 1) + 15, 8) AS int) AS ID
INTO _LagerBewBUDARetransfer
FROM SalExLog
WHERE SalExLog.FunctionName = N'StockTransaction'
  AND SalExlog.Anlage_ > N'2022-03-11 00:00:00'
  AND CAST(SUBSTRING(HTTPRequest, CHARINDEX(N'<TransactionID>', HTTPRequest, 1) + 15, 8) AS int) IN (SELECT ID FROM @StockTransaction); */

/* Auswertung Fehlerprotokoll nach nochmaliger Übertragung */

SELECT CAST(SUBSTRING(HTTPRequest, CHARINDEX(N'<TransactionID>', HTTPRequest, 1) + 15, 8) AS int) AS TransactionID, SalExLog.Anlage_ AS [Zeitpunkt Übertragung an SAP], SalExLog.HTTPRequest, SalExlog.ResponseSuccessful, SalExLog.ResponseReturnDescriptio
FROM SalExLog
WHERE SalExLog.FunctionName = N'StockTransaction'
  AND SalExlog.Anlage_ > N'2023-01-18 00:00:00'
  AND SalExLog.AnlageUserID_ = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

GO
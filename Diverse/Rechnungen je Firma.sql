USE Wozabal
GO

SELECT Firma.Bez AS Firma, Kunden.SuchCode + ' (' + CAST(Kunden.KdNr AS nvarchar(10)) + ')' AS Kunde, RechKo.RechNr, FORMAT(RechKo.RechDat, 'd', 'de-AT') AS Rechnungsdatum, FORMAT(RechKo.BruttoWert, '#.## €', 'de-AT') AS Bruttobetrag, FORMAT(RechKo.NettoWert, '#.## €', 'de-AT') AS Nettobetrag, FORMAT(RechKo.MwStBetrag, '#.## €', 'de-AT') AS MwStBetrag, FORMAT(RechKo.Druckdatum, 'd', 'de-At') AS Ausgabedatum, FORMAT(FibuExp.Zeitpunkt, 'd', 'de-AT') AS [FIBU-Übergabe]
FROM RechKo
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN FibuExp ON RechKo.FibuExpID = FibuExp.ID
WHERE RechKo.RechDat = N'2017-07-31'
AND RechKo.Status BETWEEN N'F' AND N'S'
AND Firma.SuchCode IN (N'31')
ORDER BY Ausgabedatum ASC

SELECT Firma.Bez AS Firma, Kunden.SuchCode + ' (' + CAST(Kunden.KdNr AS nvarchar(10)) + ')' AS Kunde, RechKo.RechNr, FORMAT(RechKo.RechDat, 'd', 'de-AT') AS Rechnungsdatum, FORMAT(RechKo.BruttoWert, '#.## €', 'de-AT') AS Bruttobetrag, FORMAT(RechKo.NettoWert, '#.## €', 'de-AT') AS Nettobetrag, FORMAT(RechKo.MwStBetrag, '#.## €', 'de-AT') AS MwStBetrag, FORMAT(RechKo.Druckdatum, 'd', 'de-At') AS Ausgabedatum, FORMAT(FibuExp.Zeitpunkt, 'd', 'de-AT') AS [FIBU-Übergabe]
FROM RechKo
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN FibuExp ON RechKo.FibuExpID = FibuExp.ID
WHERE RechKo.RechDat = N'2017-07-31'
AND RechKo.Status BETWEEN N'F' AND N'S'
AND Firma.SuchCode IN (N'12')
ORDER BY Ausgabedatum ASC

SELECT Firma.Bez AS Firma, Kunden.SuchCode + ' (' + CAST(Kunden.KdNr AS nvarchar(10)) + ')' AS Kunde, RechKo.RechNr, FORMAT(RechKo.RechDat, 'd', 'de-AT') AS Rechnungsdatum, FORMAT(RechKo.BruttoWert, '#.## €', 'de-AT') AS Bruttobetrag, FORMAT(RechKo.NettoWert, '#.## €', 'de-AT') AS Nettobetrag, FORMAT(RechKo.MwStBetrag, '#.## €', 'de-AT') AS MwStBetrag, FORMAT(RechKo.Druckdatum, 'd', 'de-At') AS Ausgabedatum, FORMAT(FibuExp.Zeitpunkt, 'd', 'de-AT') AS [FIBU-Übergabe]
FROM RechKo
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN FibuExp ON RechKo.FibuExpID = FibuExp.ID
WHERE RechKo.RechDat = N'2017-07-31'
AND RechKo.Status BETWEEN N'F' AND N'S'
AND Firma.SuchCode IN (N'21')
ORDER BY Ausgabedatum ASC

SELECT Firma.Bez AS Firma, Kunden.SuchCode + ' (' + CAST(Kunden.KdNr AS nvarchar(10)) + ')' AS Kunde, RechKo.RechNr, FORMAT(RechKo.RechDat, 'd', 'de-AT') AS Rechnungsdatum, FORMAT(RechKo.BruttoWert, '#.## €', 'de-AT') AS Bruttobetrag, FORMAT(RechKo.NettoWert, '#.## €', 'de-AT') AS Nettobetrag, FORMAT(RechKo.MwStBetrag, '#.## €', 'de-AT') AS MwStBetrag, FORMAT(RechKo.Druckdatum, 'd', 'de-At') AS Ausgabedatum, FORMAT(FibuExp.Zeitpunkt, 'd', 'de-AT') AS [FIBU-Übergabe]
FROM RechKo
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN FibuExp ON RechKo.FibuExpID = FibuExp.ID
WHERE RechKo.RechDat = N'2017-07-31'
AND RechKo.Status BETWEEN N'F' AND N'S'
AND Firma.SuchCode IN (N'41')
ORDER BY Ausgabedatum ASC

SELECT Firma.Bez AS Firma, Kunden.SuchCode + ' (' + CAST(Kunden.KdNr AS nvarchar(10)) + ')' AS Kunde, RechKo.RechNr, FORMAT(RechKo.RechDat, 'd', 'de-AT') AS Rechnungsdatum, FORMAT(RechKo.BruttoWert, '#.## €', 'de-AT') AS Bruttobetrag, FORMAT(RechKo.NettoWert, '#.## €', 'de-AT') AS Nettobetrag, FORMAT(RechKo.MwStBetrag, '#.## €', 'de-AT') AS MwStBetrag, FORMAT(RechKo.Druckdatum, 'd', 'de-At') AS Ausgabedatum, FORMAT(FibuExp.Zeitpunkt, 'd', 'de-AT') AS [FIBU-Übergabe]
FROM RechKo
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN FibuExp ON RechKo.FibuExpID = FibuExp.ID
WHERE RechKo.RechDat = N'2017-07-31'
AND RechKo.Status BETWEEN N'F' AND N'S'
AND Firma.SuchCode IN (N'81')
ORDER BY Ausgabedatum ASC

GO
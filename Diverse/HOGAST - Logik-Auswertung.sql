SELECT Holding.Holding, Holding.Bez, Firma.SuchCode AS Firma, Firma.Bez AS Firmenbezeichnung, N'edi.hgp@hogast.at' AS Ziel
FROM Holding
CROSS JOIN Firma
WHERE (Holding.ID = 9815 AND Firma.ID IN (5001, 5259, 5260))
UNION ALL
SELECT Holding.Holding, Holding.Bez, Firma.SuchCode AS Firma, Firma.Bez AS Firmenbezeichnung, N'edifact@hogast.at' AS Ziel
FROM Holding
CROSS JOIN Firma
WHERE (Holding.ID = 16 AND Firma.ID IN (5001, 5259, 5260))
UNION ALL
SELECT Holding.Holding, Holding.Bez, Firma.SuchCode AS Firma, Firma.Bez AS Firmenbezeichnung, N'edi.handover@hogast.at' AS Ziel
FROM Holding
CROSS JOIN Firma
WHERE (Holding.ID = 1269 AND Firma.ID = 5259)
  OR (Holding.ID = 1367 AND Firma.ID IN (5001, 5259, 5260))
  OR (Holding.ID = 1274 AND Firma.ID = 5260)
  OR (Holding.ID = 1324 AND Firma.ID = 5259)
UNION ALL
SELECT DISTINCT Holding.Holding, Holding.Bez AS Holdingbezeichnung, Firma.SuchCode AS Firma, Firma.Bez AS Firmenbezeichnung, N'https://er.bbg.gv.at/erel/ports/soappost.php?wsdl' AS Ziel
FROM Kunden
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
WHERE (Holding.Holding LIKE 'SZL%' OR Holding.Holding LIKE 'MASR%')
  AND Kunden.Status = N'A'
UNION ALL
SELECT DISTINCT Holding.Holding, Holding.Bez AS Holdingbezeichnung, Firma.SuchCode AS Firma, Firma.Bez AS Firmenbezeichnung, N'https://er.bbg.gv.at/erel/ports/soappost.php?wsdl' AS Ziel
FROM Kunden
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
WHERE Holding.Holding LIKE 'BH K%'
  AND Kunden.Status = N'A';

SELECT Kunden.KdNr, Kunden.SuchCode AS Kundenstichwort, Kunden.Debitor, N'https://txm.portal.at/at.gv.bmf.erb/V2' AS Ziel
FROM Kunden
WHERE Kunden.KdNr IN (2520328, 2522381, 2520386, 2520538, 2522059, 30292 , 30409 , 247600 , 247555 , 249091 , 293542 , 292110 , 293310)
  AND Kunden.Status = N'A';
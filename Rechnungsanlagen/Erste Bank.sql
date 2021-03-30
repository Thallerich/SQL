DECLARE @RechKoID int = $RECHKOID$;

SELECT ROW_NUMBER() OVER (ORDER BY RechPo.AbteilID, RechPo.BereichID, RechPo.RPoTypeID) AS Position, FORMAT(RechKo.RechDat, N'yyyyMMdd', N'de-AT') AS Rechnungsdatum, RechKo.RechNr AS Rechnungsnummer, RechKo.BruttoWert AS Rechnungssumme, RechPo.GPreis AS Positionsbetrag, Abteil.Bez AS Kostenstellenbezeichnung
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Abteil ON RechPo.AbteilID = Abteil.ID
WHERE RechKo.ID = @RechKoID

UNION ALL

SELECT TOP 1 9999999 AS Position, FORMAT(RechKo.RechDat, N'yyyyMMdd', N'de-AT') AS Rechnungsdatum, RechKo.RechNr AS Rechnungsnummer, RechKo.BruttoWert AS Rechnungssumme, RechKo.MwStBetrag AS Positionsbetrag, Abteil.Bez AS Kostenstellenbezeichnung
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Abteil ON RechPo.AbteilID = Abteil.ID
WHERE RechKo.ID = @RechKoID
ORDER BY Position ASC;
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Teile.Barcode, Touren.Tour AS [Ausliefertour], Prod.EinDat AS [Eingangsdatum], Prod.AusDat AS [Ausgangsdatum], Produktion.SuchCode AS Produktion, SdcDev.Bez AS Sortieranlage
FROM Prod
JOIN Teile ON Prod.TeileID = Teile.ID
JOIN Vsa ON Prod.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Touren ON Prod.AusTourID = Touren.ID
JOIN Standort AS Produktion ON Prod.ProduktionID = Produktion.ID
JOIN KdArti ON Prod.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
LEFT JOIN StBerSDC ON StBerSDC.StandBerID = StandBer.ID
LEFT JOIN SdcDev ON StBerSDC.SdcDevID = SdcDev.ID
WHERE Touren.Tour LIKE N'_-12018';

GO
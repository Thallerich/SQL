USE Wozabal
GO

UPDATE Vsa SET AnfKoLiefDatSchliessen = 1
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN ServType ON Vsa.ServTypeID = ServType.ID
WHERE Kunden.KdNr IN (2301, 19090, 26010, 26015, 26020)
AND ServType.Bez = N'Expedition GP Enns'
AND Vsa.Status = N'A'
AND Vsa.AnfKoLiefDatSchliessen = 0

GO
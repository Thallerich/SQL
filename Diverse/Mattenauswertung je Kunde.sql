DECLARE @Week nchar(7) = (SELECT Week.Woche FROM Week WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat);

SELECT Standort.Bez AS Produktionsstandort, Kunden.KdNr, Kunden.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez, SUM(VsaLeas.Menge) AS Menge
FROM VsaLeas
JOIN Vsa ON VsaLeas.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON VsaLeas.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND StandBer.BereichID = KdBer.BereichID
JOIN Standort ON StandBer.ProduktionID = Standort.ID
WHERE StandBer.ProduktionID IN (SELECT ID FROM Standort WHERE SuchCode IN (N'SMS', N'WOBH', N'WOL1'))
  AND KdBer.BereichID = (SELECT ID FROM Bereich WHERE Bereich = N'MA')
  AND @Week BETWEEN VsaLeas.InDienst AND ISNULL(VsaLeas.AusDienst, N'2099/52')
GROUP BY Standort.Bez, Kunden.KdNr, Kunden.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez;
SELECT Firma.SuchCode AS FirmenNr, Firma.Bez AS Firma, Kunden.KdNr, Kunden.Debitor, Kunden.SuchCode AS Kunde,BRLauf.BrLaufBez AS Berechnungslauf ,Standort.Bez AS Kundenstandort, KdGf.KurzBez AS Geschäftsbereich, RKoType.RKoTypeBez AS Rechnungstyp, RechKo.Art, RechKo.RechNr, RechKo.RechDat AS Rechnungsdatum, RechKo.BruttoWert AS Brutto, RechKo.NettoWert AS Netto, RechKo.MwStBetrag AS MwSt, RechKo.SkontoBetrag AS Skonto
FROM Salesianer_Test.dbo.RechKo
JOIN Salesianer_Test.dbo.Kunden ON RechKo.KundenID = Kunden.ID
JOIN Salesianer_Test.dbo.Firma ON Kunden.FirmaID = Firma.ID
JOIN Salesianer_Test.dbo.KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Salesianer_Test.dbo.Standort ON Kunden.StandortID = Standort.ID
JOIN Salesianer_Test.dbo.RKoType ON RechKo.RKoTypeID = RKoType.ID
JOIN Salesianer_Test.dbo.DrLauf ON RechKo.DrLaufID = DrLauf.ID
JOIN Salesianer_Test.dbo.BrLauf ON Kunden.BrLaufID = BrLauf.ID
  AND Firma.SuchCode = N'FA14'
  AND RechKo.RechDat IS NULL
  AND RechKo.RechNr < 0
  AND RechKo.Status < N'X'   -- nicht storniert oder ignoriert
ORDER BY Kunden.KdNr;
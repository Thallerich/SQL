SELECT Firma.SuchCode AS Firma, Holding.Holding, [Zone].ZonenCode AS Vertriebszone, Kunden.KdNr, Kunden.SuchCode AS Kunde, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Abteil.ID AS AbteilID, Kunden.ID AS KundenID, [Rechnungsempfänger] =
  CASE Abteil.Code
    WHEN N'K' THEN N'Sammelrechnung an Kundenadresse' 
    WHEN N'A' THEN N'Einzelrechnung an Kundenadresse' 
    WHEN N'V' THEN N'Sammelrechnung an eine Versandanschrift' 
    WHEN N'R' THEN N'Sammelrechnung an separate Rechnungsadresse' 
    WHEN N'S' THEN N'Einzelrechnung an separate Rechnungsadresse'
  END
FROM Abteil
JOIN Kunden ON Abteil.KundenID = Kunden.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
WHERE ASCII(Abteil.Code) IN ($1$)
  AND Kunden.AdrArtID = 1
  AND Kunden.Status = N'A'
  AND Abteil.Status = N'A'
  AND Kunden.SichtbarID IN ($SICHTBARIDS$);
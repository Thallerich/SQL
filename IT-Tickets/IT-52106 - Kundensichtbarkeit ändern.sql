DECLARE @SichtbarID int = (SELECT ID FROM Sichtbar WHERE Bez = N'Österreich');

DECLARE @SichtbarOld TABLE (
  ID int,
  SichtbarID int
);

UPDATE Kunden SET SichtbarID = @SichtbarID
OUTPUT deleted.ID, deleted.SichtbarID
INTO @SichtbarOld (ID, SichtbarID)
FROM Kunden
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Sichtbar ON Kunden.SichtbarID = Sichtbar.ID
WHERE Firma.SuchCode = N'FA14'
  AND Kunden.AdrArtID = 1
  AND Sichtbar.Bez NOT IN (N'Österreich', N'Bratislava AT', N'Gasser');

SELECT Kunden.ID AS KundenID, Kunden.KdNr, Kunden.SuchCode AS Kunde, Firma.SuchCode AS Firma, Sichtbar.Bez AS [Sichtbarkeit bisher]
FROM @SichtbarOld AS SO
JOIN Kunden ON SO.ID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Sichtbar ON SO.SichtbarID = Sichtbar.ID;
DECLARE @Changed TABLE (
  KundenID int,
  VerwendID_old int,
  VerwendID_new int
);

--SELECT Verwend.VerwendBez AS Verwendungsregel, Kunden.KdNr, Kunden.SuchCode AS Kunde, Standort.Bez AS Hauptstandort
UPDATE Kunden SET VerwendID = 1
OUTPUT inserted.ID, deleted.VerwendID, inserted.VerwendID
INTO @Changed
FROM Kunden
JOIN Verwend ON Kunden.VerwendID = Verwend.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
WHERE Kunden.FirmaID = (SELECT ID FROM Firma WHERE SuchCode = N'SAL')
  AND Kunden.VerwendID <> 1
  AND Kunden.AdrArtID = 1;

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Verwend_old.VerwendBez AS [Verwendungsregel bisher], Verwend_new.VerwendBez AS [Verwendungsregel neu]
FROM @Changed AS Changed
JOIN Kunden ON Changed.KundenID = Kunden.ID
JOIN Verwend AS Verwend_old ON Changed.VerwendID_old = Verwend_old.ID
JOIN Verwend AS Verwend_new ON Changed.VerwendID_new = Verwend_new.ID;
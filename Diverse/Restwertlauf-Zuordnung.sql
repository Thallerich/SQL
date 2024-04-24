DECLARE @RwLauf TABLE (
  RwLaufBez nvarchar(40) COLLATE Latin1_General_CS_AS,
  RwLaufID int,
  FirmaID int
);

DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

INSERT INTO @RwLauf (RwLaufBez, FirmaID)
SELECT DISTINCT N'RW-Lauf Firma: ' + Firma.SuchCode AS RwLaufBez, Firma.ID AS FirmaID
FROM Kunden
JOIN Firma ON Kunden.FirmaID = Firma.ID
WHERE Kunden.RWLaufID = -1
  AND Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1
  AND Kunden.ID > 0;

UPDATE r SET RwLaufID = RwLauf.ID
FROM @RwLauf AS r
JOIN RwLauf ON RwLauf.RWLaufBez = r.RwLaufBez;

BEGIN TRANSACTION
  INSERT INTO RwLauf (RWLaufBez, RWLaufBez1, RWLaufBez2, RWLaufBez3, RWLaufBez4, RWLaufBez5, RWLaufBez6, RWLaufBez7, RWLaufBez8, RWLaufBez9, RWLaufBezA, AnlageUserID_, UserID_)
  SELECT RwLaufBez, RwLaufBez, RwLaufBez, RwLaufBez, RwLaufBez, RwLaufBez, RwLaufBez, RwLaufBez, RwLaufBez, RwLaufBez, RwLaufBez, @UserID, @UserID
  FROM @RwLauf
  WHERE RwLaufID IS NULL;

  UPDATE r SET RwLaufID = RwLauf.ID
  FROM @RwLauf AS r
  JOIN RwLauf ON RwLauf.RWLaufBez = r.RwLaufBez
  WHERE RwLaufID IS NULL;

  UPDATE Kunden SET RwLaufID = r.RwLaufID
  FROM @RwLauf AS r
  WHERE r.FirmaID = Kunden.FirmaID
    AND Kunden.RWLaufID = -1
    AND Kunden.Status = N'A'
    AND Kunden.AdrArtID = 1
    AND Kunden.ID > 0;

COMMIT;

GO
DECLARE @Customer TABLE (
  CustomerID int
);

DECLARE @Wearer TABLE (
  VsaID int,
  TraegerID int
);

DECLARE @MoveParts TABLE (
  TeileID int,
  KdArtiID int,
  ArtGroeID int,
  MoveToVsaID int
);

DECLARE @UserID int = (SELECT Mitarbei.ID FROM Mitarbei WHERE Mitarbei.UserName = N'THALST');

INSERT INTO @Customer (CustomerID)
VALUES (2938677), (2938678), (2938681), (2938713), (2938729);

INSERT INTO @Wearer (VsaID, TraegerID)
SELECT Traeger.VsaID, Traeger.ID
FROM Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.ID IN (
    SELECT CustomerID
    FROM @Customer
  )
  AND Traeger.Traeger = N'0000';

INSERT INTO @MoveParts (TeileID, KdArtiID, ArtGroeID, MoveToVsaID)
SELECT Teile.ID, Teile.KdArtiID, Teile.ArtGroeID, OPTeile.VsaID AS MoveToVsaID
FROM Teile
JOIN Vsa ON Teile.VsaID = Vsa.ID
JOIN OPTeile ON Teile.OPTeileID = OPTeile.ID
JOIN Vsa AS PoolVsa ON OPTeile.VsaID = PoolVsa.ID
WHERE Vsa.KundenID IN (
    SELECT CustomerID
    FROM @Customer
  )
  AND PoolVsa.KundenID = Vsa.KundenID
  AND Teile.OPTeileID > 0
  AND OPTeile.VsaID > 0;

MERGE INTO TraeArti
USING (
  SELECT DISTINCT MoveParts.MoveToVsaID AS VsaID, Wearer.TraegerID, MoveParts.ArtGroeID, MoveParts.KdArtiID
  FROM @MoveParts AS MoveParts
  JOIN @Wearer AS Wearer ON MoveParts.MoveToVsaID = Wearer.VsaID
) AS NewTraeArti ON TraeArti.TraegerID = NewTraeArti.TraegerID AND TraeArti.ArtGroeID = NewTraeArti.ArtGroeID AND TraeArti.KdArtiID = NewTraeArti.KdArtiID
WHEN NOT MATCHED THEN
  INSERT (VsaID, TraegerID, ArtGroeID, KdArtiID, AnlageUserID_, UserID_)
  VALUES (NewTraeArti.VsaID, NewTraeArti.TraegerID, NewTraeArti.ArtGroeID, NewTraeArti.KdArtiID, @UserID, @UserID);

UPDATE Teile SET VsaID = TraeArti.VsaID, TraeArtiID = TraeArti.ID, TraegerID = TraeArti.TraegerID, UserID_ = @UserID
FROM @MoveParts AS MoveParts
JOIN @Wearer AS Wearer On MoveParts.MoveToVsaID = Wearer.VsaID
JOIN TraeArti ON TraeArti.VsaID = MoveParts.MoveToVsaID AND TraeArti.TraegerID = Wearer.TraegerID AND TraeArti.KdArtiID = MoveParts.KdArtiID AND TraeArti.ArtGroeID = MoveParts.ArtGroeID
WHERE Teile.ID = MoveParts.TeileID
  AND Teile.TraegerID != TraeArti.TraegerID;
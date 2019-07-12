DECLARE @MaID int = 9013879; -- ID des neuen Mitarbeiters

DECLARE @KdBer TABLE (
  ID int
);

INSERT INTO @KdBer
SELECT KdBer.ID
FROM KdBer
JOIN Kunden ON KdBer.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
WHERE Holding.Holding IN (N'BH K2', N'BH K3')
  AND Kunden.AdrArtID = 1
  AND Kunden.[Status] = N'A';

UPDATE KdBer SET BetreuerID = @MaID
WHERE ID IN (SELECT ID FROM @KdBer);

UPDATE VsaBer SET BetreuerID = @MaID
WHERE KdBerID IN (SELECT ID FROM @KdBer);
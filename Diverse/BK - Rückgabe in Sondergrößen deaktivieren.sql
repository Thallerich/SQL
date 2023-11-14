CREATE TABLE __FakRueckSonder_20231114 (
  KundenID int,
  FakRueckSonder bit
);

GO

UPDATE Kunden SET FakRueckSonder = 0
OUTPUT deleted.ID, deleted.FakRueckSonder
INTO __FakRueckSonder_20231114
WHERE Kunden.FirmaID = (SELECT ID FROM Firma WHERE SuchCode = N'FA14')
  AND Kunden.FakRueckSonder = 1
  AND Kunden.AdrArtID = 1;

GO
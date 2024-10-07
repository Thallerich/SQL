DECLARE @contarti nchar(15) = N'CONT10';
DECLARE @liefid int = 35625; --Salesianer intern
DECLARE @standortid int = (SELECT ID FROM Standort WHERE SuchCode = N'BUKA');
DECLARE @firmaid int = (SELECT FirmaID FROM Standort WHERE ID = @standortid);
DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

INSERT INTO Contain (Barcode, ArtikelID, LiefID, EKPreis, EKDatum, StandortID, FirmaID, AnlageUserID_, UserID_)
SELECT ImportTable.Barcode, Artikel.ID, @liefid, Artikel.EkPreis, GETDATE(), @standortid, @firmaid, @userid, @userid
FROM _IT87437 AS ImportTable
CROSS APPLY Artikel
WHERE Artikel.ArtikelNr = @contarti
  AND NOT EXISTS (
    SELECT c.*
    FROM Contain c
    WHERE c.Barcode = ImportTable.Barcode COLLATE Latin1_General_CS_AS
  );
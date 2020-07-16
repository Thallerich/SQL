DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

DECLARE @InsertedData TABLE (
  Barcode nchar(33) COLLATE Latin1_General_CS_AS,
  OPTeileID int
);

INSERT INTO OPTeile ([Status], Code, ArtGroeID, ArtikelID, VsaID, LiefID, ZielNrID, LastScanTime, EkPreis, EkGrundAkt, EkGrundHist, VsaOwnerID, AnlageUserID_, UserID_)
OUTPUT inserted.ID AS OPTeileID, inserted.Code AS Barcode
INTO @InsertedData (OPTeileID, Barcode)
SELECT N'Q' AS [Status], Teile.Barcode AS Code, Teile.ArtGroeID, Teile.ArtikelID, Teile.VsaID, Artikel.LiefID, 10000060 AS ZielNrID, GETDATE() AS LastScanTime, Teile.EkPreis, Teile.EKGrundAkt, Teile.EKGrundHist, Teile.VsaID AS VsaOwnerID, @UserID AS AnlageUser_, @UserID AS UserID_
FROM Teile
JOIN Artikel ON Teile.ArtikelID = Artikel.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
WHERE ArtGru.UsesBKOpTeileArtGru = 1
  AND Teile.OPTeileID < 0
  AND Teile.Status BETWEEN N'M' AND N'Q'
  AND NOT EXISTS (
    SELECT OPTeile.*
    FROM OPTeile
    WHERE OPTeile.Code = Teile.Barcode
  );

UPDATE Teile SET Teile.OPTeileID = InsertedData.OPTeileID
FROM Teile
JOIN @InsertedData AS InsertedData ON InsertedData.Barcode = Teile.Barcode;
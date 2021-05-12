DECLARE @FirmaID int = (SELECT ID FROM Firma WHERE SuchCode = N'FA14');
DECLARE @BereichID int = (SELECT ID FROM Bereich WHERE Bereich = N'PWS');
DECLARE @BewohnerRechnungID int = (SELECT ID FROM RKoType WHERE RKoTypeBez = N'Bewohnerwäsche');
DECLARE @MonatsRechnungID int = (SELECT ID FROM RKoType WHERE RKoTypeBez = N'Monatsrechnung');
DECLARE @DummyKonto int = (SELECT ID FROM Konten WHERE Konto = N'SAP');
DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

TRUNCATE TABLE RPoKonto;

WITH Firmen AS (
  SELECT Firma.ID
  FROM Firma
  WHERE Status = N'A'
    AND EXISTS (
      SELECT RechNrKr.*
      FROM RechNrKr
      WHERE RechNrKr.FirmaID = Firma.ID
    )
)
INSERT INTO RPoKonto (BereichID, ArtGruID, BrancheID, RPoTypeID, FirmaID, KdGfID, MWStID, Art, Bez, KontenID, RKoTypeID, AnlageUserID_, UserID_)
SELECT Bereich.ID AS BereichID, -1 AS ArtGruID, -1 AS BrancheID, RPoType.ID AS RPoTypeID, Firmen.ID AS FirmaID, -1 AS KdGfID, MwSt.ID AS MwStID, N'B' AS Art, N'Dummy' AS Bez, @DummyKonto AS KontenID, @MonatsRechnungID AS RKoTypeID, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM RPoType
CROSS JOIN MwSt
CROSS JOIN Bereich
CROSS JOIN Firmen
WHERE RPoType.ID > 0
  AND MwSt.ID > 0
  AND Bereich.ID > 0
  AND ((Bereich.ID != @BereichID AND Firmen.ID = @FirmaID) OR (Firmen.ID != @FirmaID));

INSERT INTO RPoKonto (BereichID, ArtGruID, BrancheID, RPoTypeID, FirmaID, KdGfID, MWStID, Art, Bez, KontenID, RKoTypeID, AnlageUserID_, UserID_)
SELECT Bereich.ID AS BereichID, -1 AS ArtGruID, -1 AS BrancheID, RPoType.ID AS RPoTypeID, @FirmaID AS FirmaID, -1 AS KdGfID, MwSt.ID AS MwStID, N'B' AS Art, N'Dummy' AS Bez, @DummyKonto AS KontenID, @BewohnerRechnungID AS RKoTypeID, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM RPoType
CROSS JOIN MwSt
CROSS JOIN Bereich
WHERE RPoType.ID > 0
  AND MwSt.ID > 0
  AND Bereich.ID = @BereichID;

GO
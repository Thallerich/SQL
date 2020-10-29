DECLARE @DestinationWearer nchar(4) = N'2650';
DECLARE @KdNr smallint = 18027;
DECLARE @DefaultSignalID int = 1000000;

DECLARE @DestinationWearerID int;
DECLARE @DestinationVSAID int;
DECLARE @UserID int;
DECLARE @DefaultSignalText nvarchar(60);

DECLARE @UpdatedParts TABLE (
  TeileID int
);

SET @DestinationWearerID = (
  SELECT Traeger.ID
  FROM Traeger
  JOIN Vsa ON Traeger.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  WHERE Traeger.Traeger = @DestinationWearer
    AND Kunden.KdNr = @KdNr
);

SET @DestinationVSAID = (
  SELECT Traeger.VsaID
  FROM Traeger
  JOIN Vsa ON Traeger.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  WHERE Traeger.Traeger = @DestinationWearer
    AND Kunden.KdNr = @KdNr
);

SET @UserID = (
  SELECT Mitarbei.ID
  FROM Mitarbei
  WHERE Mitarbei.UserName = N'THALST'
);

SET @DefaultSignalText = (
  SELECT HinwText.HinwtextBez
  FROM HinwText
  WHERE HinwText.ID = @DefaultSignalID
);

MERGE INTO TraeArti
USING (
  SELECT DISTINCT @DestinationWearerID AS TraegerID, Teile.KdArtiID, Teile.ArtGroeID, @DestinationVSAID AS VsaID
  FROM Teile
  JOIN Vsa ON Teile.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN Artikel ON Teile.ArtikelID = Artikel.ID
  JOIN Wozabal.dbo.__IT40780 ON __IT40780.ArtikelNr = Artikel.ArtikelNr AND __IT40780.VsaNr = Vsa.VsaNr
  WHERE Kunden.KdNr = @KdNr
    AND Teile.Status BETWEEN N'A' AND N'W'
) AS source ON TraeArti.TraegerID = source.TraegerID AND TraeArti.KdArtiID = source.KdArtiID AND TraeArti.ArtGroeID = source.ArtGroeID
WHEN NOT MATCHED THEN
  INSERT (TraegerID, KdArtiID, ArtGroeID, VsaID, AnlageUserID_, UserID_)
  VALUES (source.TraegerID, source.KdArtiID, source.ArtGroeID, source.VsaID, @UserID, @UserID);

WITH DestinationTraeArti AS (
  SELECT TraeArti.ID AS TraeArtiID, TraeArti.VsaID, TraeArti.TraegerID, TraeArti.KdArtiID, TraeArti.ArtGroeID
  FROM TraeArti
  WHERE TraeArti.TraegerID = @DestinationWearerID
)
UPDATE Teile SET Teile.VsaID = DestinationTraeArti.VsaID, Teile.TraegerID = DestinationTraeArti.TraegerID, Teile.TraeArtiID = DestinationTraeArti.TraeArtiID, UserID_ = @UserID
OUTPUT inserted.ID
INTO @UpdatedParts
FROM Teile
JOIN Vsa ON Teile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Artikel ON Teile.ArtikelID = Artikel.ID
JOIN Wozabal.dbo.__IT40780 ON __IT40780.ArtikelNr = Artikel.ArtikelNr AND __IT40780.VsaNr = Vsa.VsaNr
JOIN DestinationTraeArti ON DestinationTraeArti.KdArtiID = Teile.KdArtiID AND DestinationTraeArti.ArtGroeID = Teile.ArtGroeID
WHERE Kunden.KdNr = @KdNr
  AND Teile.Status BETWEEN N'A' AND N'W';

INSERT INTO Hinweis (TeileID, Aktiv, Hinweis, BisWoche, Anzahl, HinwTextID, EingabeDatum, EingabeMitarbeiID, Patchen, AnlageUserID_, UserID_)
SELECT UpdatedParts.TeileID, CAST(1 AS bit) AS Aktiv, @DefaultSignalText AS Hinweis, N'2099/52' AS BisWoche, 1 AS Anzahl, @DefaultSignalID AS HinwTextID, GETDATE() AS Eingabedatum, @UserID AS EingabeMitarbeiID, CAST(1 AS bit) AS Patchen, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM @UpdatedParts AS UpdatedParts;

SELECT Teile.Barcode FROM Teile WHERE Teile.ID IN (SELECT TeileID FROM @UpdatedParts);
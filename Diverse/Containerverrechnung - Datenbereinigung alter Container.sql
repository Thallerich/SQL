DROP TABLE IF EXISTS #Entlasten;
GO

CREATE TABLE #Entlasten (
  ContainID int,
  KundenID int,
  VsaID int
);

GO

DECLARE @Stichtag date = N'2024-01-01';

DECLARE @ArtikelID int, @BereichID int;
SELECT @ArtikelID = ID, @BereichID = BereichID FROM Artikel WHERE ArtikelNr = N'CONTMIET';

DECLARE @Kunden TABLE (
  KundenID int
);

INSERT INTO @Kunden (KundenID)
SELECT Kunden.ID AS KundenID
FROM Kunden
JOIN Standort ON Kunden.StandortID = Standort.ID
WHERE Kunden.[Status] = N'A'
  AND Kunden.AdrArtID = 1
  AND EXISTS (
    SELECT KdArti.*
    FROM KdArti
    WHERE KdArti.ArtikelID = @ArtikelID
      AND KdArti.LeasPreis = 0
      AND KdArti.KundenID = Kunden.ID
  )
  AND Standort.SuchCode IN (N'WOEN', N'WOLI');

INSERT INTO #Entlasten (ContainID, KundenID, VsaID)
SELECT ContHist.ContainID, ContHist.KundenID, ContHist.VsaID
FROM ContHist
WHERE ContHist.KundenID IN (SELECT KundenID FROM @Kunden)
  AND ContHist.MietBeginn <= N'2024/14'
  AND ContHist.Zeitpunkt < N'2024-01-01 00:00:00.000'
  AND NOT EXISTS (
    SELECT x.ID
    FROM ContHist x
    WHERE x.ContainID = ContHist.ContainID
      AND x.MietEnde < '2024/14'
      AND x.KundenID = ContHist.KundenID
      AND x.VsaID = ContHist.VsaID
      AND x.MietEnde > ContHist.MietBeginn
  );

GO

DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE MitarbeiUser = N'THALST');

INSERT INTO ContHist ([Status], ContainID, KundenID, VsaID, Zeitpunkt, MietEnde, AnlageUserID_, UserID_)
SELECT N'?', ContainID, KundenID, VsaID, GETDATE(), N'2024/01', @UserID, @UserID
FROM #Entlasten;

GO

DROP TABLE #Entlasten;
GO
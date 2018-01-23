USE Wozabal
GO

DROP TABLE IF EXISTS #Schrottteile;

SELECT Teile.ID AS TeileID, Teile.Status
INTO #Schrottteile
FROM Teile
JOIN Vsa ON Teile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Artikel ON Teile.ArtikelID = Artikel.ID
JOIN _EWSchrott ON _EWSchrott.KdNr = Kunden.KdNr AND _EWSchrott.ArtikelNr = Artikel.ArtikelNr
  AND Teile.Status < N'Y'
  AND Teile.Status > N'5';

UPDATE Teile SET Status = N'Y', Abmeldung = N'2017/47', AbmeldDat = CAST(N'2017-11-22' AS date), Ausdienst = N'2017/47', AusdienstDat = CAST(N'2017-11-22' AS date), AusdienstGrund = N'U', Einzug = CAST(N'2017-11-22' AS date)
WHERE Teile.ID IN (
  SELECT TeileID
  FROM #Schrottteile
  WHERE Status >= N'Q'
);

UPDATE Teile SET Status = N'5'
WHERE Teile.ID IN (
  SELECT TeileID
  FROM #Schrottteile
  WHERE Status < N'Q'
);

DROP TABLE IF EXISTS #Schrottteile;

GO
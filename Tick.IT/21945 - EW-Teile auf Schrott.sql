USE Wozabal
GO

UPDATE Teile SET Status = N'Y', Abmeldung = N'2017/49', AbmeldDat = CAST(GETDATE() AS date), Ausdienst = N'2017/49', AusdienstDat = CAST(GETDATE() AS date), AusdienstGrund = N'Z', Einzug = CAST(GETDATE() AS date), WegGrundID = 102
WHERE Teile.ID IN (
  SELECT Teile.ID
  FROM Teile
  JOIN Vsa ON Teile.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN Artikel ON Teile.ArtikelID = Artikel.ID
  JOIN Status ON Teile.Status = Status.Status AND Status.Tabelle = N'TEILE'
  WHERE Kunden.KdNr IN (2300, 2301, 2306, 15001, 15007, 16076, 18029, 19080, 20150, 20156, 6071, 7240, 9013, 11050, 20000, 24045, 25005)
    AND Artikel.ArtikelNr LIKE N'19%'
    AND Teile.Status >= N'Q'
    AND Teile.Status < N'X'
);

UPDATE Teile SET Status = N'5'
WHERE Teile.ID IN (
  SELECT Teile.ID
  FROM Teile
  JOIN Vsa ON Teile.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN Artikel ON Teile.ArtikelID = Artikel.ID
  JOIN Status ON Teile.Status = Status.Status AND Status.Tabelle = N'TEILE'
  WHERE Kunden.KdNr IN (2300, 2301, 2306, 15001, 15007, 16076, 18029, 19080, 20150, 20156, 6071, 7240, 9013, 11050, 20000, 24045, 25005)
    AND Artikel.ArtikelNr LIKE N'19%'
    AND Teile.Status > N'5'
    AND Teile.Status < N'Q'
);

GO
DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

INSERT INTO TeilAppl (EinzHistID, ApplArtikelID, ArtiTypeID, PlatzID, Bearbeitung, AnlageUserID_, UserID_)
SELECT EinzHist.ID AS EinzHistID, ApplArtikel.ApplArtikelID, 3 AS ArtiTypeID, Platz.PlatzID, N'-' AS Bearbeitung, @userid AS AnlageUserID_, @userid AS UserID_
FROM EinzHist
CROSS JOIN (
  SELECT Artikel.ID AS ApplArtikelID
  FROM Artikel
  WHERE Artikel.ArtikelNr = N'BWTTBB'
    AND Artikel.ArtiTypeID = 3
) AS ApplArtikel
CROSS JOIN (
  SELECT Platz.ID AS PlatzID
  FROM Platz
  WHERE Platz.Code IN (N'PN01', N'PN06')
) AS Platz
WHERE EinzHist.ArtikelID = (SELECT ID FROM Artikel WHERE Artikel.ArtikelNr = N'98H1')
  AND EinzHist.EinzHistTyp = 2
  AND EinzHist.ID = (SELECT EinzTeil.CurrEinzHistID FROM EinzTeil WHERE EinzTeil.ID = EinzHist.EinzTeilID)
  AND EinzHist.LagerArtID IN (SELECT LagerArt.ID FROM LagerArt WHERE LagerArt.LagerID IN (SELECT Standort.ID FROM Standort WHERE Standort.SuchCode LIKE N'WOL_' AND Standort.Lager = 1))
  AND EinzHist.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = 10006791)
  AND NOT EXISTS (
    SELECT TeilAppl.*
    FROM TeilAppl
    WHERE TeilAppl.EinzHistID = EinzHist.ID
  );

GO
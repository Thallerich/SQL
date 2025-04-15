DROP TABLE IF EXISTS #LsKoForecastFix;

CREATE TABLE #LsKoForecastFix (
  LsKoID int,
  NeedsZUSFix bit DEFAULT 0
);

INSERT INTO #LsKoForecastFix (LsKoID)
SELECT LsKo.ID
FROM LsKo
JOIN Fahrt ON LsKo.FahrtID = Fahrt.ID
WHERE LsKo.Datum >= N'2025-04-14'
  AND LsKo.ForecastStatus = 2
  AND LsKo.DruckMitarbeiID = -1
  AND Fahrt.MDEDevID > 0
  AND LsKo.LsKoArtID != (SELECT LsKoArt.ID FROM LsKoArt WHERE LsKoArt.ForecastLS = 1)
  AND LsKo.Status >= 'Q';

UPDATE #LsKoForecastFix SET NeedsZUSFix = 1
WHERE NOT EXISTS (
    SELECT LsPo.*
    FROM LsPo
    JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
    WHERE LsPo.LsKoID = #LsKoForecastFix.LsKoID
      AND KdArti.ArtikelID != (SELECT Artikel.ID FROM Artikel WHERE Artikel.ArtikelNr = N'ZUS')
  )
  AND EXISTS (
    SELECT LsPo.*
    FROM LsPo
    JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
    WHERE LsPo.LsKoID = #LsKoForecastFix.LsKoID
      AND KdArti.ArtikelID = (SELECT Artikel.ID FROM Artikel WHERE Artikel.ArtikelNr = N'ZUS')
  );

UPDATE LsPo SET Kostenlos = 1
WHERE LsKoID IN (
    SELECT LsKoID
    FROM #LsKoForecastFix
    WHERE NeedsZUSFix = 1
  )
  AND LsPo.Kostenlos = 0;
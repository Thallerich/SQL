-- Unique: BestandID;LagerOrtID

DECLARE @BestOrtKorrigiert TABLE (
  BestandID int,
  LagerortIDNeu int,
  LagerortIDAlt int
);

WITH LagerortLinz AS (
  SELECT Lagerort.*
  FROM Lagerort
  JOIN Standort ON Lagerort.LagerID = Standort.ID
  WHERE Standort.SuchCode = N'WOLI'
)
UPDATE BestOrt SET BestOrt.LagerOrtID = LagerortLinz.ID
OUTPUT inserted.BestandID, inserted.LagerOrtID, deleted.LagerOrtID
INTO @BestOrtKorrigiert
--SELECT Lagerart.Lagerart, Lagerort.Lagerort AS [Lagerort aktuell], LagerortLinz.Lagerort AS [Lagerort Linz], Bestort.Bestand
FROM BestOrt
JOIN Lagerort ON BestOrt.LagerOrtID = Lagerort.ID
JOIN Bestand ON BestOrt.BestandID = Bestand.ID
JOIN Lagerart ON Bestand.LagerArtID = Lagerart.ID
JOIN LagerortLinz ON Lagerort.Lagerort = LagerortLinz.Lagerort
WHERE Lagerort.LagerID != Lagerart.LagerID
  AND Bestort.Bestand != 0
  AND Lagerart.Lagerart = N'WOLIBKNU'
  AND NOT EXISTS (
    SELECT Bestort.*
    FROM Bestort
    WHERE Bestort.BestandID = Bestand.ID
      AND Bestort.LagerOrtID = LagerortLinz.ID
  );

UPDATE LagerBew SET LagerBew.LagerOrtID = BestOrtKorrigiert.LagerortIDNeu
FROM LagerBew
JOIN @BestOrtKorrigiert AS BestOrtKorrigiert ON LagerBew.BestandID = BestOrtKorrigiert.BestandID AND LagerBew.LagerOrtID = BestOrtKorrigiert.LagerortIDAlt;
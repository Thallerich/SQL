/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Positionsnummer setzen wo noch 0                                                                                          ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #myBPo;

SELECT BPo.ID AS BPoID, BPo.BKoID, MaxPos = (SELECT MAX(BPo.Pos) FROM BPo WHERE BPo.BKoID = BKo.ID), Rnk = RANK() OVER (PARTITION BY BPo.BKoID ORDER BY BPo.ID)
INTO #myBPo
FROM BPo
JOIN BKo ON BPo.BKoID = BKo.ID
WHERE bko.status BETWEEN 'E' AND 'X'
 AND BKo.SentToSap = 0
 AND BPo.Pos = 0
 AND BPo.Menge != 0;

UPDATE BPo SET BPo.Pos = #myBPo.MaxPos + #myBPo.Rnk
FROM #myBPo
WHERE #myBPo.BPoID = BPo.ID;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Zu übertragende Bestellungen in Zwischentabelle schreiben für Folge-Job "SAP: SMZL + BUDA - Bestellungen senden"          ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

IF OBJECT_ID('__BKoForSAP') IS NULL 
BEGIN
  CREATE TABLE __BKoForSAP (
    ID int PRIMARY KEY
  );
END
ELSE
BEGIN
  TRUNCATE TABLE __BKoForSAP
END;

INSERT INTO __BKoForSAP (ID)
SELECT DISTINCT BKo.ID
FROM BKo
JOIN BKoArt ON BKo.BKoArtID = BKoArt.ID
JOIN Lagerart ON BKo.LagerArtID = Lagerart.ID
JOIN Standort ON Lagerart.LagerID = Standort.ID
JOIN Firma ON Lagerart.FirmaID = Firma.ID
JOIN Lief ON BKo.LiefID = Lief.ID
JOIN LiefType ON Lief.LiefTypeID = LiefType.ID
LEFT JOIN Lagerart AS LiefLagerart ON BKo.LiefID = LiefLagerart.LiefID
WHERE BKo.Datum <= CAST(GETDATE() AS date)
  AND BKo.Status >= N'F'
  AND BKoArt.Kontrakt = 0
  AND ((Firma.SuchCode = N'FA14' AND Standort.SuchCode = N'SMZL') OR Firma.SuchCode = N'BUDA')
  AND (LiefType.InternerLief = 0 OR (Lagerart.FirmaID != COALESCE(LiefLagerart.FirmaID, -1) AND COALESCE(LiefLagerart.FirmaID, -1) > -1))
  AND BKo.SentToSAP = 0
  AND BKo.ID > 0
  AND EXISTS (
    SELECT BPo.*
    FROM BPo
    WHERE BPo.BKoID = BKo.ID
      AND BPo.Pos > 0
  )
  AND NOT EXISTS (
    SELECT BPo.*
    FROM BPo
    WHERE BPo.BKoID = BKo.ID
      AND BPo.Pos = 0
      AND BPo.Menge != 0
  );
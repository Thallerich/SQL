DECLARE @VsaList TABLE (
  VsaID int
);

INSERT INTO @VsaList
SELECT DISTINCT Vsa.ID
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
WHERE Firma.SuchCode = N'FA14'
  AND EXISTS (
    SELECT VsaTour.*
    FROM VsaTour
    JOIN Touren ON VsaTour.TourenID = Touren.ID
    JOIN Standort AS Expedition ON Touren.ExpeditionID = Expedition.ID
    WHERE VsaTour.VsaID = Vsa.ID
      AND Expedition.SuchCode IN (N'SA22', N'SAWR')
  )
  AND NOT EXISTS (
    SELECT VsaBer.*
    FROM VsaBer
    JOIN KdBer ON VsaBer.KdBerID = KdBer.ID
    JOIN Bereich ON KdBer.BereichID = Bereich.ID
    WHERE VsaBer.VsaID = Vsa.ID
      AND Bereich.Bereich IN (N'BK', N'CR', N'ST')
      AND VsaBer.Status = N'A'
  )
  AND Vsa.NichtImmerLS = 0
  AND Vsa.Status = N'A'
  AND Kunden.Status = N'A';

UPDATE Vsa SET NichtImmerLS = 1
WHERE Vsa.ID IN (
  SELECT VsaID
  FROM @VsaList
);

SELECT Kunden.KdNr, Kunden.Suchcode AS Kunde, Vsa.VsaNr, Vsa.Bez AS VsaBezeichnung
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Vsa.ID IN (
  SELECT VsaID
  FROM @VsaList
)
ORDER BY Kunden.KdNr, Vsa.VsaNr;
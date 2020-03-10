WITH Kundenstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'KUNDEN')
)
SELECT KdGf.KurzBez AS Geschäftsbereich, Holding.Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, Kundenstatus.StatusBez AS Kundenstatus, VsaTexte.VonDatum, VsaTexte.BisDatum, TextArt.TextArtBez$LAN$ AS Textart, VsaTexte.Memo AS Memotext
FROM VsaTexte
JOIN Kunden ON VsaTexte.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Kundenstatus ON Kunden.Status = Kundenstatus.Status
JOIN TextArt ON VsaTexte.TextArtID = TextArt.ID
WHERE VsaTexte.BisDatum >= CAST(GETDATE() AS date)
  AND EXISTS (
    SELECT Vsa.*
    FROM Vsa
    JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID
    WHERE StandBer.ProduktionID = $1$
      AND Vsa.Status = N'A'
      AND Vsa.KundenID = Kunden.ID
  )
  AND Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1;
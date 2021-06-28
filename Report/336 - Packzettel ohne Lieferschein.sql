WITH PzStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'AnfKo')
)
SELECT DISTINCT AnfKo.ID AS AnfKoID, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.ID AS VsaID, Vsa.VsaNr AS [VSA-Nummer], Vsa.Bez AS [VSA-Bezeichnung], AnfKo.Auftragsdatum, AnfKo.Lieferdatum, AnfKo.AuftragsNr AS [Packzettel-Nummer], PzStatus.StatusBez AS [Status Packzettel]
FROM AnfKo
JOIN Vsa ON AnfKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN PzStatus ON AnfKo.[Status] = PzStatus.[Status]
JOIN Standber ON Vsa.StandKonID = StandBer.StandKonID
JOIN Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID
WHERE AnfKo.LsKoID = -1
  AND Produktion.ID IN ($1$)
  AND AnfKo.Lieferdatum BETWEEN $STARTDATE$ AND $ENDDATE$
  AND EXISTS (
    SELECT AnfPo.*
    FROM AnfPo
    WHERE AnfPo.AnfKoID = AnfKo.ID
      AND AnfPo.Angefordert != 0
  )
ORDER BY AnfKo.Auftragsdatum;
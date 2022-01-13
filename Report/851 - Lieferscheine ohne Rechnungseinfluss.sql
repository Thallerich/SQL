WITH Lieferscheinstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'LSKO'
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.ID AS VsaID, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], LsKo.ID AS LsKoID, LsKo.LsNr, LsKo.Datum AS Lieferdatum, Lieferscheinstatus.StatusBez AS [Status Lieferschein]
FROM LsKo
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Lieferscheinstatus ON LsKo.Status = Lieferscheinstatus.Status
WHERE NOT EXISTS (
    SELECT LsPo.*
    FROM LsPo
    WHERE LsPo.LsKoID = LsKo.ID
      AND LsPo.RechPoID > 0
  )
  AND EXISTS (
    SELECT LsPo.*
    FROM LsPo
    WHERE LsPo.LsKoID = LsKo.ID
  )
  AND Kunden.ID = $ID$
  AND LsKo.Datum BETWEEN $STARTDATE$ AND $ENDDATE$;
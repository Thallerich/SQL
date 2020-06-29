WITH Auftragsstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'AUFTRAG')
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Auftrag.AuftragsNr, Auftrag.Zeitpunkt, Auftrag.PlanLieferdatum AS [Plan-Lieferdatum], Auftragsstatus.StatusBez AS Auftragsstatus, Mitarbei.Name AS [erfasst durch]
FROM Auftrag
JOIN Kunden ON Auftrag.KundenID = Kunden.ID
JOIN Auftragsstatus ON Auftrag.Status = Auftragsstatus.Status
JOIN Mitarbei ON Auftrag.ErfasstMitarbeiID = Mitarbei.ID
WHERE Auftrag.AuftragsNr = $1$;
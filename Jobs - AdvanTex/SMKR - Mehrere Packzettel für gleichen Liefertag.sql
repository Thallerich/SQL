WITH MultipleAnf AS (
  SELECT AnfKo.VsaID, AnfKo.LieferDatum
  FROM AnfKo
  WHERE AnfKo.Lieferdatum > CAST(GETDATE() AS date)
  GROUP BY AnfKo.VsaID, AnfKo.LieferDatum
  HAVING COUNT(AnfKo.ID) > 1
),
AnfStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'ANFKO'
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], AnfKo.AuftragsNr AS Packzettel, AnfKo.Lieferdatum, AnfStatus.StatusBez AS [Packzettel-Status], DENSE_RANK() OVER (PARTITION BY AnfKo.VsaID, AnfKo.Lieferdatum ORDER BY AnfKo.Anlage_ ASC) AS Reihenfolge, AnfKo.Anlage_ AS erstellt, AnfKo.Update_ AS geändert,
  [Angeforderte Menge] = (SELECT SUM(AnfPo.Angefordert) FROM AnfPo WHERE AnfPo.AnfKoID = AnfKo.ID)
FROM MultipleAnf
JOIN AnfKo ON MultipleAnf.VsaID = AnfKo.VsaID AND MultipleAnf.LieferDatum = AnfKo.LieferDatum
JOIN Vsa ON MultipleAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN AnfStatus ON AnfKo.[Status] = AnfStatus.[Status]
WHERE AnfKo.ProduktionID = (SELECT Standort.ID FROM Standort WHERE Standort.SuchCode = N'SMKR')
ORDER BY AnfKo.VsaID, Reihenfolge;
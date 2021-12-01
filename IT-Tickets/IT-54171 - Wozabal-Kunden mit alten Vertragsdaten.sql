SELECT DISTINCT Holding.Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, Branche.BrancheBez AS Branche, Abc.ABCBez AS [ABC-Klasse], Standort.SuchCode AS Hauptstandort, KdGf.KurzBez AS Geschäftsbereich, Betreuer.Name AS Betreuer, Vertrag.Nr AS [Nummer Vertrag], Vertrag.Bez AS [Vertrags-Bezeichnung], Vertrag.VertragAbschluss AS [Abschluss Vertrag], Vertrag.VertragStart AS [Start Vertrag], Vertrag.VertragEndeMoegl [mögliches Ende Vertrag], VertTyp.VertTypBez AS [Vertrags-Art]
FROM KdBer
JOIN Kunden ON KdBer.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Branche ON Kunden.BrancheID = Branche.ID
JOIN Abc ON Kunden.AbcID = Abc.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN Mitarbei AS Betreuer ON KdBer.BetreuerID = Betreuer.ID
JOIN Vertrag ON KdBer.VertragID = Vertrag.ID
JOIN VertTyp ON Vertrag.VertTypID = VertTyp.ID
WHERE Kunden.Status = N'A'
  AND KdGf.KurzBez != N'INT'
  AND KdBer.Status = N'A'
  AND Vertrag.VertragAbschluss < CAST(N'2018-01-01' AS date)
  AND EXISTS (
    SELECT RechKo.*
    FROM RechKo
    WHERE RechKo.KundenID = Kunden.ID
      AND RechKo.FirmaID IN (
        SELECT Firma.ID
        FROM Firma
        WHERE Firma.Status = N'I'
      )
  );
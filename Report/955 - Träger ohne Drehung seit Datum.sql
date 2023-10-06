DECLARE @beforeDate date = $2$;

WITH CTE_AltTeile AS (
  SELECT EinzHist.*
  FROM EinzTeil
  JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
  WHERE EinzHist.Status IN (N'Q', N'S', N'T', N'U', N'W')
    AND (EinzHist.Ausgang1 < @beforeDate OR EinzHist.Ausgang1 IS NULL)
    AND (EinzHist.Eingang1 < @beforeDate OR EinzHist.Eingang1 IS NULL)
    AND NOT EXISTS (
      SELECT h.*
      FROM EinzTeil AS e
      JOIN EinzHist AS h ON e.CurrEinzHistID = h.ID
      WHERE h.TraegerID = EinzHist.TraegerID
        AND (h.Eingang1 >= @beforeDate OR h.Ausgang1 >= @beforeDate)
    )
)
SELECT Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.Bez AS Vsa, Traeger.ID AS TraegerID, Traeger.Traeger, [Status].StatusBez AS TraegerStatus, Traeger.Nachname, Traeger.Vorname, Coalesce(Traeger.Indienst, N'') AS [Zeitraum von], Coalesce(Traeger.Ausdienst, N'') AS [Zeitraum bis], MAX(IIF(Coalesce(CTE_AltTeile.Eingang1, N'1980-01-01') > Coalesce(CTE_AltTeile.Ausgang1, N'1980-01-01'), CTE_AltTeile.Eingang1, CTE_AltTeile.Ausgang1)) AS [letzte Teile-Bewegung]
FROM Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN [Status] ON Traeger.[Status] = [Status].[Status] AND [Status].Tabelle = N'TRAEGER'
JOIN CTE_AltTeile ON CTE_AltTeile.TraegerID = Traeger.ID
WHERE Kunden.ID = $1$
  AND Traeger.Status <> N'I'
GROUP BY Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.Bez, Traeger.ID, Traeger.Traeger, [Status].StatusBez, Traeger.Nachname, Traeger.Vorname, Traeger.Indienst, Traeger.Ausdienst
ORDER BY [letzte Teile-Bewegung] ASC;
DECLARE @beforDate date = $2$;

WITH CTE_AltTeile AS (
  SELECT Teile.*
  FROM Teile
  WHERE Teile.Status IN (N'Q', N'S', N'T', N'U', N'W')
    AND (Teile.Ausgang1 < @beforDate OR Teile.Ausgang1 IS NULL)
    AND (Teile.Eingang1 < @beforDate OR Teile.Eingang1 IS NULL)
)
SELECT Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.Bez AS Vsa, Traeger.Traeger, [Status].StatusBez AS TraegerStatus, Traeger.Nachname, Traeger.Vorname, ISNULL(Traeger.Indienst, N'') AS [Zeitraum von], ISNULL(Traeger.Ausdienst, N'') AS [Zeitraum bis], MAX(IIF(ISNULL(CTE_AltTeile.Eingang1, N'1980-01-01') > ISNULL(CTE_AltTeile.Ausgang1, N'1980-01-01'), CTE_AltTeile.Eingang1, CTE_AltTeile.Ausgang1)) AS [letzte Teile-Bewegung]
FROM Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN [Status] ON Traeger.[Status] = [Status].[Status] AND [Status].Tabelle = N'TRAEGER'
JOIN CTE_AltTeile ON CTE_AltTeile.TraegerID = Traeger.ID
WHERE Kunden.ID = $1$
  AND Traeger.Status <> N'I'
GROUP BY Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.Bez, Traeger.Traeger, [Status].StatusBez, Traeger.Nachname, Traeger.Vorname, Traeger.Indienst, Traeger.Ausdienst
ORDER BY [letzte Teile-Bewegung] ASC;
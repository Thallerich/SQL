SELECT DISTINCT
  Holding = Holding.Holding,
  KdNr = Kunden.KdNr,
  Kunde = Kunden.SuchCode,
  [Kostenstelle neu] = Abteil.Bez,
  [Kostenstellenbezeichnung neu] = (
    SELECT TOP 1 Vsa.Name2
    FROM Vsa
    JOIN Abteil AS VsaAbteil ON Vsa.AbteilID = VsaAbteil.ID
    WHERE Vsa.KundenID = Kunden.ID
      AND VsaAbteil.Bez = Abteil.Bez
    GROUP BY Vsa.Name2
    ORDER BY COUNT(Vsa.ID) DESC
  ),
  [Kostenstellen alt] = STUFF((
    SELECT N'; ' + OldAbteil.Abteilung
    FROM Abteil AS OldAbteil
    WHERE OldAbteil.KundenID = Kunden.ID
      AND OldAbteil.Bez = Abteil.Bez
    FOR XML PATH ('')
  ), 1, 2, N'')
FROM Abteil
JOIN Kunden ON Abteil.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
WHERE Holding.Holding = N'VOES'
  AND Abteil.Abteilung LIKE N'%/%'
ORDER BY KdNr ASC, [Kostenstelle neu] ASC;
SELECT DISTINCT Standort.SuchCode AS Hauptstandort_Kurz, Standort.Bez AS Hauptstandort, Kunden.KdNr, Kunden.SuchCode AS Kunde, Branche.Branche, Branche.BrancheBez AS Branchenbezeichnung, Kundenservice.Name AS Kundenservice, Vertrieb.Name AS Vertrieb, Betreuung.Name AS Betreuung, Rechnung.Name AS Rechnung, Bereiche = (
  STUFF((
    SELECT N', ' + Bereich.Bereich
    FROM KdBer AS k
    JOIN Bereich ON k.BereichID = Bereich.ID
    WHERE k.KundenID = Kunden.ID
      AND k.ServiceID = Kundenservice.ID
      AND k.VertreterID = Vertrieb.ID
      AND k.BetreuerID = Betreuung.ID
      AND k.RechKoServiceID = Rechnung.ID
    FOR XML PATH('')
  ), 1, 2, N'')
)
FROM KdBer
JOIN Kunden ON KdBer.KundenID = Kunden.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN Branche ON Kunden.BrancheID = Branche.ID
JOIN Mitarbei AS Kundenservice ON KdBer.ServiceID = Kundenservice.ID
JOIN Mitarbei AS Vertrieb ON KdBer.VertreterID = Vertrieb.ID
JOIN Mitarbei AS Betreuung ON KdBer.BetreuerID = Betreuung.ID
JOIN Mitarbei AS Rechnung ON KdBer.RechKoServiceID = Rechnung.ID
WHERE Kunden.Status = N'A'
 AND Kunden.SichtbarID NOT IN (61, 62, 69, 79)
 AND Kunden.AdrArtID = 1
ORDER BY Kunden.KdNr ASC;
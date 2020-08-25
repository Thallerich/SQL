WITH CustomersPerServiceuser AS (
  SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Bereich.Bereich AS Kundenbereich, Mitarbei.Name AS Kundenservice, Mitarbei.ID AS KundenserviceID
  FROM KdBer
  JOIN Kunden ON KdBer.KundenID = Kunden.ID
  JOIN Mitarbei ON KdBer.ServiceID = Mitarbei.ID
  JOIN Bereich ON KdBer.BereichID = Bereich.ID
  WHERE Kunden.AdrArtID = 1
    AND Kunden.Status = N'A'
    AND KdBer.Status = N'A'
    AND KdBer.ServiceID IN ($1$)
)
SELECT CustomersPerServiceuser.KdNr AS Kundennummer, CustomersPerServiceuser.Kunde, CustomersPerServiceuser.Kundenservice, Kundenbereiche = CAST(
  STUFF((
    SELECT N', ' + CPS.Kundenbereich
    FROM CustomersPerServiceuser CPS
    WHERE CPS.KdNr = CustomersPerServiceuser.KdNr AND CPS.KundenserviceID = CustomersPerServiceuser.KundenserviceID
    FOR XML PATH ('')
  ), 1, 2, N'')
AS nvarchar)
FROM CustomersPerServiceuser
GROUP BY CustomersPerServiceuser.KdNr, CustomersPerServiceuser.Kunde, CustomersPerServiceuser.Kundenservice, CustomersPerServiceuser.KundenserviceID
ORDER BY KdNr ASC;
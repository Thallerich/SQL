SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, RkoOut.EMailVersand, Rechnungsempfänger = STUFF((
  SELECT DISTINCT N'; ' + Sachbear.eMail
  FROM RKoMail
  JOIN Sachbear ON RKoMail.SachbearID = Sachbear.ID
  WHERE RKoMail.TableID = Kunden.ID
    AND RKoMail.TableName = N'KUNDEN'
  ORDER BY N'; ' + Sachbear.eMail FOR XML PATH('')), 1, 1, N''
)
FROM Kunden
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN RKoOut ON Kunden.RKoOutID = RKoOut.ID
WHERE Firma.SuchCode = N'FA14'
  AND Kunden.[Status] = N'A'
  AND Kunden.AdrArtID = 1
  AND Kunden.KdGFID IN (SELECT KdGf.ID FROM KdGf WHERE KdGf.[Status] = N'A');
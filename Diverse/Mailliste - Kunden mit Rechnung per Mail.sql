SELECT 
  Kunden.KdNr, 
  Kunden.Debitor, 
  Sachbear.eMail
FROM Kunden
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN RKoOut ON Kunden.RKoOutID = RKoOut.ID
JOIN RKoMail ON RKoMail.TableID = Kunden.ID AND RKoMail.TableName = N'KUNDEN' AND RKoMail.FieldName = 'AUTOEMAIL'
JOIN Sachbear ON RKoMail.SachbearID = Sachbear.ID
WHERE RKoOut.EMailVersand = 1
  AND Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1;

GO
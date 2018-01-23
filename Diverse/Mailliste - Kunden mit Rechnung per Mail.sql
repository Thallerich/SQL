USE Wozabal
GO

SELECT 
  KdGf.KurzBez AS SGF, 
  Kunden.KdNr, 
  Kunden.SuchCode AS Kunde, 
  Kunden.Name1, 
  Kunden.Name2,
  Kunden.Name3,
  Kunden.Strasse,
  Kunden.Land,
  Kunden.PLZ,
  Kunden.Ort,
  Sachbear.Vorname, 
  Sachbear.Name, 
  Sachbear.SerienAnrede, 
  IIF(RKoOut.ID = 5, Kunden.Website, Sachbear.eMail) AS eMail, 
  RKoOut.RkoOutBez AS Ausgabeart
FROM Kunden
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN RKoOut ON Kunden.RKoOutID = RKoOut.ID
LEFT OUTER JOIN RKoMail ON RKoMail.TableID = Kunden.ID AND RKoMail.TableName = N'KUNDEN' AND RKoMail.FieldName = 'AUTOEMAIL'
LEFT OUTER JOIN Sachbear ON RKoMail.SachbearID = Sachbear.ID
WHERE (RKoOut.EMailVersand = 1 OR RKoOut.ID = 5)  --ID 5 = digital signierte Rechnung über DIG
  AND Kunden.Status = N'A'
  AND KdGf.KurzBez = N'IG'

GO
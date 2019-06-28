/* ## Prüfen auf Drückläufe, die noch Kunden enthalten ## */
SELECT DrLauf.*
FROM DrLauf
WHERE DrLauf.Bez IN (N'LEER', N'JOB WM Drucklauf (Email-Versand) EINMAL_', N'JOB WM Drucklauf (Email-Versand)_inaktiv', N'JOB WM Drucklauf monatlich_inaktiv', N'MBK Drucklauf ÖBB (INAKTIV)', N'MBK Drucklauf SANDOZ INAKTIV', N'MBK Drucklauf TOIFL- INAKTIV')
  AND EXISTS (
    SELECT Kunden.*
    FROM Kunden
    WHERE Kunden.DrLaufID = DrLauf.ID
  );

/* ############################################################################################################################################################################################### */
DECLARE @DrLaufDelete TABLE (
  ID int
);

INSERT INTO @DrLaufDelete
SELECT DrLauf.ID
FROM DrLauf
WHERE DrLauf.Bez IN (N'LEER', N'JOB WM Drucklauf (Email-Versand) EINMAL_', N'JOB WM Drucklauf (Email-Versand)_inaktiv', N'JOB WM Drucklauf monatlich_inaktiv', N'MBK Drucklauf ÖBB (INAKTIV)', N'MBK Drucklauf SANDOZ INAKTIV', N'MBK Drucklauf TOIFL- INAKTIV')
  AND NOT EXISTS (
    SELECT Kunden.*
    FROM Kunden
    WHERE Kunden.DrLaufID = DrLauf.ID
  );

UPDATE RechKo SET RechKo.DrLaufID = Kunden.DrLaufID
FROM RechKo
JOIN Kunden ON RechKo.KundenID = Kunden.ID
WHERE RechKo.DrLaufID IN (SELECT ID FROM @DrLaufDelete);

DELETE FROM DrLauf WHERE ID IN (SELECT ID FROM @DrLaufDelete);
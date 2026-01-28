SELECT LsKo.LsNr, LsKo.Datum, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], Kunden.KdNr, Kunden.SuchCode AS Kunde, LsKo.DruckZeitpunkt, ChgLogLsKo.[Timestamp]
FROM (
  SELECT ChgLog.TableID, ChgLog.[Timestamp], ChgLog.OldValue
  FROM ChgLog
  WHERE ChgLog.TableName = 'LSKO'
    AND ChgLog.FieldName = 'Status'
    AND ChgLog.MitarbeiID = (SELECT Mitarbei.ID FROM Mitarbei WHERE Mitarbei.MitarbeiUser = 'JOB')
    AND ChgLog.NewValue = 'Q'
) AS ChgLogLsKo
JOIN LsKo ON ChgLogLsKo.TableID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE EXISTS (
  SELECT Sachbear.*
  FROM SachRoll
  JOIN Sachbear ON SachRoll.SachbearID = Sachbear.ID
  WHERE Sachbear.TableID = Kunden.ID
    AND Sachbear.TableName = 'KUNDEN'
    AND SachRoll.RollenID IN (SELECT Rollen.ID FROM Rollen WHERE Rollen.LsEMail = 1)
)
OR EXISTS (
  SELECT Sachbear.*
  FROM SachRoll
  JOIN Sachbear ON SachRoll.SachbearID = Sachbear.ID
  WHERE Sachbear.TableID = Vsa.ID
    AND Sachbear.TableName = 'VSA'
    AND SachRoll.RollenID IN (SELECT Rollen.ID FROM Rollen WHERE Rollen.LsEMail = 1)
);
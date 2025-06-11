DROP TABLE IF EXISTS #SachRollCleanup;
GO

SELECT *
INTO #SachRollCleanup
FROM (
  SELECT Sachbear.ID AS SachbearID, Firma.SuchCode AS Firma, [Zone].ZonenCode, Kunden.KdNr, Kunden.SuchCode AS Kunde, Sachbear.Name, Sachbear.eMail, [hat Liefernachweis bekommen] = CAST(IIF(EXISTS(SELECT LsKo.* FROM LsKo JOIN Vsa ON LsKo.VsaID = Vsa.ID WHERE Vsa.KundenID = Kunden.ID AND LsKo.SendLsNachweis IN (2, 3)), 1, 0) AS bit)
  FROM Sachbear
  JOIN Kunden ON Sachbear.TableID = Kunden.ID AND Sachbear.TableName = N'KUNDEN'
  JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
  JOIN Firma ON Kunden.FirmaID = Firma.ID
  WHERE EXISTS (
      SELECT SachRoll.*
      FROM SachRoll
      JOIN Rollen ON SachRoll.RollenID = Rollen.ID
      WHERE SachRoll.SachbearID = Sachbear.ID
        AND Rollen.AutoLSNachw = 1
    )
    AND Kunden.[Status] = N'A'
    AND Kunden.AdrArtID = 1

  UNION

  SELECT Sachbear.ID AS SachbearID, Firma.SuchCode AS Firma, [Zone].ZonenCode, Kunden.KdNr, Kunden.SuchCode AS Kunde, Sachbear.Name, Sachbear.eMail, [hat Liefernachweis bekommen] = CAST(IIF(EXISTS(SELECT LsKo.* FROM LsKo WHERE LsKo.VsaID = Vsa.ID AND LsKo.SendLsNachweis IN (2, 3)), 1, 0) AS bit)
  FROM Sachbear
  JOIN Vsa ON Sachbear.TableID = Vsa.ID AND Sachbear.TableName = N'VSA'
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
  JOIN Firma ON Kunden.FirmaID = Firma.ID
  WHERE EXISTS (
      SELECT SachRoll.*
      FROM SachRoll
      JOIN Rollen ON SachRoll.RollenID = Rollen.ID
      WHERE SachRoll.SachbearID = Sachbear.ID
        AND Rollen.AutoLSNachw = 1
    )
    AND Vsa.[Status] = N'A'
    AND Kunden.[Status] = N'A'
    AND Kunden.AdrArtID = 1
) AS x;

GO

DELETE FROM SachRoll
WHERE SachbearID IN (SELECT SachbearID FROM #SachRollCleanup WHERE Firma != N'SMRO')
  AND RollenID IN (SELECT ID FROM Rollen WHERE AutoLSNachw = 1);

GO
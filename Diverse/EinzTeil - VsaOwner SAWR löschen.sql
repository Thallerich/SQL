DECLARE @EinTeilOwner TABLE (
  EinzTeilID int PRIMARY KEY
);

INSERT INTO @EinTeilOwner (EinzTeilID)
SELECT EinzTeil.ID
FROM EinzTeil
WHERE EinzTeil.VsaOwnerID IN (SELECT Vsa.ID FROM Vsa, Kunden WHERE Vsa.KundenID = Kunden.ID AND Kunden.KdNr = 100151)
  AND EXISTS (
    SELECT Scans.ID
    FROM Scans
    JOIN ZielNr ON Scans.ZielNrID = ZielNr.ID
    WHERE ZielNr.ProduktionsID = (SELECT ID FROM Standort WHERE Bez = N'Produktion GP Enns')
      AND Scans.[DateTime] > N'2022-01-01 00:00:00'
      AND Scans.EinzTeilID = EinzTeil.ID
  );

UPDATE EinzTeil SET VsaOwnerID = -1
WHERE ID IN (SELECT EinzTeilID FROM @EinTeilOwner);
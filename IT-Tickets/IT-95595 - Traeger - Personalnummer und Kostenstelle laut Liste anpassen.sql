SET XACT_ABORT ON;
SET NOCOUNT ON;
GO

DROP TABLE IF EXISTS #TraegerUpdate;
GO

SELECT Traeger.ID AS TraegerID, _IT95595.PersNr, Abteil.ID AS AbteilID
INTO #TraegerUpdate
FROM Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Salesianer.dbo._IT95595 ON TRY_CAST(Traeger.Traeger AS int) = _IT95595.Traeger AND ISNULL(Traeger.Nachname, N'') = ISNULL(_IT95595.Nachname, N'') AND ISNULL(Traeger.Vorname, N'') = ISNULL(_IT95595.Vorname, N'') AND Vsa.VsaNr = _IT95595.VsaNr AND Kunden.KdNr = _IT95595.KdNr
JOIN Abteil ON Abteil.KundenID = Kunden.ID AND TRY_CAST(Abteil.Abteilung AS int) = _IT95595.Kostenstelle;

GO

UPDATE Traeger SET PersNr = #TraegerUpdate.PersNr, AbteilID = #TraegerUpdate.AbteilID
FROM #TraegerUpdate
WHERE #TraegerUpdate.TraegerID = Traeger.ID;

GO
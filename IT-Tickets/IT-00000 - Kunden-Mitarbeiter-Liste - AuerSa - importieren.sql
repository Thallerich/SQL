DROP TABLE IF EXISTS #KdBerUpdate;
DROP TABLE IF EXISTS #KundenUpdate;
GO

CREATE TABLE #KdBerUpdate (
  KdBerID int PRIMARY KEY CLUSTERED,
  ServiceID int DEFAULT -1,
  VertreterID int DEFAULT -1,
  BetreuerID int DEFAULT -1
);

CREATE TABLE #KundenUpdate (
  KundenID int PRIMARY KEY CLUSTERED,
  SichtbarID int DEFAULT -1,
  AbcID int DEFAULT -1
);

GO

INSERT INTO #KdBerUpdate (KdBerID, ServiceID, VertreterID, BetreuerID)
SELECT KdBer.ID, _ImportAuerSa.ServiceID, _ImportAuerSa.VertreterID, _ImportAuerSa.BetreuerID
FROM KdBer
JOIN Kunden ON KdBer.KundenID = Kunden.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN _ImportAuerSa ON Kunden.KdNr = _ImportAuerSa.KdNr AND Bereich.BereichBez = _ImportAuerSa.Produktbereich
WHERE KdBer.ServiceID != _ImportAuerSa.ServiceID OR KdBer.VertreterID != _ImportAuerSa.VertreterID OR KdBer.BetreuerID != _ImportAuerSa.BetreuerID;

INSERT INTO #KundenUpdate (KundenID, SichtbarID, AbcID)
SELECT DISTINCT Kunden.ID, Sichtbar.ID, Abc.ID
FROM Kunden
JOIN _ImportAuerSa ON Kunden.KdNr = _ImportAuerSa.KdNr
LEFT JOIN Sichtbar ON _ImportAuerSa.Sichtbarkeit = Sichtbar.Bez
LEFT JOIN Abc ON _ImportAuerSa.[ABC-Klasse] = Abc.ABCBez

GO

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE KdBer SET ServiceID = #KdBerUpdate.ServiceID, BetreuerID = #KdBerUpdate.BetreuerID, VertreterID = #KdBerUpdate.VertreterID
    FROM #KdBerUpdate
    WHERE #KdBerUpdate.KdBerID = KdBer.ID;

    UPDATE VsaBer SET ServiceID = #KdBerUpdate.ServiceID, BetreuerID = #KdBerUpdate.BetreuerID, VertreterID = #KdBerUpdate.VertreterID
    FRoM #KdBerUpdate
    WHERE #KdBerUpdate.KdBerID = VsaBer.KdBerID;

    UPDATE Kunden SET SichtbarID = #KundenUpdate.SichtbarID, AbcID = #KundenUpdate.AbcID
    FROM #KundenUpdate
    WHERE #KundenUpdate.KundenID = Kunden.ID;
  
  COMMIT;
END TRY
BEGIN CATCH
  DECLARE @Message varchar(MAX) = ERROR_MESSAGE();
  DECLARE @Severity int = ERROR_SEVERITY();
  DECLARE @State smallint = ERROR_STATE();
  
  IF XACT_STATE() != 0
    ROLLBACK TRANSACTION;
  
  RAISERROR(@Message, @Severity, @State) WITH NOWAIT;
END CATCH;

GO

DROP TABLE #KdBerUpdate;
DROP TABLE #KundenUpdate;
DROP TABLE _ImportAuerSa;

GO
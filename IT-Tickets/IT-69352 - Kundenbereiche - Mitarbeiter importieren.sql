DECLARE @KdBerUpdated TABLE (
  KdBerID int,
  ServiceID int,
  VertreterID int,
  BetreuerID int
);

BEGIN TRY
  BEGIN TRANSACTION;
  
    WITH ImportData AS (
      SELECT KdBer.ID AS KdBerID, ISNULL(ServiceMA.ID, -1) AS ServiceID, ISNULL(VertreterMA.ID, -1) AS VertreterID, ISNULL(BetreuerMA.ID, -1) AS BetreuerID, ISNULL(FakturaMA.ID, -1) AS RechKoServiceID
      FROM _IT69352
      JOIN Kunden ON _IT69352.KdNr = Kunden.KdNr
      JOIN Bereich ON _IT69352.Bereich = Bereich.Bereich
      JOIN KdBer ON Kunden.ID = KdBer.KundenID AND Bereich.ID = KdBer.BereichID
      LEFT JOIN Mitarbei ServiceMA ON _IT69352.Kundenservice = ServiceMA.Name
      LEFT JOIN Mitarbei VertreterMA ON _IT69352.Vertrieb = VertreterMA.Name
      LEFT JOIN Mitarbei BetreuerMA ON _IT69352.Betreuung = BetreuerMA.Name
      LEFT JOIN Mitarbei FakturaMA ON _IT69352.Rechnung = FakturaMA.Name
    )
    UPDATE KdBer SET ServiceID = ImportData.ServiceID, VertreterID = ImportData.VertreterID, BetreuerID = ImportData.BetreuerID, RechKoServiceID = ImportData.RechKoServiceID
    OUTPUT inserted.ID, inserted.ServiceID, inserted.VertreterID, inserted.BetreuerID
    INTO @KdBerUpdated (KdBerID, ServiceID, VertreterID, BetreuerID)
    FROM ImportData
    WHERE ImportData.KdBerID = KdBer.ID;

    UPDATE VsaBer SET ServiceID = KdBerUpdated.ServiceID, VertreterID = KdBerUpdated.VertreterID, BetreuerID = KdBerUpdated.BetreuerID
    FROM @KdBerUpdated KdBerUpdated
    WHERE KdBerUpdated.KdBerID = VsaBer.KdBerID;
  
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
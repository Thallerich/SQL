DECLARE @maxvertragnr int;
DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

DECLARE @PeKunden TABLE (
  VertragID int PRIMARY KEY CLUSTERED,
  KundenID int,
  KdBerID int,
  AddNr int
);

DECLARE @NewVertrag TABLE (
  VertragID int,
  KundenID int,
  BereichID int
);

INSERT INTO @PeKunden (VertragID, KundenID, KdBerID, AddNr)
SELECT DISTINCT Vertrag.ID, Vertrag.KundenID, KdBer.ID AS KdBerID, DENSE_RANK() OVER (ORDER BY Vertrag.ID) AS AddNr
FROM PePo
JOIN Vertrag ON PePo.VertragID = Vertrag.ID
JOIN KdBer ON KdBer.VertragID = Vertrag.ID
WHERE PePo.PeKoID = 1192
  AND KdBer.BereichID = (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich = N'FW');

BEGIN TRY
  BEGIN TRANSACTION;

    SELECT @maxvertragnr = MAX(Nr) FROM Vertrag;

    INSERT INTO Vertrag (KundenID, Bez, [Status], Nr, VertTypID, VertragAbschluss, VertragStart, VertragEnde, VertragFristErst, VertragFrist, VertragVerlaeng, Preisgarantie, AbschlussID, StartGruID, EingabeDatum, BereichID, PrLaufID, VertragAnlageID, VertragBearbeiID, AnlageUserID_, UserID_)
    OUTPUT inserted.ID, inserted.KundenID, inserted.BereichID
    INTO @NewVertrag (VertragID, KundenID, BereichID)
    SELECT Vertrag.KundenID, Vertrag.Bez + N' - FW', Vertrag.[Status], [@PeKunden].AddNr + @maxvertragnr AS Nr, Vertrag.VertTypID, Vertrag.VertragAbschluss, Vertrag.VertragStart, Vertrag.VertragEnde, Vertrag.VertragFristErst, Vertrag.VertragFrist, Vertrag.VertragVerlaeng, Vertrag.Preisgarantie, Vertrag.AbschlussID, Vertrag.StartGruID, Vertrag.EingabeDatum, Bereich.ID AS BereichID, Vertrag.PrLaufID, Vertrag.VertragAnlageID, Vertrag.VertragBearbeiID, @userid AS AnlageUserID_, @userid AS UserID_
    FROM Vertrag
    JOIN @PeKunden ON [@PeKunden].[VertragID] = Vertrag.ID
    CROSS JOIN Bereich
    WHERE Bereich.Bereich = N'FW';

    UPDATE KdBer SET VertragID = [@NewVertrag].VertragID
    FROM @NewVertrag
    WHERE KdBer.KundenID = [@NewVertrag].KundenID
      AND KdBer.BereichID = [@NewVertrag].BereichID;
  
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
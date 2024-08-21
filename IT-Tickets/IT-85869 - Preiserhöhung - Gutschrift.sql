DROP TABLE IF EXISTS #Customer;
GO

CREATE TABLE #Customer (
  RechPoID int NOT NULL,
  RechKoID int NOT NULL,
  NewRechKoID int NOT NULL DEFAULT -1,
  Prozentsatz numeric(18, 4),
  RechMemotext nvarchar(107)
);

GO

DECLARE @rechdat date = N'2024-08-11';
DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

INSERT INTO #Customer (RechPoID, RechKoID, Prozentsatz, RechMemotext)
SELECT RechPo.ID, RechKo.ID, 2.21 AS Prozentsatz, N'Gutschrift Preiserhöhung von 2,21% zur Rechnung '  + CAST(RechKo.RechNr AS nvarchar) AS RechMemotext
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
WHERE Holding.Holding IN (N'VOES', N'VOESAN', N'VOESLE')
  AND Kunden.FirmaID = (SELECT ID FROM Firma WHERE SuchCode = N'FA14')
  AND Kunden.AdrArtID = 1
  AND RechKo.RechDat = @rechdat
  AND NOT EXISTS (
    SELECT Gutschrift.*
    FROM RechPo AS Gutschrift
    WHERE Gutschrift.OriginalRechPoID = RechPo.ID
  )
  AND EXISTS (
    SELECT PePo.*
    FROM PePo
    JOIN PeKo ON PePo.PeKoID = PeKo.ID
    JOIN Vertrag ON PePo.VertragID = Vertrag.ID
    WHERE Vertrag.KundenID = Kunden.ID
      AND PeKo.WirksamDatum = N'2024-07-01'
      AND PePo.[Status] = N'R'
      AND PePo.PeProzent = 2.21
  );

GO

DECLARE @NewRechKo TABLE (
  RechKoID int,
  NewRechKoID int
);

INSERT INTO @NewRechKo (RechKoID)
SELECT DISTINCT #Customer.RechKoID
FROM #Customer;

UPDATE @NewRechKo SET NewRechKoID = NEXT VALUE FOR NextID_RECHKO;

UPDATE #Customer SET NewRechKoID = [@NewRechKo].NewRechKoID
FROM @NewRechKo
WHERE #Customer.RechKoID = [@NewRechKo].RechKoID;

GO

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

BEGIN TRY
  BEGIN TRANSACTION;
  
    INSERT INTO RechKo (ID, RechNr, RechDat, LeistDat, Art, [Status], RKoTypeID, KundenID, AbteilID, VsaID, RechAdrID, VertragWaeID, RechWaeID, WaeKursID, FirmaID, Debitor, Name1, Name2, Name3, Strasse, Strasse2, Land, PLZ, Ort, Region, AdressBlock, Skonto, MWStID, MwStSatz, MWSt2ID, MemoFuss, VonDatum, BisDatum, ErsteWo, Positionen, FaelligDat, EffektivBis, DrLaufID, RKoOutID, LanguageID, FakFreqID, BasisRechKoID, ZahlArtID, ZahlZielID, TourenID, MwStDat, MwStWaeKursID, AnlageUserID_, UserID_)
    SELECT x.NewRechKoID AS ID,
      x.NewRechKoID * -1 - 2 AS RechNr,
      CAST(GETDATE() AS date) AS RechDat,
      CAST(GETDATE() AS date) AS LeistDat,
      N'G' AS Art,
      N'B' AS [Status],
      RechKo.RKoTypeID,
      RechKo.KundenID,
      RechKo.AbteilID,
      RechKo.VsaID,
      RechKo.RechAdrID,
      RechKo.VertragWaeID,
      RechKo.RechWaeID,
      RechKo.WaeKursID,
      RechKo.FirmaID,
      RechKo.Debitor,
      RechKo.Name1,
      RechKo.Name2,
      RechKo.Name3,
      RechKo.Strasse,
      RechKo.Strasse2,
      RechKo.Land,
      RechKo.PLZ,
      RechKo.Ort,
      RechKo.Region,
      RechKo.AdressBlock,
      RechKo.Skonto,
      RechKo.MWStID,
      RechKo.MwStSatz,
      RechKo.MWSt2ID,
      RechKo.MemoFuss,
      RechKo.VonDatum,
      RechKo.BisDatum,
      RechKo.ErsteWo,
      x.Positionen,
      CAST(GETDATE() AS date) AS FaelligDat,
      RechKo.EffektivBis,
      RechKo.DrLaufID,
      RechKo.RKoOutID,
      RechKo.LanguageID,
      RechKo.FakFreqID,
      RechKo.ID AS BasisRechKoID,
      RechKo.ZahlArtID,
      RechKo.ZahlZielID,
      RechKo.TourenID,
      RechKo.MwStDat,
      RechKo.MwStWaeKursID,
      @userid AS AnlageUserID_,
      @userid AS UserID_
    FROM RechKo
    JOIN (SELECT RechKoID, NewRechKoID, RechMemotext, COUNT(DISTINCT RechPoID) AS Positionen FROM #Customer GROUP BY RechKoID, NewRechKoID, RechMemotext) AS x ON x.RechKoID = RechKo.ID;

    UPDATE RechKo SET BasisRechKoID = x.NewRechKoID
    FROM (SELECT DISTINCT RechKoID, NewRechKoID FROM #Customer) AS x
    WHERE RechKo.ID = x.RechKoID
      AND RechKo.BasisRechKoID = -1;

    INSERT INTO RechPo (RechKoID, AbteilID, VsaID, BereichID, RPoTypeID, KdBerID, KontenID, MwStID, Bez, Menge, Menge1, Menge2, Menge3, Menge4, Menge5, Menge6, EPreis, EPreisVertWae, Sonderpreis, RabattProz, Rabatt, GPreis, GPreisVertWae, FixedRechPreis, SteuerSchl, KsSt, OriginalRechPoID, KdArtiID, ArtGruID, VonDatum, BisDatum, AnzWochen, Memo, AnzPerioden, KdFeeID, LeasPrKzID, ProduktionID, ExpeditionID, AnlageUserID_, UserID_)
    SELECT #Customer.NewRechKoID,
      RechPo.AbteilID,
      RechPo.VsaID,
      RechPo.BereichID,
      RechPo.RPoTypeID,
      RechPo.KdBerID,
      RechPo.KontenID,
      RechPo.MwStID,
      RechPo.Bez,
      RechPo.Menge * -1 AS Menge,
      RechPo.Menge1 * -1 AS Menge1,
      RechPo.Menge2 * -1 AS Menge2,
      RechPo.Menge3 * -1 AS Menge3,
      RechPo.Menge4 * -1 AS Menge4,
      RechPo.Menge5 * -1 AS Menge5,
      RechPo.Menge6 * -1 AS Menge6,
      ROUND(CAST(RechPo.EPreis / 100 * #Customer.Prozentsatz AS money), 3) AS EPreis,
      ROUND(CAST(RechPo.EPreisVertWae / 100 * #Customer.Prozentsatz AS money), 3) AS EPreisVertWae,
      RechPo.Sonderpreis,
      RechPo.RabattProz,
      ROUND(CAST(CAST((RechPo.EPreis / 100 * #Customer.Prozentsatz) * Menge AS money) / CAST(100 AS numeric(18, 4)) * RechPo.RabattProz AS money), 2) AS Rabatt,
      ROUND(CAST((RechPo.EPreis / 100 * #Customer.Prozentsatz) * Menge AS money), 2) AS GPreis,
      ROUND(CAST((RechPo.EPreisVertWae / 100 * #Customer.Prozentsatz) * Menge AS money), 2) AS GPreisVertWae,
      RechPo.FixedRechPreis,
      RechPo.SteuerSchl,
      RechPo.KsSt,
      #Customer.RechPoID AS OriginalRechPoID,
      RechPo.KdArtiID,
      RechPo.ArtGruID,
      RechPo.VonDatum,
      RechPo.BisDatum,
      RechPo.AnzWochen,
      ISNULL(RechPo.Memo + CHAR(13) + CHAR(10), N'') + #Customer.RechMemotext AS Memo,
      RechPo.AnzPerioden,
      RechPo.KdFeeID,
      RechPo.LeasPrKzID,
      RechPo.ProduktionID,
      RechPo.ExpeditionID,
      @userid AS AnlageUserID_,
      @userid AS UserID_
    FROM RechPo
    JOIN #Customer ON #Customer.RechPoID = RechPo.ID;
  
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

DROP TABLE #Customer;
GO
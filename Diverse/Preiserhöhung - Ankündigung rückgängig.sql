DECLARE @PeBack TABLE (
  KdArtiID int,
  WaschPreis money,
  LeasPreis money,
  VkPreis money,
  SonderPreis money,
  LeasPreisAbwAbWo money,
  BasisRestwert money,
  PePoID int
);

DECLARE @VsaTexte TABLE (
  VsaTextID int
);

DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');
DECLARE @PeKoID int = 1140;

WITH PE AS (
  SELECT PeKo.ID, PeKo.AnkuendDatum, PeKo.AnkuendMitarbeiID, PeKo.WirksamDatum
  FROM PeKo
  WHERE PeKo.ID = @PeKoID
)
INSERT INTO @VsaTexte (VsaTextID)
SELECT VsaTexte.ID
FROM VsaTexte
CROSS JOIN PE
WHERE VsaTexte.TextArtID = 13
  AND VsaTexte.VonDatum = PE.WirksamDatum
  AND CAST(VsaTexte.Anlage_ AS date) = PE.AnkuendDatum
  AND VsaTexte.AnlageUserID_ = PE.AnkuendMitarbeiID;

BEGIN TRY

  BEGIN TRANSACTION;

    DELETE FROM PrArchiv
    WHERE PrArchiv.PeKoID = @PeKoID;

    UPDATE PeKo SET [Status] = N'C', AnkuendDatum = NULL, AnkuendMitarbeiID = -1
    WHERE PeKo.ID = @PeKoID;

    DELETE FROM VsaTexte
    WHERE VsaTexte.ID IN (SELECT VsaTextID FROM @VsaTexte);
  
  COMMIT;
END TRY
BEGIN CATCH
  DECLARE @Message varchar(MAX) = ERROR_MESSAGE();
  DECLARE @Severity int = ERROR_SEVERITY();
  DECLARE @State smallint = ERROR_STATE();

  IF XACT_STATE() != 0
    ROLLBACK TRANSACTION;
 
  RAISERROR(@Message, @Severity, @State);
END CATCH;
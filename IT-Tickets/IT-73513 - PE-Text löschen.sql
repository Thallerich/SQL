SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, TextArt.TextArtBez AS [Text-Art], Mitarbei.UserName AS [angelegt von], VsaTexte.Anlage_ AS [angelegt am], VsaTexte.VonDatum AS [gültig ab], VsaTexte.BisDatum AS [gültig bis], VSaTexte.Memo AS [Text]
FROM VsaTexte
JOIN Kunden ON VsaTexte.KundenID = Kunden.ID
JOIN TextArt ON VsaTexte.TextArtID = TextArt.ID
JOIN Mitarbei ON VsaTexte.AnlageUserID_ = Mitarbei.ID
WHERE EXISTS (
    SELECT Vertrag.*
    FROM Vertrag
    WHERE Vertrag.KundenID = Kunden.ID
      AND Vertrag.ID IN (
        SELECT PePo.VertragID
        FROM PePo
        WHERE PePo.PeKoID IN (
            SELECT PeKo.ID
            FROM PeKo
            WHERE PeKo.Bez IN ('PE JULI 2023 "N" GAST', 'PE JULI 2023 "V" BM', 'PE JULI 2023 "V" GAST', 'PE JULI 2023 "N" BM')
          )
          AND PePo.[Status] = N'R'
      )
  )
  AND Kunden.HoldingID IN (
    SELECT Holding.ID
    FROM Holding
    WHERE Holding.Holding IN (N'HOGD', N'HGP')
  )
  AND CAST(GETDATE() AS date) BETWEEN VsaTexte.VonDatum AND VsaTexte.BisDatum
  AND VsaTexte.TextArtID = (
    SELECT TextArt.ID
    FROM TextArt
    WHERE TextArt.TextArtBez = N'Fakturatext Fuß'
  )
  AND VsaTexte.AnlageUserID_ IN (
    SELECT PeKo.DurchfuehrungMitarbeiID
    FROM PeKo
    WHERE PeKo.Bez IN ('PE JULI 2023 "N" GAST', 'PE JULI 2023 "V" BM', 'PE JULI 2023 "V" GAST', 'PE JULI 2023 "N" BM')
  );

GO

DECLARE @TextDelete TABLE (
  VsaTextID int
);

INSERT INTO @TextDelete (VsaTextID)
SELECT VsaTexte.ID
FROM VsaTexte
JOIN Kunden ON VsaTexte.KundenID = Kunden.ID
JOIN TextArt ON VsaTexte.TextArtID = TextArt.ID
WHERE EXISTS (
    SELECT Vertrag.*
    FROM Vertrag
    WHERE Vertrag.KundenID = Kunden.ID
      AND Vertrag.ID IN (
        SELECT PePo.VertragID
        FROM PePo
        WHERE PePo.PeKoID IN (
            SELECT PeKo.ID
            FROM PeKo
            WHERE PeKo.Bez IN ('PE JULI 2023 "N" GAST', 'PE JULI 2023 "V" BM', 'PE JULI 2023 "V" GAST', 'PE JULI 2023 "N" BM')
          )
          AND PePo.[Status] = N'R'
      )
  )
  AND Kunden.HoldingID IN (
    SELECT Holding.ID
    FROM Holding
    WHERE Holding.Holding IN (N'HOGD', N'HGP')
  )
  AND CAST(GETDATE() AS date) BETWEEN VsaTexte.VonDatum AND VsaTexte.BisDatum
  AND VsaTexte.TextArtID = (
    SELECT TextArt.ID
    FROM TextArt
    WHERE TextArt.TextArtBez = N'Fakturatext Fuß'
  )
  AND VsaTexte.AnlageUserID_ IN (
    SELECT PeKo.DurchfuehrungMitarbeiID
    FROM PeKo
    WHERE PeKo.Bez IN ('PE JULI 2023 "N" GAST', 'PE JULI 2023 "V" BM', 'PE JULI 2023 "V" GAST', 'PE JULI 2023 "N" BM')
  );

BEGIN TRY
  BEGIN TRANSACTION;
  
    DELETE FROM VsaTexte
    WHERE VsaTexte.ID IN (
      SELECT VsaTextID
      FROM @TextDelete
    );
  
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
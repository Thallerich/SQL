/* Do not run on DB Salesianer - remove when development is finished */
SET NOEXEC OFF;

IF DB_NAME() = N'Salesianer'
  SET NOEXEC ON;

GO

/* -- */

PRINT N'Begin execution...';
GO

DROP TABLE IF EXISTS #LsPoMerge;

GO

DECLARE @customer int = 30686;
DECLARE @costcenter nchar(1) = N'-';

DECLARE @kundenid int = (SELECT ID FROM Kunden WHERE KdNr = @customer);
DECLARE @abteilid int = (SELECT ID FROM Abteil WHERE KundenID = @kundenid AND Abteilung = @costcenter);

CREATE TABLE #LsPoMerge (
  LsKoID int NOT NULL,
  LsPoIDOld int NOT NULL,
  LsPoIDNew int NOT NULL DEFAULT -1
);

BEGIN TRY
  BEGIN TRANSACTION;

    INSERT INTO #LsPoMerge (LsKoID, LsPoIDOld)
    SELECT LsPo.LsKoID, LsPo.ID AS LsPoID
    FROM LsPo
    WHERE LsPo.LsKoID IN (
      SELECT LsKo.ID
      FROM LsKo
      JOIN Vsa ON LsKo.VsaID = Vsa.ID
      WHERE LsKo.Status < N'W'
        AND Vsa.KundenID = @kundenid
        AND EXISTS (
          SELECT Pos.*
          FROM LsPo Pos
          WHERE Pos.LsKoID = LsKo.ID
            AND Pos.AbteilID != @abteilid
        )
    );

    MERGE INTO LsPo USING (
      SELECT LsPo.LsKoID, @abteilid AS AbteilID, LsPo.KdArtiID, LsPo.Kostenlos, LsPo.ArtGroeID, LsPo.VsaOrtID, SUM(LsPo.Menge) AS Menge, SUM(LsPo.MengeZurueck) AS MengeZurueck, SUM(LsPo.MengeReserviert) AS MengeReserviert, SUM(LsPo.MengeEntnommen) AS MengeEntnommen, SUM(LsPo.UrMenge) AS UrMenge, SUM(LsPo.NachLief) AS NachLief, MAX(LsPo.EPreis) AS EPreis, SUM(LsPo.FehlMenge) AS FehlMenge, CAST(MAX(CAST(LsPo.PreisBelassen AS tinyint)) AS bit) AS PreisBelassen, MAX(LsPo.EPreisRech) AS EPreisRech, LsPo.WaeKursID, CAST(MAX(CAST(LsPo.IgnoreFreimenge AS tinyint)) AS bit) AS IgnoreFreimenge, -1 AS RechPoID, CAST(MAX(CAST(LsPo.Prognose AS tinyint)) AS bit) AS Prognose, LsPo.ProduktionID, MAX(LsPo.EkPreis) AS EKPreis, LsPo.TraegerID, LsPo.LagerOrtID, LsPo.LsKoGruID, LsPo.VpsKoID, MAX(LsPo.InternKalkPreis) AS InternKalkPreis
      FROM LsPo
      WHERE LsPo.ID IN (SELECT LsPoIDOld FROM #LsPoMerge)
      GROUP BY LsPo.LsKoID, LsPo.KdArtiID, LsPo.Kostenlos, LsPo.ArtGroeID, LsPo.VsaOrtID, LsPo.WaeKursID, LsPo.ProduktionID, LsPo.TraegerID, LsPo.LagerOrtID, LsPo.LsKoGruID, LsPo.VpsKoID
    ) AS CombinedLsPo (LsKoID, AbteilID, KdArtiID, Kostenlos, ArtGroeID, VsaOrtID, Menge, MengeZurueck, MengeReserviert, MengeEntnommen, UrMenge, NachLief, EPreis, FehlMenge, PreisBelassen, EPreisRech, WaeKursID, IgnoreFreimenge, RechPoID, Prognose, ProduktionID, EKPreis, TraegerID, LagerOrtID, LsKoGruID, VpsKoID, InternKalkPreis)
    ON LsPo.LsKoID = CombinedLsPo.LsKoID AND LsPo.AbteilID = CombinedLsPo.AbteilID AND LsPo.KdArtiID = CombinedLsPo.KdArtiID AND LsPo.Kostenlos = CombinedLsPo.Kostenlos AND LsPo.ArtGroeID = CombinedLsPo.ArtGroeID AND LsPo.VsaOrtID = CombinedLsPo.VsaOrtID AND LsPo.WaeKursID = CombinedLsPo.WaeKursID AND LsPo.ProduktionID = CombinedLsPo.ProduktionID AND LsPo.TraegerID = CombinedLsPo.TraegerID AND LsPo.LagerOrtID = CombinedLsPo.LagerOrtID AND LsPo.LsKoGruID = CombinedLsPo.LsKoGruID AND LsPo.VpsKoID = CombinedLsPo.VpsKoID
    WHEN MATCHED THEN
      UPDATE SET Menge = CombinedLsPo.Menge, MengeZurueck = CombinedLsPo.MengeZurueck, MengeReserviert = CombinedLsPo.MengeReserviert, MengeEntnommen = CombinedLsPo.MengeEntnommen, UrMenge = CombinedLsPo.UrMenge, Nachlief = CombinedLsPo.Nachlief, EPreis = CombinedLsPo.EPreis, FehlMenge = CombinedLsPo.FehlMenge, PreisBelassen = CombinedLsPo.PreisBelassen, EPreisRech = CombinedLsPo.EPreisRech, IgnoreFreimenge = CombinedLsPo.IgnoreFreimenge, Prognose = CombinedLsPo.Prognose, EKPreis = CombinedLsPo.EKPreis, InternKalkPreis = CombinedLsPo.InternKalkPreis
    WHEN NOT MATCHED THEN
      INSERT (LsKoID, AbteilID, KdArtiID, Kostenlos, ArtGroeID, VsaOrtID, Menge, MengeZurueck, MengeReserviert, MengeEntnommen, UrMenge, NachLief, EPreis, FehlMenge, PreisBelassen, EPreisRech, WaeKursID, IgnoreFreimenge, RechPoID, Prognose, ProduktionID, EKPreis, TraegerID, LagerOrtID, LsKoGruID, VpsKoID, InternKalkPreis)
      VALUES (CombinedLsPo.LsKoID, CombinedLsPo.AbteilID, CombinedLsPo.KdArtiID, CombinedLsPo.Kostenlos, CombinedLsPo.ArtGroeID, CombinedLsPo.VsaOrtID, CombinedLsPo.Menge, CombinedLsPo.MengeZurueck, CombinedLsPo.MengeReserviert, CombinedLsPo.MengeEntnommen, CombinedLsPo.UrMenge, CombinedLsPo.NachLief, CombinedLsPo.EPreis, CombinedLsPo.FehlMenge, CombinedLsPo.PreisBelassen, CombinedLsPo.EPreisRech, CombinedLsPo.WaeKursID, CombinedLsPo.IgnoreFreimenge, CombinedLsPo.RechPoID, CombinedLsPo.Prognose, CombinedLsPo.ProduktionID, CombinedLsPo.EKPreis, CombinedLsPo.TraegerID, CombinedLsPo.LagerOrtID, CombinedLsPo.LsKoGruID, CombinedLsPo.VpsKoID, CombinedLsPo.InternKalkPreis);
    
    UPDATE #LsPoMerge SET LsPoIDNew = LsPoMap.LsPoIDNew
    FROM (
      SELECT LsPo.ID AS LsPoIDOld, NewLsPo.LsPoID AS LsPoIDNew
      FROM LsPo
      JOIN (
        SELECT LsPo.ID AS LsPoID, LsPo.LsKoID, LsPo.AbteilID, LsPo.KdArtiID, LsPo.Kostenlos, LsPo.ArtGroeID, LsPo.VsaOrtID, LsPo.LagerOrtID, LsPo.LsKoGruID, LsPo.VpsKoID, LsPo.TraegerID
        FROM LsPo
        WHERE LsPo.LsKoID IN (SELECT LsKoID FROM #LsPoMerge)
          AND LsPo.AbteilID = @abteilid
      ) NewLsPo ON LsPo.LsKoID = NewLsPo.LsKoID AND LsPo.KdArtiID = NewLsPo.KdArtiID AND LsPo.Kostenlos = NewLsPo.Kostenlos AND LsPo.ArtGroeID = NewLsPo.ArtGroeID AND LsPo.VsaOrtID = NewLsPo.VsaOrtID AND LsPo.LagerOrtID = NewLsPo.LagerOrtID AND LsPo.LsKoGruID = NewLsPo.LagerOrtID AND LsPo.VpsKoID = NewLsPo.VpsKoID AND LsPo.TraegerID = NewLsPo.TraegerID
    ) LsPoMap
    WHERE LsPoMap.LsPoIDOld = #LsPoMerge.LsPoIDOld;

    UPDATE Scans SET LsPoID = #LsPoMerge.LsPoIDNew
    FROM #LsPoMerge
    WHERE Scans.LsPoID = #LsPoMerge.LsPoIDOld
      AND #LsPoMerge.LsPoIDOld != #LsPoMerge.LsPoIDNew;

    UPDATE EinzHist SET LastLsPoID = #LsPoMerge.LsPoIDNew
    FROM #LsPoMerge
    WHERE EinzHist.LastLsPoID = #LsPoMerge.LsPoIDOld
      AND #LsPoMerge.LsPoIDOld != #LsPoMerge.LsPoIDNew;

    DELETE FROM LsPo
    WHERE ID IN (SELECT LsPoIDOld FROM #LsPoMerge WHERE LsPoIDOld != LsPoIDNew);

    UPDATE AnfPo SET AbteilID = @abteilid
    WHERE ID IN (
      SELECT AnfPo.ID
      FROM AnfPo
      JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
      JOIN LsKo ON AnfKo.LsKoID = LsKo.ID
      JOIN Vsa ON AnfKo.VsaID = Vsa.ID
      WHERE Vsa.KundenID = @kundenid
        AND LsKo.[Status] < N'W'
        AND AnfKo.LieferDatum > N'2023-03-01'
        AND AnfPo.AbteilID != @abteilid
    );

    UPDATE MsgTrae SET AbteilID = @abteilid
    WHERE ID IN (
      SELECT MsgTrae.ID
      FROM MsgTrae
      JOIN WebUser ON MsgTrae.WebuserID = WebUser.ID
      WHERE WebUser.KundenID = @kundenid
        AND MsgTrae.[Status] < N'U'
        AND MsgTrae.AbteilID != @abteilid
    );

    UPDATE MsgVsAnf SET AbteilID = @abteilid
    WHERE ID IN (
      SELECT MsgVsAnf.ID
      FROM MsgVsAnf
      JOIN WebUser ON MsgVsAnf.WebuserID = WebUser.ID
      WHERE WebUser.KundenID = @kundenid
        AND MsgVsAnf.[Status] < N'U'
        AND MsgVsAnf.AbteilID != @abteilid
    );

    UPDATE Schrank SET AbteilID = @abteilid
    WHERE ID IN (
      SELECT Schrank.ID
      FROM Schrank
      JOIN Vsa ON Schrank.VsaID = Vsa.ID
      WHERE Vsa.KundenID = @kundenid
        AND Schrank.AbteilID != @abteilid
    );

    UPDATE Traeger SET AbteilID = @abteilid
    WHERE ID IN (
      SELECT Traeger.ID
      FROM Traeger
      JOIN Vsa ON Traeger.VsaID = Vsa.ID
      WHERE Vsa.KundenID = @kundenid
        AND Traeger.AbteilID != @abteilid
    );

    UPDATE Vsa SET AbteilID = @abteilid
    WHERE ID IN (
      SELECT Vsa.ID
      FROM Vsa
      WHERE Vsa.KundenID = @kundenid
        AND Vsa.AbteilID != @abteilid
    );
      
    UPDATE VsaAnf SET AbteilID = @abteilid
    WHERE ID IN (
      SELECT VsaAnf.ID
      FROM VsaAnf
      JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
      WHERE Vsa.KundenID = @kundenid
        AND VsaAnf.AbteilID != @abteilid
    );

    UPDATE VsaLeas SET AbteilID = @abteilid
    WHERE ID IN (
      SELECT VsaLeas.ID
      FROM VsaLeas
      JOIN Vsa ON VsaLeas.VsaID = Vsa.ID
      WHERE Vsa.KundenID = @kundenid
        AND FORMAT(DATEPART(year, GETDATE()), N'0000') + N'/' + FORMAT(DATEPART(week, GETDATE()), N'00') BETWEEN Vsaleas.InDienst AND ISNULL(VsaLeas.AusDienst, N'2099/52')
        AND VsaLeas.AbteilID != @abteilid
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
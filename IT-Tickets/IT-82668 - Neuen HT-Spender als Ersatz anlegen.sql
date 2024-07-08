/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ALTER TABLE _IT82668
     ADD KundenID int,
         ArtikelID_Alt int,
         ArtikelID_Neu int;
   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #KdArtiSrc, #KdArtiNew;
GO

DECLARE @article_new nchar(15) = N'BD718MW';
DECLARE @articleid_new int;
DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

DECLARE @PreisChanged TABLE (
  KdArtiID int,
  LeasPreis money,
  WaschPreis money,
  SonderPreis money,
  VKPreis money,
  BasisRestwert money,
  LeasPreisAbwAbWo money,
  LeasPreisPrListKdArtiID int,
  WaschPreisPrListKdArtiID int,
  SondPreisPrListKdArtiID int,
  VkPreisPrListKdArtiID int,
  BasisRWPrListKdArtiID int
);

SELECT @articleid_new = Artikel.ID
FROM Artikel
WHERE Artikel.ArtikelNr = @article_new;

UPDATE _IT82668 SET KundenID = Kunden.ID, ArtikelID_Alt = Artikel.ID, ArtikelID_Neu = @articleid_new
FROM _IT82668
JOIN Kunden ON _IT82668.KdNr = Kunden.KdNr
JOIN Artikel ON _IT82668.ArtikelNr = Artikel.ArtikelNr
WHERE _IT82668.KundenID IS NULL OR _IT82668.ArtikelID_Alt IS NULL OR _IT82668.ArtikelID_Neu IS NULL;

WITH UniqueSrc AS (
  SELECT x.KundenID
  FROM (
    SELECT DISTINCT _IT82668.KundenID, _IT82668.ArtikelID_Neu, KdArti.[Status], KdArti.WaschPreis, KdArti.LeasPreis
    FROM KdArti
    JOIN _IT82668 ON KdArti.ArtikelID = _IT82668.ArtikelID_Alt AND KdArti.KundenID = _IT82668.KundenID
    WHERE KdArti.[Status] = N'A'
  ) AS x
  GROUP BY x.KundenID
  HAVING COUNT(*) = 1
)
SELECT KdArtiID = (
  SELECT TOP 1 KdArti.ID
  FROM KdArti
  JOIN _IT82668 ON _IT82668.KundenID = KdArti.KundenID AND _IT82668.ArtikelID_Alt = KdArti.ArtikelID
  WHERE KdArti.KundenID = UniqueSrc.KundenID
)
INTO #KdArtiSrc
FROM UniqueSrc;

SELECT KdArti.*
INTO #KdArtiNew
FROM KdArti
WHERE KdArti.ID IN (SELECT KdArtiID FROM #KdArtiSrc)
  AND NOT EXISTS (
    SELECT k.*
    FROM KdArti AS k
    WHERE k.KundenID = KdArti.KundenID
      AND k.ArtikelID = @articleid_new
  );

BEGIN TRY
  BEGIN TRANSACTION;

    UPDATE #KdArtiNew SET ID = NEXT VALUE FOR NextID_KDARTI, ArtikelID = @articleid_new, Umlauf = 0, AnlageUserID_ = @userid, Anlage_ = GETDATE(), UserID_ = @userid, Update_ = GETDATE();

    INSERT INTO KdArti
    OUTPUT inserted.ID, inserted.LeasPreis, inserted.WaschPreis, inserted.SonderPreis, inserted.VkPreis, inserted.BasisRestwert, inserted.LeasPreisAbwAbWo, inserted.LeasPreisPrListKdArtiID, inserted.WaschPreisPrListKdArtiID, inserted.SondPreisPrListKdArtiID, inserted.VkPreisPrListKdArtiID, inserted.BasisRWPrListKdArtiID
    INTO @PreisChanged (KdArtiID, LeasPreis, WaschPreis, SonderPreis, VKPreis, BasisRestwert, LeasPreisAbwAbWo, LeasPreisPrListKdArtiID, WaschPreisPrListKdArtiID, SondPreisPrListKdArtiID, VkPreisPrListKdArtiID, BasisRWPrListKdArtiID)
    SELECT *
    FROM #KdArtiNew;

    INSERT INTO PrArchiv (KdArtiID, Datum, LeasPreis, WaschPreis, SonderPreis, VKPreis, BasisRestwert, LeasPreisAbwAbWo, MitarbeiID, Aktivierungszeitpunkt, LeasPreisPrListKdArtiID, WaschPreisPrListKdArtiID, SondPreisPrListKdArtiID, VkPreisPrListKdArtiID, BasisRWPrListKdArtiID, AnlageUserID_, UserID_)
    SELECT KdArtiID, CAST(GETDATE() AS date) AS Datum, LeasPreis, WaschPreis, SonderPreis, VKPreis, BasisRestwert, LeasPreisAbwAbWo, @UserID AS MitarbeiID, GETDATE() AS Aktivierungszeitpunkt, LeasPreisPrListKdArtiID, WaschPreisPrListKdArtiID, SondPreisPrListKdArtiID, VkPreisPrListKdArtiID, BasisRWPrListKdArtiID, @UserID AS AnlageUserID_, @UserID AS UserID_
    FROM @PreisChanged;
  
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

DROP TABLE #KdArtiSrc, #KdArtiNew;
GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Mengenleasing-Umstellung                                                                                                  ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #VsaLeas;
GO

DECLARE @curweek nchar(7) = (SELECT Week.Woche FROM Week WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat);
DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

DECLARE @NewKdArti TABLE (
  KundenID int,
  KdArtiID int
);

INSERT INTO @NewKdArti (KundenID, KdArtiID)
SELECT KdArti.KundenID, KdArti.ID AS KdArtiID
FROM KdArti
WHERE KdArti.ArtikelID = (SELECT ID FROM Artikel WHERE ArtikelNr = N'BD718MW');

WITH Src AS (
  SELECT *
  FROM _IT82668
)
SELECT VsaLeas.*
INTO #VsaLeas
FROM VsaLeas
JOIN KdArti ON VsaLeas.KdArtiID = KdArti.ID
JOIN Src ON KdArti.KundenID = Src.KundenID AND KdArti.ArtikelID = Src.ArtikelID_Alt
WHERE ISNULL(VsaLeas.AusDienst, N'2099/52') > @curweek;

DECLARE @VsaLeasMap TABLE (
  VsaLeasID_old int,
  VsaLeasID_new int
);

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE VsaLeas SET AusDienst = @curweek, UserID_ = @userid
    WHERE ID IN (SELECT ID FROM #VsaLeas);

    UPDATE #VsaLeas SET ID = NEXT VALUE FOR NextID_VSALEAS, KdArtiID = NewKdArti.KdArtiID, InDienst = @curweek, Anlage_ = GETDATE(), AnlageUserID_ = @userid, UserID_ = @userid
    OUTPUT deleted.ID, inserted.ID
    INTO @VsaLeasMap (VsaLeasID_old, VsaLeasID_new)
    FROM KdArti
    JOIN @NewKdArti AS NewKdArti ON KdArti.KundenID = NewKdArti.KundenID
    WHERE #VsaLeas.KdArtiID = KdArti.ID;

    INSERT INTO VsaLeas
    SELECT DISTINCT *
    FROM #VsaLeas
    WHERE NOT EXISTS (
      SELECT vl.*
      FROM VsaLeas AS vl
      WHERE vl.KdArtiID = #VsaLeas.KdArtiID
        AND vl.VsaID = #VsaLeas.VsaID
    );

    INSERT INTO JahrLief (TableName, TableID, Jahr, Lieferwochen, AnlageUserID_, UserID_)
    SELECT DISTINCT N'VSALEAS' AS TableName, VsaLeasMap.VsaLeasID_new AS TableID, JahrLief.Jahr, JahrLief.Lieferwochen, @userid AS AnlageUserID_, @userid AS UserID_
    FROM JahrLief
    JOIN @VsaLeasMap AS VsaLeasMap ON VsaLeasMap.VsaLeasID_old = JahrLief.TableID
    WHERE JahrLief.TableName = N'VSALEAS'
      AND JahrLief.Jahr >= YEAR(GETDATE())
      AND EXISTS (
        SELECT VsaLeas.*
        FROM VsaLeas
        WHERE VsaLeas.ID = VsaLeasMap.VsaLeasID_new
      )
      AND NOT EXISTS (
        SELECT jl.*
        FROM JahrLief AS jl
        WHERE jl.TableName = N'VSALEAS'
          AND jl.TableID = VsaLeasMap.VsaLeasID_new
          AND jl.Jahr = JahrLief.Jahr
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

DROP TABLE IF EXISTS #VsaLeas;
GO
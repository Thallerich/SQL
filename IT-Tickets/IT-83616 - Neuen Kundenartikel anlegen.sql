DROP TABLE IF EXISTS #IT83616_Worktable;
GO

SELECT Kunden.ID AS KundenID, Artikel_Alt.ID AS ArtikelID_Alt, Artikel_Neu.ID AS ArtikelID_Neu
INTO #IT83616_Worktable
FROM _IT83616
JOIN Kunden ON _IT83616.KdNr = Kunden.KdNr
JOIN Artikel AS Artikel_Alt ON _IT83616.ArtikelNr_Alt = Artikel_Alt.ArtikelNr
LEFT JOIN Artikel AS Artikel_Neu ON _IT83616.ArtikelNr_Neu = Artikel_Neu.ArtikelNr;

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

BEGIN TRY
  BEGIN TRANSACTION;

    INSERT INTO KdArti ([Status], KundenID, ArtikelID, KdBerID, Variante, VariantBez, Referenz, LeasPreis, WaschPreis, SonderPreis, Lagerverkauf, VkPreis, Bestellerfassung, LiefArtID, WaschPrgID, AfaWochen, AusblendenVsaAnfAusgang, AusblendenVsaAnfEingang, LeasPreisPrListKdArtiID, WaschPreisPrListKdArtiID, SondPreisPrListKdArtiID, VkPreisPrListKdArtiID, BasisRWPrListKdArtiID, AnlageUserID_, UserID_)
    OUTPUT inserted.ID, inserted.LeasPreis, inserted.WaschPreis, inserted.SonderPreis, inserted.VkPreis, inserted.BasisRestwert, inserted.LeasPreisAbwAbWo, inserted.LeasPreisPrListKdArtiID, inserted.WaschPreisPrListKdArtiID, inserted.SondPreisPrListKdArtiID, inserted.VkPreisPrListKdArtiID, inserted.BasisRWPrListKdArtiID
    INTO @PreisChanged (KdArtiID, LeasPreis, WaschPreis, SonderPreis, VKPreis, BasisRestwert, LeasPreisAbwAbWo, LeasPreisPrListKdArtiID, WaschPreisPrListKdArtiID, SondPreisPrListKdArtiID, VkPreisPrListKdArtiID, BasisRWPrListKdArtiID)
    SELECT KdArti.[Status],
      KdArti.KundenID,
      #IT83616_Worktable.ArtikelID_Neu AS ArtikelID,
      KdArti.KdBerID,
      KdArti.Variante,
      KdArti.VariantBez,
      KdArti.Referenz,
      KdArti.LeasPreis,
      KdArti.WaschPreis,
      KdArti.SonderPreis,
      KdArti.Lagerverkauf,
      KdArti.VkPreis,
      KdArti.Bestellerfassung,
      KdArti.LiefArtID,
      KdArti.WaschPrgID,
      KdArti.AfaWochen,
      KdArti.AusblendenVsaAnfAusgang,
      KdArti.AusblendenVsaAnfEingang,
      LeasPreisPrListKdArtiID = ISNULL((
        SELECT PrListKdArti.ID
        FROM KdArti AS PrListKdArti
        JOIN KundPrLi ON KundPrLi.PrListKundenID = PrListKdArti.KundenID
        WHERE KundPrLi.KundenID = KdArti.KundenID
          AND PrListKdArti.ArtikelID = #IT83616_Worktable.ArtikelID_Neu
          AND PrListKdArti.Variante = KdArti.Variante
          AND KundPrLi.UseLeasPreis = 1
      ), -1),
      WaschPreisPrListKdArtiID = ISNULL((
        SELECT PrListKdArti.ID
        FROM KdArti AS PrListKdArti
        JOIN KundPrLi ON KundPrLi.PrListKundenID = PrListKdArti.KundenID
        WHERE KundPrLi.KundenID = KdArti.KundenID
          AND PrListKdArti.ArtikelID = #IT83616_Worktable.ArtikelID_Neu
          AND PrListKdArti.Variante = KdArti.Variante
          AND KundPrLi.UseWaschPreis = 1
      ), -1),
      SondPreisPrListKdArtiID = ISNULL((
        SELECT PrListKdArti.ID
        FROM KdArti AS PrListKdArti
        JOIN KundPrLi ON KundPrLi.PrListKundenID = PrListKdArti.KundenID
        WHERE KundPrLi.KundenID = KdArti.KundenID
          AND PrListKdArti.ArtikelID = #IT83616_Worktable.ArtikelID_Neu
          AND PrListKdArti.Variante = KdArti.Variante
          AND KundPrLi.UseSonderPreis = 1
      ), -1),
      VkPreisPrListKdArtiID = ISNULL((
        SELECT PrListKdArti.ID
        FROM KdArti AS PrListKdArti
        JOIN KundPrLi ON KundPrLi.PrListKundenID = PrListKdArti.KundenID
        WHERE KundPrLi.KundenID = KdArti.KundenID
          AND PrListKdArti.ArtikelID = #IT83616_Worktable.ArtikelID_Neu
          AND PrListKdArti.Variante = KdArti.Variante
          AND KundPrLi.UseVkPreis = 1
      ), -1),
      BasisRWPrListKdArtiID = ISNULL((
        SELECT PrListKdArti.ID
        FROM KdArti AS PrListKdArti
        JOIN KundPrLi ON KundPrLi.PrListKundenID = PrListKdArti.KundenID
        WHERE KundPrLi.KundenID = KdArti.KundenID
          AND PrListKdArti.ArtikelID = #IT83616_Worktable.ArtikelID_Neu
          AND PrListKdArti.Variante = KdArti.Variante
          AND KundPrLi.UseBasisRestwert = 1
      ), -1),
      @userid AS AnlageUserID_,
      @userid AS UserID_
    FROM #IT83616_Worktable
    JOIN KdArti ON #IT83616_Worktable.KundenID = KdArti.KundenID AND #IT83616_Worktable.ArtikelID_Alt = KdArti.ArtikelID
    WHERE #IT83616_Worktable.ArtikelID_Neu IS NOT NULL
      AND NOT EXISTS (
        SELECT k.*
        FROM KdArti k
        WHERE k.KundenID = KdArti.KundenID
          AND k.ArtikelID = #IT83616_Worktable.ArtikelID_Neu
          AND k.Variante = KdArti.Variante
      );

    INSERT INTO PrArchiv (KdArtiID, Datum, LeasPreis, WaschPreis, SonderPreis, VKPreis, BasisRestwert, LeasPreisAbwAbWo, MitarbeiID, Aktivierungszeitpunkt, LeasPreisPrListKdArtiID, WaschPreisPrListKdArtiID, SondPreisPrListKdArtiID, VkPreisPrListKdArtiID, BasisRWPrListKdArtiID, AnlageUserID_, UserID_)
    SELECT KdArtiID, CAST(GETDATE() AS date) AS Datum, LeasPreis, WaschPreis, SonderPreis, VKPreis, BasisRestwert, LeasPreisAbwAbWo, @UserID AS MitarbeiID, GETDATE() AS Aktivierungszeitpunkt, LeasPreisPrListKdArtiID, WaschPreisPrListKdArtiID, SondPreisPrListKdArtiID, VkPreisPrListKdArtiID, BasisRWPrListKdArtiID, @UserID AS AnlageUserID_, @UserID AS UserID_
    FROM @PreisChanged;

    UPDATE KdArti SET [Status] = N'I', UserID_ = @userid
    WHERE ID IN (
      SELECT KdArti.ID
      FROM #IT83616_Worktable
      JOIN KdArti ON #IT83616_Worktable.KundenID = KdArti.KundenID AND #IT83616_Worktable.ArtikelID_Alt = KdArti.ArtikelID
      WHERE KdArti.[Status] = N'A'
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
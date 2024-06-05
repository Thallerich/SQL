DECLARE @article_old nchar(15) = N'9903FL';
DECLARE @article_new nchar(15) = N'840013';
DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

DECLARE @customer TABLE (
  KdNr int
);

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

INSERT INTO @customer (KdNr)
VALUES (240181), (246856), (246908), (249232), (150737), (10000976), (180534), (293272), (294178), (10002098), (10004447), (10004451), (247969), (272509), (271887), (248024), (248642), (248104), (249360), (250283), (249184), (250948), (240824), (10002114), (242926), (10002406), (10003852), (10003866), (10003920), (10004376), (10003620), (10003454), (10004521), (10004519), (10003858), (10003910), (10003797), (10001595), (10003660), (10003853), (250250), (242919), (31108), (30913), (30535), (40514), (41600), (31312), (30500), (31111), (31186), (30846), (40732), (30519), (30938), (41111), (41604), (31120), (30677), (31222), (30983), (47072), (40513), (30684), (30685), (44124), (30340), (31102), (30867), (30532), (40604), (40620), (31107), (41412), (41514), (47148), (47227), (40128), (42202), (10005127), (10001846), (272750), (10005170), (10005589), (10003673), (10002364), (10002314), (10005684), (30258), (10005625), (10005866), (10003857), (10002321), (245564), (10005098), (10003753), (10005630), (10003367), (10004148), (10004599), (248292), (10002962), (10001491), (10002950), (248176), (245144), (30324), (10004685), (10005713), (246298), (10003931), (245062), (10000933), (249188), (10004688), (250917), (10005208), (10005840), (251094), (10005639), (248711), (249156), (160014), (150360), (272438), (10005291), (10004691), (30445), (10004607), (10003642), (10003646), (248174), (10004721), (10003798), (10004972), (10003731), (246869), (245918), (10004689), (10004352), (272829), (10005903), (10003743), (10005651), (246909), (10001406), (10002369), (10005789), (251323), (247972), (272676), (10003886), (10006217), (246999), (10003887), (10001063), (10003953), (250918), (246991), (10004272), (248175), (10006653), (10006424), (10003363), (272188), (10003894), (246871), (10003032), (10006922), (10003051), (10003579), (10005951), (10003327), (10003433), (10002370), (10006164), (10004690), (10005023), (47134), (248964), (251190), (248315), (10003054), (248234), (10004684), (10006466), (10001041), (10005870), (248580), (247933);

DECLARE @articleid_new int = (SELECT ID FROM Artikel WHERE ArtikelNr = @article_new);

BEGIN TRY
  BEGIN TRANSACTION;

    INSERT INTO KdArti ([Status], KundenID, ArtikelID, KdBerID, Variante, VariantBez, Referenz, LeasPreis, WaschPreis, SonderPreis, Lagerverkauf, VkPreis, Bestellerfassung, LiefArtID, WaschPrgID, AfaWochen, AusblendenVsaAnfAusgang, AusblendenVsaAnfEingang, LeasPreisPrListKdArtiID, WaschPreisPrListKdArtiID, SondPreisPrListKdArtiID, VkPreisPrListKdArtiID, BasisRWPrListKdArtiID, AnlageUserID_, UserID_)
    OUTPUT inserted.ID, inserted.LeasPreis, inserted.WaschPreis, inserted.SonderPreis, inserted.VkPreis, inserted.BasisRestwert, inserted.LeasPreisAbwAbWo, inserted.LeasPreisPrListKdArtiID, inserted.WaschPreisPrListKdArtiID, inserted.SondPreisPrListKdArtiID, inserted.VkPreisPrListKdArtiID, inserted.BasisRWPrListKdArtiID
    INTO @PreisChanged (KdArtiID, LeasPreis, WaschPreis, SonderPreis, VKPreis, BasisRestwert, LeasPreisAbwAbWo, LeasPreisPrListKdArtiID, WaschPreisPrListKdArtiID, SondPreisPrListKdArtiID, VkPreisPrListKdArtiID, BasisRWPrListKdArtiID)
    SELECT KdArti.[Status],
      KdArti.KundenID,
      @articleid_new AS ArtikelID,
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
          AND PrListKdArti.ArtikelID = @articleid_new
          AND KundPrLi.UseLeasPreis = 1
      ), -1),
      WaschPreisPrListKdArtiID = ISNULL((
        SELECT PrListKdArti.ID
        FROM KdArti AS PrListKdArti
        JOIN KundPrLi ON KundPrLi.PrListKundenID = PrListKdArti.KundenID
        WHERE KundPrLi.KundenID = KdArti.KundenID
          AND PrListKdArti.ArtikelID = @articleid_new
          AND KundPrLi.UseWaschPreis = 1
      ), -1),
      SondPreisPrListKdArtiID = ISNULL((
        SELECT PrListKdArti.ID
        FROM KdArti AS PrListKdArti
        JOIN KundPrLi ON KundPrLi.PrListKundenID = PrListKdArti.KundenID
        WHERE KundPrLi.KundenID = KdArti.KundenID
          AND PrListKdArti.ArtikelID = @articleid_new
          AND KundPrLi.UseSonderPreis = 1
      ), -1),
      VkPreisPrListKdArtiID = ISNULL((
        SELECT PrListKdArti.ID
        FROM KdArti AS PrListKdArti
        JOIN KundPrLi ON KundPrLi.PrListKundenID = PrListKdArti.KundenID
        WHERE KundPrLi.KundenID = KdArti.KundenID
          AND PrListKdArti.ArtikelID = @articleid_new
          AND KundPrLi.UseVkPreis = 1
      ), -1),
      BasisRWPrListKdArtiID = ISNULL((
        SELECT PrListKdArti.ID
        FROM KdArti AS PrListKdArti
        JOIN KundPrLi ON KundPrLi.PrListKundenID = PrListKdArti.KundenID
        WHERE KundPrLi.KundenID = KdArti.KundenID
          AND PrListKdArti.ArtikelID = @articleid_new
          AND KundPrLi.UseBasisRestwert = 1
      ), -1),
      @userid AS AnlageUserID_,
      @userid AS UserID_
    FROM KdArti
    JOIN Kunden ON KdArti.KundenID = Kunden.ID
    WHERE KdArti.ArtikelID = (SELECT ID FROM Artikel WHERE ArtikelNr = @article_old)
      AND KdArti.[Status] = N'A'
      AND Kunden.KdNr IN (SELECT KdNr FROM @customer)
      AND NOT EXISTS (
        SELECT k.*
        FROM KdArti k
        WHERE k.KundenID = KdArti.KundenID
          AND k.ArtikelID = @articleid_new
          AND k.Variante = KdArti.Variante
      );

    INSERT INTO PrArchiv (KdArtiID, Datum, LeasPreis, WaschPreis, SonderPreis, VKPreis, BasisRestwert, LeasPreisAbwAbWo, MitarbeiID, Aktivierungszeitpunkt, LeasPreisPrListKdArtiID, WaschPreisPrListKdArtiID, SondPreisPrListKdArtiID, VkPreisPrListKdArtiID, BasisRWPrListKdArtiID, AnlageUserID_, UserID_)
    SELECT KdArtiID, CAST(GETDATE() AS date) AS Datum, LeasPreis, WaschPreis, SonderPreis, VKPreis, BasisRestwert, LeasPreisAbwAbWo, @UserID AS MitarbeiID, GETDATE() AS Aktivierungszeitpunkt, LeasPreisPrListKdArtiID, WaschPreisPrListKdArtiID, SondPreisPrListKdArtiID, VkPreisPrListKdArtiID, BasisRWPrListKdArtiID, @UserID AS AnlageUserID_, @UserID AS UserID_
    FROM @PreisChanged;

    UPDATE KdArti SET [Status] = N'I', UserID_ = @userid
    WHERE ID IN (
      SELECT KdArti.ID
      FROM KdArti
      JOIN Kunden ON KdArti.KundenID = Kunden.ID
      WHERE KdArti.ArtikelID = (SELECT ID FROM Artikel WHERE ArtikelNr = @article_old)
        AND KdArti.[Status] = N'A'
        AND Kunden.KdNr IN (SELECT KdNr FROM @customer)
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
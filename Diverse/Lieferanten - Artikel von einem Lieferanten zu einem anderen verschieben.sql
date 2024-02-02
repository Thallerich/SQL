/* LIEFTAGE, ARTILIEF, ARGRLIEF, LIEFPRIO, ARTEKHIS */

DECLARE @liefnr_source int = 30021;
DECLARE @liefnr_destination int = 28764;

DECLARE @liefid_source int = (SELECT Lief.ID FROM Lief WHERE Lief.LiefNr = @liefnr_source);
DECLARE @liefid_destination int = (SELECT Lief.ID FROM Lief WHERE Lief.LiefNr = @liefnr_destination);
DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

DECLARE @ArtiLiefMap TABLE (
  ArtiLiefID int,
  ArtikelID int,
  StandortID int,
  LiefPackMenge int,
  VonDatum date,
  LiefID int
);

BEGIN TRY
  BEGIN TRANSACTION;
  
    INSERT INTO LiefTage (LiefID, LiefTageBez, LiefTageBez1, LiefTageBez2, LiefTageBez3, LiefTageBez4, LiefTageBez5, LiefTageBez6, LiefTageBez7, LiefTageBez8, LiefTageBez9, LiefTageBezA, TageM, TageN, TageT, TageV, TageX, TageS, MakeToOrder, Farbe, Meldung, Meldung1, Meldung2, Meldung3, Meldung4, Meldung5, Meldung6, Meldung7, Meldung8, Meldung9, MeldungA, AnlageUserID_, UserID_)
    SELECT @liefid_destination AS LiefID, LiefTage.LiefTageBez, LiefTage.LiefTageBez1, LiefTage.LiefTageBez2, LiefTage.LiefTageBez3, LiefTage.LiefTageBez4, LiefTage.LiefTageBez5, LiefTage.LiefTageBez6, LiefTage.LiefTageBez7, LiefTage.LiefTageBez8, LiefTage.LiefTageBez9, LiefTage.LiefTageBezA, LiefTage.TageM, LiefTage.TageN, LiefTage.TageT, LiefTage.TageV, LiefTage.TageX, LiefTage.TageS, LiefTage.MakeToOrder, LiefTage.Farbe, LiefTage.Meldung, LiefTage.Meldung1, LiefTage.Meldung2, LiefTage.Meldung3, LiefTage.Meldung4, LiefTage.Meldung5, LiefTage.Meldung6, LiefTage.Meldung7, LiefTage.Meldung8, LiefTage.Meldung9, LiefTage.MeldungA, @userid AS AnlageUserID_, @userid AS UserID_
    FROM LiefTage
    WHERE LiefTage.LiefID = @liefid_source
      AND NOT EXISTS (
        SELECT lt.*
        FROM LiefTage AS lt
        WHERE lt.LiefID = @liefid_destination AND lt.TageM = LiefTage.TageM AND lt.TageN = LiefTage.TageN AND lt.TageT = LiefTage.TageT AND lt.TageV = LiefTage.TageV AND lt.TageX = LiefTage.TageX AND lt.TageS = LiefTage.TageS AND lt.MakeToOrder = LiefTage.MakeToOrder
      );

    INSERT INTO ArtiLief (LiefID, ArtikelID, EkPreis, EPreisPack, EkPreisSeit, LiefPackMenge, VonDatum, BisDatum, StandortID, MinBestMengeArtikel, MinBestMengeGroessen, LiefTageID, OrderPack, AnlageUserID_, UserID_)
    OUTPUT inserted.ID, inserted.ArtikelID, inserted.StandortID, inserted.LiefPackMenge, inserted.VonDatum, inserted.LiefID
    INTO @ArtiLiefMap (ArtiLiefID, ArtikelID, StandortID, LiefPackMenge, VonDatum, LiefID)
    SELECT @liefid_destination AS LiefID, ArtiLief.ArtikelID, ArtiLief.EkPreis, ArtiLief.EPreisPack, ArtiLief.EkPreisSeit, ArtiLief.LiefPackMenge, ArtiLief.VonDatum, ArtiLief.BisDatum, ArtiLief.StandortID, ArtiLief.MinBestMengeArtikel, ArtiLief.MinBestMengeGroessen, NewLiefTage.ID AS LiefTageID, ArtiLief.OrderPack, @userid AS AnlageUserID_, @userid AS UserID_
    FROM ArtiLief
    JOIN LiefTage ON ArtiLief.LiefTageID = LiefTage.ID
    JOIN LiefTage AS NewLiefTage ON LiefTage.TageM = NewLiefTage.TageM AND LiefTage.TageN = NewLiefTage.TageN AND LiefTage.TageT = NewLiefTage.TageT AND LiefTage.TageV = NewLiefTage.TageV AND LiefTage.TageX = NewLiefTage.TageX AND LiefTage.TageS = NewLiefTage.TageS AND LiefTage.MakeToOrder = NewLiefTage.MakeToOrder
    WHERE ArtiLief.LiefID = @liefid_source
      AND NewLiefTage.LiefID = @liefid_destination
      AND ArtiLief.ID > 0
      AND NOT EXISTS (
        SELECT al.*
        FROM ArtiLief AS al
        WHERE al.ArtikelID = ArtiLief.ArtikelID
          AND al.StandortID = ArtiLief.StandortID
          AND al.LiefPackMenge = ArtiLief.LiefPackMenge
          AND ISNULL(al.VonDatum, N'1900-01-01') = ISNULL(ArtiLief.VonDatum, N'1900-01-01')
          AND al.LiefID = @liefid_destination
      );

    INSERT INTO ArGrLief (ArtiLiefID, ArtGroeID, BestellNr, EkPreis, AbMenge, Zuschlag, ZuschlagAbs, VonDatum, BisDatum, BestellInfoText, EAN, LiefTageID, BestellText, AnlageUserID_, UserID_)
    SELECT ArtiLiefMap.ArtiLiefID, ArGrLief.ArtGroeID, ArGrLief.BestellNr, ArGrLief.EkPreis, ArGrLief.AbMenge, ArGrLief.Zuschlag, ArGrLief.ZuschlagAbs, ArGrLief.VonDatum, ArGrLief.BisDatum, ArGrLief.BestellInfoText, ArGrLief.EAN, NewLiefTage.ID AS LiefTageID, ArGrLief.BestellText, @userid AS AnlageUserID_, @userid AS UserID_
    FROM ArGrLief
    JOIN ArtiLief ON ArGrLief.ArtiLiefID = ArtiLief.ID
    JOIN @ArtiLiefMap AS ArtiLiefMap ON ArtiLief.ArtikelID = ArtiLiefMap.ArtikelID AND ArtiLief.StandortID = ArtiLiefMap.StandortID AND ArtiLief.LiefPackMenge = ArtiLiefMap.LiefPackMenge AND ArtiLief.VonDatum = ArtiLiefMap.VonDatum AND ArtiLief.LiefID = ArtiLiefMap.LiefID
    JOIN LiefTage ON ArGrLief.LiefTageID = LiefTage.ID
    JOIN LiefTage AS NewLiefTage ON LiefTage.TageM = NewLiefTage.TageM AND LiefTage.TageN = NewLiefTage.TageN AND LiefTage.TageT = NewLiefTage.TageT AND LiefTage.TageV = NewLiefTage.TageV AND LiefTage.TageX = NewLiefTage.TageX AND LiefTage.TageS = NewLiefTage.TageS AND LiefTage.MakeToOrder = NewLiefTage.MakeToOrder
    WHERE ArtiLief.LiefID = @liefid_source
      AND NewLiefTage.LiefID = @liefid_destination
      AND ArtiLief.ID > 0
      AND ArGrLief.ID > 0
      AND NOT EXISTS (
        SELECT agl.*
        FROM ArGrLief AS agl
        WHERE agl.ArtiLiefID = ArtiLiefMap.ArtiLiefID AND agl.ArtGroeID = ArGrLief.ArtGroeID AND agl.AbMenge = ArGrLief.AbMenge AND ISNULL(agl.VonDatum, N'1900-01-01') = ISNULL(ArGrLief.VonDatum, N'1900-01-01')
      );

    INSERT INTO LiefPrio (LiefID, StandortID, ArtikelID, ArtGroeID, AnlageUserID_, UserID_)
    SELECT @liefid_destination AS LiefID, LiefPrio.StandortID, LiefPrio.ArtikelID, LiefPrio.ArtGroeID, @userid AS AnlageUserID_, UserID_
    FROM LiefPrio
    WHERE LiefPrio.LiefID = @liefid_source
      AND NOT EXISTS (
        SELECT lp.*
        FROM LiefPrio AS lp
        WHERE lp.LiefID = @liefid_destination
          AND lp.StandortID = LiefPrio.StandortID
          AND lp.ArtikelID = LiefPrio.ArtikelID
          AND lp.ArtGroeID = LiefPrio.ArtGroeID
      );

    INSERT INTO ArtEkHis (ArtikelID, EkPreis, GueltigSeit, LiefID, AnlageUserID_, UserID_)
    SELECT ArtEKHis.ArtikelID, ArtEKHis.EkPreis, ArtEKHis.GueltigSeit, @liefid_destination AS LiefID, @userid AS AnlageUserID_, @userid AS UserID_
    FROM ArtEkHis
    WHERE ArtEKHis.ID IN (
      SELECT x.ArtEKHisID
      FROM (
        SELECT ArtEkHis.ID AS ArtEkHisID, SortOrder = DENSE_RANK() OVER (PARTITION BY ArtEkHis.LiefID, ArtEkHis.ArtikelID ORDER BY ArtEkHis.Anlage_ DESC)
        FROM ArtEkHis
        WHERE ArtEkHis.LiefID = @liefid_source
      ) x
      WHERE x.SortOrder = 1
    );

    DELETE FROM LiefPrio WHERE LiefID = @liefid_source;

    UPDATE ArtGroe SET LiefID = @liefid_destination
    WHERE ArtGroe.LiefID = @liefid_source;

    UPDATE Artikel SET LiefID = @liefid_destination
    WHERE Artikel.LiefID = @liefid_source;
  
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
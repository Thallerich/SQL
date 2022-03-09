DECLARE @NewKdArti TABLE (
  KdArtiID int,
  WaschPreis money,
  LeasPreis money,
  Sonderpreis money,
  VKPreis money,
  BasisRestwert money,
  AfaWochen int,
  LeasPreisAbwAbWo money
);

DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

BEGIN TRANSACTION;

  WITH ArtiMap AS (
    SELECT NeuArtikel.ID AS NeuArtikelID, AltArtikel.ID AS AltArtikelID
    FROM __ArtiMapKentaur20220309
    JOIN Artikel AS NeuArtikel ON __ArtiMapKentaur20220309.ArtikelNrNeu = NeuArtikel.ArtikelNr
    JOIN Artikel AS AltArtikel ON __ArtiMapKentaur20220309.ArtikelNrAlt = AltArtikel.ArtikelNr
  )
  INSERT INTO KdArti ([Status], KundenID, ArtikelID, KdBerID, Variante, VariantBez, Referenz, LeasPreis, WaschPreis, SonderPreis, Lagerverkauf, VkPreis, Bestellerfassung, LiefArtID, WaschPrgID, AfaWochen, MaxWaschen, MinEinwaschen, MinEinwaschenGebraucht, BasisRestwert, WaescherID, Lieferwochen, Anfordern, Vorlaeufig, Kaufpflicht, AnteilNS, AnteilEmbl, AnteilSchrank, AnteilZubehoer, AnteilFachsort, FolgeKdArtiID, Memo, BearbProzessID, LieferProzessID, KeineAnfPo, KostenlosRPo, BKojeVSAKunde, KontrolleXMal, MindLagerProz, KdArtikelNr, KdArtikelNr2, KdArtikelBez, WebArtikel, FakRepModus, KaufwareModus, FixAusschluss, KundQualID, FreqID, LSAusblenden, ESDGrenzeNachmessung, ESDGrenzeAustausch, BDE, EigentumID, ErsatzFuerKdArtiID, IstBestandAnpass, Vertragsartikel, VerwendID, SofaKdBeachten, CheckPackmenge, AfAundBasisRWausPrList, AusblendenVsaAnfAusgang, AusblendenVsaAnfEingang, ArtiZwingendBarcodiert, ArtiOptionalBarcodiert, AnfErfNurAusgang, AbwLeasPrNachWo, LeasPreisAbwAbWo, UsesBkOpTeile, AnlageUserID_, UserID_)
  OUTPUT inserted.ID, inserted.WaschPreis, inserted.LeasPreis, inserted.SonderPreis, inserted.VkPreis, inserted.BasisRestwert, inserted.AfaWochen, inserted.LeasPreisAbwAbWo
  INTO @NewKdArti (KdArtiID, WaschPreis, LeasPreis, Sonderpreis, VKPreis, BasisRestwert, AfaWochen, LeasPreisAbwAbWo)
  SELECT KdArti.[Status], KdArti.KundenID, ArtiMap.NeuArtikelID AS ArtikelID, KdArti.KdBerID, KdArti.Variante, KdArti.VariantBez, KdArti.Referenz, KdArti.LeasPreis, KdArti.WaschPreis, KdArti.SonderPreis, KdArti.Lagerverkauf, KdArti.VkPreis, KdArti.Bestellerfassung, KdArti.LiefArtID, KdArti.WaschPrgID, KdArti.AfaWochen, KdArti.MaxWaschen, KdArti.MinEinwaschen, KdArti.MinEinwaschenGebraucht, KdArti.BasisRestwert, KdArti.WaescherID, KdArti.Lieferwochen, KdArti.Anfordern, KdArti.Vorlaeufig, KdArti.Kaufpflicht, KdArti.AnteilNS, KdArti.AnteilEmbl, KdArti.AnteilSchrank, KdArti.AnteilZubehoer, KdArti.AnteilFachsort, KdArti.FolgeKdArtiID, KdArti.Memo, KdArti.BearbProzessID, KdArti.LieferProzessID, KdArti.KeineAnfPo, KdArti.KostenlosRPo, KdArti.BKojeVSAKunde, KdArti.KontrolleXMal, KdArti.MindLagerProz, KdArti.KdArtikelNr, KdArti.KdArtikelNr2, KdArti.KdArtikelBez, KdArti.WebArtikel, KdArti.FakRepModus, KdArti.KaufwareModus, KdArti.FixAusschluss, KdArti.KundQualID, KdArti.FreqID, KdArti.LSAusblenden, KdArti.ESDGrenzeNachmessung, KdArti.ESDGrenzeAustausch, KdArti.BDE, KdArti.EigentumID, KdArti.ErsatzFuerKdArtiID, KdArti.IstBestandAnpass, KdArti.Vertragsartikel, KdArti.VerwendID, KdArti.SofaKdBeachten, KdArti.CheckPackmenge, KdArti.AfAundBasisRWausPrList, KdArti.AusblendenVsaAnfAusgang, KdArti.AusblendenVsaAnfEingang, KdArti.ArtiZwingendBarcodiert, KdArti.ArtiOptionalBarcodiert, KdArti.AnfErfNurAusgang, KdArti.AbwLeasPrNachWo, KdArti.LeasPreisAbwAbWo, KdArti.UsesBkOpTeile, @UserID AS AnlageUserID_, @UserID AS UserID_
  FROM KdArti
  JOIN Kunden ON KdArti.KundenID = Kunden.ID
  JOIN ArtiMap ON KdArti.ArtikelID = ArtiMap.AltArtikelID
  WHERE Kunden.KdNr NOT IN (30284, 30285, 30286, 30287, 30698)
    AND NOT EXISTS (
      SELECT k.*
      FROM KdArti k
      WHERE k.KundenID = Kunden.ID
        AND k.ArtikelID = ArtiMap.NeuArtikelID
        AND k.Variante = KdArti.Variante
    );

  INSERT INTO PrArchiv (KdArtiID, Datum, WaschPreis, SonderPreis, LeasPreis, VKPreis, BasisRestwert, MitarbeiID, Aktivierungszeitpunkt, LeasPreisAbwAbWo, AnlageUserID_, UserID_)
  SELECT NewKdArti.KdArtiID, CAST(GETDATE() AS date) AS Datum, NewKdArti.WaschPreis, NewKdArti.SonderPreis, NewKdArti.LeasPreis, NewKdArti.VKPreis, NewKdArti.BasisRestwert, @UserID AS MitarbeiID, GETDATE() AS Aktivierungszeitpunkt, NewKdArti.LeasPreisAbwAbWo, @UserID AS AnlageUserID_, @UserID AS UserID_
  FROM @NewKdArti AS NewKdArti;

  WITH ArtiMap AS (
    SELECT NeuArtikel.ID AS NeuArtikelID, AltArtikel.ID AS AltArtikelID
    FROM __ArtiMapKentaur20220309
    JOIN Artikel AS NeuArtikel ON __ArtiMapKentaur20220309.ArtikelNrNeu = NeuArtikel.ArtikelNr
    JOIN Artikel AS AltArtikel ON __ArtiMapKentaur20220309.ArtikelNrAlt = AltArtikel.ArtikelNr
  )
  INSERT INTO KdArAppl (KdArtiID, ArtiTypeID, ApplKdArtiID, PlatzID, NutzeZeile1, NutzeZeile2, NutzeZeile3, NutzeZeile4, AutoModus, AnlageUserID_, UserID_)
  SELECT NeuKdArti.ID AS KdArtiID, KdArAppl.ArtiTypeID, KdArAppl.ApplKdArtiID, KdArAppl.PlatzID, KdArAppl.NutzeZeile1, KdArAppl.NutzeZeile2, KdArAppl.NutzeZeile3, KdArAppl.NutzeZeile4, KdArAppl.AutoModus, @UserID AS AnlageUserID_, @UserID AS UserID_
  FROM KdArAppl
  JOIN KdArti ON KdArAppl.KdArtiID = KdArti.ID
  JOIN Kunden ON KdArti.KundenID = Kunden.ID
  JOIN ArtiMap ON KdArti.ArtikelID = ArtiMap.AltArtikelID
  JOIN KdArti AS NeuKdArti ON ArtiMap.NeuArtikelID = NeuKdArti.ArtikelID AND KdArti.Variante = NeuKdArti.Variante AND KdArti.KundenID = NeuKdArti.KundenID
  WHERE Kunden.KdNr NOT IN (30284, 30285, 30286, 30287, 30698)
    AND NOT EXISTS (
      SELECT kaa.*
      FROM KdArAppl kaa
      WHERE kaa.KdArtiID = NeuKdArti.ID
        AND kaa.ApplKdArtiID = KdArAppl.ApplKdArtiID
        AND kaa.PlatzID = KdArAppl.PlatzID
    );

/* COMMIT; */
/* ROLLBACK; */
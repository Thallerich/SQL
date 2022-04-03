DECLARE @ArtiMap TABLE (
  ArtikelNrAlt nchar(15) COLLATE Latin1_General_CS_AS,
  ArtikelNrNeu nchar(15) COLLATE Latin1_General_CS_AS
);

INSERT INTO @ArtiMap (ArtikelNrAlt, ArtikelNrNeu)
VALUES (N'313700', N'111204040001'),
  (N'31BL00', N'111204040036'),
  (N'719921', N'110616242701'),
  (N'75VS02', N'110604020090'),
  (N'75VS10', N'110604020090'),
  (N'75VS11', N'110604020090'),
  (N'760170', N'110608662001'),
  (N'76MG02', N'110608020090'),
  (N'76MG10', N'110608020090'),
  (N'76MG11', N'110608020090'),
  (N'81010B', N'114416025001'),
  (N'G20100', N'113635209001'),
  (N'P128M', N'110620010001'),
  (N'P275', N'101260020001'),
  (N'P275FB', N'101260020001'),
  (N'P578', N'110620010001'),
  (N'P5DC75', N'117008020006'),
  (N'PH9000', N'111807002003'),
  (N'SW8987', N'840009'),
  (N'WS0100', N'114470015060'),
  (N'WS0701', N'110620010001'),
  (N'SW8985', N'114470015060'),
  (N'31GE00', N'111204040036'),
  (N'323700', N'111228040001'),
  (N'54A3', N'54A7XL'),
  (N'77MG03', N'110604202703'),
  (N'78MG03', N'1110608020004'),
  (N'G10100', N'113605205001'),
  (N'G30114', N'113665141401'),
  (N'P154', N'110608662001'),
  (N'P578', N'112698510011'),
  (N'PH5000', N'111807002003'),
  (N'32GE00', N'111228040036'),
  (N'SW8988', N'840013');

DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

INSERT INTO KdArti ([Status], KundenID, ArtikelID, KdBerID, Variante, VariantBez, Referenz, LeasPreis, WaschPreis, SonderPreis, Lagerverkauf, VkPreis, Bestellerfassung, LiefArtID, WaschPrgID, AfaWochen, MaxWaschen, MinEinwaschen, MinEinwaschenGebraucht, WaescherID, LieferWochen, Anfordern, Vorlaeufig, Kaufpflicht, FakAustausch, AnteilNS, AnteilEmbl, AnteilSchrank, AnteilZubehoer, AnteilFachsort, FolgeKdArtiID, Memo, BearbProzessID, LieferProzessID, KeineAnfPo, KostenlosRPo, BKojeVSAKunde, KontrolleXMal, MindLagerProz, KdArtikelNr, KdArtikelNr2, KdArtikelBez, WebArtikel, FakRepModus, KaufwareModus, FixAusschluss, KundQualID, FreqID, LSAusblenden, ESDGrenzeNachmessung, ESDGrenzeAustausch, BDE, EigentumID, ErsatzFuerKdArtiID, AbrechMenge, IstBestandAnpass, Vertragsartikel, VerwendID, SofaKdBeachten, CheckPackMenge, AfAundBasisRWausPrList, AusblendenVsaAnfAusgang, AusblendenVsaAnfEingang, ArtiZwingendBarcodiert, ArtiOptionalBarcodiert, AnfErfNurAusgang, AbwLeasPrNachWo, LeasPreisAbwAbWo, UsesBkOpTeile, AnlageUserID_, UserID_)
SELECT DISTINCT N'A' AS [Status], k.KundenID, ArtikelNeu.ID AS ArtikelID, k.KdBerID, k.Variante, k.VariantBez, k.Referenz, k.LeasPreis, k.WaschPreis, k.SonderPreis, k.Lagerverkauf, k.VkPreis, k.Bestellerfassung, k.LiefArtID, k.WaschPrgID, k.AfaWochen, k.MaxWaschen, k.MinEinwaschen, k.MinEinwaschenGebraucht, k.WaescherID, k.LieferWochen, k.Anfordern, k.Vorlaeufig, k.Kaufpflicht, k.FakAustausch, k.AnteilNS, k.AnteilEmbl, k.AnteilSchrank, k.AnteilZubehoer, k.AnteilFachsort, k.FolgeKdArtiID, k.Memo, k.BearbProzessID, k.LieferProzessID, k.KeineAnfPo, k.KostenlosRPo, k.BKojeVSAKunde, k.KontrolleXMal, k.MindLagerProz, k.KdArtikelNr, k.KdArtikelNr2, k.KdArtikelBez, CAST(1 AS bit) AS WebArtikel, k.FakRepModus, k.KaufwareModus, k.FixAusschluss, k.KundQualID, k.FreqID, k.LSAusblenden, k.ESDGrenzeNachmessung, k.ESDGrenzeAustausch, k.BDE, k.EigentumID, k.ErsatzFuerKdArtiID, k.AbrechMenge, CAST(1 AS bit) AS IstBestandAnpass, CAST(1 AS bit) AS Vertragsartikel, k.VerwendID, k.SofaKdBeachten, CAST(1 AS bit) AS CheckPackMenge, k.AfAundBasisRWausPrList, k.AusblendenVsaAnfAusgang, k.AusblendenVsaAnfEingang, k.ArtiZwingendBarcodiert, k.ArtiOptionalBarcodiert, k.AnfErfNurAusgang, k.AbwLeasPrNachWo, k.LeasPreisAbwAbWo, k.UsesBkOpTeile, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM KdArti AS k
JOIN Kunden ON k.KundenID = Kunden.ID
JOIN Artikel AS ArtikelAlt ON k.ArtikelID = ArtikelAlt.ID
JOIN @ArtiMap AS ArtiMap ON ArtikelAlt.ArtikelNr = ArtiMap.ArtikelNrAlt
JOIN Artikel AS ArtikelNeu ON ArtiMap.ArtikelNrNeu = ArtikelNeu.ArtikelNr
WHERE Kunden.KdNr IN (160094, 160143, 246268, 260722, 260752, 260903, 270069, 270250, 270997, 271701, 271857, 272349, 10005718)
  AND NOT EXISTS (
    SELECT ka.*
    FROM KdArti ka
    WHERE ka.KundenID = k.KundenID
      AND ka.ArtikelID = ArtikelNeu.ID
      AND ka.Variante = k.Variante
  )
  AND (CAST(k.KundenID AS nvarchar) + ' ' + CAST(ArtikelNeu.ID AS nvarchar) != N'2951305 1798582')
  AND (CAST(k.KundenID AS nvarchar) + ' ' + CAST(ArtikelNeu.ID AS nvarchar) != N'3161351 1798582')
  AND (CAST(k.KundenID AS nvarchar) + ' ' + CAST(ArtikelNeu.ID AS nvarchar) != N'3161361 1798582')
  AND (CAST(k.KundenID AS nvarchar) + ' ' + CAST(ArtikelNeu.ID AS nvarchar) != N'3161356 3068175');


SELECT DISTINCT k.KundenID, ArtikelNeu.ID AS ArtikelID, k.Variante, Kunden.KdNr, ArtikelNeu.ArtikelNr
FROM KdArti AS k
JOIN Kunden ON k.KundenID = Kunden.ID
JOIN Artikel AS ArtikelAlt ON k.ArtikelID = ArtikelAlt.ID
JOIN @ArtiMap AS ArtiMap ON ArtikelAlt.ArtikelNr = ArtiMap.ArtikelNrAlt
JOIN Artikel AS ArtikelNeu ON ArtiMap.ArtikelNrNeu = ArtikelNeu.ArtikelNr
WHERE Kunden.KdNr IN (160094, 160143, 246268, 260722, 260752, 260903, 270069, 270250, 270997, 271701, 271857, 272349, 10005718)
  AND NOT EXISTS (
    SELECT ka.*
    FROM KdArti ka
    WHERE ka.KundenID = k.KundenID
      AND ka.ArtikelID = ArtikelNeu.ID
      AND ka.Variante = k.Variante
  )
  AND k.KundenID = 3161361
  AND ArtikelNeu.ID = 1798582;

/* UPDATE KdArti SET [Status] = N'I'
WHERE ID IN (
  SELECT k.ID
  FROM KdArti AS k
  JOIN Kunden ON k.KundenID = Kunden.ID
  JOIN Artikel AS ArtikelAlt ON k.ArtikelID = ArtikelAlt.ID
  JOIN @ArtiMap AS ArtiMap ON ArtikelAlt.ArtikelNr = ArtiMap.ArtikelNrAlt
  WHERE Kunden.KdNr IN (160094, 160143, 246268, 260722, 260752, 260903, 270069, 270250, 270997, 271701, 271857, 272349, 10005718)
); */
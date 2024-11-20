/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Vorbereitend                                                                                                              ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #TmpLSMimZeitraum;

CREATE TABLE #TmpLSMimZeitraum (
  Holding nvarchar(10) COLLATE Latin1_General_CS_AS,
  KdNr int,
  Kunde nvarchar(20) COLLATE Latin1_General_CS_AS,
  Produktion nvarchar(40) COLLATE Latin1_General_CS_AS,
  Lieferdatum date,
  VsaNr int,
  VsaStichwort nvarchar(40) COLLATE Latin1_General_CS_AS,
  VsaBezeichnung nvarchar(40) COLLATE Latin1_General_CS_AS,
  VsaName1 nvarchar(40) COLLATE Latin1_General_CS_AS,
  VsaName2 nvarchar(40) COLLATE Latin1_General_CS_AS,
  Gebäude nvarchar(40) COLLATE Latin1_General_CS_AS,
  VsaUnterort nvarchar(60) COLLATE Latin1_General_CS_AS,
  LsNotiz nvarchar(max) COLLATE Latin1_General_CS_AS,
  KsSt nvarchar(20) COLLATE Latin1_General_CS_AS,
  KsStBez nvarchar(80) COLLATE Latin1_General_CS_AS,
  Bereich nchar(3) COLLATE Latin1_General_CS_AS,
  ArtiGruppe nchar(8) COLLATE Latin1_General_CS_AS,
  ArtikelNr nvarchar(15) COLLATE Latin1_General_CS_AS,
  ArtikelBez nvarchar(60) COLLATE Latin1_General_CS_AS,
  ArtiGröße nvarchar(12) COLLATE Latin1_General_CS_AS,
  Variante nchar(4) COLLATE Latin1_General_CS_AS,
  VarianteBez nvarchar(60) COLLATE Latin1_General_CS_AS,
  Umlauf int,
  Auslieferart nvarchar(60) COLLATE Latin1_General_CS_AS,
  Tour nchar(10) COLLATE Latin1_General_CS_AS,
  TourBez nvarchar(40) COLLATE Latin1_General_CS_AS,
  Liefermenge numeric(18,4),
  Mengeneinheit nchar(3) COLLATE Latin1_General_CS_AS,
  LsNr int,
  LsArt nchar(1) COLLATE Latin1_General_CS_AS
);

DECLARE @sqltext nvarchar(max);
DECLARE @start date, @end date;

SET @start = $STARTDATE$;
SET @end = $ENDDATE$;

IF $9$ = -1
BEGIN
  IF $10$ = N''
  BEGIN
    SET @sqltext = N'
      INSERT INTO #TmpLsMimZeitraum (Holding, KdNr, Kunde, Produktion, Lieferdatum, VsaNr, VsaStichwort, VsaBezeichnung, VsaName1, VsaName2, Gebäude, VsaUnterort, LsNotiz, KsSt, KsStBez, Bereich, ArtiGruppe, ArtikelNr, ArtikelBez, ArtiGröße, Variante, VarianteBez, Umlauf, Auslieferart, Tour, TourBez, Liefermenge, Mengeneinheit, LsNr, LsArt)
      SELECT Holding.Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, Standort.Bez AS Produktion, LsKo.Datum AS Lieferdatum, Vsa.VsaNr, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS VsaBezeichnung, Vsa.Name1 AS VsaName1, Vsa.Name2 AS VsaName2, Vsa.GebaeudeBez AS Gebäude, VsaOrt.Bez AS VsaUnterort, LsPo.Memo AS LsNotiz, Abteil.Abteilung AS KsSt, Abteil.Bez AS KsStBez, Bereich.Bereich, ArtGru.Gruppe AS ArtiGruppe, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, ArtGroe.Groesse AS ArtiGröße, KdArti.Variante, KdArti.VariantBez, KdArti.Umlauf, LiefArt.LiefartBez$LAN$ AS Auslieferart, Touren.Tour, Touren.Bez AS TourBez, LsPo.Menge AS Liefermenge, IIF(ME.ID < 0, N''ST'', ME.IsoCode) AS Mengeneinheit, LsKo.LsNr, LsKoArt.Art
      FROM LsPo
      JOIN LsKo ON LsPo.LsKoID = LsKo.ID
      JOIN Vsa ON LsKo.VsaID = Vsa.ID
      JOIN Kunden ON Vsa.KundenID = Kunden.ID
      JOIN Holding ON Kunden.HoldingID = Holding.ID
      JOIN Standort ON LsPo.ProduktionID = Standort.ID
      JOIN VsaOrt ON LsPo.VsaOrtID = VsaOrt.ID
      JOIN Abteil ON LsPo.AbteilID = Abteil.ID
      JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
      JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
      JOIN KdBer ON KdArti.KdBerID = KdBer.ID
      JOIN Bereich ON KdBer.BereichID = Bereich.ID
      JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
      JOIN ArtGroe ON LsPo.ArtGroeID = ArtGroe.ID
      JOIN LiefArt ON KdArti.LiefArtID = LiefArt.ID
      JOIN Fahrt ON LsKo.FahrtID = Fahrt.ID
      JOIN Touren ON Fahrt.TourenID = Touren.ID
      JOIN ME ON Artikel.MEID = ME.ID
      JOIN LsKoArt ON LsKo.LsKoArtID = LsKoArt.ID
      WHERE LsKo.Datum BETWEEN @start AND @end
        AND Kunden.ID IN ($5$)
        AND Standort.ID IN ($6$)
        AND Bereich.ID IN ($7$)
        AND ArtGru.ID IN ($8$)
        AND Kunden.SichtbarID IN ($SICHTBARIDS$)
        AND Vsa.SichtbarID IN ($SICHTBARIDS$);
    ';
  END
  ELSE
  BEGIN
    SET @sqltext = N'
      INSERT INTO #TmpLsMimZeitraum (Holding, KdNr, Kunde, Produktion, Lieferdatum, VsaNr, VsaStichwort, VsaBezeichnung, VsaName1, VsaName2, Gebäude, VsaUnterort, LsNotiz, KsSt, KsStBez, Bereich, ArtiGruppe, ArtikelNr, ArtikelBez, ArtiGröße, Variante, VarianteBez, Umlauf, Auslieferart, Tour, TourBez, Liefermenge, Mengeneinheit, LsNr, LsArt)
      SELECT Holding.Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, Standort.Bez AS Produktion, LsKo.Datum AS Lieferdatum, Vsa.VsaNr, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS VsaBezeichnung, Vsa.Name1 AS VsaName1, Vsa.Name2 AS VsaName2, Vsa.GebaeudeBez AS Gebäude, VsaOrt.Bez AS VsaUnterort, LsPo.Memo AS LsNotiz, Abteil.Abteilung AS KsSt, Abteil.Bez AS KsStBez, Bereich.Bereich, ArtGru.Gruppe AS ArtiGruppe, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, ArtGroe.Groesse AS ArtiGröße, KdArti.Variante, KdArti.VariantBez, KdArti.Umlauf, LiefArt.LiefartBez$LAN$ AS Auslieferart, Touren.Tour, Touren.Bez AS TourBez, LsPo.Menge AS Liefermenge, IIF(ME.ID < 0, N''ST'', ME.IsoCode) AS Mengeneinheit, LsKo.LsNr, LsKoArt.Art
      FROM LsPo
      JOIN LsKo ON LsPo.LsKoID = LsKo.ID
      JOIN Vsa ON LsKo.VsaID = Vsa.ID
      JOIN Kunden ON Vsa.KundenID = Kunden.ID
      JOIN Holding ON Kunden.HoldingID = Holding.ID
      JOIN Standort ON LsPo.ProduktionID = Standort.ID
      JOIN VsaOrt ON LsPo.VsaOrtID = VsaOrt.ID      
      JOIN Abteil ON LsPo.AbteilID = Abteil.ID
      JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
      JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
      JOIN KdBer ON KdArti.KdBerID = KdBer.ID
      JOIN Bereich ON KdBer.BereichID = Bereich.ID
      JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
      JOIN ArtGroe ON LsPo.ArtGroeID = ArtGroe.ID
      JOIN LiefArt ON KdArti.LiefArtID = LiefArt.ID
      JOIN Fahrt ON LsKo.FahrtID = Fahrt.ID
      JOIN Touren ON Fahrt.TourenID = Touren.ID
      JOIN ME ON Artikel.MEID = ME.ID
      JOIN LsKoArt ON LsKo.LsKoArtID = LsKoArt.ID
      WHERE LsKo.Datum BETWEEN @start AND @end
        AND Kunden.ID IN ($5$)
        AND Standort.ID IN ($6$)
        AND Bereich.ID IN ($7$)
        AND ArtGru.ID IN ($8$)
        AND Artikel.ArtikelNr = N'$10$'
        AND Kunden.SichtbarID IN ($SICHTBARIDS$)
        AND Vsa.SichtbarID IN ($SICHTBARIDS$);
    ';
  END;
END
ELSE
BEGIN
  IF $10$ = N''
  BEGIN
    SET @sqltext = N'
      INSERT INTO #TmpLsMimZeitraum (Holding, KdNr, Kunde, Produktion, Lieferdatum, VsaNr, VsaStichwort, VsaBezeichnung, VsaName1, VsaName2, Gebäude, VsaUnterort, LsNotiz, StammKsSt, StammKsStBez, LsKsSt, LsKsStBez, Bereich, ArtiGruppe, ArtikelNr, ArtikelBez, ArtiGröße, Variante, VarianteBez, Umlauf, Auslieferart, Tour, TourBez, Liefermenge, Mengeneinheit, LsNr, LsArt)
      SELECT Holding.Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, Standort.Bez AS Produktion, LsKo.Datum AS Lieferdatum, Vsa.VsaNr, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS VsaBezeichnung, Vsa.Name1 AS VsaName1, Vsa.Name2 AS VsaName2, Vsa.GebaeudeBez AS Gebäude, VsaOrt.Bez AS VsaUnterort, LsPo.Memo AS LsNotiz, Abteil.Abteilung AS KsSt, Abteil.Bez AS KsStBez, Bereich.Bereich, ArtGru.Gruppe AS ArtiGruppe, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, ArtGroe.Groesse AS ArtiGröße, KdArti.Variante, KdArti.VariantBez, KdArti.Umlauf, LiefArt.LiefartBez$LAN$ AS Auslieferart, Touren.Tour, Touren.Bez AS TourBez, LsPo.Menge AS Liefermenge, IIF(ME.ID < 0, N''ST'', ME.IsoCode) AS Mengeneinheit, LsKo.LsNr, LsKoArt.Art
      FROM LsPo
      JOIN LsKo ON LsPo.LsKoID = LsKo.ID
      JOIN Vsa ON LsKo.VsaID = Vsa.ID
      JOIN Kunden ON Vsa.KundenID = Kunden.ID
      JOIN Holding ON Kunden.HoldingID = Holding.ID
      JOIN Standort ON LsPo.ProduktionID = Standort.ID
      JOIN VsaOrt ON LsPo.VsaOrtID = VsaOrt.ID
      JOIN Abteil ON LsPo.AbteilID = Abteil.ID
      JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
      JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
      JOIN KdBer ON KdArti.KdBerID = KdBer.ID
      JOIN Bereich ON KdBer.BereichID = Bereich.ID
      JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
      JOIN ArtGroe ON LsPo.ArtGroeID = ArtGroe.ID
      JOIN LiefArt ON KdArti.LiefArtID = LiefArt.ID
      JOIN Fahrt ON LsKo.FahrtID = Fahrt.ID
      JOIN Touren ON Fahrt.TourenID = Touren.ID
      JOIN ME ON Artikel.MEID = ME.ID
      JOIN LsKoArt ON LsKo.LsKoArtID = LsKoArt.ID
      WHERE LsKo.Datum BETWEEN @start AND @end
        AND Kunden.KdNr = $9$
        AND Standort.ID IN ($6$)
        AND Bereich.ID IN ($7$)
        AND ArtGru.ID IN ($8$)
        AND Kunden.SichtbarID IN ($SICHTBARIDS$)
        AND Vsa.SichtbarID IN ($SICHTBARIDS$);
    ';
  END
  ELSE
  BEGIN
    SET @sqltext = N'
      INSERT INTO #TmpLsMimZeitraum (Holding, KdNr, Kunde, Produktion, Lieferdatum, VsaNr, VsaStichwort, VsaBezeichnung, VsaName1, VsaName2, Gebäude, VsaUnterort, LsNotiz, KsSt, KsStBez, Bereich, ArtiGruppe, ArtikelNr, ArtikelBez, ArtiGröße, Variante, VarianteBez, Umlauf, Auslieferart, Tour, TourBez, Liefermenge, Mengeneinheit, LsNr, LsArt)
      SELECT Holding.Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, Standort.Bez AS Produktion, LsKo.Datum AS Lieferdatum, Vsa.VsaNr, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS VsaBezeichnung, Vsa.Name1 AS VsaName1, Vsa.Name2 AS VsaName2, Vsa.GebaeudeBez AS Gebäude, VsaOrt.Bez AS VsaUnterort, LsPo.Memo AS LsNotiz, VsaAbteil.Abteilung AS StammKsSt, VsaAbteil.Bez AS StammKsStBez, LsAbteil.Abteilung AS LsKsSt, LsAbteil.Bez AS LsKsStBez, Bereich.Bereich, ArtGru.Gruppe AS ArtiGruppe, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, ArtGroe.Groesse AS ArtiGröße, KdArti.Variante, KdArti.VariantBez, KdArti.Umlauf, LiefArt.LiefartBez$LAN$ AS Auslieferart, Touren.Tour, Touren.Bez AS TourBez, LsPo.Menge AS Liefermenge, IIF(ME.ID < 0, N''ST'', ME.IsoCode) AS Mengeneinheit, LsKo.LsNr, LsKoArt.Art
      FROM LsPo
      JOIN LsKo ON LsPo.LsKoID = LsKo.ID
      JOIN Vsa ON LsKo.VsaID = Vsa.ID
      JOIN Kunden ON Vsa.KundenID = Kunden.ID
      JOIN Holding ON Kunden.HoldingID = Holding.ID
      JOIN Standort ON LsPo.ProduktionID = Standort.ID
      JOIN VsaOrt ON LsPo.VsaOrtID = VsaOrt.ID
      JOIN Abteil ON LsPo.AbteilID = Abteil.ID
      JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
      JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
      JOIN KdBer ON KdArti.KdBerID = KdBer.ID
      JOIN Bereich ON KdBer.BereichID = Bereich.ID
      JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
      JOIN ArtGroe ON LsPo.ArtGroeID = ArtGroe.ID
      JOIN LiefArt ON KdArti.LiefArtID = LiefArt.ID
      JOIN Fahrt ON LsKo.FahrtID = Fahrt.ID
      JOIN Touren ON Fahrt.TourenID = Touren.ID
      JOIN ME ON Artikel.MEID = ME.ID
      JOIN LsKoArt ON LsKo.LsKoArtID = LsKoArt.ID
      WHERE LsKo.Datum BETWEEN @start AND @end
        AND Kunden.KdNr = $9$
        AND Standort.ID IN ($6$)
        AND Bereich.ID IN ($7$)
        AND ArtGru.ID IN ($8$)
        AND Artikel.ArtikelNr = N'$10$'
        AND Kunden.SichtbarID IN ($SICHTBARIDS$)
        AND Vsa.SichtbarID IN ($SICHTBARIDS$);
    ';
  END;
END;

EXEC sp_executesql @sqltext, N'@start date, @end date', @start, @end;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Jahresauswertung                                                                                                          ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT DATEPART(year, x.Lieferdatum) AS Jahr, x.Holding, x.KdNr, x.Kunde, x.VsaNr, x.VsaStichwort AS [Vsa-Stichwort], x.VsaBezeichnung AS [Vsa-Bezeichnung], x.VsaName1 AS [Vsa-Adresszeile 1], x.VsaName2 AS [Vsa-Adresszeile 2], x.Gebäude, x.KsSt AS Kostenstelle, x.KsStBez AS Kostenstellenbezeichnung, x.Produktion, x.Bereich AS Produktbereich, x.ArtiGruppe AS Artikelgruppe, x.ArtikelNr, x.ArtikelBez AS Artikelbezeichnung, x.ArtiGröße AS Größe, SUM(x.Liefermenge) AS Liefermenge
FROM #TmpLSMimZeitraum AS x
GROUP BY DATEPART(year, x.Lieferdatum), x.Holding, x.KdNr, x.Kunde, x.VsaNr, x.VsaStichwort, x.VsaBezeichnung, x.VsaName1, x.VsaName2, x.Gebäude, x.KsSt, x.KsStBez, x.Produktion, x.Bereich, x.ArtiGruppe, x.ArtikelNr, x.ArtikelBez, x.ArtiGröße;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Monatsauswertung                                                                                                          ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT FORMAT(x.Lieferdatum, N'yyyy-MM') AS Monat, x.Holding, x.KdNr, x.Kunde, x.VsaNr, x.VsaStichwort AS [Vsa-Stichwort], x.VsaBezeichnung AS [Vsa-Bezeichnung], x.VsaName1 AS [Vsa-Adresszeile 1], x.VsaName2 AS [Vsa-Adresszeile 2], x.Gebäude, x.KsSt AS Kostenstelle, x.KsStBez AS Kostenstellenbezeichnung, x.Produktion, x.Bereich AS Produktbereich, x.ArtiGruppe AS Artikelgruppe, x.ArtikelNr, x.ArtikelBez AS Artikelbezeichnung, x.ArtiGröße AS Größe, SUM(x.Liefermenge) AS Liefermenge
FROM #TmpLSMimZeitraum AS x
GROUP BY FORMAT(x.Lieferdatum, N'yyyy-MM'), x.Holding, x.KdNr, x.Kunde, x.VsaNr, x.VsaStichwort, x.VsaBezeichnung, x.VsaName1, x.VsaName2, x.Gebäude, x.KsSt, x.KsStBez, x.Produktion, x.Bereich, x.ArtiGruppe, x.ArtikelNr, x.ArtikelBez, x.ArtiGröße;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Wochenauswertung                                                                                                          ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT FORMAT(DATEPART(year, x.Lieferdatum), N'0000') + N'/' + FORMAT(DATEPART(week, x.Lieferdatum), N'00') AS Woche, x.Holding, x.KdNr, x.Kunde, x.VsaNr, x.VsaStichwort AS [Vsa-Stichwort], x.VsaBezeichnung AS [Vsa-Bezeichnung], x.VsaName1 AS [Vsa-Adresszeile 1], x.VsaName2 AS [Vsa-Adresszeile 2], x.Gebäude, x.KsSt AS Kostenstelle, x.KsStBez AS Kostenstellenbezeichnung, x.Produktion, x.Bereich AS Produktbereich, x.ArtiGruppe AS Artikelgruppe, x.ArtikelNr, x.ArtikelBez AS Artikelbezeichnung, x.ArtiGröße AS Größe, SUM(x.Liefermenge) AS Liefermenge
FROM #TmpLSMimZeitraum AS x
GROUP BY FORMAT(DATEPART(year, x.Lieferdatum), N'0000') + N'/' + FORMAT(DATEPART(week, x.Lieferdatum), N'00'), x.Holding, x.KdNr, x.Kunde, x.VsaNr, x.VsaStichwort, x.VsaBezeichnung, x.VsaName1, x.VsaName2, x.Gebäude, x.KsSt, x.KsStBez, x.Produktion, x.Bereich, x.ArtiGruppe, x.ArtikelNr, x.ArtikelBez, x.ArtiGröße;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Kostenstellenauswertung                                                                                                   ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT x.Lieferdatum, x.Holding, x.KdNr, x.Kunde, x.VsaNr, x.VsaStichwort AS [Vsa-Stichwort], x.VsaBezeichnung AS [Vsa-Bezeichnung], x.VsaName1 AS [Vsa-Adresszeile 1], x.VsaName2 AS [Vsa-Adresszeile 2], x.Gebäude, x.KsSt AS Kostenstelle, x.KsStBez AS Kostenstellenbezeichnung, x.Produktion, x.Bereich AS Produktbereich, x.ArtiGruppe AS Artikelgruppe, x.ArtikelNr, x.ArtikelBez AS Artikelbezeichnung, x.ArtiGröße AS Größe, SUM(x.Liefermenge) AS Liefermenge
FROM #TmpLSMimZeitraum AS x
GROUP BY x.Lieferdatum, x.Holding, x.KdNr, x.Kunde, x.VsaNr, x.VsaStichwort, x.VsaBezeichnung, x.VsaName1, x.VsaName2, x.Gebäude, x.KsSt, x.KsStBez, x.Produktion, x.Bereich, x.ArtiGruppe, x.ArtikelNr, x.ArtikelBez, x.ArtiGröße;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Detailauswertung                                                                                                          ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT x.Holding, x.KdNr, x.Kunde, x.VsaNr, x.VsaStichwort AS [Vsa-Stichwort], x.VsaBezeichnung AS [Vsa-Bezeichnung], x.VsaName1 AS [Vsa-Adresszeile 1], x.VsaName2 AS [Vsa-Adresszeile 2], x.Gebäude, x.KsSt AS Kostenstelle, x.KsStBez AS Kostenstellenbezeichnung, x.Produktion, x.LsNr, x.Lieferdatum, x.LsArt AS [Lieferschein-Art], x.Bereich AS Produktbereich, x.ArtiGruppe AS Artikelgruppe, x.ArtikelNr, x.ArtikelBez AS Artikelbezeichnung, x.ArtiGröße AS Größe, x.Tour, x.TourBez AS [Tour-Bezeichnung], x.Variante, x.VarianteBez AS Variantenbezeichnung, x.Auslieferart, SUM(x.Liefermenge) AS Liefermenge, x.Umlauf, x.Mengeneinheit
FROM #TmpLSMimZeitraum AS x
GROUP BY x.Holding, x.KdNr, x.Kunde, x.Lieferdatum, x.VsaNr, x.VsaStichwort, x.VsaBezeichnung, x.VsaName1, x.VsaName2, x.Gebäude, x.KsSt, x.KsStBez, x.Produktion, x.LsNr, x.Lieferdatum, x.LsArt, x.Bereich, x.ArtiGruppe, x.ArtikelNr, x.ArtikelBez, x.ArtiGröße, x.Tour, x.TourBez, x.Variante, x.VarianteBez, x.Auslieferart, x.Umlauf, x.Mengeneinheit;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Touren-Auswertung                                                                                                         ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT x.Lieferdatum, x.Tour, x.TourBez AS [Tour-Bezeichnung], x.Holding, x.KdNr, x.Kunde, x.VsaNr, x.VsaStichwort AS [Vsa-Stichwort], x.VsaBezeichnung AS [Vsa-Bezeichnung], x.Bereich AS Produktbereich, x.ArtiGruppe AS Artikelgruppe, x.ArtikelNr, x.ArtikelBez AS Artikelbezeichnung, SUM(x.Liefermenge) AS Liefermenge
FROM #TmpLSMimZeitraum AS x
GROUP BY x.Lieferdatum, x.Tour, x.TourBez, x.Holding, x.KdNr, x.Kunde, x.VsaNr, x.VsaStichwort, x.VsaBezeichnung, x.Bereich, x.ArtiGruppe, x.ArtikelNr, x.ArtikelBez;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Kunde mit VSA-Unterort                                                                                                    ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT x.Holding, x.KdNr, x.Kunde, x.ArtikelNr, x.ArtikelBez AS Artikelbezeichnung, x.KsSt, x.KsStBez, x.VsaUnterort, x.LsNotiz, SUM(x.Liefermenge) AS Liefermenge
FROM #TmpLSMimZeitraum AS x
GROUP BY x.Holding, x.KdNr, x.Kunde, x.ArtikelNr, x.ArtikelBez, x.KsSt, x.KsStBez, x.VsaUnterort, x.LsNotiz;
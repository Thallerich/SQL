DROP TABLE IF EXISTS #TmpVOESTRechnung;

GO

DECLARE @RechKoID int = (SELECT RechKo.ID FROM RechKo WHERE RechKo.RechNr = 30355381);

/* BK-Leasing */

SELECT Artikel.ID AS ArtikelID,
  Traeger.ID AS TraegerID,
  RechPo.ID AS RechPoID,
  RechKo.RechNr,
  RechKo.RechDat,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.ID AS VsaID,
  Vsa.VsaNr,
  Vsa.SuchCode AS VsaStichwort,
  Vsa.Bez AS VsaBezeichnung,
  Vsa.GebaeudeBez AS Abteilung,
  Vsa.Name2 AS Bereich,
  Abteil.ID AS AbteilID,
  Abteil.Abteilung AS Kostenstelle,
  Abteil.Bez AS Kostenstellenbezeichnung,
  Traeger.Traeger AS TraegerNr,
  Traeger.PersNr,
  Traeger.Nachname,
  Traeger.Vorname,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez AS ArtikelBez,
  COALESCE(ArtGroe.Groesse, NULL) AS Größe,
  KdArti.VariantBez AS Variante,
  [Week].Woche AS Abrechnungswoche,
  AbtKdArW.EPreis AS Einzelpreis,
  SUM(TraeArch.Menge) AS Menge,
  ROUND(SUM(TraeArch.Menge) * AbtKdArW.EPreis, 2) AS Kosten,
  Barcodes = STUFF((
    SELECT N', ' + EinzHist.Barcode
    FROM EinzHist
    JOIN EinzTeil ON EinzHist.EinzTeilID = EinzTeil.ID
    LEFT JOIN [Week] AS AusdienstWeek ON EinzHist.AusdienstDat BETWEEN AusdienstWeek.VonDat AND AusdienstWeek.BisDat
    WHERE EinzHist.TraeArtiID = TraeArch.TraeArtiID
      AND EinzTeil.AltenheimModus = 0
      AND EinzHist.EinzHistTyp = 1
      AND (ISNULL(EinzHist.Indienst, N'2099/52') <= [Week].Woche AND EinzHist.EinzHistVon < [Week].BisDat)
      AND (
        (CAST(EinzHist.EinzHistBis AS date) = N'2099-12-31' AND IIF(EinzHist.Ausdienst IS NOT NULL AND EinzHist.Ausdienst != AusdienstWeek.Woche, AusdienstWeek.Woche, ISNULL(EinzHist.Ausdienst, N'2099/52')) > [Week].Woche)
        OR
        (CAST(EinzHist.EinzHistBis AS date) < N'2099-12-31' AND (IIF(EinzHist.Ausdienst IS NOT NULL AND EinzHist.Ausdienst <= [Week].Woche AND EinzHist.Ausdienst != AusdienstWeek.Woche, AusdienstWeek.Woche, EinzHist.Ausdienst) > [Week].Woche OR (EinzHist.Ausdienst IS NULL AND EinzHist.EinzHistBis > [Week].BisDat)))
      )
    FOR XML PATH('')
  ), 1, 2, N''),
  BarcodeAnzahl = (
    SELECT COUNT(EinzHist.ID)
    FROM EinzHist
    JOIN EinzTeil ON EinzHist.EinzTeilID = EinzTeil.ID
    LEFT JOIN [Week] AS AusdienstWeek ON EinzHist.AusdienstDat BETWEEN AusdienstWeek.VonDat AND AusdienstWeek.BisDat
    WHERE EinzHist.TraeArtiID = TraeArch.TraeArtiID
      AND EinzTeil.AltenheimModus = 0
      AND EinzHist.EinzHistTyp = 1
      AND (ISNULL(EinzHist.Indienst, N'2099/52') <= [Week].Woche AND EinzHist.EinzHistVon < [Week].BisDat)
      AND (
        (CAST(EinzHist.EinzHistBis AS date) = N'2099-12-31' AND IIF(EinzHist.Ausdienst IS NOT NULL AND EinzHist.Ausdienst != AusdienstWeek.Woche, AusdienstWeek.Woche, ISNULL(EinzHist.Ausdienst, N'2099/52')) > [Week].Woche)
        OR
        (CAST(EinzHist.EinzHistBis AS date) < N'2099-12-31' AND (IIF(EinzHist.Ausdienst IS NOT NULL AND EinzHist.Ausdienst <= [Week].Woche AND EinzHist.Ausdienst != AusdienstWeek.Woche, AusdienstWeek.Woche, EinzHist.Ausdienst) > [Week].Woche OR (EinzHist.Ausdienst IS NULL AND EinzHist.EinzHistBis > [Week].BisDat)))
      )
  ),
  CAST(N'L' AS nchar(1)) AS Art
INTO #TmpVOESTRechnung
FROM TraeArch
JOIN AbtKdArW ON TraeArch.AbtKdArWID = AbtKdArW.ID
JOIN Wochen ON AbtKdArW.WochenID = Wochen.ID
JOIN [Week] ON Wochen.Woche = [Week].Woche
JOIN RechPo ON ABtKdArW.RechPoID = RechPo.ID
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN TraeArti ON TraeArch.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON TraeArch.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Abteil ON RechPo.AbteilID = Abteil.ID
JOIN KdArti ON RechPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
WHERE RechKo.ID = @RechKoID
GROUP BY Artikel.ID,
  Traeger.ID,
  RechPo.ID,
  RechKo.RechNr,
  RechKo.RechDat,
  Kunden.KdNr,
  Kunden.SuchCode,
  Vsa.ID,
  Vsa.VsaNr,
  Vsa.SuchCode,
  Vsa.Bez,
  Vsa.GebaeudeBez,
  Vsa.Name2,
  Abteil.ID,
  Abteil.Abteilung,
  Abteil.Bez,
  Traeger.Traeger,
  Traeger.PersNr,
  Traeger.Nachname,
  Traeger.Vorname,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez,
  ArtGroe.Groesse,
  KdArti.VariantBez,
  [Week].Woche,
  [Week].BisDat,
  [Week].VonDat,
  AbtKdArW.EPreis,
  TraeArch.TraeArtiID;

/* Leasing sonstige */

INSERT INTO #TmpVOESTRechnung (ArtikelID, TraegerID, RechPoID, RechNr, RechDat, KdNr, Kunde, VsaID, VsaNr, VsaStichwort, VsaBezeichnung, Abteilung, Bereich, AbteilID, Kostenstelle, Kostenstellenbezeichnung, ArtikelNr, ArtikelBez, Variante, Abrechnungswoche, Einzelpreis, Menge, Kosten, Art)
SELECT Artikel.ID AS ArtikelID,
  CAST(-1 AS int) AS TraegerID,
  RechPo.ID AS RechPoID,
  RechKo.RechNr,
  RechKo.RechDat,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.ID AS VsaID,
  Vsa.VsaNr,
  Vsa.SuchCode AS VsaStichwort,
  Vsa.Bez AS VsaBezeichnung,
  Vsa.GebaeudeBez AS Abteilung,
  Vsa.Name2 AS Bereich,
  Abteil.ID AS AbteilID,
  Abteil.Abteilung AS Kostenstelle,
  Abteil.Bez AS Kostenstellenbezeichnung,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez AS ArtikelBez,
  KdArti.VariantBez AS Variante,
  Wochen.Woche AS Abrechnungswoche,
  AbtKdArW.EPreis AS Einzelpreis,
  SUM(AbtKdArW.Menge) AS Menge,
  ROUND(SUM(AbtKdArW.Menge) * AbtKdArW.EPreis, 2) AS Kosten,
  CAST(N'S' AS nchar(1)) AS Art
FROM AbtKdArW
JOIN Wochen ON AbtKdArW.WochenID = Wochen.ID
JOIN RechPo ON ABtKdArW.RechPoID = RechPo.ID
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Vsa ON AbtKdArW.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Abteil ON RechPo.AbteilID = Abteil.ID
JOIN KdArti ON RechPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE RechKo.ID = @RechKoID
  AND NOT EXISTS (
    SELECT TraeArch.*
    FROM TraeArch
    WHERE TraeArch.AbtKdArWID = AbtKdArW.ID
  )
GROUP BY Artikel.ID,
  RechPo.ID,
  RechKo.RechNr,
  RechKo.RechDat,
  Kunden.KdNr,
  Kunden.SuchCode,
  Vsa.ID,
  Vsa.VsaNr,
  Vsa.SuchCode,
  Vsa.Bez,
  Vsa.GebaeudeBez,
  Vsa.Name2,
  Abteil.ID,
  Abteil.Abteilung,
  Abteil.Bez,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez,
  KdArti.VariantBez,
  Wochen.Woche,
  AbtKdArW.EPreis;

/* Bearbeitung BK */

INSERT INTO #TmpVOESTRechnung (ArtikelID, TraegerID, RechPoID, RechNr, RechDat, KdNr, Kunde, VsaID, VsaNr, VsaStichwort, VsaBezeichnung, Abteilung, Bereich, AbteilID, Kostenstelle, Kostenstellenbezeichnung, TraegerNr, PersNr, Nachname, Vorname, ArtikelNr, ArtikelBez, Größe, Variante, Abrechnungswoche, Einzelpreis, Menge, Kosten, Barcodes, Art)
SELECT Artikel.ID AS ArtikelID,
  Traeger.ID AS TraegerID,
  RechPo.ID AS RechPoID,
  RechKo.RechNr,
  RechKo.RechDat,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.ID AS VsaID,
  Vsa.VsaNr,
  Vsa.SuchCode AS VsaStichwort,
  Vsa.Bez AS VsaBezeichnung,
  Vsa.GebaeudeBez AS Abteilung,
  Vsa.Name2 AS Bereich,
  Abteil.ID AS AbteilID,
  Abteil.Abteilung AS Kostenstelle,
  Abteil.Bez AS Kostenstellenbezeichnung,
  Traeger.Traeger AS TraegerNr,
  Traeger.PersNr,
  Traeger.Nachname,
  Traeger.Vorname,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez AS ArtikelBez,
  ArtGroe.Groesse AS Größe,
  KdArti.VariantBez AS Variante,
  [Week].Woche AS Abrechnungswoche,
  LsPo.EPreis AS Einzelpreis,
  COUNT(Scans.ID) AS Menge,
  ROUND(COUNT(Scans.ID) * LsPo.EPreis, 2) AS Kosten,
  EinzHist.Barcode,
  N'B' AS Art
FROM LsPo
JOIN RechPo ON LsPo.RechPoID = RechPo.ID
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN [Week] ON LsKo.Datum BETWEEN [Week].VonDat AND [Week].BisDat
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Abteil ON RechPo.AbteilID = Abteil.ID
JOIN KdArti ON RechPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Scans ON Scans.LsPoID = LsPo.ID
JOIN EinzHist ON Scans.EinzHistID = EinzHist.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
WHERE RechKo.ID = @RechKoID
GROUP BY Artikel.ID,
  Traeger.ID,
  RechPo.ID,
  RechKo.RechNr,
  RechKo.RechDat,
  Kunden.KdNr,
  Kunden.SuchCode,
  Vsa.ID,
  Vsa.VsaNr,
  Vsa.SuchCode,
  Vsa.Bez,
  Vsa.GebaeudeBez,
  Vsa.Name2,
  Abteil.ID,
  Abteil.Abteilung,
  Abteil.Bez,
  Traeger.Traeger,
  Traeger.PersNr,
  Traeger.Nachname,
  Traeger.Vorname,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez,
  ArtGroe.Groesse,
  KdArti.VariantBez,
  [Week].Woche,
  LsPo.EPreis,
  EinzHist.Barcode;

/* Bearbeitung sonstige */

INSERT INTO #TmpVOESTRechnung (ArtikelID, TraegerID, RechPoID, RechNr, RechDat, KdNr, Kunde, VsaID, VsaNr, VsaStichwort, VsaBezeichnung, Abteilung, Bereich, AbteilID, Kostenstelle, Kostenstellenbezeichnung, ArtikelNr, ArtikelBez, Variante, Abrechnungswoche, Einzelpreis, Menge, Kosten, Art)
SELECT Artikel.ID AS ArtikelID,
  CAST(-1 AS int) AS TraegerID,
  RechPo.ID AS RechPoID,
  RechKo.RechNr,
  RechKo.RechDat,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.ID AS VsaID,
  Vsa.VsaNr,
  Vsa.SuchCode AS VsaStichwort,
  Vsa.Bez AS VsaBezeichnung,
  Vsa.GebaeudeBez AS Abteilung,
  Vsa.Name2 AS Bereich,
  Abteil.ID AS AbteilID,
  Abteil.Abteilung AS Kostenstelle,
  Abteil.Bez AS Kostenstellenbezeichnung,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez AS ArtikelBez,
  KdArti.VariantBez AS Variante,
  [Week].Woche AS Abrechnungswoche,
  LsPo.EPreis AS Einzelpreis,
  SUM(LsPo.Menge) AS Menge,
  ROUND(SUM(LsPo.Menge) * LsPo.EPreis, 2) AS Kosten,
  N'F' AS Art
FROM LsPo
JOIN RechPo ON LsPo.RechPoID = RechPo.ID
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN [Week] ON LsKo.Datum BETWEEN [Week].VonDat AND [Week].BisDat
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Abteil ON RechPo.AbteilID = Abteil.ID
JOIN KdArti ON RechPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE RechKo.ID = @RechKoID
  AND NOT EXISTS (
    SELECT Scans.*
    FROM Scans
    WHERE Scans.LsPoID = LsPo.ID
  )
GROUP BY Artikel.ID,
  RechPo.ID,
  RechKo.RechNr,
  RechKo.RechDat,
  Kunden.KdNr,
  Kunden.SuchCode,
  Vsa.ID,
  Vsa.VsaNr,
  Vsa.SuchCode,
  Vsa.Bez,
  Vsa.GebaeudeBez,
  Vsa.Name2,
  Abteil.ID,
  Abteil.Abteilung,
  Abteil.Bez,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez,
  KdArti.VariantBez,
  [Week].Woche,
  LsPo.EPreis;

/* Restwert-fakturierte Teile */

INSERT INTO #TmpVOESTRechnung (ArtikelID, TraegerID, RechPoID, RechNr, RechDat, KdNr, Kunde, VsaID, VsaNr, VsaStichwort, VsaBezeichnung, Abteilung, Bereich, AbteilID, Kostenstelle, Kostenstellenbezeichnung, TraegerNr, PersNr, Nachname, Vorname, ArtikelNr, ArtikelBez, Größe, Variante, Abrechnungswoche, Einzelpreis, Menge, Kosten, Barcodes, Art)
SELECT Artikel.ID AS ArtikelID,
  Traeger.ID AS TraegerID,
  RechPo.ID AS RechPoID,
  RechKo.RechNr,
  RechKo.RechDat,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.ID AS VsaID,
  Vsa.VsaNr,
  Vsa.SuchCode AS VsaStichwort,
  Vsa.Bez AS VsaBezeichnung,
  Vsa.GebaeudeBez AS Abteilung,
  Vsa.Name2 AS Bereich,
  Abteil.ID AS AbteilID,
  Abteil.Abteilung AS Kostenstelle,
  Abteil.Bez AS Kostenstellenbezeichnung,
  Traeger.Traeger AS TraegerNr,
  Traeger.PersNr,
  Traeger.Nachname,
  Traeger.Vorname,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez AS ArtikelBez,
  ArtGroe.Groesse AS Größe,
  KdArti.VariantBez AS Variante,
  Wochen.Woche AS Abrechnungswoche,
  TeilSoFa.EPreis AS Einzelpreis,
  RechPo.Menge,
  ROUND(RechPo.Menge * TeilSoFa.EPreis, 2) AS Kosten,
  EinzHist.Barcode,
  N'R' AS Art
FROM TeilSoFa
JOIN RechPo ON TeilSoFa.RechPoID = RechPo.ID
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Wochen ON RechKo.MasterWochenID = Wochen.ID
JOIN EinzHist ON TeilSoFa.EinzHistID = EinzHist.ID
JOIN TraeArti ON EinzHist.TraeArtiID = TraeArti.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON RechPo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Abteil ON RechPo.AbteilID = Abteil.ID
WHERE RechKo.ID = @RechKoID;

SELECT RechNr, RechDat AS Rechnungsdatum, KdNr, Kunde, VsaNr, VsaBezeichnung AS [Vsa-Bezeichnung], Abteilung, Bereich, Kostenstelle, Kostenstellenbezeichnung, TraegerNr AS TrägerNr, PersNr AS Personalnummer, Nachname, Vorname, ArtikelNr, ArtikelBez AS Artikelbezeichnung, Variante AS Verrechnungsart, Abrechnungswoche, Kosten, Menge, Barcodes, BarcodeAnzahl AS BarcodeLeasingMenge, Art
FROM #TmpVOESTRechnung
WHERE BarcodeAnzahl != Menge
ORDER BY RechNr, KdNr, VsaNr, TrägerNr, ArtikelNr;

SELECT N'Auswertung' AS Source, SUM(Kosten) FROM #TmpVOESTRechnung
UNION ALL
SELECT N'Rechnung' AS Source, RechKo.NettoWert FROM RechKo WHERE RechKo.ID = @RechKoID;



/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++                                                                                                                           ++ */
/* ++ Data checking queries                                                                                                     ++ */
/* ++                                                                                                                           ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

/*
DECLARE @tnr nchar(8) = N'0162';
DECLARE @pnr nchar(10) = N'7122420';
DECLARE @artikelnr nchar(15) = N'26VH';
DECLARE @woche nchar(7) = N'2023/29';

DECLARE @vondat date, @bisdat date, @sqltext nvarchar(max);

SELECT @vondat = [Week].VonDat,@bisdat = [Week].BisDat
FROM [Week] 
WHERE [Week].Woche = @woche;

SET @sqltext = N'
  SELECT EinzHist.Barcode, EinzHist.[Status], EinzHist.Indienst, EinzHist.Ausdienst, EinzHist.EinzHistVon, EinzHist.EinzHistBis, EinzHist.Archiv, EinzHist.EinzHistTyp, @vondat AS VonDat, @bisdat AS BisDat
  FROM EinzHist
  JOIN EinzTeil ON EinzHist.EinzTeilID = EinzTeil.ID
  LEFT JOIN [Week] ON EinzHist.AusdienstDat BETWEEN [Week].VonDat AND [Week].BisDat
  WHERE EinzHist.TraeArtiID IN (
      SELECT DISTINCT TraeArch.TraeArtiID
      FROM TraeArch
      JOIN TraeArti ON TraeArch.TraeArtiID = TraeArti.ID
      JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
      JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
      JOIN Wochen ON TraeArch.WochenID = Wochen.ID
      JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
      JOIN Vsa ON Traeger.VsaID = Vsa.ID
      JOIN Kunden ON Vsa.KundenID = Kunden.ID
      WHERE Kunden.KdNr = 272295
        AND Traeger.Traeger = @tnr
        AND Traeger.PersNr = @pnr
        AND Artikel.ArtikelNr = @artikelnr
        AND Wochen.Woche = @woche
    )
    AND EinzTeil.AltenheimModus = 0
    AND EinzHist.EinzHistTyp = 1
    AND (ISNULL(EinzHist.Indienst, N''2099/52'') <= @woche AND EinzHist.EinzHistVon < @bisdat)
    AND (
      (CAST(EinzHist.EinzHistBis AS date) = N''2099-12-31'' AND IIF(EinzHist.Ausdienst IS NOT NULL AND EinzHist.Ausdienst != [Week].Woche, [Week].Woche, ISNULL(EinzHist.Ausdienst, N''2099/52'')) > @woche)
      OR
      (CAST(EinzHist.EinzHistBis AS date) < N''2099-12-31'' AND (IIF(EinzHist.Ausdienst IS NOT NULL AND EinzHist.Ausdienst <= [Week].Woche AND EinzHist.Ausdienst != [Week].Woche, [Week].Woche, EinzHist.Ausdienst) > @woche OR (EinzHist.Ausdienst IS NULL AND EinzHist.EinzHistBis > @bisdat)))
    );
';

EXEC sp_executesql @sqltext, N'@woche nchar(7), @tnr nchar(8), @pnr nchar(10), @artikelnr nchar(15), @vondat date, @bisdat date', @woche, @tnr, @pnr, @artikelnr, @vondat, @bisdat;

SET @sqltext = N'
  SELECT EinzHist.Barcode, EinzHist.[Status], EinzHist.VsaID, EinzHist.Indienst, EinzHist.Ausdienst, EinzHist.AusdienstDat, EinzHist.EinzHistVon, EinzHist.EinzHistBis, EinzHist.Archiv, EinzHist.EinzHistTyp, @vondat AS VonDat, @bisdat AS BisDat, [Week].Woche, EinzHist.TraeArtiID
  FROM EinzHist
  LEFT JOIN [Week] ON EinzHist.AusdienstDat BETWEEN [Week].VonDat AND [Week].BisDat
  WHERE EinzHist.TraeArtiID IN (
    SELECT DISTINCT TraeArch.TraeArtiID
    FROM TraeArch
    JOIN TraeArti ON TraeArch.TraeArtiID = TraeArti.ID
    JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
    JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
    JOIN Wochen ON TraeArch.WochenID = Wochen.ID
    JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
    JOIN Vsa ON Traeger.VsaID = Vsa.ID
    JOIN Kunden ON Vsa.KundenID = Kunden.ID
    WHERE Kunden.KdNr = 272295
      AND Traeger.Traeger = @tnr
      AND Traeger.PersNr = @pnr
      AND Artikel.ArtikelNr = @artikelnr
      AND Wochen.Woche = @woche
  );
';

EXEC sp_executesql @sqltext, N'@woche nchar(7), @tnr nchar(8), @pnr nchar(10), @artikelnr nchar(15), @vondat date, @bisdat date', @woche, @tnr, @pnr, @artikelnr, @vondat, @bisdat;

GO
*/
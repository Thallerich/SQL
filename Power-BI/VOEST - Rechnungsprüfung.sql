DROP TABLE IF EXISTS #TmpVOESTRechnung;

DECLARE @RechKo TABLE (
  RechKoID int
);

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Zu Testzwecken nur die Haupt-Kundennummer verwenden                                                                       ++ */
/* ++ Darunter das Query für alle Kunden der Holdings VOES / VOESAN                                                             ++ */
/* ++ Diese einfach tauschen, um entsprechend alle Kunden auszuwerten                                                           ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

INSERT INTO @RechKo (RechKoID)
SELECT RechKo.ID
FROM RechKo
WHERE RechKo.RechDat >= DATEADD(year, -1, GETDATE())
  AND RechKo.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = 272295);

/* 
INSERT INTO @RechKo (RechKoID)
SELECT RechKo.ID
FROM RechKo
WHERE RechKo.RechDat >= DATEADD(year, -1, GETDATE())
  AND RechKo.KundenID IN (
    SELECT Kunden.ID
    FROM Kunden
    JOIN Holding ON Kunden.HoldingID = Holding.ID
    WHERE Holding.Holding IN (N'VOES', N'VOESAN')
  );
 */

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
  Vsa.Name2 AS Abteilung,
  Vsa.GebaeudeBez AS Bereich,
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
  CAST(N'Leasing BK' AS nchar(20)) AS Art
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
WHERE RechKo.ID IN (SELECT RechKoID FROM @RechKo)
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
  Vsa.Name2 AS Abteilung,
  Vsa.GebaeudeBez AS Bereich,
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
  N'Leasing sonstige' AS Art
FROM AbtKdArW
JOIN Wochen ON AbtKdArW.WochenID = Wochen.ID
JOIN RechPo ON ABtKdArW.RechPoID = RechPo.ID
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Vsa ON AbtKdArW.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Abteil ON RechPo.AbteilID = Abteil.ID
JOIN KdArti ON RechPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE RechKo.ID IN (SELECT RechKoID FROM @RechKo)
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

INSERT INTO #TmpVOESTRechnung (ArtikelID, TraegerID, RechPoID, RechNr, RechDat, KdNr, Kunde, VsaID, VsaNr, VsaStichwort, VsaBezeichnung, Abteilung, Bereich, AbteilID, Kostenstelle, Kostenstellenbezeichnung, TraegerNr, PersNr, Nachname, Vorname, ArtikelNr, ArtikelBez, Größe, Variante, Abrechnungswoche, Einzelpreis, Menge, Kosten, Art)
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
  Vsa.Name2 AS Abteilung,
  Vsa.GebaeudeBez AS Bereich,
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
  N'Bearbeitung BK' AS Art
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
WHERE RechKo.ID IN (SELECT RechKoID FROM @RechKo)
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
  Vsa.Name2 AS Abteilung,
  Vsa.GebaeudeBez AS Bereich,
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
  N'Bearbeitung sonstige' AS Art
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
WHERE RechKo.ID IN (SELECT RechKoID FROM @RechKo)
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

INSERT INTO #TmpVOESTRechnung (ArtikelID, TraegerID, RechPoID, RechNr, RechDat, KdNr, Kunde, VsaID, VsaNr, VsaStichwort, VsaBezeichnung, Abteilung, Bereich, AbteilID, Kostenstelle, Kostenstellenbezeichnung, TraegerNr, PersNr, Nachname, Vorname, ArtikelNr, ArtikelBez, Größe, Variante, Abrechnungswoche, Einzelpreis, Menge, Kosten, Art)
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
  Vsa.Name2 AS Abteilung,
  Vsa.GebaeudeBez AS Bereich,
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
  N'Restwert/Verkauf' AS Art
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
WHERE RechKo.ID IN (SELECT RechKoID FROM @RechKo);

SELECT RechNr, RechDat AS Rechnungsdatum, KdNr, Kunde, VsaNr, VsaBezeichnung AS [Vsa-Bezeichnung], Abteilung, Bereich, Kostenstelle, Kostenstellenbezeichnung, TraegerNr AS TrägerNr, PersNr AS Personalnummer, Nachname, Vorname, ArtikelNr, ArtikelBez AS Artikelbezeichnung, Variante AS Verrechnungsart, Abrechnungswoche, Kosten, Menge, Art
FROM #TmpVOESTRechnung
ORDER BY RechNr, KdNr, VsaNr, TrägerNr, ArtikelNr;
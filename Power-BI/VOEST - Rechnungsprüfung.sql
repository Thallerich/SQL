DROP TABLE IF EXISTS #TmpVOESTRechnung, #RechKo;

CREATE TABLE #RechKo (
  RechKoID int
);

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Zu Testzwecken nur die Haupt-Kundennummer verwenden                                                                       ++ */
/* ++ Darunter das Query für alle Kunden der Holdings VOES / VOESAN                                                             ++ */
/* ++ Diese einfach tauschen, um entsprechend alle Kunden auszuwerten                                                           ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

/*INSERT INTO @RechKo (RechKoID)
SELECT RechKo.ID
FROM RechKo
WHERE RechKo.RechDat >= DATEADD(year, -1, GETDATE())
  AND RechKo.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = 272295);
  */

INSERT INTO #RechKo (RechKoID)
SELECT RechKo.ID
FROM RechKo
WHERE RechKo.RechDat >= DATEADD(MONTH, -11, GETDATE())
  AND RechKo.KundenID IN (
    SELECT Kunden.ID
    FROM Kunden
    JOIN Holding ON Kunden.HoldingID = Holding.ID
    WHERE Holding.Holding IN (N'VOES', N'VOESAN',N'VOESLE')
  );


/* BK-Leasing */

SELECT Artikel.ID AS ArtikelID,
  KdBer.BereichID,
  Traeger.ID AS TraegerID,
  RechPo.ID AS RechPoID,
  RechKo.RechNr,
  RechKo.RechDat,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  IIF(VaterVsa.ID IS NULL, Vsa.ID, VaterVsa.ID) AS VsaID,
  IIF(VaterVsa.ID IS NULL, Vsa.VsaNr, VaterVsa.VsaNr) AS VsaNr,
  IIF(VaterVsa.ID IS NULL, Vsa.Bez, VaterVsa.Bez) AS VsaBez,
  IIF(VaterVsa.ID IS NULL, Vsa.GebaeudeBez, VaterVsa.GebaeudeBez) AS Abteilung,
  IIF(VaterVsa.ID IS NULL, Vsa.Name2, VaterVsa.Name2) AS Bereich,
  Abteil.ID AS AbteilID,
  Abteil.Abteilung AS Kostenstelle,
  Abteil.Bez AS Kostenstellenbezeichnung,
  Traeger.Traeger AS TraegerNr,
  Traeger.PersNr,
  Traeger.Nachname,
  Traeger.Vorname,
  Artikel.ArtikelNr,
  COALESCE(ArtGroe.Groesse, NULL) AS Größe,
  KdArti.VariantBez AS Variante,
  [Week].Woche AS Abrechnungswoche,
  AbtKdArW.EPreis AS Einzelpreis,
  SUM(TraeArch.Menge) AS Menge,
  ROUND(SUM(TraeArch.Menge) * AbtKdArW.EPreis, 2) AS Kosten,
  CAST(N'Mietpreis' AS nchar(20)) AS Art
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
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
LEFT JOIN (
  SELECT DISTINCT TraeArch.WochenID, TraeArch.VsaID, TraeArti.TraegerID
  FROM TraeArch
  JOIN TraeArti ON TraeArch.TraeArtiID = TraeArti.ID
) AS VaterTraeArch ON Traeger.ParentTraegerID = VaterTraeArch.TraegerID AND TraeArch.WochenID = VaterTraeArch.WochenID
LEFT JOIN Vsa AS VaterVsa ON VaterTraeArch.VsaID = VaterVsa.ID
WHERE RechKo.ID IN (SELECT RechKoID FROM #RechKo)
GROUP BY Artikel.ID,
  KdBer.BereichID,
  Traeger.ID,
  RechPo.ID,
  RechKo.RechNr,
  RechKo.RechDat,
  Kunden.KdNr,
  Kunden.SuchCode,
  IIF(VaterVsa.ID IS NULL, Vsa.ID, VaterVsa.ID),
  IIF(VaterVsa.ID IS NULL, Vsa.VsaNr, VaterVsa.VsaNr) ,
  IIF(VaterVsa.ID IS NULL, Vsa.Bez, VaterVsa.Bez) ,
  IIF(VaterVsa.ID IS NULL, Vsa.GebaeudeBez, VaterVsa.GebaeudeBez),
  IIF(VaterVsa.ID IS NULL, Vsa.Name2, VaterVsa.Name2),
  Abteil.ID,
  Abteil.Abteilung,
  Abteil.Bez,
  Traeger.Traeger,
  Traeger.PersNr,
  Traeger.Nachname,
  Traeger.Vorname,
  Artikel.ArtikelNr,
  ArtGroe.Groesse,
  KdArti.VariantBez,
  [Week].Woche,
  [Week].BisDat,
  [Week].VonDat,
  AbtKdArW.EPreis,
  TraeArch.TraeArtiID;

/* Leasing sonstige */

INSERT INTO #TmpVOESTRechnung (ArtikelID, BereichID, TraegerID, RechPoID, RechNr, RechDat, KdNr, Kunde, VsaID, VsaNr, VsaBez, Abteilung, Bereich, AbteilID, Kostenstelle, Kostenstellenbezeichnung, ArtikelNr, Variante, Abrechnungswoche, Einzelpreis, Menge, Kosten, Art)
SELECT Artikel.ID AS ArtikelID,
  KdBer.BereichID,
  CAST(-1 AS int) AS TraegerID,
  RechPo.ID AS RechPoID,
  RechKo.RechNr,
  RechKo.RechDat,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.ID AS VsaID,
  Vsa.VsaNr AS VsaNr,
  Vsa.Bez AS VsaBez,
  Vsa.GebaeudeBez AS Abteilung,
  Vsa.Name2 AS Bereich,
  Abteil.ID AS AbteilID,
  Abteil.Abteilung AS Kostenstelle,
  Abteil.Bez AS Kostenstellenbezeichnung,
  Artikel.ArtikelNr,
  KdArti.VariantBez AS Variante,
  Wochen.Woche AS Abrechnungswoche,
  AbtKdArW.EPreis AS Einzelpreis,
  SUM(AbtKdArW.Menge) AS Menge,
  ROUND(SUM(AbtKdArW.Menge) * AbtKdArW.EPreis, 2) AS Kosten,
  N'Mietpreis' AS Art
FROM AbtKdArW
JOIN Wochen ON AbtKdArW.WochenID = Wochen.ID
JOIN RechPo ON ABtKdArW.RechPoID = RechPo.ID
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Vsa ON AbtKdArW.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Abteil ON RechPo.AbteilID = Abteil.ID
JOIN KdArti ON RechPo.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE RechKo.ID IN (SELECT RechKoID FROM #RechKo)
  AND NOT EXISTS (
    SELECT TraeArch.*
    FROM TraeArch
    WHERE TraeArch.AbtKdArWID = AbtKdArW.ID
  )
GROUP BY Artikel.ID,
  KdBer.BereichID,
  RechPo.ID,
  RechKo.RechNr,
  RechKo.RechDat,
  Kunden.KdNr,
  Kunden.SuchCode,
  Vsa.ID,
  Vsa.VsaNr,
  Vsa.Bez,
  Vsa.GebaeudeBez,
  Vsa.Name2,
  Abteil.ID,
  Abteil.Abteilung,
  Abteil.Bez,
  Artikel.ArtikelNr,
  KdArti.VariantBez,
  Wochen.Woche,
  AbtKdArW.EPreis;

/* Bearbeitung BK */

INSERT INTO #TmpVOESTRechnung (ArtikelID, BereichID, TraegerID, RechPoID, RechNr, RechDat, KdNr, Kunde, VsaID,VsaNr, VsaBez, Abteilung, Bereich, AbteilID, Kostenstelle, Kostenstellenbezeichnung, TraegerNr, PersNr, Nachname, Vorname, ArtikelNr, Größe, Variante, Abrechnungswoche, Einzelpreis, Menge, Kosten, Art)
SELECT Artikel.ID AS ArtikelID,
  KdBer.BereichID,
  Traeger.ID AS TraegerID,
  RechPo.ID AS RechPoID,
  RechKo.RechNr,
  RechKo.RechDat,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  IIF(VaterVsa.ID IS NULL, Vsa.ID, VaterVsa.ID) AS VsaID,
  IIF(VaterVsa.ID IS NULL, Vsa.VsaNr, VaterVsa.VsaNr) AS VsaNr,
  IIF(VaterVsa.ID IS NULL, Vsa.Bez, VaterVsa.Bez) AS VsaBez,
  IIF(VaterVsa.ID IS NULL, Vsa.GebaeudeBez, VaterVsa.GebaeudeBez) AS Abteilung,
  IIF(VaterVsa.ID IS NULL, Vsa.Name2, VaterVsa.Name2) AS Bereich,
  Abteil.ID AS AbteilID,
  Abteil.Abteilung AS Kostenstelle,
  Abteil.Bez AS Kostenstellenbezeichnung,
  Traeger.Traeger AS TraegerNr,
  Traeger.PersNr,
  Traeger.Nachname,
  Traeger.Vorname,
  Artikel.ArtikelNr,
  ArtGroe.Groesse AS Größe,
  KdArti.VariantBez AS Variante,
  [Week].Woche AS Abrechnungswoche,
  LsPo.EPreis AS Einzelpreis,
  COUNT(Scans.ID) AS Menge,
  ROUND(COUNT(Scans.ID) * LsPo.EPreis, 2) AS Kosten,
  N'Waschpreis' AS Art
FROM LsPo
JOIN RechPo ON LsPo.RechPoID = RechPo.ID
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN [Week] ON LsKo.Datum BETWEEN [Week].VonDat AND [Week].BisDat
JOIN Wochen ON [Week].Woche = Wochen.Woche
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Abteil ON RechPo.AbteilID = Abteil.ID
JOIN KdArti ON RechPo.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Scans ON Scans.LsPoID = LsPo.ID
JOIN EinzHist ON Scans.EinzHistID = EinzHist.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
LEFT JOIN (
  SELECT DISTINCT TraeArch.WochenID, TraeArch.VsaID, TraeArti.TraegerID
  FROM TraeArch
  JOIN TraeArti ON TraeArch.TraeArtiID = TraeArti.ID
) AS VaterTraeArch ON Traeger.ParentTraegerID = VaterTraeArch.TraegerID AND Wochen.ID = VaterTraeArch.WochenID
LEFT JOIN Vsa AS VaterVsa ON VaterTraeArch.VsaID = VaterVsa.ID
WHERE RechKo.ID IN (SELECT RechKoID FROM #RechKo)
GROUP BY Artikel.ID,
  KdBer.BereichID,
  Traeger.ID,
  RechPo.ID,
  RechKo.RechNr,
  RechKo.RechDat,
  Kunden.KdNr,
  Kunden.SuchCode,
  IIF(VaterVsa.ID IS NULL, Vsa.ID, VaterVsa.ID),
  IIF(VaterVsa.ID IS NULL, Vsa.VsaNr, VaterVsa.VsaNr) ,
  IIF(VaterVsa.ID IS NULL, Vsa.Bez, VaterVsa.Bez) ,
  IIF(VaterVsa.ID IS NULL, Vsa.GebaeudeBez, VaterVsa.GebaeudeBez),
  IIF(VaterVsa.ID IS NULL, Vsa.Name2, VaterVsa.Name2),
  Abteil.ID,
  Abteil.Abteilung,
  Abteil.Bez,
  Traeger.Traeger,
  Traeger.PersNr,
  Traeger.Nachname,
  Traeger.Vorname,
  Artikel.ArtikelNr,
  ArtGroe.Groesse,
  KdArti.VariantBez,
  [Week].Woche,
  LsPo.EPreis,
  EinzHist.Barcode;

/* Bearbeitung sonstige */

INSERT INTO #TmpVOESTRechnung (ArtikelID, BereichID, TraegerID, RechPoID, RechNr, RechDat, KdNr, Kunde, VsaID,VsaNr, VSaBez, Abteilung, Bereich, AbteilID, Kostenstelle, Kostenstellenbezeichnung, ArtikelNr, Variante, Abrechnungswoche, Einzelpreis, Menge, Kosten, Art)
SELECT Artikel.ID AS ArtikelID,
  KdBer.BereichID,
  CAST(-1 AS int) AS TraegerID,
  RechPo.ID AS RechPoID,
  RechKo.RechNr,
  RechKo.RechDat,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.ID AS VsaID,
  Vsa.VsaNr AS VsaNr,
  Vsa.Bez AS VsaBez,
  Vsa.GebaeudeBez AS Abteilung,
  Vsa.Name2 AS Bereich,
  Abteil.ID AS AbteilID,
  Abteil.Abteilung AS Kostenstelle,
  Abteil.Bez AS Kostenstellenbezeichnung,
  Artikel.ArtikelNr,
  KdArti.VariantBez AS Variante,
  [Week].Woche AS Abrechnungswoche,
  LsPo.EPreis AS Einzelpreis,
  SUM(LsPo.Menge) AS Menge,
  ROUND(SUM(LsPo.Menge) * LsPo.EPreis, 2) AS Kosten,
  N'Waschpreis' AS Art
FROM LsPo
JOIN RechPo ON LsPo.RechPoID = RechPo.ID
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN [Week] ON LsKo.Datum BETWEEN [Week].VonDat AND [Week].BisDat
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Abteil ON RechPo.AbteilID = Abteil.ID
JOIN KdArti ON RechPo.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE RechKo.ID IN (SELECT RechKoID FROM #RechKo)
  AND NOT EXISTS (
    SELECT Scans.*
    FROM Scans
    WHERE Scans.LsPoID = LsPo.ID
  )
GROUP BY Artikel.ID,
  KdBer.BereichID,
  RechPo.ID,
  RechKo.RechNr,
  RechKo.RechDat,
  Kunden.KdNr,
  Kunden.SuchCode,
  Vsa.ID,
  Vsa.Vsanr,
  Vsa.Bez,
  Vsa.GebaeudeBez,
  Vsa.Name2,
  Abteil.ID,
  Abteil.Abteilung,
  Abteil.Bez,
  Artikel.ArtikelNr,
  KdArti.VariantBez,
  [Week].Woche,
  LsPo.EPreis;

/* Restwert-fakturierte Teile */

INSERT INTO #TmpVOESTRechnung (ArtikelID, BereichID, TraegerID, RechPoID, RechNr, RechDat, KdNr, Kunde, VsaID, VsaNr, VsaBez,Abteilung, Bereich, AbteilID, Kostenstelle, Kostenstellenbezeichnung, TraegerNr, PersNr, Nachname, Vorname, ArtikelNr, Größe, Variante, Abrechnungswoche, Einzelpreis, Menge, Kosten, Art)
SELECT Artikel.ID AS ArtikelID,
  KdBer.BereichID,
  Traeger.ID AS TraegerID,
  RechPo.ID AS RechPoID,
  RechKo.RechNr,
  RechKo.RechDat,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.ID AS VsaID,
  Vsa.VsaNr AS VsaNr,
  Vsa.Bez as VsaBez,
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
  ArtGroe.Groesse AS Größe,
  KdArti.VariantBez AS Variante,
  Wochen.Woche AS Abrechnungswoche,
  TeilSoFa.EPreis AS Einzelpreis,
  RechPo.Menge,
  ROUND(RechPo.Menge * TeilSoFa.EPreis, 2) AS Kosten,
  Art = 
    CASE
      WHEN RwArt.ID <> -1 THEN N'Verkauf und Restwert' --IN (2,6, 7, 8) 
      ELSE CONCAT('XXXXXX_',RwArt.ID)
    END
FROM TeilSoFa
JOIN RechPo ON TeilSoFa.RechPoID = RechPo.ID
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Wochen ON RechKo.MasterWochenID = Wochen.ID
JOIN EinzHist ON TeilSoFa.EinzHistID = EinzHist.ID
JOIN TraeArti ON EinzHist.TraeArtiID = TraeArti.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON RechPo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Abteil ON RechPo.AbteilID = Abteil.ID
JOIN RwArt ON TeilSoFa.RwArtID = RwArt.ID
WHERE RechKo.ID IN (SELECT RechKoID FROM #RechKo);

WITH VOESTProduktbereich AS (
  SELECT Bereich.ID AS BereichID,
    Bereichsbezeichnung = 
      CASE Bereich.Bereich
        WHEN N'BK' THEN N'Arbeitskleidung'
        WHEN N'BC' THEN N'Waschraumhygiene'
        WHEN N'FW' THEN N'Geschirr-, Handtücher, etc.'
        WHEN N'HW' THEN N'Kaufware'
        ELSE Bereich.BereichBez
      END
  FROM Bereich
)
SELECT #TmpVOESTRechnung.RechNr, #TmpVOESTRechnung.RechDat AS Rechnungsdatum, #TmpVOESTRechnung.KdNr, #TmpVOESTRechnung.Kunde, #TmpVOESTRechnung.VsaID,#TmpVOESTRechnung.Vsanr, #TmpVOESTRechnung.VsaBez ,#TmpVOESTRechnung.Abteilung, #TmpVOESTRechnung.Bereich, #TmpVOESTRechnung.Kostenstelle, #TmpVOESTRechnung.Kostenstellenbezeichnung, #TmpVOESTRechnung.TraegerNr AS TrägerNr, #TmpVOESTRechnung.TraegerID, #TmpVOESTRechnung.PersNr AS Personalnummer, #TmpVOESTRechnung.Nachname, #TmpVOESTRechnung.Vorname, #TmpVOESTRechnung.ArtikelNr, VOESTProduktbereich.Bereichsbezeichnung AS Artikelbereich, #TmpVOESTRechnung.Variante AS Verrechnungsart, #TmpVOESTRechnung.Abrechnungswoche, #TmpVOESTRechnung.Kosten, #TmpVOESTRechnung.Menge, #TmpVOESTRechnung.Art
FROM #TmpVOESTRechnung
JOIN VOESTProduktbereich ON #TmpVOESTRechnung.BereichID = VOESTProduktbereich.BereichID
ORDER BY RechNr, KdNr, VsaID, TrägerNr, ArtikelNr;
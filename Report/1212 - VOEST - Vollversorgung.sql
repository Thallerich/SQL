DROP TABLE IF EXISTS #TmpVOESTRechnung;

DECLARE @vonDatum date = $STARTDATE$;
DECLARE @bisDatum date = $ENDDATE$;
DECLARE @Wochenanzahl int;

DECLARE @RechKo TABLE (
  RechKoID int
);

INSERT INTO @RechKo (RechKoID)
SELECT RechKo.ID
FROM RechKo
JOIN Kunden ON RechKo.KundenID = Kunden.ID
WHERE RechKo.RechDat BETWEEN @vonDatum AND @bisDatum
  AND RechKo.Status = N'F'
  AND Kunden.KdNr = 272295;

SELECT @Wochenanzahl = DATEDIFF(week, MIN(Week.VonDat), MAX(Week.BisDat))
FROM AbtKdArW
JOIN RechPo ON AbtKdArW.RechPoID = RechPo.ID
JOIN Wochen ON AbtKdArW.WochenID = Wochen.ID
JOIN Week ON Wochen.Woche = Week.Woche
WHERE RechPo.RechKoID IN (
  SELECT RechKoID
  FROM @RechKo
);

SELECT Artikel.ID AS ArtikelID,
  Traeger.ID AS TraegerID,
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
  KdArti.VariantBez AS Variante,
  0 AS Waschzyklen,
  SUM(EinzHist.RuecklaufK) AS WaschzyklenGesamt,
  SUM(AbtKdArW.EPreis) AS Mietkosten,
  CAST(0 AS money) AS Waschkosten,
  CAST(0 AS money) AS Gesamt,
  EinzHist.Barcode,
  MIN(EinzHist.IndienstDat) AS Erstausgabedatum
INTO #TmpVOESTRechnung
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN AbtKdArW ON AbtKdArW.RechPoID = RechPo.ID
JOIN TraeArch ON TraeArch.AbtKdArWID = AbtKdArW.ID
JOIN TraeArti ON TraeArch.TraeArtiID = TraeArti.ID
JOIN EinzHist ON EinzHist.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON TraeArch.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Abteil ON RechPo.AbteilID = Abteil.ID
JOIN KdArti ON RechPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE RechKo.ID IN (SELECT RechKoID FROM @RechKo)
  AND EinzHist.EinzHistVon <= RechKo.BisDatum
  AND ISNULL(EinzHist.EinzHistBis, N'2099-12-31') >= RechKo.VonDatum
  AND EinzHist.Indienst IS NOT NULL
GROUP BY Artikel.ID,
  Traeger.ID,
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
  KdArti.VariantBez,
  EinzHist.Barcode;

MERGE INTO #TmpVOESTRechnung AS VOESTRechnung
USING (
  SELECT EinzHist.ArtikelID, Scans.TraegerID, EinzHist.Barcode, MIN(EinzHist.IndienstDat) AS Erstausgabedatum, RechKo.RechNr, RechKo.RechDat, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.ID AS VsaID, Vsa.VsaNr, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS VsaBezeichnung, Vsa.GebaeudeBez AS Abteilung, Vsa.Name2 AS Bereich, Abteil.ID AS AbteilID, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Traeger.Traeger AS TraegerNr, Traeger.PersNr, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez AS ArtikelBez, KdArti.VariantBez AS Variante, LsPo.EPreis, COUNT(Scans.ID) AS Waschzyklen, SUM(EinzHist.RuecklaufK) AS RuecklaufK
  FROM Scans
  JOIN LsPo ON Scans.LsPoID = LsPo.ID
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  JOIN EinzHist ON Scans.EinzHistID = EinzHist.ID
  JOIN Traeger ON Scans.TraegerID = Traeger.ID
  JOIN Vsa ON LsKo.VsaID = Vsa.ID
  JOIN Kunden oN Vsa.KundenID = Kunden.ID
  JOIN RechPo ON LsPo.RechPoID = RechPo.ID
  JOIN RechKo ON RechPo.RechKoID = RechKo.ID
  JOIN Abteil ON LsPo.AbteilID = Abteil.ID
  JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  WHERE RechKo.ID IN (SELECT RechKoID FROM @RechKo)
    AND Scans.EinzHistID > 0
  GROUP BY EinzHist.ArtikelID, Scans.TraegerID, EinzHist.Barcode, RechKo.RechNr, RechKo.RechDat, Kunden.KdNr, Kunden.SuchCode, Vsa.ID, Vsa.VsaNr, Vsa.SuchCode, Vsa.Bez, Vsa.GebaeudeBez, Vsa.Name2, Abteil.ID, Abteil.Abteilung, Abteil.Bez, Traeger.Traeger, Traeger.PersNr, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez, KdArti.VariantBez, LsPo.EPreis
) AS Bearbeitung
ON Bearbeitung.ArtikelID = VOESTRechnung.ArtikelID AND Bearbeitung.TraegerID = VOESTRechnung.TraegerID AND Bearbeitung.Variante = VOESTRechnung.Variante AND Bearbeitung.Barcode = VOESTRechnung.Barcode AND Bearbeitung.AbteilID = VOESTRechnung.AbteilID AND Bearbeitung.VsaID = VOESTRechnung.VsaID
WHEN MATCHED THEN
  UPDATE SET Waschkosten = Bearbeitung.EPreis * Bearbeitung.Waschzyklen, Waschzyklen = Bearbeitung.Waschzyklen
WHEN NOT MATCHED THEN
  INSERT (ArtikelID, TraegerID, Barcode, Erstausgabedatum, RechNr, RechDat, KdNr, Kunde, VsaID, VsaNr, VsaStichwort, VsaBezeichnung, Abteilung, Bereich, AbteilID, Kostenstelle, Kostenstellenbezeichnung, TraegerNr, PersNr, Nachname, Vorname, ArtikelNr, ArtikelBez, Variante, Mietkosten, Waschkosten, Waschzyklen, WaschzyklenGesamt)
  VALUES (Bearbeitung.ArtikelID, Bearbeitung.TraegerID, Bearbeitung.Barcode, Bearbeitung.Erstausgabedatum, Bearbeitung.RechNr, Bearbeitung.RechDat, Bearbeitung.KdNr, Bearbeitung.Kunde, Bearbeitung.VsaID, Bearbeitung.VsaNr, Bearbeitung.VsaStichwort, Bearbeitung.VsaBezeichnung, Bearbeitung.Abteilung, Bearbeitung.Bereich, Bearbeitung.AbteilID, Bearbeitung.Kostenstelle, Bearbeitung.Kostenstellenbezeichnung, Bearbeitung.TraegerNr, Bearbeitung.PersNr, Bearbeitung.Nachname, Bearbeitung.Vorname, Bearbeitung.ArtikelNr, Bearbeitung.ArtikelBez, Bearbeitung.Variante, 0, Bearbeitung.EPreis * Bearbeitung.Waschzyklen, Bearbeitung.Waschzyklen, Bearbeitung.RuecklaufK);

UPDATE #TmpVOESTRechnung SET Gesamt = Waschkosten + Mietkosten;

SELECT FORMAT(@vonDatum, N'dd.MM.yyyy', N'de-AT') + N' - ' + FORMAT(@bisDatum, N'dd.MM.yyyy', N'de-AT') AS Auswertungszeitraum, VOESTRechnung.KdNr, VOESTRechnung.Kunde, VOESTRechnung.VsaNr, VOESTRechnung.VsaBezeichnung AS [Vsa-Bezeichnung], VOESTRechnung.Abteilung, VOESTRechnung.Bereich, VOESTRechnung.Kostenstelle, VOESTRechnung.Kostenstellenbezeichnung, VOESTRechnung.TraegerNr AS TrägerNr, VOESTRechnung.PersNr AS Personalnummer, VOESTRechnung.Nachname, VOESTRechnung.Vorname, VOESTRechnung.ArtikelNr, VOESTRechnung.ArtikelBez AS Artikelbezeichnung, VOESTRechnung.Variante AS Verrechnungsart, VOESTRechnung.Barcode, VOESTRechnung.Erstausgabedatum, VOESTRechnung.Waschzyklen, VOESTRechnung.WaschzyklenGesamt AS [Waschzyklen Gesamt], VOESTRechnung.Mietkosten, VOESTRechnung.Waschkosten, VOESTRechnung.Gesamt AS Gesamtkosten, VOEST_VVPrList.Vollversorgungspreis * @Wochenanzahl AS [Kosten bei Vollversorgung], IIF(VOEST_VVPrList.Vollversorgungspreis * @Wochenanzahl < VOESTRechnung.Gesamt, VOESTRechnung.Gesamt - VOEST_VVPrList.Vollversorgungspreis * @Wochenanzahl, 0) AS [Ersparnis bei Vollversorgung]
FROM #TmpVOESTRechnung AS VOESTRechnung
JOIN Salesianer_Archive.dbo.VOEST_VVPrList ON VOESTRechnung.ArtikelNr = VOEST_VVPrList.ArtikelNr
WHERE VOEST_VVPrList.Vollversorgungspreis != 0
ORDER BY KdNr, VsaNr, TrägerNr, ArtikelNr;
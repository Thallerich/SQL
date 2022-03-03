DROP TABLE IF EXISTS #TmpVOESTRechnung;

DECLARE @vonDatum date = N'2021-01-01';
DECLARE @bisDatum date = N'2021-12-31';
DECLARE @Wochenanzahl int;

DECLARE @RechKo TABLE (
  RechKoID int
);

INSERT INTO @RechKo (RechKoID)
SELECT RechKo.ID
FROM RechKo
JOIN Kunden ON RechKo.KundenID = Kunden.ID
WHERE RechKo.RechDat BETWEEN N'2021-01-01' AND N'2021-12-31'
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
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
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
  Teile.RuecklaufG AS WaschzyklenGesamt,
  SUM(AbtKdArW.EPreis) AS Mietkosten,
  CAST(0 AS money) AS Waschkosten,
  CAST(0 AS money) AS Gesamt,
  Teile.Barcode,
  Teile.IndienstDat AS Erstausgabedatum
INTO #TmpVOESTRechnung
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN AbtKdArW ON AbtKdArW.RechPoID = RechPo.ID
JOIN TraeArch ON TraeArch.AbtKdArWID = AbtKdArW.ID
JOIN TraeArti ON TraeArch.TraeArtiID = TraeArti.ID
JOIN Teile ON Teile.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Abteil ON RechPo.AbteilID = Abteil.ID
JOIN KdArti ON RechPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE RechKo.ID IN (SELECT RechKoID FROM @RechKo)
  AND Teile.IndienstDat <= RechKo.BisDatum
  AND ISNULL(Teile.AusdienstDat, N'2099-12-31') >= RechKo.VonDatum
  AND KdArti.WaschPreis != 0
  AND KdArti.LeasPreis != 0
GROUP BY Artikel.ID,
  Traeger.ID,
  Kunden.KdNr,
  Kunden.SuchCode,
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
  Teile.RuecklaufG,
  Teile.Barcode,
  Teile.IndienstDat;

MERGE INTO #TmpVOESTRechnung AS VOESTRechnung
USING (
  SELECT ArtikelID, TraegerID, Barcode, Erstausgabedatum, KdNr, Kunde, VsaNr, VsaStichwort, VsaBezeichnung, Abteilung, Bereich, AbteilID, Kostenstelle, Kostenstellenbezeichnung, TraegerNr, PersNr, Nachname, Vorname, ArtikelNr, ArtikelBez, Variante, SUM(EPreis * Waschzyklen) AS Bearbeitungspreis, SUM(Waschzyklen) AS Waschzyklen, RuecklaufG
  FROM (
    SELECT Teile.ArtikelID, Teile.TraegerID, Teile.Barcode, Teile.IndienstDat AS Erstausgabedatum, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS VsaBezeichnung, Vsa.GebaeudeBez AS Abteilung, Vsa.Name2 AS Bereich, Abteil.ID AS AbteilID, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Traeger.Traeger AS TraegerNr, Traeger.PersNr, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez AS ArtikelBez, KdArti.VariantBez AS Variante, LsPo.EPreis, COUNT(Scans.ID) AS Waschzyklen, Teile.RuecklaufG
    FROM Scans
    JOIN LsPo ON Scans.LsPoID = LsPo.ID
    JOIN Teile ON Scans.TeileID = Teile.ID
    JOIN Traeger ON Teile.TraegerID = Traeger.ID
    JOIN Vsa ON Traeger.VsaID = Vsa.ID
    JOIN Kunden oN Vsa.KundenID = Kunden.ID
    JOIN RechPo ON LsPo.RechPoID = RechPo.ID
    JOIN RechKo ON RechPo.RechKoID = RechKo.ID
    JOIN Abteil ON LsPo.AbteilID = Abteil.ID
    JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
    JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
    WHERE RechKo.ID IN (SELECT RechKoID FROM @RechKo)
    GROUP BY Teile.ArtikelID, Teile.TraegerID, Teile.Barcode, Teile.IndienstDat, Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.SuchCode, Vsa.Bez, Vsa.GebaeudeBez, Vsa.Name2, Abteil.ID, Abteil.Abteilung, Abteil.Bez, Traeger.Traeger, Traeger.PersNr, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez, KdArti.VariantBez, LsPo.EPreis, Teile.RuecklaufG
  ) x
  GROUP BY ArtikelID, TraegerID, Barcode, Erstausgabedatum, KdNr, Kunde, VsaNr, VsaStichwort, VsaBezeichnung, Abteilung, Bereich, AbteilID, Kostenstelle, Kostenstellenbezeichnung, TraegerNr, PersNr, Nachname, Vorname, ArtikelNr, ArtikelBez, Variante, RuecklaufG
) AS Bearbeitung
ON Bearbeitung.ArtikelID = VOESTRechnung.ArtikelID AND Bearbeitung.TraegerID = VOESTRechnung.TraegerID AND Bearbeitung.Variante = VOESTRechnung.Variante AND Bearbeitung.Barcode = VOESTRechnung.Barcode AND Bearbeitung.AbteilID = VOESTRechnung.AbteilID
WHEN MATCHED THEN
  UPDATE SET Waschkosten = Bearbeitung.Bearbeitungspreis, Waschzyklen = Bearbeitung.Waschzyklen
WHEN NOT MATCHED THEN
  INSERT (ArtikelID, TraegerID, Barcode, Erstausgabedatum, KdNr, Kunde, VsaNr, VsaStichwort, VsaBezeichnung, Abteilung, Bereich, AbteilID, Kostenstelle, Kostenstellenbezeichnung, TraegerNr, PersNr, Nachname, Vorname, ArtikelNr, ArtikelBez, Variante, Mietkosten, Waschkosten, Waschzyklen, WaschzyklenGesamt)
  VALUES (Bearbeitung.ArtikelID, Bearbeitung.TraegerID, Bearbeitung.Barcode, Bearbeitung.Erstausgabedatum, Bearbeitung.KdNr, Bearbeitung.Kunde, Bearbeitung.VsaNr, Bearbeitung.VsaStichwort, Bearbeitung.VsaBezeichnung, Bearbeitung.Abteilung, Bearbeitung.Bereich, Bearbeitung.AbteilID, Bearbeitung.Kostenstelle, Bearbeitung.Kostenstellenbezeichnung, Bearbeitung.TraegerNr, Bearbeitung.PersNr, Bearbeitung.Nachname, Bearbeitung.Vorname, Bearbeitung.ArtikelNr, Bearbeitung.ArtikelBez, Bearbeitung.Variante, 0, Bearbeitung.Bearbeitungspreis, Bearbeitung.Waschzyklen, Bearbeitung.RuecklaufG);

UPDATE #TmpVOESTRechnung SET Gesamt = Waschkosten + Mietkosten;

SELECT FORMAT(@vonDatum, N'dd.MM.yyyy', N'de-AT') + N' - ' + FORMAT(@bisDatum, N'dd.MM.yyyy', N'de-AT') AS Auswertungszeitraum, VOESTRechnung.KdNr, VOESTRechnung.Kunde, VOESTRechnung.VsaNr, VOESTRechnung.VsaBezeichnung AS [Vsa-Bezeichnung], VOESTRechnung.Abteilung, VOESTRechnung.Bereich, VOESTRechnung.Kostenstelle, VOESTRechnung.Kostenstellenbezeichnung, VOESTRechnung.TraegerNr AS TrägerNr, VOESTRechnung.PersNr AS Personalnummer, VOESTRechnung.Nachname, VOESTRechnung.Vorname, VOESTRechnung.ArtikelNr, VOESTRechnung.ArtikelBez AS Artikelbezeichnung, VOESTRechnung.Variante AS Verrechnungsart, VOESTRechnung.Barcode, VOESTRechnung.Erstausgabedatum, VOESTRechnung.Waschzyklen, VOESTRechnung.WaschzyklenGesamt AS [Waschzyklen Gesamt], VOESTRechnung.Mietkosten, VOESTRechnung.Waschkosten, VOESTRechnung.Gesamt AS Gesamtkosten, VOEST_VVPrList.Vollversorgungspreis * @Wochenanzahl AS [Kosten bei Vollversorgung], IIF(VOEST_VVPrList.Vollversorgungspreis * @Wochenanzahl < VOESTRechnung.Gesamt, VOESTRechnung.Gesamt - VOEST_VVPrList.Vollversorgungspreis * @Wochenanzahl, 0) AS [Ersparnis bei Vollversorgung]
FROM #TmpVOESTRechnung AS VOESTRechnung
JOIN Salesianer_Archive.dbo.VOEST_VVPrList ON VOESTRechnung.ArtikelNr = VOEST_VVPrList.ArtikelNr
WHERE VOEST_VVPrList.Vollversorgungspreis != 0
ORDER BY KdNr, VsaNr, TrägerNr, ArtikelNr;
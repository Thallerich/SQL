DROP TABLE IF EXISTS #TmpVOESTRechnungPrep, #TmpVOESTRechnung;

DECLARE @RechKoID int, @MasterWoche varchar(7);
SELECT @RechKoID = RechKo.ID, @MasterWoche = Wochen.Woche FROM RechKo JOIN Wochen ON RechKo.MasterWochenID = Wochen.ID WHERE RechKo.ID = $RECHKOID$;

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
  EinzHist.RuecklaufK,
  AbtKdArW.EPreis,
  EinzHist.Barcode,
  EinzHist.IndienstDat,
  EinzHist.Kostenlos,
  EinzHist.Indienst,
  EinzHist.Ausdienst,
  Traeger.[Status] AS Trägerstatus
INTO #TmpVOESTRechnungPrep
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
WHERE RechKo.ID = @RechKoID
  AND EinzHist.EinzHistVon <= RechKo.BisDatum
  AND ISNULL(EinzHist.EinzHistBis, N'2099-12-31') >= RechKo.VonDatum
  AND EinzHist.Indienst IS NOT NULL;

/* Kostenlose / nicht relevante Einsatz-Historie-Datensätze löschen */
/* Wird nicht direkt im oberen Query gemacht, da so die Performance besser ist --> kein Index Scan auf EINZHIST.PK_EINZHIST im oberen SELECT */
DELETE FROM #TmpVOESTRechnungPrep
WHERE Kostenlos = 1
  OR Trägerstatus IN (N'K', N'P')
  OR Indienst > @MasterWoche
  OR ISNULL(Ausdienst, N'2099/52') < @MasterWoche;

SELECT ArtikelID,
  TraegerID,
  RechNr,
  RechDat,
  KdNr,
  Kunde,
  VsaID,
  VsaNr,
  VsaStichwort,
  VsaBezeichnung,
  Abteilung,
  Bereich,
  AbteilID,
  Kostenstelle,
  Kostenstellenbezeichnung,
  TraegerNr,
  PersNr,
  Nachname,
  Vorname,
  ArtikelNr,
  ArtikelBez,
  Variante,
  CAST(0 AS int) AS Waschzyklen,
  SUM(RuecklaufK) AS WaschzyklenGesamt,
  SUM(EPreis) AS Mietkosten,
  CAST(0 AS money) AS Waschkosten,
  CAST(0 AS money) AS Restwert,
  CAST(0 AS money) AS Gesamt,
  Barcode,
  MIN(IndienstDat) AS Erstausgabedatum
INTO #TmpVOESTRechnung
FROM #TmpVOESTRechnungPrep
GROUP BY ArtikelID,
  TraegerID,
  RechNr,
  RechDat,
  KdNr,
  Kunde,
  VsaID,
  VsaNr,
  VsaStichwort,
  VsaBezeichnung,
  Abteilung,
  Bereich,
  AbteilID,
  Abteilung,
  Kostenstelle,
  Kostenstellenbezeichnung,
  TraegerNr,
  PersNr,
  Nachname,
  Vorname,
  ArtikelNr,
  ArtikelBez,
  Variante,
  Barcode;

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
  WHERE RechKo.ID = @RechKoID
    AND Scans.EinzHistID > 0
  GROUP BY EinzHist.ArtikelID, Scans.TraegerID, EinzHist.Barcode, RechKo.RechNr, RechKo.RechDat, Kunden.KdNr, Kunden.SuchCode, Vsa.ID, Vsa.VsaNr, Vsa.SuchCode, Vsa.Bez, Vsa.GebaeudeBez, Vsa.Name2, Abteil.ID, Abteil.Abteilung, Abteil.Bez, Traeger.Traeger, Traeger.PersNr, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez, KdArti.VariantBez, LsPo.EPreis
) AS Bearbeitung
ON Bearbeitung.ArtikelID = VOESTRechnung.ArtikelID AND Bearbeitung.TraegerID = VOESTRechnung.TraegerID AND Bearbeitung.Variante = VOESTRechnung.Variante AND Bearbeitung.Barcode = VOESTRechnung.Barcode AND Bearbeitung.AbteilID = VOESTRechnung.AbteilID AND Bearbeitung.VsaID = VOESTRechnung.VsaID
WHEN MATCHED THEN
  UPDATE SET Waschkosten = Bearbeitung.EPreis * Bearbeitung.Waschzyklen, Waschzyklen = Bearbeitung.Waschzyklen
WHEN NOT MATCHED THEN
  INSERT (ArtikelID, TraegerID, Barcode, Erstausgabedatum, RechNr, RechDat, KdNr, Kunde, VsaID, VsaNr, VsaStichwort, VsaBezeichnung, Abteilung, Bereich, AbteilID, Kostenstelle, Kostenstellenbezeichnung, TraegerNr, PersNr, Nachname, Vorname, ArtikelNr, ArtikelBez, Variante, Mietkosten, Waschkosten, Restwert, Waschzyklen, WaschzyklenGesamt)
  VALUES (Bearbeitung.ArtikelID, Bearbeitung.TraegerID, Bearbeitung.Barcode, Bearbeitung.Erstausgabedatum, Bearbeitung.RechNr, Bearbeitung.RechDat, Bearbeitung.KdNr, Bearbeitung.Kunde, Bearbeitung.VsaID, Bearbeitung.VsaNr, Bearbeitung.VsaStichwort, Bearbeitung.VsaBezeichnung, Bearbeitung.Abteilung, Bearbeitung.Bereich, Bearbeitung.AbteilID, Bearbeitung.Kostenstelle, Bearbeitung.Kostenstellenbezeichnung, Bearbeitung.TraegerNr, Bearbeitung.PersNr, Bearbeitung.Nachname, Bearbeitung.Vorname, Bearbeitung.ArtikelNr, Bearbeitung.ArtikelBez, Bearbeitung.Variante, 0, Bearbeitung.EPreis * Bearbeitung.Waschzyklen, 0, Bearbeitung.Waschzyklen, Bearbeitung.RuecklaufK);

MERGE INTO #TmpVOESTRechnung AS VOESTRechnung
USING (
  SELECT EinzHist.ArtikelID, Traeger.ID AS TraegerID, EinzHist.Barcode, EinzHist.IndienstDat AS Erstausgabedatum, RechKo.RechNr, RechKo.RechDat, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.ID AS VsaID, Vsa.VsaNr, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS VsaBezeichnung, Vsa.GebaeudeBez AS Abteilung, Vsa.Name2 AS Bereich, Abteil.ID AS AbteilID, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Traeger.Traeger AS TraegerNr, Traeger.PersNr, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez AS ArtikelBez, KdArti.VariantBez AS Variante, TeilSoFa.EPreis, EinzHist.RuecklaufK AS RuecklaufK
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
  WHERE RechKo.ID = @RechKoID
) AS RestwertFakt
ON RestwertFakt.ArtikelID = VOESTRechnung.ArtikelID AND RestwertFakt.TraegerID = VOESTRechnung.TraegerID AND RestwertFakt.Variante = VOESTRechnung.Variante AND RestwertFakt.Barcode = VOESTRechnung.Barcode AND RestwertFakt.AbteilID = VOESTRechnung.AbteilID AND RestwertFakt.VsaID = VOESTRechnung.VsaID
WHEN MATCHED THEN
  UPDATE SET Restwert = RestwertFakt.EPreis
WHEN NOT MATCHED THEN
  INSERT (ArtikelID, TraegerID, Barcode, Erstausgabedatum, RechNr, RechDat, KdNr, Kunde, VsaID, VsaNr, VsaStichwort, VsaBezeichnung, Abteilung, Bereich, AbteilID, Kostenstelle, Kostenstellenbezeichnung, TraegerNr, PersNr, Nachname, Vorname, ArtikelNr, ArtikelBez, Variante, Mietkosten, Waschkosten, Restwert, Waschzyklen, WaschzyklenGesamt)
  VALUES (RestwertFakt.ArtikelID, RestwertFakt.TraegerID, RestwertFakt.Barcode, RestwertFakt.Erstausgabedatum, RestwertFakt.RechNr, RestwertFakt.RechDat, RestwertFakt.KdNr, RestwertFakt.Kunde, RestwertFakt.VsaID, RestwertFakt.VsaNr, RestwertFakt.VsaStichwort, RestwertFakt.VsaBezeichnung, RestwertFakt.Abteilung, RestwertFakt.Bereich, RestwertFakt.AbteilID, RestwertFakt.Kostenstelle, RestwertFakt.Kostenstellenbezeichnung, RestwertFakt.TraegerNr, RestwertFakt.PersNr, RestwertFakt.Nachname, RestwertFakt.Vorname, RestwertFakt.ArtikelNr, RestwertFakt.ArtikelBez, RestwertFakt.Variante, 0, 0, RestwertFakt.EPreis, 0, RestwertFakt.RuecklaufK);

UPDATE #TmpVOESTRechnung SET Gesamt = Waschkosten + Mietkosten + Restwert;

SELECT RechNr, RechDat AS Rechnungsdatum, KdNr, Kunde, VsaNr, VsaBezeichnung AS [Vsa-Bezeichnung], Abteilung, Bereich, Kostenstelle, Kostenstellenbezeichnung, TraegerNr AS TrägerNr, PersNr AS Personalnummer, Nachname, Vorname, ArtikelNr, ArtikelBez AS Artikelbezeichnung, Variante AS Verrechnungsart, Waschzyklen, WaschzyklenGesamt AS [Waschzyklen Gesamt], Mietkosten, Waschkosten, Restwert AS [Restwert-Verkauf], Gesamt AS Gesamtkosten, Barcode, Erstausgabedatum
FROM #TmpVOESTRechnung
ORDER BY RechNr, KdNr, VsaNr, TrägerNr, ArtikelNr;
DROP TABLE IF EXISTS #TmpVOESTRechnung;

DECLARE @RechKoID int = $RECHKOID$;

SELECT Artikel.ID AS ArtikelID,
  Traeger.ID AS TraegerID,
  RechKo.RechNr,
  RechKo.RechDat,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.VsaNr,
  Vsa.SuchCode AS VsaStichwort,
  Vsa.Bez AS VsaBezeichnung,
  Vsa.GebaeudeBez AS Abteilung,
  Vsa.Name2 AS Bereich,
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
WHERE RechKo.ID = @RechKoID
  AND Teile.IndienstDat <= RechKo.BisDatum
  AND ISNULL(Teile.AusdienstDat, N'2099-12-31') >= RechKo.VonDatum
GROUP BY Artikel.ID,
  Traeger.ID,
  RechKo.RechNr,
  RechKo.RechDat,
  Kunden.KdNr,
  Kunden.SuchCode,
  Vsa.VsaNr,
  Vsa.SuchCode,
  Vsa.Bez,
  Vsa.GebaeudeBez,
  Vsa.Name2,
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
  SELECT Teile.ArtikelID, Teile.TraegerID, Teile.Barcode, Teile.IndienstDat AS Erstausgabedatum, RechKo.RechNr, RechKo.RechDat, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS VsaBezeichnung, Vsa.GebaeudeBez AS Abteilung, Vsa.Name2 AS Bereich, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Traeger.Traeger AS TraegerNr, Traeger.PersNr, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez AS ArtikelBez, KdArti.Variante, LsPo.EPreis, COUNT(Scans.ID) AS Waschzyklen, Teile.RuecklaufG
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
  WHERE RechKo.ID = @RechKoID
  GROUP BY Teile.ArtikelID, Teile.TraegerID, Teile.Barcode, Teile.IndienstDat, RechKo.RechNr, RechKo.RechDat, Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.SuchCode, Vsa.Bez, Vsa.GebaeudeBez, Vsa.Name2, Abteil.Abteilung, Abteil.Bez, Traeger.Traeger, Traeger.PersNr, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez, KdArti.Variante, LsPo.EPreis, Teile.RuecklaufG
) AS Bearbeitung
ON Bearbeitung.ArtikelID = VOESTRechnung.ArtikelID AND Bearbeitung.TraegerID = VOESTRechnung.TraegerID AND Bearbeitung.Variante = VOESTRechnung.Variante AND Bearbeitung.Barcode = VOESTRechnung.Barcode
WHEN MATCHED THEN
  UPDATE SET Waschkosten = Bearbeitung.EPreis * Bearbeitung.Waschzyklen, Waschzyklen = Bearbeitung.Waschzyklen
WHEN NOT MATCHED THEN
  INSERT (ArtikelID, TraegerID, Barcode, Erstausgabedatum, RechNr, RechDat, KdNr, Kunde, VsaNr, VsaStichwort, VsaBezeichnung, Abteilung, Bereich, Kostenstelle, Kostenstellenbezeichnung, TraegerNr, PersNr, Nachname, Vorname, ArtikelNr, ArtikelBez, Variante, Mietkosten, Waschkosten, Waschzyklen, WaschzyklenGesamt /*, offenBestellt */)
  VALUES (Bearbeitung.ArtikelID, Bearbeitung.TraegerID, Bearbeitung.Barcode, Bearbeitung.Erstausgabedatum, Bearbeitung.RechNr, Bearbeitung.RechDat, Bearbeitung.KdNr, Bearbeitung.Kunde, Bearbeitung.VsaNr, Bearbeitung.VsaStichwort, Bearbeitung.VsaBezeichnung, Bearbeitung.Abteilung, Bearbeitung.Bereich, Bearbeitung.Kostenstelle, Bearbeitung.Kostenstellenbezeichnung, Bearbeitung.TraegerNr, Bearbeitung.PersNr, Bearbeitung.Nachname, Bearbeitung.Vorname, Bearbeitung.ArtikelNr, Bearbeitung.ArtikelBez, Bearbeitung.Variante, 0, Bearbeitung.EPreis * Bearbeitung.Waschzyklen, Bearbeitung.Waschzyklen, Bearbeitung.RuecklaufG /* , 0 */);

UPDATE #TmpVOESTRechnung SET Gesamt = Waschkosten + Mietkosten;

SELECT RechNr, RechDat AS Rechnungsdatum, KdNr, Kunde, VsaNr, VsaBezeichnung AS [Vsa-Bezeichnung], Abteilung, Bereich, Kostenstelle, Kostenstellenbezeichnung, TraegerNr AS TrägerNr, PersNr AS Personalnummer, Nachname, Vorname, ArtikelNr, ArtikelBez AS Artikelbezeichnung, Variante AS Verrechnungsart, /* Maximalbestand, */ Waschzyklen, WaschzyklenGesamt AS [Waschzyklen Gesamt], Mietkosten, Waschkosten, Gesamt AS Gesamtkosten, /* offenBestellt AS [offene bestelle Wäscheteile] */ Barcode, Erstausgabedatum
FROM #TmpVOESTRechnung
ORDER BY RechNr, KdNr, VsaNr, TrägerNr, ArtikelNr;
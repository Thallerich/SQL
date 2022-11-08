/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Details für Barcodes auf Lieferscheine                                                                                    ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

UPDATE LsBcDet SET LsBCDetSQL = N'SELECT EinzTeil.Code
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN Scans ON Scans.EinzTeilID = EinzTeil.ID
WHERE Scans.LsPoID = $LsPoId$
  AND EinzHist.PatchDatum = $Datum$
ORDER BY 1'
WHERE ID = 7;

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Rechnungsanlagen                                                                                                          ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

UPDATE RKoAnlag SET SQLSkript = N'SELECT Kunden.KdNr, Vsa.VsaNr, Vsa.SuchCode AS VsaSuchCode, Vsa.Name1, Vsa.Name2, Vsa.Name3, Vsa.Strasse, Vsa.Land, Vsa.PLZ, Vsa.Ort, Vsa.MemoLS, LsKo.LsNr, LsKo.Datum, Touren.Bez AS Tour, Touren.Tour AS TourKurz, TRIM(Mitarbei.Nachname) + IIF(Mitarbei.Vorname <> '''', '', '' + TRIM(Mitarbei.Vorname), '''') AS Fahrer, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, KdArti.Variante, ArtGroe.Groesse, Abteil.Bez AS Kostenstelle, Traeger.Traeger, Traeger.Nachname, Traeger.Vorname, EinzHist.Barcode, Scans.[DateTime] AS AusleseZeitpunkt, Traeger.ID AS TraegerID, Abteil.ID AS KostenstellenID
FROM Scans
JOIN EinzHist ON Scans.EinzHistID = EinzHist.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN LsPo ON Scans.LsPoID = LsPo.ID
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Fahrt ON LsKo.FahrtID = Fahrt.ID
JOIN Touren ON Fahrt.TourenID = Touren.ID
JOIN Mitarbei ON Fahrt.MitarbeiID = Mitarbei.ID
JOIN RechPo ON LsPo.RechPoID = RechPo.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Abteil ON LsPo.AbteilID = Abteil.ID
WHERE RechPo.RechKoID = $RECHKOID$
  AND EinzHist.AltenheimModus = 0 --keine Bewohnerwäsche
  AND Scans.EinzHistID > 0
ORDER BY Kunden.KdNr, Vsa.VsaNr, LsKo.LsNr, KostenstellenID, Traeger.Nachname, Artikel.ArtikelNr;'
WHERE ID = 1023;

GO

UPDATE RKoAnlag SET SQLSkript = N'DROP TABLE IF EXISTS #TmpVOESTRechnung;

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
  EinzHist.RuecklaufK AS WaschzyklenGesamt,
  SUM(AbtKdArW.EPreis) AS Mietkosten,
  CAST(0 AS money) AS Waschkosten,
  CAST(0 AS money) AS Gesamt,
  EinzHist.Barcode,
  EinzHist.IndienstDat AS Erstausgabedatum
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
WHERE RechKo.ID = @RechKoID
  AND EinzHist.IndienstDat <= RechKo.BisDatum
  AND ISNULL(EinzHist.AusdienstDat, N''2099-12-31'') >= RechKo.VonDatum
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
  EinzHist.RuecklaufK,
  EinzHist.Barcode,
  EinzHist.IndienstDat;

MERGE INTO #TmpVOESTRechnung AS VOESTRechnung
USING (
  SELECT EinzHist.ArtikelID, EinzHist.TraegerID, EinzHist.Barcode, EinzHist.IndienstDat AS Erstausgabedatum, RechKo.RechNr, RechKo.RechDat, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS VsaBezeichnung, Vsa.GebaeudeBez AS Abteilung, Vsa.Name2 AS Bereich, Abteil.ID AS AbteilID, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Traeger.Traeger AS TraegerNr, Traeger.PersNr, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez AS ArtikelBez, KdArti.VariantBez AS Variante, LsPo.EPreis, COUNT(Scans.ID) AS Waschzyklen, EinzHist.RuecklaufK
  FROM Scans
  JOIN LsPo ON Scans.LsPoID = LsPo.ID
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  JOIN EinzHist ON Scans.EinzHistID = EinzHist.ID
  JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
  JOIN Vsa ON LsKo.VsaID = Vsa.ID
  JOIN Kunden oN Vsa.KundenID = Kunden.ID
  JOIN RechPo ON LsPo.RechPoID = RechPo.ID
  JOIN RechKo ON RechPo.RechKoID = RechKo.ID
  JOIN Abteil ON LsPo.AbteilID = Abteil.ID
  JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  WHERE RechKo.ID = @RechKoID
    AND Scans.EinzHistID > 0
  GROUP BY EinzHist.ArtikelID, EinzHist.TraegerID, EinzHist.Barcode, EinzHist.IndienstDat, RechKo.RechNr, RechKo.RechDat, Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.SuchCode, Vsa.Bez, Vsa.GebaeudeBez, Vsa.Name2, Abteil.ID, Abteil.Abteilung, Abteil.Bez, Traeger.Traeger, Traeger.PersNr, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez, KdArti.VariantBez, LsPo.EPreis, EinzHist.RuecklaufK
) AS Bearbeitung
ON Bearbeitung.ArtikelID = VOESTRechnung.ArtikelID AND Bearbeitung.TraegerID = VOESTRechnung.TraegerID AND Bearbeitung.Variante = VOESTRechnung.Variante AND Bearbeitung.Barcode = VOESTRechnung.Barcode AND Bearbeitung.AbteilID = VOESTRechnung.AbteilID
WHEN MATCHED THEN
  UPDATE SET Waschkosten = Bearbeitung.EPreis * Bearbeitung.Waschzyklen, Waschzyklen = Bearbeitung.Waschzyklen
WHEN NOT MATCHED THEN
  INSERT (ArtikelID, TraegerID, Barcode, Erstausgabedatum, RechNr, RechDat, KdNr, Kunde, VsaNr, VsaStichwort, VsaBezeichnung, Abteilung, Bereich, AbteilID, Kostenstelle, Kostenstellenbezeichnung, TraegerNr, PersNr, Nachname, Vorname, ArtikelNr, ArtikelBez, Variante, Mietkosten, Waschkosten, Waschzyklen, WaschzyklenGesamt)
  VALUES (Bearbeitung.ArtikelID, Bearbeitung.TraegerID, Bearbeitung.Barcode, Bearbeitung.Erstausgabedatum, Bearbeitung.RechNr, Bearbeitung.RechDat, Bearbeitung.KdNr, Bearbeitung.Kunde, Bearbeitung.VsaNr, Bearbeitung.VsaStichwort, Bearbeitung.VsaBezeichnung, Bearbeitung.Abteilung, Bearbeitung.Bereich, Bearbeitung.AbteilID, Bearbeitung.Kostenstelle, Bearbeitung.Kostenstellenbezeichnung, Bearbeitung.TraegerNr, Bearbeitung.PersNr, Bearbeitung.Nachname, Bearbeitung.Vorname, Bearbeitung.ArtikelNr, Bearbeitung.ArtikelBez, Bearbeitung.Variante, 0, Bearbeitung.EPreis * Bearbeitung.Waschzyklen, Bearbeitung.Waschzyklen, Bearbeitung.RuecklaufK);

UPDATE #TmpVOESTRechnung SET Gesamt = Waschkosten + Mietkosten;

SELECT RechNr, RechDat AS Rechnungsdatum, KdNr, Kunde, VsaNr, VsaBezeichnung AS [Vsa-Bezeichnung], Abteilung, Bereich, Kostenstelle, Kostenstellenbezeichnung, TraegerNr AS TrägerNr, PersNr AS Personalnummer, Nachname, Vorname, ArtikelNr, ArtikelBez AS Artikelbezeichnung, Variante AS Verrechnungsart, Waschzyklen, WaschzyklenGesamt AS [Waschzyklen Gesamt], Mietkosten, Waschkosten, Gesamt AS Gesamtkosten, Barcode, Erstausgabedatum
FROM #TmpVOESTRechnung
ORDER BY RechNr, KdNr, VsaNr, TrägerNr, ArtikelNr;'
WHERE ID = 1764;

GO

UPDATE RKoAnlag SET SQLSkript = N'SELECT Scans.[DateTime] AS [Datum der Entnahme], EntnahmeTraeger.PersNr, EntnahmeTraeger.Traeger AS TraegerNr, EntnahmeTraeger.Nachname, EntnahmeTraeger.Vorname, Abteil.Abteilung AS KsSt, Abteil.Bez AS Kostenstelle, EinzHist.Barcode, EinzHist.RentomatChip AS Chipcode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Kunden.KdNr, Kunden.SuchCode AS Kunde
FROM Scans
JOIN LsPo ON Scans.LsPoID = LsPo.ID
JOIN RechPo ON LsPo.RechPoID = RechPo.ID
JOIN EinzHist ON Scans.EinzHistID = EinzHist.ID
JOIN TraeArti ON EinzHist.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON LsPo.ArtGroeID = ArtGroe.ID
JOIN Traeger AS EntnahmeTraeger ON Scans.LastPoolTraegerID = EntnahmeTraeger.ID
JOIN Abteil ON EntnahmeTraeger.AbteilID = Abteil.ID
WHERE RechPo.RechKoID = $RECHKOID$
  AND Scans.ActionsID = 65;'
WHERE ID = 1777;

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Jobs                                                                                                                      ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

UPDATE SysJob SET Skript = N'DECLARE @HalfYearAgo datetime = DATEADD(day, -180, GETDATE());
DECLARE @KdNr AS TABLE (KdNr int);

INSERT INTO @KdNr VALUES (24045), (11050), (20000), (6071), (7240), (9013), (23041), (23042), (23044), (23032), (23037), (10001756), (242013), (2710499), (2710498), (18029), (245347), (248564), (246805), (10003247), (19080), (20156), (25033), (10001810), (10001671), (10001672), (10001770), (10001816);

DROP TABLE IF EXISTS #TmpSchwundAuto;

SELECT EinzTeil.ID AS EinzTeilID, IIF(EinzTeil.LastErsatzFuerKdArtiID < 0, EinzTeil.ArtikelID, KdArti.ArtikelID) AS ArtikelID, EinzTeil.VsaID AS VsaID
INTO #TmpSchwundAuto
FROM EinzTeil
JOIN Vsa ON EinzTeil.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON EinzTeil.LastErsatzFuerKdArtiID = KdArti.ID
JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
WHERE Kunden.KdNr IN (SELECT KdNr FROM @KdNr)
  AND EinzTeil.Status = N''Q''
  AND Bereich.Bereich != N''ST''
  AND EinzTeil.LastActionsID IN (102, 120, 136)
  AND EinzTeil.LastScanTime < @HalfYearAgo;

UPDATE EinzTeil SET [Status] = N''W'', LastActionsID = 116
WHERE ID IN (
  SELECT EinzTeilID FROM #TmpSchwundAuto
);

DROP TABLE IF EXISTS #TmpSchwundAuto;'
WHERE ID = 76;

GO

UPDATE SysJob SET Skript = N'DECLARE @previousday datetime2 = DATEADD(day, -1, CAST(GETDATE() AS date));
DECLARE @daystart datetime2 = DATEFROMPARTS(YEAR(@previousday), MONTH(@previousday), DAY(@previousday));
DECLARE @dayend datetime2 = DATEADD(day, 1, DATEFROMPARTS(YEAR(@previousday), MONTH(@previousday), DAY(@previousday)));
DECLARE @sqltext nvarchar(max);

SET @sqltext = N''SELECT EinzHist.Barcode, EinzHist.RentomatChip, Scans.[DateTime] AS Entnahmezeitpunkt, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse, ISNULL(Traeger.Nachname, N'''') + N'' '' + ISNULL(Traeger.Vorname, N'''') + N'' ('' + Traeger.Traeger + N'')'' AS [entnommen von]
FROM Scans
JOIN EinzHist ON Scans.EinzHistID = EinzHist.ID
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Traeger ON Scans.LastPoolTraegerID = Traeger.ID
WHERE Vsa.ID = 6140348
  AND Scans.[DateTime] BETWEEN @daystart AND @dayend
  AND Scans.ActionsID = 65;''

EXEC sp_executesql @sqltext, N''@daystart datetime2, @dayend datetime2'', @daystart, @dayend;'
WHERE ID = 100186;

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Webportal-Auswertungen                                                                                                    ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

UPDATE WebLists SET SQLCode = N'-- {Liste #27}
SELECT Kunden.Kdnr AS KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS VSABez, LsKo.LsNr, CONVERT(varchar, Lsko.Datum, 104) AS LiefDat, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikel, EinzTeil.Code
FROM Scans
JOIN EinzTeil ON Scans.EinzTeilID = EinzTeil.ID
JOIN AnfPo ON Scans.AnfPoID = AnfPo.ID
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN LsKo ON AnfKo.LsKoID = LsKo.ID
JOIN LsPo ON LsPo.LsKoID = LsKo.ID AND LsPo.KdArtiID = AnfPo.KdArtiID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE LsKo.Datum BETWEEN CAST($vonDat AS date) AND CAST($bisDat AS date)
  AND LsKo.VsaID IN ($vsaids)
  AND (AnfPo.Angefordert > 0 OR AnfPo.Geliefert > 0)
ORDER BY LiefDat, Vsa.VsaNr, LsKo.LsNr, Artikel.ArtikelNr;'
WHERE ID = 27;

GO

UPDATE WebLists SET SQLCode = N'-- {Liste #30}
SELECT Kunden.Kdnr AS KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS VSABez, LsKo.LsNr, CONVERT(varchar, Lsko.Datum, 104) AS LiefDat, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikel, EinzTeil.Code
FROM Scans
JOIN EinzTeil ON Scans.EinzTeilID = EinzTeil.ID
JOIN AnfPo ON Scans.AnfPoID = AnfPo.ID
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN LsKo ON AnfKo.LsKoID = LsKo.ID
JOIN LsPo ON LsPo.LsKoID = LsKo.ID AND LsPo.KdArtiID = AnfPo.KdArtiID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE LsKo.LsNr = $lsnr
  AND LsKo.VsaID IN ($vsaids)
  AND (AnfPo.Angefordert > 0 OR AnfPo.Geliefert > 0)
ORDER BY LiefDat, Vsa.VsaNr, LsKo.LsNr, Artikel.ArtikelNr;'
WHERE ID = 30;

GO

UPDATE WebLists SET SQLCode = N'-- {Liste #38}
WITH LastScan AS (
  SELECT Scans.EinzHistID, MAX(Scans.ID) AS ScanID
  FROM Scans
  WHERE Scans.ActionsID = 135  -- Action Ausgabe an Pool-Träger
  GROUP BY Scans.EinzHistID
)
SELECT EinzHist.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse, CAST(Scans.[DateTime] AS date) AS Ausgabedatum, Scans.Info AS [Träger laut Webportal]
FROM EinzHist
JOIN Artikel ON EinzHist.ArtikelID = Artikel.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN LastScan ON LastScan.EinzHistID = EinzHist.ID
JOIN Scans ON LastScan.ScanID = Scans.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE EinzHist.LastActionsID = 135  -- Action Ausgabe an Pool-Träger
  AND Kunden.ID = $kundenID
  AND Vsa.ID IN (
    SELECT Vsa.ID
    FROM Vsa
    JOIN WebUser ON WebUser.KundenID = Vsa.KundenID
    LEFT JOIN WebUVsa ON WebUVsa.WebUserID = WebUser.ID
    WHERE WebUser.ID = $webuserID
      AND (WebUVsa.ID IS NULL OR WebUVsa.VsaID = Vsa.ID)
  )
  AND Traeger.AbteilID IN (
    SELECT WebUAbt.AbteilID
      FROM WebUAbt
      WHERE WebUAbt.WebUserID =  $webuserID
  );'
WHERE ID = 38;

GO
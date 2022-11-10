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

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Auswertungen                                                                                                              ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

UPDATE ChartSQL SET ChartSQL = N'DECLARE @von datetime = $2$;
DECLARE @bis datetime = DATEADD(day, 1, $2$);

WITH ExpScan AS (
  SELECT Scans.EinzHistID, Scans.[DateTime] AS Zeitpunkt
  FROM Scans
  WHERE Scans.[DateTime] BETWEEN @von AND @bis
    AND Scans.ZielNrID = 2
    AND Scans.ActionsID = 2
)
SELECT L.KdNr, L.SuchCode, L.VsaID, L.VsaNr, L.Vsa, L.Nachname, L.Vorname, L.ZimmerNr, L.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez
FROM (
  SELECT Kunden.KdNr, Kunden.SuchCode, Vsa.ID AS VsaID, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Traeger.Nachname, Traeger.Vorname, Traeger.PersNr AS ZimmerNr, EinzHist.Barcode, EinzHist.ID AS TeileID, EinzHist.KdArtiID, Scans.Zeitpunkt
  FROM ExpScan AS Scans, EinzHist, Traeger, Vsa, Kunden
  WHERE Scans.EinzHistID = EinzHist.ID
    AND EinzHist.TraegerID = Traeger.ID
    AND Traeger.VsaID = Vsa.ID
    AND Vsa.KundenID = Kunden.ID
    AND Kunden.ID = $1$
) L, KdArti, LiefArt, Artikel
WHERE L.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND KdArti.LiefArtID = LiefArt.ID
  AND LiefArt.LiefArt = ''H''
ORDER BY L.KdNr, L.VsaID, L.VsaNr, L.ZimmerNr, L.Nachname, L.Vorname , Artikel.ArtikelNr, L.TeileID;'
WHERE ID = 171;

GO

UPDATE ChartSQL SET ChartSQL = N'SELECT MAX(Scans.[DateTime]) AS "Letzter Scan", (
  SELECT TOP 1 ZielNr.ZielNrBez$LAN$
    FROM ZielNr, Scans
    WHERE Scans.ZielNrID = ZielNr.ID
      AND Scans.EinzHistID = a.EinzHistID
    ORDER BY Scans.[DateTime] DESC
  ) AS "Letztes Ziel", a.*
FROM (
  SELECT EinzHist.ID AS EinzHistID, Kunden.KdNr, Kunden.Name2, Kunden.Name3, Kunden.Name1 AS Kunde, EinzHist.Barcode AS Seriennummer, Artikel.ArtikelBez$LAN$ AS Artikel, EinzHist.Status, EinzHist.Eingang1, EinzHist.Ausgang1, ISNULL(RTRIM(Traeger.Nachname), '''') + '' '' + ISNULL(RTRIM(Traeger.Vorname), '''') AS Träger, Traeger.PersNr AS ZimmerNr, VSA.SuchCode, VSA.Bez AS Bez, VSA.Name1 AS Vsa, VSA.Name2 AS VSA2, VSA.Name3 AS VSA3, (SELECT TOP 1 Fach FROM ScanFach WHERE ScanFach.VsaID = Vsa.ID AND ScanFach.TraegerID = Traeger.ID) AS Fach
  FROM EinzHist, Traeger, VSA, Kunden, Artikel
  WHERE EinzHist.TraegerID = Traeger.ID
    AND Traeger.VSAID = VSA.ID
    AND VSA.KundenID = Kunden.ID
    AND Kunden.ID = $1$
    AND EinzHist.Eingang1 IS NOT NULL
    AND (EinzHist.Eingang1 > EinzHist.Ausgang1 OR EinzHist.Ausgang1 IS NULL)
    AND EinzHist.Status IN (''Q'', ''M'', ''N'')
    AND EinzHist.ArtikelID = Artikel.ID
    AND EinzHist.AltenheimModus != 0
    AND Traeger.Status != N''I''
  ) a, Scans
WHERE a.EinzHistID = Scans.EinzHistID
  AND Scans.AnlageUserID_ <> (SELECT Mitarbei.ID FROM Mitarbei WHERE Mitarbei.UserName = N''ADVSUP'')
GROUP BY a.EinzHistID, KdNr, Name2, Name3, Kunde, Seriennummer, Artikel, Status, Eingang1, Ausgang1, Träger, ZimmerNr, SuchCode, Bez, Vsa, Vsa2, Vsa3, Fach
HAVING MAX(CONVERT(date, [DateTime])) <= $2$
ORDER BY SuchCode, Träger;'
WHERE ID = 48;

GO

UPDATE ChartSQL SET ChartSQL = N'WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N''EINZHIST'')
),
Traegerstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N''TRAEGER'')
),
ErstAuslesen AS (
  SELECT Scans.EinzHistID, MIN(Scans.EinAusDat) AS LiefDat
  FROM Scans
  WHERE Scans.Menge = -1
  GROUP BY Scans.EinzHistID
)
SELECT Kunden.Kdnr, Kunden.Suchcode as Kunde, Holding.Holding, Traeger.Nachname, Traeger.Vorname, Traegerstatus.StatusBez AS Trägerstatus, EinzHist.Barcode, Teilestatus.StatusBez AS Teilestatus, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Einsatz.EinsatzBez AS Einsatzgrund, EinzHist.Anlage_ AS [Teil angelegt am], IIF(EinzHist.Status = N''E'' AND TeileBPo.ID IS NOT NULL, Lief.SuchCode, NULL) AS [bestellt bei Lieferant], Lager.SuchCode AS [lieferndes Lager], EntnKo.ID AS EntnahmelistenNr, EntnKo.Anlage_ AS [Entnahmeliste angelegt am], EntnKo.DruckDatum AS [Druckdatum Entnahmeliste], [Entnahme-Datum] = (
  SELECT MAX(Scans.[DateTime])
  FROM Scans
  WHERE Scans.EinzHistID = EinzHist.ID
    AND Scans.ActionsID = 57
), EntnKo.PatchDatum AS [Patchdatum Entnahmeliste], IIF(EinzHist.IndienstDat < ISNULL(ErstAuslesen.LiefDat, N''2099-12-31''), EinzHist.IndienstDat, ErstAuslesen.LiefDat) AS [Lieferdatum zum Kunden]
FROM EinzHist
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Teilestatus ON EinzHist.[Status] = Teilestatus.[Status]
JOIN Traegerstatus ON Traeger.[Status] = Traegerstatus.[Status]
JOIN Einsatz ON EinzHist.EinsatzGrund = Einsatz.EinsatzGrund
JOIN Lagerart ON EinzHist.LagerartID = Lagerart.ID
JOIN Standort AS Lager ON Lagerart.LagerID = Lager.ID
LEFT JOIN EntnPo ON EinzHist.EntnPoID = EntnPo.ID AND EinzHist.EntnPoID > 0 AND EinzHist.Status >= N''K''
LEFT JOIN EntnKo ON EntnPo.EntnKoID = EntnKo.ID
LEFT JOIN TeileBPo ON TeileBPo.EinzHistID = EinzHist.ID AND TeileBPo.Latest = 1
LEFT JOIN BPo ON TeileBPo.BPoID = BPo.ID
LEFT JOIN BKo ON BPo.BKoID = BKo.ID
LEFT JOIN Lief ON BKo.LiefID = Lief.ID
LEFT JOIN ErstAuslesen ON ErstAuslesen.EinzHistID = EinzHist.ID
WHERE Artikel.BereichID = 100
  AND Kunden.Status = N''A''
  AND Vsa.Status = N''A''
  AND Traeger.Status != N''I''
  AND Teilestatus.ID IN ($2$)
  AND Kunden.KdGfID IN ($1$)
  AND Kunden.StandortID IN ($3$)
  AND EinzHist.Anlage_ BETWEEN $STARTDATE$ AND $ENDDATE$
ORDER BY [Entnahmeliste angelegt am];'
WHERE ID = 167;

GO

UPDATE ChartSQL SET ChartSQL = N'DECLARE @fromtime datetime;
DECLARE @totime datetime;
DECLARE @fromdate DATE;
DECLARE @todate DATE;

SET @fromtime = $1$;
SET @totime = DATEADD(day, 1, $2$);
SET @fromdate = $1$;
SET @todate = $2$;
 
DROP TABLE IF EXISTS #TmpFinal;

SELECT EinzHist.Barcode, Status.Teilestatus, Traeger.Vorname, Traeger.Nachname, Vsa.Bez AS Vsa, Abteil.Bez AS Kostenstelle, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, 0 AS Waschzyklen, EinzHist.ID AS EinzHistID
INTO #TmpFinal
FROM EinzHist, TraeArti, Traeger, Vsa, Kunden, KdArti, Artikel, ArtGroe, Abteil, (
  SELECT [Status].[Status], [Status].StatusBez$LAN$ AS Teilestatus
  FROM [Status]
  WHERE [Status].Tabelle = ''EINZHIST''
) AS [Status]
WHERE EinzHist.TraeArtiID = TraeArti.ID
  AND TraeArti.TraegerID = Traeger.ID
  AND Traeger.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND TraeArti.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND TraeArti.ArtGroeID = ArtGroe.ID
  AND Traeger.AbteilID = Abteil.ID
  AND EinzHist.Status = [Status].[Status]
  AND Kunden.ID = $ID$
  AND EinzHist.IndienstDat <= @todate
  AND EinzHist.IndienstDat IS NOT NULL
  AND COALESCE(EinzHist.AusdienstDat, CONVERT(date, ''2099-12-31'')) > @fromdate;
  
DROP TABLE IF EXISTS #TmpScans;

SELECT Scans.*
INTO #TmpScans
FROM Scans
WHERE Scans.[DateTime] BETWEEN @fromtime AND @totime
  AND Scans.EinzHistID IN (SELECT EinzHistID FROM #TmpFinal)
  AND Scans.Menge = -1;

UPDATE x SET x.Waschzyklen = Waschen.Waschzyklen
FROM #TmpFinal AS x, (
  SELECT Scans.EinzHistID, COUNT(Scans.ID) AS Waschzyklen
  FROM #TmpScans AS Scans
  WHERE EXISTS (
    SELECT Final.EinzHistID
    FROM #TmpFinal AS Final
    WHERE Final.EinzHistID = Scans.EinzHistID)
  GROUP BY Scans.EinzHistID
) AS Waschen
WHERE x.EinzHistID = Waschen.EinzHistID;

SELECT Final.Barcode, Final.Teilestatus, Final.Vorname, Final.Nachname, Final.Vsa, Final.Kostenstelle, Final.ArtikelNr, Final.Artikelbezeichnung, Final.Groesse, Final.Waschzyklen
FROM #TmpFinal AS Final
ORDER BY Final.Vsa, Final.Nachname, Final.Vorname, Final.ArtikelNr;'
WHERE ID = 212;

GO

UPDATE ChartSQL SET ChartSQL = N'WITH Lagerbestand (Lager, ArtikelNr, ArtikelBez$LAN$, Groesse, BestandNeu, BestandGebraucht, LagerID, ArtikelID, ArtGroeID)
AS (
  SELECT Standort.Bez AS Lager, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, ArtGroe.Groesse, SUM(IIF(LagerArt.Neuwertig = 1, Bestand.Bestand, 0)) AS BestandNeu, SUM(IIF(LagerArt.Neuwertig = 0, Bestand.Bestand, 0)) AS BestandGebraucht, Standort.ID AS LagerID, Artikel.ID AS ArtikelID, ArtGroe.ID AS ArtGroeID
  FROM Bestand
  JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
  JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
  JOIN LagerArt ON Bestand.LagerArtID = LagerArt.ID
  JOIN Standort ON LagerArt.LagerID = Standort.ID
  GROUP BY Standort.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, ArtGroe.Groesse, Standort.ID, Artikel.ID, ArtGroe.ID
),
Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N''EINZHIST''
)
SELECT KdGf.KurzBez AS SGF, Holding.Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, Mitarbei.Name AS Kundenservice, Vsa.VsaNr, Vsa.Bez AS Vsa, Traeger.Traeger AS [Trägernummer], COALESCE(RTRIM(Traeger.Nachname), N'''') + IIF(RTRIM(Traeger.Nachname) + RTRIM(Traeger.Vorname) IS NOT NULL, N'', '', N'''') + COALESCE(RTRIM(Traeger.Vorname), N'''') AS [Trägername], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS [Größe], Teilestatus.StatusBez AS Teilestatus, COUNT(DISTINCT EinzHist.ID) AS Menge, BKo.BestNr AS Bestellnummer, BKo.Datum AS Bestelldatum, MAX(LiefAbPo.Termin) AS [Liefertermin Lieferant], Lagerbestand.BestandNeu AS [Lagerbestand Neuware], Lagerbestand.BestandGebraucht AS [Lagerbestand Gebrauchtware], Lagerbestand.Lager AS Lagerstandort, Einsatz.EinsatzBez$LAN$ AS Einsatzgrund
FROM EinzHist
JOIN TraeArti ON EinzHist.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN VsaBer ON VsaBer.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Mitarbei ON VsaBer.ServiceID = Mitarbei.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Teilestatus ON EinzHist.Status = Teilestatus.Status
JOIN StandKon ON Vsa.StandKonID = StandKon.ID
JOIN StandBer ON StandBer.StandKonID = StandKon.ID AND StandBer.BereichID = Artikel.BereichID
JOIN Einsatz ON EinzHist.EinsatzGrund = Einsatz.EinsatzGrund
JOIN TeileBPo ON TeileBPo.EinzHistID = EinzHist.ID AND TeileBPo.Latest = 1
JOIN BPo ON TeileBPo.BPoID = BPo.ID
JOIN BKo ON BPo.BKoID = BKo.ID
LEFT OUTER JOIN LiefAbPo ON LiefAbPo.BPoID = BPo.ID
LEFT OUTER JOIN Lagerbestand ON ArtGroe.ID = Lagerbestand.ArtGroeID AND StandBer.LagerID = Lagerbestand.LagerID
WHERE EinzHist.Status IN (N''E'', N''G'', N''I'') -- nur Teile die bestellt wurden oder bestätigt (Auftragsbestätigung vom Lieferanten) wurden
  AND KdGf.ID IN ($1$)
  AND Kunden.StandortID IN ($2$)
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
  AND Vsa.SichtbarID IN ($SICHTBARIDS$)
GROUP BY KdGf.KurzBez, Holding.Holding, Kunden.KdNr, Kunden.SuchCode, Mitarbei.Name, Vsa.VsaNr, Vsa.Bez, Traeger.Traeger, COALESCE(RTRIM(Traeger.Nachname), N'''') + IIF(RTRIM(Traeger.Nachname) + RTRIM(Traeger.Vorname) IS NOT NULL, N'', '', N'''') + COALESCE(RTRIM(Traeger.Vorname), N''''), Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, ArtGroe.Groesse, Teilestatus.StatusBez, BKo.BestNr, BKo.Datum, Lagerbestand.BestandNeu, Lagerbestand.BestandGebraucht, LagerBestand.Lager, Einsatz.EinsatzBez$LAN$
ORDER BY SGF, KdNr, [Trägername], ArtikelNr, Teilestatus;'
WHERE ID = 296;

GO

UPDATE ChartSQL SET ChartSQL = N'SELECT WegGrund.WegGrundBez$LAN$ AS Grund, EinzHist.Barcode, [Status].StatusBez AS [Status], Week.Woche AS ErstWoche, EinzHist.ErstDatum, EinzHist.PatchDatum, EinzHist.Ausdienst, Artikel.ArtikelNr, Artikel.ArtikelNr2, Artikel.ArtikelBez$LAN$, Artikel.EKPreis, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Produktion.Bez AS Produktionsstandort, Kunden.KdNr, Kunden.SuchCode AS Kunde, Kundenservice.Bez AS [Kundenservice-Standort], KdGf.KurzBez AS SGF, EinzHist.AusdRestw AS RestWert
FROM EinzHist
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN [Status] ON EinzHist.[Status] = [Status].[Status] AND [Status].Tabelle = ''EINZHIST''
JOIN Artikel ON EinzHist.ArtikelID = Artikel.ID
JOIN WegGrund ON EinzHist.WegGrundID = WegGrund.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND Bereich.ID = StandBer.BereichID
JOIN Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID
JOIN Standort AS Kundenservice ON Kunden.StandortID = Kundenservice.ID
JOIN Week ON DATEADD(day, EinzHist.AnzTageImLager, EinzHist.ErstDatum) BETWEEN Week.VonDat AND Week.BisDat
  AND Kunden.ID IN ($ID$)
  AND EinzHist.[Status] = ''Y''
  AND WegGrund.ID IN ($3$)
  AND EinzHist.AusDienstDat BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Bereich.ID IN ($5$)
ORDER BY Kdnr, VsaNr, ArtikelNr;'
WHERE ID = 612;

GO

UPDATE ChartSQL SET ChartSQL = N'DECLARE @KdNrs NVARCHAR(1000) = $6$

[DROPTABLE, #KdNrs]  
SELECT value KdNr  
INTO #KdNrs
FROM STRING_SPLIT(@KdNrs, '','')  
WHERE RTRIM(value) <> '''';

[DROPTABLE, #Schrottteile]
CREATE TABLE #Schrottteile(
 EinzHistID INTEGER default -1,
 EinzTeilID INTEGER default -1,
 VsaId INTEGER default -1,
 BereichId INTEGER default -1,
 HoldingId INTEGER default -1,
 StandortId INTEGER default -1,
 RestwertInfo money,
 AusdienstGrund NVARCHAR(1),
 WeggrundID INTEGER default -1,
 VerschrottungDat Date,
 AusdienstGrundBez NVarChar(100),
 RechPoID INTEGER default -1,
 SchrottUserID INTEGER default -1);
-- select * from #Schrottteile;

-----------------------------------------
-- Schrottteile aus TEILE-Tabelle
-----------------------------------------
IF EXISTS (SELECT TOP 1 ID FROM EinzHist WHERE 1 in ($7$)) BEGIN
-- Schrottteile anhand des Verschrottungs-Scans identifizieren
 [DROPTABLE, #Schrottteile_ALLE]
 select scans.EinzHistID, EinzHist.RestwertInfo, EinzHist.AusdienstGrund, 
 EinzHist.WegGrundID, cast(scans.[datetime] as date) VerschrottungDat,
 EinzHist.RechPoID, Scans.AnlageUserID_ SchrottUserID 
 into #Schrottteile_ALLE
 from scans, EinzHist,
 (select Scans.EinzHistID, Max(Scans.ID) MaxScansID
  from Scans
  where Scans.ActionsID = 7 -- Verschrotten
  group by Scans.EinzHistID) Daten
 where daten.EinzHistID = EinzHist.id
 and daten.MaxScansID = scans.id
 and EinzHist.AltenheimModus = 0
 and scans.EinzHistID = EinzHist.id
 and EinzHist.status = ''Y'';
 -- weitere Schrottteile nur anhand des Schrott-Status identifizieren
 insert into #Schrottteile_ALLE (EinzHistID, RestwertInfo, AusdienstGrund, 
 WegGrundID, VerschrottungDat, RechPoID, SchrottUserID)
 select EinzHist.id EinzHistID, EinzHist.RestwertInfo, EinzHist.AusdienstGrund, 
 EinzHist.WegGrundID, EinzHist.ausdienstdat, EinzHist.RechPoID, -1 
 from EinzHist 
 where EinzHist.AltenheimModus = 0
 and EinzHist.status = ''Y''
 and EinzHist.ID not in (select EinzHistID from #Schrottteile_ALLE);

 -- Eingrenzung der Schrottteile auf die durch die Parameter vorgegebenen Einstellungen
 insert into #Schrottteile (EinzHistID, EinzTeilID, VsaID, BereichID, HoldingId, StandortID, 
 RestwertInfo, AusdienstGrund, WegGrundID, VerschrottungDat, RechPoID, SchrottUserID)
 select x.EinzHistID, -1, EinzHist.VsaID, KdBer.BereichID, Kunden.HoldingID, Kunden.StandortID, 
 x.RestwertInfo, x.AusdienstGrund, x.WegGrundID, x.VerschrottungDat, x.RechPoID, x.SchrottUserID
 from #Schrottteile_ALLE x, EinzHist, Vsa, Kunden, KdArti, KdBer, StandBer
 where x.VerschrottungDat BETWEEN $1$ AND $2$
 and x.EinzHistID = EinzHist.ID
 and EinzHist.VsaID = Vsa.ID
 and Vsa.KundenID = Kunden.ID
 and EinzHist.KdArtiID = KdArti.ID
 and KdArti.KdBerID = KdBer.ID
 and Vsa.StandKonID = StandBer.StandKonID
 and StandBer.BereichID = KdBer.BereichID
 and Kunden.StandortID IN ($3$)
 and Kunden.HoldingID IN ($5$)
 and StandBer.ExpeditionID IN ($4$)
 and (((SELECT COUNT(*) FROM #KdNrs) = 0) OR (Kunden.KdNr in (SELECT KdNr FROM #KdNrs)));
 
 update #Schrottteile set AusdienstGrundBez = rtrim(Einsatz.EinsatzBez$Lan$) + '' ('' + Einsatz.EinsatzGrund + '')'' 
 from #Schrottteile Schrottteile, Einsatz
 where Schrottteile.AusdienstGrund collate Latin1_General_CI_AS = Einsatz.EinsatzGrund;
END; 

-----------------------------------------
-- Schrottteile aus OPTEILE-Tabelle
-----------------------------------------
IF EXISTS (SELECT TOP 1 ID FROM EinzTeil WHERE 2 in ($7$)) BEGIN
 [DROPTABLE, #SchrottOpteile_ALLE]
 select Scans.EinzTeilID, EinzTeil.RestwertInfo, ''?'' AusdienstGrund, 
 EinzTeil.WegGrundID, cast(Scans.[DateTime] as date) VerschrottungDat,
 EinzTeil.RechPoID, EinzTeil.AnlageUserID_ SchrottUserID
 into #SchrottOpteile_ALLE
 from Scans, EinzTeil,
 (select Scans.EinzTeilID, Max(Scans.ID) MaxOpScansID
  from Scans
  where Scans.ActionsID = 108 -- OP Schrott
  group by Scans.EinzTeilID) Daten
 where daten.EinzTeilID = EinzTeil.id
 and daten.MaxOpScansID = Scans.id
 and Scans.EinzTeilID = EinzTeil.id
 and EinzTeil.status = ''Z'';
 -- weitere Schrottteile nur anhand des Schrott-Status identifizieren
 insert into #SchrottOpteile_ALLE (EinzTeilID, RestwertInfo, AusdienstGrund, 
 WegGrundID, VerschrottungDat, x.RechPoID, x.SchrottUserID)
 select EinzTeil.id, EinzTeil.RestwertInfo, ''?'', EinzTeil.WegGrundID, 
 EinzTeil.WegDatum, EinzTeil.RechPoID,  -1
 from EinzTeil 
 where EinzTeil.status = ''Z''
 and EinzTeil.ID not in (select EinzTeilID from #SchrottOpteile_ALLE);
 
 -- Eingrenzung der Schrottteile auf die durch die Parameter vorgegebenen Einstellungen
 insert into #Schrottteile (EinzHistID, EinzTeilID, VsaID, BereichID, HoldingId, StandortID, 
 RestwertInfo, AusdienstGrund, WegGrundID, VerschrottungDat, RechPoID, SchrottUserID)
 select -1, x.EinzTeilID, EinzTeil.VsaID, Artikel.BereichID, Kunden.HoldingID, Kunden.StandortID, 
 x.RestwertInfo, x.AusdienstGrund, x.WegGrundID, x.VerschrottungDat, x.RechPoID, x.SchrottUserID
 from #SchrottOpteile_ALLE x, EinzTeil, Vsa, Kunden, Artikel, StandBer
 where x.VerschrottungDat BETWEEN $1$ AND $2$
 and x.EinzTeilID = EinzTeil.ID
 and EinzTeil.VsaID = Vsa.ID
 and Vsa.KundenID = Kunden.ID
 and EinzTeil.ArtikelID = Artikel.ID
 and Vsa.StandKonID = StandBer.StandKonID
 and StandBer.BereichID = Artikel.BereichID

 and Kunden.StandortID IN ($3$)
 and Kunden.HoldingID IN ($5$)
 and StandBer.ExpeditionID IN ($4$)
 and (((SELECT COUNT(*) FROM #KdNrs) = 0) OR (Kunden.KdNr in (SELECT KdNr FROM #KdNrs)));
 
 update #Schrottteile set AusdienstGrundBez = ''???'' where ausdienstgrund = ''?'';
END;

select * from #Schrottteile;'
WHERE ID = 860;

GO

UPDATE ChartSQL SET ChartSQL = N'select 
-- Parameter
dbo.AdvCurrentDate() Datum,
(select chartkobez from chartko where id = 1100056) Name,
$1$ ''Schrottdatum von'', 
$2$ ''Schrottdatum bis'',
$6$ ''angegebene KdNrs'', 
STUFF(
(select distinct '', '' + (Standort.Suchcode)
 from Standort
 where Standort.ID IN ($3$)
 order by '', '' + (Standort.Suchcode)
 FOR XML PATH(''''),TYPE).value(''.'',''VARCHAR(MAX)''), 1, 1,'''') ''gewählte Hauptstandorte'',
STUFF(
(select distinct '', '' + (Standort.Suchcode)
 from Standort
 where Standort.ID IN ($4$)
 order by '', '' + (Standort.Suchcode)
 FOR XML PATH(''''),TYPE).value(''.'',''VARCHAR(MAX)''), 1, 1,'''') ''gewählte Expedtions-Standorte'',
STUFF(
(select distinct '', '' + (Holding.Holding)
 from Holding
 where Holding.ID IN ($5$)
 order by '', '' + (Holding.Holding)
 FOR XML PATH(''''),TYPE).value(''.'',''VARCHAR(MAX)''), 1, 1,'''') ''gewählte Holdings'',
Daten.*
from
(select ''TEILE'' Art, EinzHist.Barcode Code, (rtrim(Standort.Suchcode) + ''('' + rtrim(Standort.Bez) + '')'') Hauptstandort, 
 (rtrim(Holding.Holding) + '' ('' + rtrim(Holding.Bez) + '')'') Holding, Produktion.Bez Waescher, 
 Expedition.Bez "Expeditions-Standort", Schrottteile.AusdienstGrundBez, Schrottteile.RestwertInfo Restwert, 
 EinzHist.ErstDatum ''Einsatzdatum'', EinzHist.RuecklaufG ''Anzahl Wäschen'', EinzHist.AlterInfo ''Alter in Wochen'',
 WegGrund.WegGrundBez$Lan$ SchrottGrund, Schrottteile.VerschrottungDat "Schrott-Datum",
 Kunden.KdNr, Kunden.Name1 Kunde, Vsa.VsaNr, Vsa.Bez Vsa, Traeger.Traeger, Traeger.Nachname, 
 Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse,
 Bereich.BereichBez$LAN$ Bereich, ArtGru.ArtGruBez$LAN$ Artikelgruppe,
 Mitarbei.Name VerschrottUser,iif(RechPo.RechKoID > 0, RechKo.RechNr, 0) Rechnung 
 --, Teile.EKPreis as "EK Preis Teil (bei Kauf)"
 --, Teile.EkGrundakt as "EK Preis Teil aktuell"
 , Bestand.Gleitpreis
 --, Artikel.EkPreis as "EK Preis Artikel"
 , ArtGroe.EkPreis as "EK Preis Größe"
 from #Schrottteile Schrottteile, EinzHist, Traeger, ArtGroe, Holding, ArtGru, 
 Artikel, Vsa, Kunden, WegGrund, Standort, Standort Produktion, Standber,
 Bereich, Standort Expedition, RechPo, RechKo, Mitarbei , Lagerart, Bestand
 where Schrottteile.EinzHistID = EinzHist.ID
 and EinzHist.TraegerID = Traeger.ID
 and Traeger.VsaID = Vsa.ID
 and Vsa.KundenID = Kunden.ID
 and EinzHist.ArtGroeID = ArtGroe.ID
 and ArtGroe.ArtikelID = Artikel.ID
 and Artgroe.ID = Bestand.Artgroeid 
 and Bestand.Lagerartid = Lagerart.id 
 and Lagerart.Id = $9$
 and Schrottteile.WegGrundID = WegGrund.ID
 and Kunden.StandortID = Standort.ID
 and Kunden.HoldingID = Holding.ID
 and Standber.StandKonID = Vsa.StandkonID
 and Standber.BereichID = Schrottteile.BereichID
 and Standber.ProduktionID = Produktion.ID
 and Standber.ExpeditionID = Expedition.ID
 and Schrottteile.BereichID = Bereich.ID
 and Artikel.ArtGruID = ArtGru.ID
 and Schrottteile.EinzHistID > 0
 and Schrottteile.RechPoID = RechPo.ID
 and RechPo.RechKoID = RechKo.ID
 and Schrottteile.SchrottUserID = Mitarbei.ID
 union all
 select ''OPTEILE'' Art, EinzTeil.Code, (rtrim(Standort.Suchcode) + '' ('' + rtrim(Standort.Bez) + '')'') Hauptstandort, 
 (rtrim(Holding.Holding) + '' ('' + rtrim(Holding.Bez) + '')'') Holding, Produktion.Bez Waescher, 
 Expedition.Bez "Expeditions-Standort", Schrottteile.AusdienstGrundBez, Schrottteile.RestwertInfo Restwert, 
 dbo.FirstDoW(EinzTeil.Erstwoche) ''Einsatzdatum'', EinzTeil.AnzWasch ''Anzahl Wäschen'', 
 EinzTeil.AlterInfo ''Alter in Wochen'', WegGrund.WegGrundBez$Lan$ SchrottGrund, 
 Schrottteile.VerschrottungDat "Schrott-Datum", Kunden.KdNr, Kunden.Name1 Kunde, 
 Vsa.VsaNr, Vsa.Bez Vsa, ''-'' Traeger, '''' Nachname, '''' Vorname, Artikel.ArtikelNr, 
 Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ''?'' Groesse, Bereich.BereichBez$LAN$ Bereich, 
 ArtGru.ArtGruBez$LAN$ Artikelgruppe,
 Mitarbei.Name VerschrottUser,iif(RechPo.RechKoID > 0, RechKo.RechNr, 0) Rechnung 
  --, OPTeile.EKPreis as "EK Preis Teil (bei Kauf)"
  --, OPTeile.EkGrundakt as "EK Preis Teil aktuell"
  , null as Gleitpreis
  --, Artikel.EkPreis as "EK Preis Artikel"
  , null as "EK Preis Größe"
 from #Schrottteile Schrottteile, EinzTeil, Holding, ArtGru, 
 Artikel, Vsa, Kunden, WegGrund, Standort, Standort Produktion, Standber,
 Bereich, Standort Expedition, RechPo, RechKo, Mitarbei 
 where Schrottteile.EinzTeilID = EinzTeil.ID
 and EinzTeil.VsaID = Vsa.ID
 and Vsa.KundenID = Kunden.ID
 and EinzTeil.ArtikelID = Artikel.ID
 and Schrottteile.WegGrundID = WegGrund.ID
 and Kunden.StandortID = Standort.ID
 and Kunden.HoldingID = Holding.ID
 and Standber.StandKonID = Vsa.StandkonID
 and Standber.BereichID = Schrottteile.BereichID
 and Standber.ProduktionID = Produktion.ID
 and Standber.ExpeditionID = Expedition.ID
 and Schrottteile.BereichID = Bereich.ID
 and Artikel.ArtGruID = ArtGru.ID
 and Schrottteile.EinzTeilID > 0
 and Schrottteile.RechPoID = RechPo.ID
 and RechPo.RechKoID = RechKo.ID
 and Schrottteile.SchrottUserID = Mitarbei.ID
 ) Daten
order by Art, KdNr, ArtikelNr, "Schrott-Datum" DESC;'
WHERE ID = 740;

GO

UPDATE ChartSQL SET ChartSQL = N'SELECT EinzHist.Barcode, [Status].StatusBez$LAN$ AS [Status], Einsatz.EinsatzBez$LAN$ AS Einsatzgrund, kunden.KdNr, kunden.suchcode AS Kunde, kunden.name1 As Kundenname1, vsa.VsaNr, vsa.SuchCode AS VSA, vsa.Bez AS VsaBez, traeger.Vorname, traeger.Nachname, traeger.Traeger, traeger.PersNr, artikel.ArtikelNr, kdarti.Variante, artikel.ArtikelBez$LAN$ AS ArtikelBez, artgroe.Groesse, EinzHist.Eingang1, EinzHist.Ausgang1, Kunden.ID AS KundenID, EinzHist.VsaID, EinzHist.TraegerID, EinzHist.ID AS EinzHistID, iif(EntnKo.ID = -1, null, EntnKo.ID) AS EntnKoID, iif(EntnKo.ID = -1, null, StatusEntnKo.StatusBez) AS EntnKoStatus, LagerArt.LagerArtBez$LAN$ AS LagerArtBez, BKO.BestNr, LIEFABPO.Termin as [Bestätigt zu], LIEFABPO.Version as [AB-Version]
FROM EinzHist
LEFT OUTER JOIN TEILEBPO ON TEILEBPO.EinzHistID = EinzHist.id
LEFT OUTER JOIN BPO on BPO.id = TEILEBPO.BPoID
LEFT OUTER JOIN BKO on BKO.id = BPO.BKoID
LEFT OUTER JOIN LIEFABPO on LIEFABPO.BPoID = BPO.id
LEFT OUTER JOIN Einsatz ON Einsatz.Einsatzgrund = EinzHist.Einsatzgrund
LEFT OUTER JOIN [Status] ON [Status].[Status] = EinzHist.[Status] AND [Status].Tabelle = ''EINZHIST'', traeger, kdarti, vsa, artikel, artgroe, kunden, Auftrag, EntnPo, LagerArt, EntnKo
LEFT OUTER JOIN [Status] AS StatusEntnKo ON StatusEntnKo.Tabelle = ''ENTNKO'' AND StatusEntnKo.[Status] = EntnKo.[Status]
WHERE traeger.id = EinzHist.traegerid
 AND artgroe.id = EinzHist.artgroeid
 AND artikel.id = artgroe.artikelid
 AND vsa.id = EinzHist.vsaid
 AND kunden.id = vsa.kundenid
 AND (Auftrag.ID = EinzHist.StartAuftragID OR Auftrag.ID = EinzHist.StopAuftragID)
 AND EntnPo.ID = EinzHist.EntnPoID
 AND EntnKo.ID = EntnPo.EntnKoID
 AND LagerArt.ID = EinzHist.LagerArtID
 AND KdArti.ID = EinzHist.KdArtiID
 AND Auftrag.ID = (Select ID From Auftrag where Auftrag.Auftragsnr = $0$)
 AND (EinzHist.StartAuftragID = (Select ID From Auftrag where Auftrag.Auftragsnr = $0$) OR EinzHist.StopAuftragID = (Select ID From Auftrag where Auftrag.Auftragsnr = $0$))
 AND (artikel.id = $1$ OR $1$=-1) 
 AND EinzHist.IsCurrEinzHist = 1
ORDER BY Einsatz.EinsatzBez, Status, Barcode'
WHERE ID = 1581;

GO

UPDATE ChartSQL SET ChartSQL = N'DECLARE @von date = $1$;
DECLARE @bis date = $2$;

DECLARE @Standort TABLE (
  StandortID int,
  OPStandortID int
);

IF OBJECT_ID(N''tempdb..#EinzTeilProd'') IS NULL
BEGIN
  CREATE TABLE #EinzTeilProd (
    EinzTeilID int PRIMARY KEY,
    ArtikelID int NOT NULL,
    LastScanID int DEFAULT -1
  );
END ELSE BEGIN
  TRUNCATE TABLE #EinzTeilProd;
END;

INSERT INTO @Standort (StandortID)
SELECT Standort.ID
FROM Standort
WHERE Standort.ID IN ($3$);

UPDATE @Standort SET OPStandortID = 
  CASE StandortID
    WHEN 2 THEN 2
    WHEN 4 THEN 2
    WHEN 4547 THEN 2
    WHEN 5005 THEN 2
    WHEN 5007 THEN 2
    WHEN 5010 THEN 2
    WHEN 5011 THEN 2
    WHEN 5001 THEN 5001
    WHEN 5000 THEN 5001
    WHEN 5212 THEN 5001
    WHEN 5213 THEN 5001
    WHEN 5214 THEN 5001
    WHEN 5133 THEN 5133
    ELSE -1
  END;

DECLARE @OPStats TABLE (
  StandortID int DEFAULT NULL,
  ArtikelID int DEFAULT NULL,
  Liefermenge int DEFAULT 0,
  Schrottmenge int DEFAULT 0,
  NeuMenge int DEFAULT 0,
  InProd int DEFAULT 0
);

INSERT INTO @OPStats (StandortID, ArtikelID, Liefermenge)
SELECT s.OPStandortID AS StandortID, Artikel.ID AS ArtikelID, SUM(CAST(LsPo.Menge AS int) * (OPSets.Menge / OPSetArtikel.Packmenge)) AS Liefermenge
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN OPSets ON OPSets.ArtikelID = KdArti.ArtikelID
JOIN Artikel ON OPSets.Artikel1ID = Artikel.ID
JOIN @Standort s ON LsPo.ProduktionID = s.StandortID
JOIN Artikel AS OPSetArtikel ON OPSets.ArtikelID = OPSetArtikel.ID
WHERE LsKo.Datum BETWEEN @von AND @bis
  AND NOT EXISTS (
    SELECT SiS.*
    FROM OPSets AS SiS
    WHERE Sis.ArtikelID = OPSets.Artikel1ID
  )
GROUP BY s.OPStandortID, Artikel.ID;

MERGE INTO @OPStats AS OPStats
USING (
  SELECT s.OPStandortID AS StandortID, Artikel.ID AS ArtikelID, SUM(CAST(LsPo.Menge AS int) * (OPSets.Menge / OPSetArtikel.Packmenge) * (SiS.Menge / SiSArtikel.Packmenge)) AS Liefermenge
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
  JOIN OPSets ON OPSets.ArtikelID = KdArti.ArtikelID
  JOIN OPSets AS SiS ON OPSets.Artikel1ID = SiS.ArtikelID
  JOIN Artikel ON SiS.Artikel1ID = Artikel.ID
  JOIN @Standort s ON LsPo.ProduktionID = s.StandortID
  JOIN Artikel AS OPSetArtikel ON OPSets.ArtikelID = OPSetArtikel.ID
  JOIN Artikel AS SiSArtikel ON SiS.ArtikelID = SiSArtikel.ID
  WHERE LsKo.Datum BETWEEN @von AND @bis
  GROUP BY s.OPStandortID, Artikel.ID
) AS SiSLiefermenge (StandortID, ArtikelID, Liefermenge)
ON OPStats.ArtikelID = SiSLiefermenge.ArtikelID AND OPStats.StandortID = SiSLiefermenge.StandortID
WHEN MATCHED THEN
  UPDATE SET OPStats.Liefermenge = OPStats.Liefermenge + SiSLiefermenge.Liefermenge
WHEN NOT MATCHED THEN
  INSERT (StandortID, ArtikelID, Liefermenge) VALUES (SiSLiefermenge.StandortID, SiSLiefermenge.ArtikelID, SiSLiefermenge.Liefermenge);

MERGE INTO @OPStats AS OPStats
USING (
  SELECT EinzTeil.ArtikelID, s.OPStandortID AS StandortID, COUNT(EinzTeil.ID) AS Schrottmenge
  FROM EinzTeil
  JOIN Vsa ON EinzTeil.VsaID = Vsa.ID
  JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
  JOIN StandBer ON StandBer.StandKonID = Vsa.StandKonID AND StandBer.BereichID = Artikel.BereichID
  JOIN @Standort s ON StandBer.ProduktionID = s.StandortID
  WHERE EinzTeil.WegDatum BETWEEN @von AND @bis
    AND EinzTeil.Status = N''Z''
  GROUP BY EinzTeil.ArtikelID, s.OPStandortID
) AS OPSchrott (ArtikelID, StandortID, Schrottmenge)
ON OPStats.ArtikelID = OPSchrott.ArtikelID AND OPStats.StandortID = OPSchrott.StandortID
WHEN MATCHED THEN
  UPDATE SET OPStats.Schrottmenge = OPSchrott.Schrottmenge
WHEN NOT MATCHED THEN
  INSERT (StandortID, ArtikelID, Schrottmenge) VALUES (OPSchrott.StandortID, OPSchrott.ArtikelID, OPSchrott.Schrottmenge);

MERGE INTO @OPStats AS OPStats
USING (
  SELECT EinzTeil.ArtikelID, s.OPStandortID AS StandortID, COUNT(DISTINCT EinzTeil.ID) AS NeuMenge
  FROM Scans
  JOIN EinzTeil ON Scans.EinzTeilID = EinzTeil.ID
  JOIN ArbPlatz ON Scans.ArbPlatzID = ArbPlatz.ID
  JOIN @Standort s ON ArbPlatz.StandortID = s.StandortID
  WHERE Scans.ActionsID = 115 --OP erstellt
    AND Scans.[DateTime] BETWEEN @von AND DATEADD(day, 1, @bis)
    AND Scans.EinzHistID = -1
  GROUP BY EinzTeil.ArtikelID, s.OPStandortID
) AS OPNeu (ArtikelID, StandortID, NeuMenge)
ON OPStats.ArtikelID = OPNeu.ArtikelID AND OPStats.StandortID = OPNeu.StandortID
WHEN MATCHED THEN
  UPDATE SET OPStats.NeuMenge = OPNeu.NeuMenge
WHEN NOT MATCHED THEN
  INSERT (StandortID, ArtikelID, NeuMenge) VALUES (OPNeu.StandortID, OPNeu.ArtikelID, OPNeu.NeuMenge);

INSERT INTO #EinzTeilProd (EinzTeilID, ArtikelID)
SELECT EinzTeil.ID, EinzTeil.ArtikelID
FROM EinzTeil
WHERE ISNULL(EinzTeil.LastScanTime, N''1980-01-01 00:00:00'') > DATEADD(year, -1, GETDATE())
    AND EinzTeil.LastActionsID NOT IN (102, 107, 108);

UPDATE #EinzTeilProd SET LastScanID = LastScan.LastScanID
FROM (
  SELECT EinzTeilProd.EinzTeilID, MAX(Scans.ID) AS LastScanID
  FROM #EinzTeilProd AS EinzTeilProd
  JOIN Scans ON Scans.EinzTeilID = EinzTeilProd.EinzTeilID
  GROUP BY EinzTeilProd.EinzTeilID
) LastScan
WHERE LastScan.EinzTeilID = #EinzTeilProd.EinzTeilID;

MERGE INTO @OPStats AS OPStats
USING (
  SELECT EinzTeilProd.ArtikelID, s.OPStandortID AS StandortID, COUNT(DISTINCT EinzTeilProd.EinzTeilID) AS NeuMenge
  FROM #EinzTeilProd AS EinzTeilProd
  JOIN Scans ON EinzTeilProd.LastScanID = Scans.ID
  JOIN ArbPlatz ON Scans.ArbPlatzID = ArbPlatz.ID
  JOIN @Standort s ON ArbPlatz.StandortID = s.StandortID
  GROUP BY EinzTeilProd.ArtikelID, s.OPStandortID
) AS OPInProd (ArtikelID, StandortID, InProdMenge)
ON OPStats.ArtikelID = OPInProd.ArtikelID AND OPStats.StandortID = OPInProd.StandortID
WHEN MATCHED THEN
  UPDATE SET OPStats.InProd = OPInProd.InProdMenge
WHEN NOT MATCHED THEN
  INSERT (StandortID, ArtikelID, InProd) VALUES (OPInProd.StandortID, OPInProd.ArtikelID, OPInProd.InProdMenge);

WITH Lagerbestand AS (
  SELECT StandortID = 
    CASE Lagerart.LagerID
      WHEN 2 THEN 2
      WHEN 4 THEN 2
      WHEN 4547 THEN 2
      WHEN 5005 THEN 2
      WHEN 5007 THEN 2
      WHEN 5010 THEN 2
      WHEN 5011 THEN 2
      WHEN 5001 THEN 5001
      WHEN 5000 THEN 5001
      WHEN 5212 THEN 5001
      WHEN 5213 THEN 5001
      WHEN 5214 THEN 5001
      WHEN 5133 THEN 5133
      ELSE -1
    END,
  ArtGroe.ArtikelID,
  SUM(Bestand.Bestand) AS Bestand
  FROM Bestand
  JOIN Lagerart ON Bestand.LagerartID = Lagerart.ID
  JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
  WHERE Lagerart.Neuwertig = 1
  GROUP BY
    CASE Lagerart.LagerID
      WHEN 2 THEN 2
      WHEN 4 THEN 2
      WHEN 4547 THEN 2
      WHEN 5005 THEN 2
      WHEN 5007 THEN 2
      WHEN 5010 THEN 2
      WHEN 5011 THEN 2
      WHEN 5001 THEN 5001
      WHEN 5000 THEN 5001
      WHEN 5212 THEN 5001
      WHEN 5213 THEN 5001
      WHEN 5214 THEN 5001
      WHEN 5133 THEN 5133
      ELSE -1
    END,
    ArtGroe.ArtikelID
),
BestelltOffen AS (
  SELECT StandortID =
    CASE BKo.LagerID
      WHEN 2 THEN 2
      WHEN 4 THEN 2
      WHEN 4547 THEN 2
      WHEN 5005 THEN 2
      WHEN 5007 THEN 2
      WHEN 5010 THEN 2
      WHEN 5011 THEN 2
      WHEN 5001 THEN 5001
      WHEN 5000 THEN 5001
      WHEN 5212 THEN 5001
      WHEN 5213 THEN 5001
      WHEN 5214 THEN 5001
      WHEN 5133 THEN 5133
      ELSE -1
    END,
    ArtGroe.ArtikelID,
    SUM(BPo.Menge - BPo.LiefMenge) AS MengeOffen
  FROM BPo
  JOIN BKo ON BPo.BKoID = BKo.ID
  JOIN ArtGroe ON BPo.ArtGroeID = ArtGroe.ID
  WHERE BKo.Status BETWEEN N''F'' AND N''K''
    AND BPo.Menge > BPo.LiefMenge
  GROUP BY
    CASE BKo.LagerID
      WHEN 2 THEN 2
      WHEN 4 THEN 2
      WHEN 4547 THEN 2
      WHEN 5005 THEN 2
      WHEN 5007 THEN 2
      WHEN 5010 THEN 2
      WHEN 5011 THEN 2
      WHEN 5001 THEN 5001
      WHEN 5000 THEN 5001
      WHEN 5212 THEN 5001
      WHEN 5213 THEN 5001
      WHEN 5214 THEN 5001
      WHEN 5133 THEN 5133
      ELSE -1
    END,
    ArtGroe.ArtikelID
)
SELECT Standort.Bez AS Produktionsstandort,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  ArtGru.ArtGruBez$LAN$ AS Artikelgruppe,
  OPStats.Liefermenge AS [Liefermenge im Zeitraum],
  OPStats.Schrottmenge AS [Teile verschrottet im Zeitraum],
  ROUND(IIF(OPStats.Liefermenge = 0, 0, CAST(OPStats.Schrottmenge AS float) * 100 / CAST(OPStats.Liefermenge AS float)), 2) AS [Teile verschrottet im Zeitraum prozentual],
  OPStats.NeuMenge AS [Neuteile im Zeitraum],
  ROUND(IIF(OPStats.Liefermenge = 0, 0, CAST(OPStats.NeuMenge AS float) * 100 / CAST(OPStats.Liefermenge AS float)), 2) AS [Neuteile im Zeitraum prozentual],
  OPStats.InProd AS [aktuell in Produktion],
  Lagerbestand.Bestand AS [Neuware im Lager],
  ISNULL(BestelltOffen.MengeOffen, 0) AS [noch offene bestellte Menge]
FROM @OPStats AS OPStats
JOIN Standort ON OPStats.StandortID = Standort.ID
JOIN Artikel ON OPStats.ArtikelID = Artikel.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN Lagerbestand ON Lagerbestand.ArtikelID = Artikel.ID AND Lagerbestand.StandortID = OPStats.StandortID
LEFT JOIN BestelltOffen ON BestelltOffen.ArtikelID = Artikel.ID AND BestelltOffen.StandortID = OPStats.StandortID;'
WHERE ID = 850;

GO

UPDATE ChartSQL SET ChartSQL = N'With Scan as (select EinzHistID, AnlageUserID_, ActionsID from SCANS where
ActionsID in (4,7))
SELECT Kdgf.Kurzbez,Kunden.KdNr, Kunden.SuchCode AS Kunde,VSA.SuchCode as VsaNr, Vsa.Bez AS Vsa, EinzHist.Barcode, [Status].StatusBez$LAN$ AS Teilestatus, Artikel.ArtikelNr, Artikel.ArtikelNr2,Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, Artikel.EkPreis
, EinzHist.Ausdienst, EinzHist.AusdienstDat
, CONVERT(char(60), NULL) AS AusdienstGrund, WegGrund.WeggrundBez$LAN$ AS Grund,''Tausch'' as Art, EinzHist.RestwertInfo AS Restwert
, Week.Woche AS Erstwoche
, EinzHist.ErstDatum
, EinzHist.PatchDatum
, EinzHist.IndienstDat
, EinzHist.Kostenlos
, EinzHist.RuecklaufG as [Anzahl Wäschen]
, EinzHist.RuecklaufK as [Anzahl WÄschen K]
, MITARBEI.Name
, Produktion.Bez as Produktionbsstandort
, Kundenservice.Bez as [Kundenservice-Standort]
, case when EinzHist.rechpoid = -1 then 0 else 1 end Berechnet
FROM EinzHist
join Vsa on EinzHist.VsaID = Vsa.ID
join Kunden on Vsa.KundenID = Kunden.ID -- AND Kunden.ID = $ID$
join KDGF on KDGF.ID = KUNDEN.KdGFID and kdgf.id in ($5$)
join Artikel on EinzHist.ArtikelID = Artikel.ID
join ArtGroe on EinzHist.ArtGroeID = ArtGroe.ID
join [Status] on EinzHist.[Status] = [Status].[Status] and [Status].Tabelle = ''EINZHIST'' AND EinzHist.Status = ''S''
join WegGrund on EinzHist.WegGrundID = WegGrund.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND Bereich.ID = StandBer.BereichID
JOIN Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID and Produktion.ID in ($3$)
JOIN Standort AS Kundenservice ON Kunden.StandortID = Kundenservice.ID and Kundenservice.ID in ($4$)
left join Scan on Scan.EinzHistID = EinzHist.ID and Scan.ActionsID = 4
join MITARBEI on Scan.AnlageUserID_ = MITARBEI.id
JOIN Week ON DATEADD(day, EinzHist.AnzTageImLager, EinzHist.ErstDatum) BETWEEN Week.VonDat AND Week.BisDat
WHERE EinzHist.AltenheimModus = 0
  AND EinzHist.IsCurrEinzHist = 1
  
UNION ALL

SELECT Kdgf.Kurzbez,Kunden.KdNr, Kunden.SuchCode AS Kunde,VSA.SuchCode as VsaNr,  Vsa.Bez AS Vsa, EinzHist.Barcode, [Status].StatusBez$LAN$ AS Teilestatus, Artikel.ArtikelNr, Artikel.ArtikelNr2, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, Artikel.EkPreis
, EinzHist.Ausdienst, EinzHist.AusdienstDat
, Einsatz.EinsatzBez$LAN$ AS AusdienstGrund, WegGrund.WegGrundBez$LAN$ AS Grund, ''Tausch'' as Art, EinzHist.AusdRestw AS Restwert
, Week.Woche AS Erstwoche
, EinzHist.ErstDatum
, EinzHist.PatchDatum
, EinzHist.IndienstDat
, EinzHist.Kostenlos
, EinzHist.RuecklaufG as [Anzahl Wäschen]
, EinzHist.RuecklaufK as [Anzahl WÄschen K]
, MITARBEI.Name
, Produktion.Bez as Produktionbsstandort
, Kundenservice.Bez as [Kundenservice-Standort]
, case when EinzHist.rechpoid = -1 then 0 else 1 end Berechnet
FROM EinzHist
join Vsa on EinzHist.VsaID = Vsa.ID
join Kunden on Vsa.KundenID = Kunden.ID --and Kunden.ID = $ID$
join KDGF on KDGF.ID = KUNDEN.KdGFID and kdgf.id in ($5$)
join Einsatz on EinzHist.AusdienstGrund = Einsatz.EinsatzGrund
join Artikel on EinzHist.ArtikelID = Artikel.ID
join ArtGroe on EinzHist.ArtGroeID = ArtGroe.ID
join [Status] on EinzHist.Status = [Status].[Status] AND [Status].Tabelle = ''EINZHIST'' AND EinzHist.Status > ''S''
join WegGrund on EinzHist.WegGrundID = WegGrund.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND Bereich.ID = StandBer.BereichID
JOIN Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID and Produktion.ID in ($3$)
JOIN Standort AS Kundenservice ON Kunden.StandortID = Kundenservice.ID and Kundenservice.ID in ($4$)
left join Scan on Scan.EinzHistID = EinzHist.ID and Scan.ActionsID = 4
join Mitarbei on Scan.AnlageUserID_ = MITARBEI.id
JOIN Week ON DATEADD(day, EinzHist.AnzTageImLager, EinzHist.ErstDatum) BETWEEN Week.VonDat AND Week.BisDat
WHERE EinzHist.AltenheimModus = 0
  AND EinzHist.AusdienstGrund IN (''A'', ''a'', ''B'', ''b'', ''C'', ''c'')
  AND EinzHist.AusdienstDat BETWEEN $1$ AND $2$

 UNION ALL

 Select Kdgf.Kurzbez,Kunden.KdNr, Kunden.SuchCode AS Kunde,VSA.SuchCode as VsaNr,  Vsa.Bez AS Vsa, EinzHist.Barcode, Status.StatusBez$LAN$ AS Teilestatus, Artikel.ArtikelNr, Artikel.ArtikelNr2, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Artgroe.Groesse, Artikel.EkPreis
 ,EinzHist.Ausdienst, EinzHist.AusdienstDat
 , Einsatz.EinsatzBez$LAN$ AS AusdienstGrund
, WegGrund.WegGrundBez$LAN$ AS Grund,''Schrott'' as Art
, EinzHist.AusdRestw AS Restwert
, Week.Woche AS Erstwoche
, EinzHist.ErstDatum
, EinzHist.PatchDatum
, EinzHist.IndienstDat
, EinzHist.Kostenlos
, EinzHist.RuecklaufG as [Anzahl Wäschen]
, EinzHist.RuecklaufK as [Anzahl WÄschen K]
, MITARBEI.Name
, Produktion.Bez as Produktionbsstandort
, Kundenservice.Bez as [Kundenservice-Standort]
, case when EinzHist.rechpoid = -1 then 0 else 1 end Berechnet
FROM EinzHist
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
join KDGF on KDGF.ID = KUNDEN.KdGFID and kdgf.id in ($5$)
join Einsatz on EinzHist.AusdienstGrund = Einsatz.EinsatzGrund
JOIN [Status] ON EinzHist.[Status] = [Status].[Status] AND [Status].Tabelle = ''EINZHIST'' AND EinzHist.[Status] = ''Y''
JOIN Artikel ON EinzHist.ArtikelID = Artikel.ID
JOIN WegGrund ON EinzHist.WegGrundID = WegGrund.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND Bereich.ID = StandBer.BereichID
JOIN Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID and Produktion.ID in ($3$)
JOIN Standort AS Kundenservice ON Kunden.StandortID = Kundenservice.ID and Kundenservice.ID in ($4$)
left join Scan on Scan.EinzHistID = EinzHist.ID and Scan.ActionsID = 7
join MITARBEI on MITARBEI.ID = Scan.AnlageUserID_
JOIN Week ON DATEADD(day, EinzHist.AnzTageImLager, EinzHist.ErstDatum) BETWEEN Week.VonDat AND Week.BisDat
where EinzHist.AusDienstDat BETWEEN $1$ AND $2$;'
WHERE ID = 1115;

GO

UPDATE ChartSQL SET ChartSQL = N'DECLARE @DateSelection date = $1$;

DECLARE @Barcode varchar(33);
DECLARE @ArtikelNr nchar(15);
DECLARE @Artikelbezeichnung nvarchar(60);
DECLARE @Groesse nchar(10);
DECLARE @TeileID int;
DECLARE @ScanID int;
DECLARE @Eingangsscan datetime;
DECLARE @Abholung date;

DECLARE curTeile CURSOR FOR
SELECT EinzHist.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, EinzHist.ID AS TeileID
FROM EinzHist
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.ID = $2$
  AND EinzHist.IsCurrEinzHist = 1
  AND EXISTS (
    SELECT Scans.*
    FROM Scans
    WHERE Scans.EinzHistID = EinzHist.ID
      AND Scans.Menge <> 0
      AND Scans.[DateTime] > @DateSelection
  );

DROP TABLE IF EXISTS #TeileInOut;

CREATE TABLE #TeileInOut (
  Barcode varchar(33),
  ArtikelNr nchar(15),
  Artikelbezeichnung nvarchar(60),
  Groesse nchar(10),
  Eingangsscan datetime,
  Ausgangsscan datetime,
  Abholung date,
  Lieferung date,
  LsNr int
);

OPEN curTeile;

FETCH NEXT FROM curTeile INTO @Barcode, @ArtikelNr, @Artikelbezeichnung, @Groesse, @TeileID;

WHILE @@FETCH_STATUS = 0
BEGIN
  DECLARE curEingangsscan CURSOR FOR
    SELECT Scans.ID AS ScanID, Scans.[DateTime] AS Eingangsscan, Scans.EinAusDat AS Abholung
    FROM Scans
    WHERE Scans.EinzHistID = @TeileID
      AND Scans.DateTime > = @DateSelection
      AND Scans.Menge = 1
    ORDER BY Scans.ID ASC;

  OPEN curEingangsscan;

  FETCH NEXT FROM curEingangsscan INTO @ScanID, @Eingangsscan, @Abholung;

  WHILE @@FETCH_STATUS = 0
  BEGIN
    INSERT INTO #TeileInOut
    SELECT @Barcode, @ArtikelNr, @Artikelbezeichnung, @Groesse, @Eingangsscan, Scans.[DateTime] AS Ausgangsscan, @Abholung, Scans.EinAusDat AS Lieferung, LsKo.LsNr
    FROM Scans
    JOIN LsPo ON Scans.LsPoID = LsPo.ID
    JOIN LsKo ON LsPo.LsKoID = LsKo.ID
    WHERE Scans.ID = (
      SELECT MIN(Scans.ID)
      FROM Scans
      WHERE Scans.EinzHistID = @TeileID
        AND Scans.Menge = -1
        AND Scans.ID > @ScanID
    );

    FETCH NEXT FROM curEingangsscan INTO @ScanID, @Eingangsscan, @Abholung;
  END;

  CLOSE curEingangsscan;
  DEALLOCATE curEingangsscan;

  FETCH NEXT FROM curTeile INTO @Barcode, @ArtikelNr, @Artikelbezeichnung, @Groesse, @TeileID;
END;

CLOSE curTeile;
DEALLOCATE curTeile;

SELECT * FROM #TeileInOut;'
WHERE ID = 424;

GO

UPDATE ChartSQL SET ChartSQL = N'WITH CTEScans AS (
  SELECT SCANS.ID, Scans.EinzHistID, SCANS.[DateTime], Scans.EinAusDat
  FROM Scans
  join EinzHist on EinzHist.ID = SCANS.EinzHistID
  JOIN TraeArti ON EinzHist.TraeArtiID = TraeArti.ID
  JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
  JOIN Vsa ON Traeger.VsaID = Vsa.ID
  JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN StandBer ON KdBer.BereichID = StandBer.BereichID AND Vsa.StandKonID = StandBer.StandKonID
  JOIN Standort ON StandBer.ProduktionID = Standort.ID and Standort.id in ($3$) 
  WHERE Scans.[DateTime] >= $1$ and Scans.[DateTime] < dateadd(d,1,$2$)
	 and Scans.Menge = 1
)
SELECT Standort.Bez AS Produktionsstandort,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.VsaNr,
  Vsa.SuchCode AS VsaStichwort,
  Vsa.Bez AS VsaBezeichnung,
  Traeger.Traeger AS TraegerNr,
  Traeger.Vorname,
  Traeger.Nachname,
  Traeger.PersNr,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$lan$ AS Artikelbezeichnung,
  EinzHist.Barcode,
  FORMAT(CTEScans.DateTime, N''d'', N''de-AT'') as Datum,
  Format(CTEScans.DateTime, N''t'', N''de-AT'') As Uhrzeit,
  CTESCANS.EinAusDat [Tourenabholdatum],
  COUNT(CTEScans.ID) as Anzahl
  
FROM EinzHist
JOIN TraeArti ON EinzHist.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID and kunden.kdgfid in ($4$)
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN StandBer ON KdBer.BereichID = StandBer.BereichID AND Vsa.StandKonID = StandBer.StandKonID
JOIN Standort ON StandBer.ProduktionID = Standort.ID and Standort.id in ($3$) 
join CTEScans on ctescans.EinzHistID = EinzHist.ID
WHERE Kunden.SichtbarID IN ($SICHTBARIDS$)
 and Standort.SichtbarID IN  ($SICHTBARIDS$)
 group by Standort.Bez,
  Kunden.KdNr,
  Kunden.SuchCode ,
  Vsa.VsaNr,
  Vsa.SuchCode ,
  Vsa.Bez ,
  Traeger.Traeger ,
  Traeger.Vorname,
  Traeger.Nachname,
  Traeger.PersNr,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$lan$ ,
  EinzHist.Barcode,
  FORMAT(CTEScans.DateTime, N''d'', N''de-AT''),
  Format(CTEScans.DateTime, N''t'', N''de-AT''),
  CTESCANS.EinAusDat
  order by FORMAT(CTEScans.DateTime, N''d'', N''de-AT''), Format(CTEScans.DateTime, N''t'', N''de-AT'')'
WHERE ID = 1094;

GO

UPDATE ChartSQL SET ChartSQL = N'DECLARE @CalendarMonths TABLE (
  [Month] nchar(7)
);

DECLARE
  @basedate date,
  @maxdate date,
  @lastdate date,
  @offset int,
  @maxmonths int,
  @pivotcolumns nvarchar(max),
  @pivotsql nvarchar(max);

SET @basedate = $STARTDATE$;
SET @maxdate = $ENDDATE$;
SET @lastdate = @basedate;
SET @offset = 1;
SET @maxmonths = DATEDIFF(month, @basedate, @maxdate);

INSERT INTO @CalendarMonths ([Month]) VALUES (FORMAT(@basedate, N''yyyy-MM'', N''de-AT''));

WHILE (@offset <= @maxmonths)
BEGIN
  SET @lastdate = DATEADD(month, 1, @lastdate);

  INSERT INTO @CalendarMonths ([Month])
  VALUES (FORMAT(@lastdate, N''yyyy-MM'', N''de-AT''));

  SET @offset = @offset + 1;
END;

SELECT @pivotcolumns = COALESCE(@pivotcolumns + '', '','''') + QUOTENAME(CalMon.[Month])
FROM (
  SELECT [Month]
  FROM @CalendarMonths
) AS CalMon
ORDER BY CalMon.[Month] ASC;

DROP TABLE IF EXISTS #LiefermengeVSA;

WITH LiefermengeMonatlich AS (
  SELECT FORMAT(LsKo.Datum, N''yyyy-MM'', N''de-AT'') AS Monat, LsKo.VsaID, LsPo.KdArtiID, LsPo.AbteilID, LsPo.ArtGroeID, SUM(LsPo.Menge) AS Liefermenge
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  JOIN Vsa ON LsKo.VsaID = Vsa.ID
  WHERE LsKo.Datum BETWEEN @basedate AND @maxdate
    AND LsKo.Status >= N''Q''
    AND Vsa.KundenID = $ID$
    AND LsPo.Menge != 0
    AND NOT EXISTS (
      SELECT Scans.*
      FROM Scans
      WHERE Scans.LsPoID = LsPo.ID
    )
  GROUP BY FORMAT(LsKo.Datum, N''yyyy-MM'', N''de-AT''), LsKo.VsaID, LsPo.KdArtiID, LsPo.AbteilID, LsPo.ArtGroeID

  UNION ALL

  SELECT FORMAT(LsKo.Datum, N''yyyy-MM'', N''de-AT'') AS Monat, LsKo.VsaID, LsPo.KdArtiID, LsPo.AbteilID, EinzHist.ArtGroeID, COUNT(Scans.ID) AS Liefermenge
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  JOIN Vsa ON LsKo.VsaID = Vsa.ID
  JOIN Scans ON Scans.LsPoID = LsPo.ID
  JOIN EinzHist ON Scans.EinzHistID = EinzHist.ID
  WHERE LsKo.Datum BETWEEN @basedate AND @maxdate
    AND LsKo.Status >= N''Q''
    AND Vsa.KundenID = $ID$
    AND LsPo.Menge != 0
  GROUP BY FORMAT(LsKo.Datum, N''yyyy-MM'', N''de-AT''), LsKo.VsaID, LsPo.KdArtiID, LsPo.AbteilID, EinzHist.ArtGroeID
)
SELECT ProdBetrieb.SuchCode AS [produzierender Betrieb], IntProdBetrieb.SuchCode AS [intern produzierender Betrieb], Holding.Holding AS Kette, Kunden.KdNr AS Kundennummer, Kunden.SuchCode AS Kundenname, Vsa.VsaNr AS [VSA-Nummer], Vsa.Bez AS [VSA-Bezeichnung], Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Bereich.Bereich AS Produktbereich, ArtGru.Gruppe AS Artikelgruppe, Artikel.ArtikelNr AS Artikelnummer, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Artikel.StueckGewicht AS Stückgewicht, LiefArt.LiefArt AS Auslieferart, LiefermengeMonatlich.Monat, LiefermengeMonatlich.Liefermenge
INTO #LiefermengeVSA
FROM (
  SELECT Monat, VsaID, KdArtiID, AbteilID, ArtGroeID, SUM(Liefermenge) AS Liefermenge
  FROM LiefermengeMonatlich
  GROUP BY Monat, VsaID, KdArtiID, AbteilID, ArtGroeID
) AS LiefermengeMonatlich
JOIN Vsa ON LiefermengeMonatlich.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN KdArti ON LiefermengeMonatlich.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN LiefArt ON KdArti.LiefArtID = LiefArt.ID
JOIN ArtGroe ON LiefermengeMonatlich.ArtGroeID = ArtGroe.ID
JOIN Abteil ON LiefermengeMonatlich.AbteilID = Abteil.ID
JOIN StandBer ON StandBer.StandKonID = Vsa.StandKonID AND StandBer.BereichID = Bereich.ID
JOIN Standort AS ProdBetrieb ON StandBer.ExpeditionID = ProdBetrieb.ID
JOIN Standort AS IntProdBetrieb ON StandBer.ProduktionID = IntProdBetrieb.ID
WHERE Kunden.ID = $ID$;

SET @pivotsql = N''SELECT [produzierender Betrieb], [intern produzierender Betrieb], Kette, Kundennummer, Kundenname, [VSA-Nummer], [VSA-Bezeichnung], Kostenstelle, Kostenstellenbezeichnung, Produktbereich, Artikelgruppe, Artikelnummer, Artikelbezeichnung, Größe, Stückgewicht, Auslieferart, '' + @pivotcolumns + '' FROM #LiefermengeVSA AS LiefermengeVSA PIVOT ( SUM(LiefermengeVSA.Liefermenge) FOR LiefermengeVSA.Monat IN ('' + @pivotcolumns + '')) AS PivotResult ORDER BY Kundennummer, [VSA-Nummer],Artikelnummer'';

EXEC (@pivotsql);'
WHERE ID = 1152;

GO

UPDATE ChartSQL SET ChartSQL = N'WITH TeileInProd AS (
  SELECT Prod.AusTourID AS TourenID, Prod.VsaID, Prod.ZielNrID, Prod.EinDat, Prod.AusDat, Prod.ProduktionID AS ProdStandortID, EinzHist.ID AS TeileID
  FROM Prod
  JOIN EinzHist ON Prod.EinzHistID = EinzHist.ID
  WHERE EinzHist.Status IN (N''N'', N''Q'')
    AND Prod.VsaID IN (SELECT ID FROM Vsa WHERE Vsa.StandKonID IN ($1$))
),
Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N''EINZHIST''
)
SELECT Daten.Tour AS Liefertour, Daten.Bez AS [Liefertour-Bezeichnung], Wochentag = 
  CASE Daten.Wochentag
    WHEN 1 THEN N''Montag''
    WHEN 2 THEN N''Dienstag''
    WHEN 3 THEN N''Mittwoch''
    WHEN 4 THEN N''Donnerstag''
    WHEN 5 THEN N''Freitag''
    WHEN 6 THEN N''Samstag''
    WHEN 7 THEN N''Sonntag''
    ELSE N''WTF?''
  END
  , Standort.Bez AS Produktionsstandort, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS [VSA-Stichwort], Vsa.Bez AS [VSA-Bezeichnung], Traeger.Traeger AS TrägerNr, Traeger.Nachname, Traeger.Vorname, EinzHist.Barcode, Teilestatus.StatusBez AS [Status Teil], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Daten.EinDat AS [Abhol-Datum beim Kunden], Daten.AusDat AS [geplantes Lieferdatum], ZielNr.ZielNrBez$LAN$ AS [letzter Scan-Ort]
FROM ZielNr
JOIN (
    SELECT DISTINCT Touren.ID, Touren.Tour, Touren.Bez, Touren.TourPrioID, Touren.Wochentag, Vsa.ID AS VsaID, Vsa.Suchcode AS VsaSuchcode, Vsa.Bez AS VsaBez, BkZiele.TeileID, BkZiele.ZielNrID, BkZiele.EinDat, BkZiele.AusDat, VSA.KundenID, Touren.SDCTour, WLot.Bez AS WLotBez, Touren.ExpeditionID AS TourExpeditionID, BKZiele.ProdStandortID, TourPrio.TourPrioBez AS TourPrioBez, Fahrt.PlanDatum AS FahrtPlanDatum
    FROM VsaTour, Vsa, TourPrio, TeileInProd AS BkZiele
    LEFT JOIN Touren ON Touren.ID = BkZiele.TourenID
    LEFT JOIN WLot ON WLot.ID = Touren.WLotID
    LEFT JOIN Fahrt ON (Fahrt.TourenID = Touren.ID AND Fahrt.UrDatum = BkZiele.AusDat)
    LEFT JOIN LsKo ON LsKo.FahrtID = Fahrt.ID
    WHERE Touren.ID = VsaTour.TourenID
      AND BkZiele.AusDat BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum
      AND Vsa.ID = VsaTour.VsaID
      AND BkZiele.VsaID = Vsa.ID
      AND Touren.TourPrioID = TourPrio.ID
) AS Daten ON Daten.ZielNrID = ZielNr.ID
JOIN EinzHist ON Daten.TeileID = EinzHist.ID
JOIN TraeArti ON EinzHist.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Standort ON Daten.ProdStandortID = Standort.ID
JOIN Teilestatus ON EinzHist.[Status] = Teilestatus.[Status]
WHERE ZielNr.IstKomplett = 0
  AND Daten.FahrtPlanDatum <= CAST(GETDATE() AS date);'
WHERE ID = 675;

GO

UPDATE ChartSQL SET ChartSQL = N'WITH ScansCTE AS (
  SELECT Scans.EinzHistID, Scans.[DateTime], Scans.Info
  FROM Scans
  WHERE Scans.ActionsID = 47
    AND Scans.[DateTime] BETWEEN $2$ AND DATEADD(day,1, $3$)
)
SELECT EinzHist.Barcode, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.ID AS VsaID, Vsa.VsaNr, Vsa.Bez AS Vsa, Traeger.ID AS TraegerID, Traeger.Traeger AS BewohnerNr, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ScansCTE.[DateTime] AS [Scan-Zeitpunkt], CAST(LEFT(ScansCTE.Info, 200) AS nvarchar(200)) AS AbwurfInfo
FROM ScansCTE
JOIN EinzHist ON ScansCTE.EinzHistID = EinzHist.ID
JOIN TraeArti ON EinzHist.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE Kunden.StandortID IN ($1$);'
WHERE ID = 777;

GO

UPDATE ChartSQL SET ChartSQL = N'WITH CTEScans AS (
  SELECT Scans.ID, Scans.EinzHistID, Scans.Menge, Scans.[DateTime]
  FROM Scans
  WHERE Scans.[DateTime] BETWEEN $0$ AND $1$
    AND Scans.EinzHistID > 0
)
SELECT Standort.Bez AS Produktionsstandort,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.VsaNr,
  Vsa.SuchCode AS VsaStichwort,
  Vsa.Bez AS VsaBezeichnung,
  Traeger.Traeger AS TraegerNr,
  Traeger.Vorname,
  Traeger.Nachname,
  Traeger.PersNr,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$Lan$ AS Artikelbezeichnung,
  EinzHist.Barcode,
  Eingänge = (
    SELECT COUNT(CTEScans.ID)
    FROM CTEScans
    WHERE CTEScans.Menge = 1
      AND CTEScans.EinzHistID = EinzHist.ID
  ),
  Eingangsdaten = (
    STUFF(
      (
        SELECT N'', '' + FORMAT(CTEScans.[DateTime], N''d'', N''de-AT'')
        FROM CTEScans
        WHERE CTEscans.Menge = 1
          AND CTEScans.EinzHistID = EinzHist.ID
        FOR XML PATH ('''')
      ), 1, 2, N''''
    )
  ),
  Ausgänge = (
    SELECT COUNT(CTEScans.ID)
    FROM CTEScans
    WHERE CTEScans.Menge = -1
      AND CTEScans.EinzHistID = EinzHist.ID
  ),
  Ausgangsdaten = (
    STUFF(
      (
        SELECT N'', '' + FORMAT(CTEScans.[DateTime], N''d'', N''de-AT'')
        FROM CTEScans
        WHERE CTEscans.Menge = -1
          AND CTEScans.EinzHistID = EinzHist.ID
        FOR XML PATH ('''')
      ), 1, 2, N''''
    )
  )
FROM EinzHist
JOIN TraeArti ON EinzHist.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN StandBer ON KdBer.BereichID = StandBer.BereichID AND Vsa.StandKonID = StandBer.StandKonID
JOIN Standort ON StandBer.ProduktionID = Standort.ID and Standort.id in ($2$)
WHERE Kunden.id in ($3$) AND Kunden.SichtbarID IN ($SICHTBARIDS$)
  AND (EinzHist.Eingang1 >= $0$ OR EinzHist.Ausgang1 >= $0$);'
WHERE ID = 956;

GO

UPDATE ChartSQL SET ChartSQL = N'WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N''EINZHIST'')
),
EAScans as (
	Select Scans.EinzHistID, MAX(Scans.[DateTime]) as Scan, Scans.Menge
  from scans 
	join EinzHist on EinzHist.ID = Scans.EinzHistID 
	join VSA on VSA.ID = EinzHist.VsaID
	join KUNDEN on Kunden.ID = VSA.Kundenid
	join HOLDING on Holding.ID = KUNDEN.HoldingID
	where (SCANS.Menge = 1 or (Scans.Menge = -1 and Scans.lspoid > 0))
	and Kunden.HoldingID IN ($1$)
  AND Kunden.ID IN ($2$)
  AND Vsa.ID IN ($3$)
	group by SCANS.EinzHistID, Scans.Menge
)
SELECT Holding.Holding,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.VsaNr,
  Vsa.SuchCode AS [VSA-Stichwort],
  Vsa.Bez AS [VSA-Bezeichnung],
  Vsa.Name1 AS [VSA-Adresszeile 1],
  Vsa.Name2 AS [VSA-Adresszeile 2],
  Vsa.GebaeudeBez AS Gebäude,
  Abteil.Abteilung AS [Stamm-KsSt],
  Abteil.Bez AS [Stammkostenstellen-Bezeichnung],
  Schrank.SchrankNr AS Schrank,
  TraeFach.Fach,
  Traeger.Traeger AS [Träger-Nr],
  Traeger.Nachname,
  Traeger.Vorname,
  Traeger.PersNr,
  ab.Abteilung AS [KsSt Träger],
  ab.Bez AS [Kostenstellen-Bezeichnung Träger],
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  CAST(IIF(EinzHist.Status > N''Q'', 1, 0) AS bit) AS Stilllegung,
  IIF($7$ = 1, ArtGroe.Groesse, NULL) AS Größe,
  TraeArti.Menge AS [Max. Bestand],
  (Select COUNT(distinct Barcode) from EinzHist t1 where t1.ArtGroeID = EinzHist.ArtGroeID and t1.VsaID = EinzHist.VsaID and EinzHist.TraeArtiID = t1.TraeArtiID  and T1.Status between N''Q'' and N''W'') AS Umlauf,
  EinzHist.Barcode,
  Teilestatus.StatusBez AS Teilestatus,
  cast(EScans.Scan as date) as Eingangsscan,
  cast(AScans.Scan as date) as Ausgangsscan,
  EinzHist.Eingang1,
  EinzHist.Ausgang1,
  Kdarti.LeasPreis as Mietpreis,
  convert(date,getdate()) as Heute,
  datediff(day,EinzHist.Ausgang1,getdate()) as [Diff. Tage],
  convert(dec(10,0),datediff(day,EinzHist.Ausgang1,getdate()) / 7 ) as [Diff. Wochen],
  KdArtiLeasProWoche.LeasPreisProWo * convert(dec(10,0),datediff(day,EinzHist.Ausgang1,getdate()) / 7 ) as Kosten,
  EinzHist.kostenlos as [Teile auf Depot]
FROM EinzHist
JOIN TraeArti ON EinzHist.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
join abteil on abteil.id = vsa.abteilid
join abteil ab on ab.id = traeger.AbteilID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
CROSS APPLY advFunc_GetLeasPreisProWo(KdArti.ID) AS KdArtiLeasProWoche
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN LiefArt ON KdArti.LiefArtID = LiefArt.ID
LEFT OUTER JOIN TraeFach ON TraeFach.TraegerID = Traeger.ID
LEFT OUTER JOIN Schrank ON TraeFach.SchrankID = Schrank.ID
JOIN Teilestatus ON EinzHist.Status = Teilestatus.Status
left join lagerart on LagerArt.ID = EinzHist.LagerArtID
left join EAScans EScans on EScans.EinzHistID = EinzHist.ID and Escans.Menge = 1
left join EAScans AScans on AScans.EinzHistID = EinzHist.ID and Ascans.Menge = -1
WHERE Kunden.HoldingID IN ($1$)
  AND Kunden.ID IN ($2$)
  AND Vsa.ID IN ($3$)
  AND EinzHist.Ausgang1 < $4$
  and (($5$ = 1 and Traeger.Status <> N''I'') or $5$ = 0)
  and (($6$=1 and Kdarti.Status <> ''I'') or $6$ = 0)
  AND EinzHist.Status BETWEEN N''Q'' AND N''W''
  AND EinzHist.Einzug IS NULL
  AND EinzHist.IsCurrEinzHist = 1
GROUP BY Holding.Holding,
  Kunden.KdNr,
  Kunden.SuchCode,
  Vsa.VsaNr,
  Vsa.SuchCode,
  Vsa.Bez,
  Vsa.Name1,
  Vsa.Name2,
  VSA.GebaeudeBez,
  ABTEIL.Abteilung,
  ABTEIL.Bez,
  ab.Abteilung,
  ab.Bez,
  Schrank.SchrankNr,
  TraeFach.Fach,
  Traeger.Traeger,
  Traeger.Nachname,
  Traeger.Vorname,
  Traeger.PersNr,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$,
  IIF($7$ = 1, ArtGroe.Groesse, NULL),
  TraeArti.Menge,
  EinzHist.Barcode,
  CAST(IIF(EinzHist.Status > N''Q'', 1, 0) AS bit),
  Teilestatus.Statusbez,
  EinzHist.Eingang1,
  EinzHist.Ausgang1,
  EScans.Scan,
  AScans.Scan,
  EinzHist.IndienstDat,
  EinzHist.VsaID,
  EinzHist.ArtGroeID,
  EinzHist.TraeArtiID,
  Kdarti.LeasPreis,
  datediff(day,EinzHist.Ausgang1,getdate()),
  convert(dec(10,0),datediff(day,EinzHist.Ausgang1,getdate()) / 7 ),
  KdArtiLeasProWoche.LeasPreisProWo * convert(dec(10,0),datediff(day,EinzHist.Ausgang1,getdate()) / 7 ),
  EinzHist.kostenlos 
ORDER BY KdNr, VsaNr, Traeger, ArtikelNr, Größe;'
WHERE ID = 1009;

GO
DECLARE @fromtime datetime;
DECLARE @totime datetime;
DECLARE @fromdate date;
DECLARE @todate date;

SET @fromtime = $1$;
SET @totime = DATEADD(day, 1, $2$);
SET @fromdate = $1$;
SET @todate = $2$;

IF object_id('tempdb..#TmpFinal954b') IS NOT NULL
BEGIN
  DROP TABLE #TmpFinal954b;
END;

SELECT Teile.Barcode, Status.Teilestatus, Traeger.Vorname, Traeger.Nachname, Vsa.Bez AS Vsa, Abteil.Bez AS Kostenstelle, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, 0 AS Waschzyklen, Teile.ID AS TeileID
INTO #TmpFinal954b
FROM Teile, TraeArti, Traeger, Vsa, Kunden, KdArti, Artikel, ArtGroe, Abteil, (
  SELECT Status.Status, Status.StatusBez$LAN$ AS Teilestatus
  FROM Status
  WHERE Status.Tabelle = 'TEILE'
) AS Status
WHERE Teile.TraeArtiID = TraeArti.ID
  AND TraeArti.TraegerID = Traeger.ID
  AND Traeger.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND TraeArti.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND TraeArti.ArtGroeID = ArtGroe.ID
  AND Traeger.AbteilID = Abteil.ID
  AND Teile.Status = Status.Status
  AND Kunden.ID = $ID$
  AND Traeger.AbteilID = 23311606
  AND Teile.IndienstDat <= @todate
  AND Teile.IndienstDat IS NOT NULL
  AND IIF(Teile.AusdienstDat IS NULL, CONVERT(date, '2099-12-31'), Teile.AusdienstDat) > @fromdate;

IF object_id('tempdb..#TmpScans954b') IS NOT NULL
BEGIN
  DROP TABLE #TmpScans954b;
END

SELECT Scans.*
INTO #TmpScans954b
FROM Scans
WHERE Scans.DateTime BETWEEN @fromtime AND @totime
  AND Scans.TeileID IN (SELECT TeileID FROM #TmpFinal954b)
  AND Scans.Menge = -1;

UPDATE x SET x.Waschzyklen = Waschen.Waschzyklen
FROM #TmpFinal954b AS x, (
  SELECT Scans.TeileID, COUNT(Scans.ID) AS Waschzyklen
  FROM #TmpScans954b AS Scans
  WHERE EXISTS (
    SELECT Final.TeileID
    FROM #TmpFinal954b AS Final
    WHERE Final.TeileID = Scans.TeileID)
  GROUP BY Scans.TeileID
) AS Waschen
WHERE x.TeileID = Waschen.TeileID;

SELECT Final.Vorname, Final.Nachname, Final.Vsa, Final.Kostenstelle, Final.ArtikelNr, Final.Artikelbezeichnung, Final.Groesse, SUM(Final.Waschzyklen) AS Waschzyklen
FROM #TmpFinal954b AS Final
GROUP BY Final.Vorname, Final.Nachname, Final.Vsa, Final.Kostenstelle, Final.ArtikelNr, Final.Artikelbezeichnung, Final.Groesse
ORDER BY Final.Vsa, Final.Nachname, Final.Vorname, Final.ArtikelNr;
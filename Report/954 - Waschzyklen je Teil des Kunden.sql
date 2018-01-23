DECLARE @fromtime datetime;
DECLARE @totime datetime;
DECLARE @fromdate DATE;
DECLARE @todate DATE;

SET @fromtime = $1$;
SET @totime = DATEADD(day, 1, $2$);
SET @fromdate = $1$;
SET @todate = $2$;
 
DROP TABLE IF EXISTS #TmpFinal;

SELECT Teile.Barcode, Status.Teilestatus, Traeger.Vorname, Traeger.Nachname, Vsa.Bez AS Vsa, Abteil.Bez AS Kostenstelle, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, 0 AS Waschzyklen, Teile.ID AS TeileID
INTO #TmpFinal
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
  AND Teile.IndienstDat <= @todate
  AND Teile.IndienstDat IS NOT NULL
  AND ISNULL(Teile.AusdienstDat, CONVERT(date, '2099-12-31')) > @fromdate;
  
DROP TABLE IF EXISTS #TmpScans;

SELECT Scans.*
INTO #TmpScans
FROM Scans
WHERE Scans.DateTime BETWEEN @fromtime AND @totime
  AND Scans.TeileID IN (SELECT TeileID FROM #TmpFinal)
  AND Scans.Menge = -1;

UPDATE x SET x.Waschzyklen = Waschen.Waschzyklen
FROM #TmpFinal AS x, (
  SELECT Scans.TeileID, COUNT(Scans.ID) AS Waschzyklen
  FROM #TmpScans AS Scans
  WHERE EXISTS (
    SELECT Final.TeileID
    FROM #TmpFinal AS Final
    WHERE Final.TeileID = Scans.TeileID)
  GROUP BY Scans.TeileID
) AS Waschen
WHERE x.TeileID = Waschen.TeileID;

SELECT Final.Barcode, Final.Teilestatus, Final.Vorname, Final.Nachname, Final.Vsa, Final.Kostenstelle, Final.ArtikelNr, Final.Artikelbezeichnung, Final.Groesse, Final.Waschzyklen
FROM #TmpFinal AS Final
ORDER BY Final.Vsa, Final.Nachname, Final.Vorname, Final.ArtikelNr;
DECLARE @fromtime TIMESTAMP;
DECLARE @totime TIMESTAMP;
DECLARE @fromdate DATE;
DECLARE @todate DATE;

@fromtime = CONVERT($1$ + ' 00:00:00', SQL_TIMESTAMP);
@totime = CONVERT($2$ + ' 23:59:59', SQL_TIMESTAMP);
@fromdate = CONVERT($1$, SQL_DATE);
@todate = CONVERT($2$, SQL_DATE);
 
TRY
  DROP TABLE #TmpFinal;
CATCH ADS_SCRIPT_EXCEPTION
  IF __errcode <> 7112 THEN 
    RAISE; 
  END IF;
END TRY;

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
  AND IFNULL(Teile.AusdienstDat, CONVERT('31.12.2099', SQL_DATE)) > @fromdate;
  
TRY
  DROP TABLE #TmpScans;
CATCH ADS_SCRIPT_EXCEPTION
  IF __errcode <> 7112 THEN
    RAISE;
  END IF;
END TRY;

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
BEGIN TRY
  DROP TABLE #TmpBewTeile;
  DROP TABLE #TmpAusScans;
END TRY
BEGIN CATCH
END CATCH

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.Bez AS Vsa, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Teile.Barcode, Scans.EinAusDat AS Eingang, CONVERT(date, NULL) AS Ausgang, Teile.ID AS TeileID
INTO #TmpBewTeile
FROM Teile, TraeArti, Traeger, Vsa, Kunden, KdArti, Artikel, Scans
WHERE Teile.TraeArtiID = TraeArti.ID
  AND TraeArti.TraegerID = Traeger.ID
  AND Traeger.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND TraeArti.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Scans.TeileID = Teile.ID
  AND Scans.ZielNrID = 1 --Eingang
  AND Scans.EinAusDat IS NOT NULL
  AND Kunden.ID = $ID$
  AND Teile.AltenheimModus = 1;

SELECT Scans.TeileID, Scans.EinAusDat
INTO #TmpAusScans
FROM Scans
WHERE Scans.TeileID IN (SELECT TeileID FROM #TmpBewTeile)
  AND Scans.ZielNrID = 2; --Ausgang;

UPDATE BewTeile SET Ausgang = (
  SELECT MIN(AusScans.EinAusDat) 
  FROM #TmpAusScans AS AusScans 
  WHERE AusScans.TeileID = BewTeile.TeileID 
    AND AusScans.EinAusDat > BewTeile.Eingang
    AND NOT EXISTS (
      SELECT *
      FROM #TmpBewTeile AS x
      WHERE x.TeileID = AusScans.TeileID
        AND x.Eingang < AusScans.EinAusDat
        AND x.Eingang > BewTeile.Eingang
    ))
FROM #TmpBewTeile AS BewTeile;

SELECT KdNr, Kunde, Vsa, Nachname, Vorname, ArtikelNr, Artikelbezeichnung, Barcode, Eingang, Ausgang, DATEDIFF(day, Eingang, Ausgang) AS Bearbeitungstage
FROM #TmpBewTeile;
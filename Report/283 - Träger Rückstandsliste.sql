SELECT Kunden.SuchCode AS Kunde, Teile.Barcode AS Seriennummer, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, TRIM(ISNULL(Traeger.Nachname, '')) + ' ' + TRIM(ISNULL(Traeger.Vorname, '')) AS Träger, Scans.DateTime AS [Letzter Scan], ZielNr.ZielNrBez$LAN$ AS [Letztes Ziel]
FROM Scans, Teile, ZielNr, KdArti, Kunden, Artikel, Traeger, (
  SELECT MAX(Scans.ID) AS ScanID, Scans.TeileID
  FROM Scans
  WHERE Scans.TeileID IN (
    SELECT Teile.ID
    FROM Teile
    WHERE Teile.TraegerID = $ID$
      AND Teile.Status = 'Q'
  )
  GROUP BY Scans.TeileID
) LastScan
WHERE Traeger.ID = Teile.TraegerID 
  AND Teile.ArtikelID = Artikel.ID 
  AND KdArti.KundenID = Kunden.ID 
  AND KdArti.ID = Teile.KdArtiID 
  AND ZielNr.ID = Scans.ZielNrID 
  AND LastScan.ScanID = Scans.ID
  AND LastScan.TeileID = Teile.ID
  AND Eingang1 > Ausgang1 
  AND Eingang1 < $1$
  AND Traeger.ID = $ID$;
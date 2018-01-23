TRY
  DROP TABLE #TmpLsMurnau;
CATCH ALL END;

SELECT Kunden.KdNr, Vsa.VsaNr, Vsa.Bez AS Vsa, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, LsKo.LsNr, LsKo.Datum, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, KdArti.WaschPreis AS EPreis, 0 AS Menge, LsPo.ID AS LsPoID
INTO #TmpLsMurnau
FROM LsPo, LsKo, Vsa, Kunden, KdArti, Artikel, Abteil
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND LsPo.AbteilID = Abteil.ID
  AND LsKo.Datum BETWEEN '01.02.2016' AND '30.04.2016'
  AND Kunden.KdNr = 60400
  AND LsKo.Memo LIKE '%Mengen per Script auf 0 gesetzt'
  AND LsPo.Kostenlos = $FALSE$;

UPDATE LsMurnau SET Menge = ScanData.Menge
FROM #TmpLsMurnau LsMurnau, (
  SELECT s.LsPoID, COUNT(DISTINCT s.TeileID) AS Menge
  FROM (
    SELECT Scans.LsPoID, Scans.TeileID
    FROM Scans
    WHERE Scans.LsPoID IN (SELECT LsPoID FROM #TmpLsMurnau)

    UNION ALL

    SELECT SCANS_20160309.LsPoID, SCANS_20160309.TeileID
    FROM SCANS_20160309
    WHERE SCANS_20160309.LsPoID IN (SELECT LsPoID FROM #TmpLsMurnau)
  ) s
  GROUP BY s.LsPoID
) ScanData
WHERE ScanData.LsPoID = LsMurnau.LsPoID;

SELECT LsMurnau.KdNr, LsMurnau.VsaNr, LsMurnau.Vsa, LsMurnau.Kostenstelle, LsMurnau.Kostenstellenbezeichnung, LsMurnau.LsNr, LsMurnau.Datum, LsMurnau.ArtikelNr, LsMurnau.Artikelbezeichnung, LsMurnau.Menge, LsMurnau.EPreis, LsMurnau.Menge * LsMurnau.EPreis AS GPreis
FROM #TmpLsMurnau LsMurnau
ORDER BY LsMurnau.KdNr, LsMurnau.Kostenstelle, LsMurnau.ArtikelNr;
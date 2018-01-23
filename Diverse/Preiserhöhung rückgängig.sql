DROP TABLE IF EXISTS #TmpPrArchiv;
DROP TABLE IF EXISTS #TmpPreis;

SELECT PrArchiv.KdArtiID, MAX(PrArchiv.Datum) AS Datum
INTO #TmpPrArchiv
FROM PrArchiv, KdArti, Kunden
WHERE PrArchiv.KdArtiID = KdArti.ID
  AND KdArti.KundenID = Kunden.ID
  AND Kunden.KdNr IN (20124, 20125, 20126)
  AND DATEPART(year, PrArchiv.Datum) <= 2014
GROUP BY PrArchiv.KdArtiID;

SELECT PrArchiv.KdArtiID, PrArchiv.LeasingPreis, PrArchiv.WaschPreis, PrArchiv.SonderPreis, PrArchiv.PeriodenPreis, PrArchiv.VKPreis
INTO #TmpPreis
FROM PrArchiv, #TmpPrArchiv PrArchivUniq
WHERE PrArchiv.KdArtiID = PrArchivUniq.KdArtiID
  AND PrArchiv.Datum = PrArchivUniq.Datum
  AND (PrArchiv.LeasingPreis <> 0 OR PrArchiv.WaschPreis <> 0 OR PrArchiv.SonderPreis <> 0 OR PrArchiv.PeriodenPreis <> 0)
GROUP BY PrArchiv.KdArtiID, PrArchiv.LeasingPreis, PrArchiv.WaschPreis, PrArchiv.SonderPreis, PrArchiv.PeriodenPreis, PrArchiv.VKPreis;

SELECT *
FROM #TmpPreis
ORDER BY KdArtiID;

-- Zum Prüfen der Änderungen!
/*;
SELECT AltPreis.KdArtiID, KdArti.LeasingPreis, AltPreis.LeasingPreis, KdArti.WaschPreis, AltPreis.WaschPreis, KdArti.SonderPreis, AltPreis.SonderPreis, KdArti.PeriodenPreis, AltPreis.PeriodenPreis, KdArti.VKPreis, AltPreis.VKPreis
FROM KdArti, #TmpPreis AltPreis
WHERE AltPreis.KdArtiID = KdArti.ID
  AND (KdArti.LeasingPreis <> AltPreis.LeasingPreis OR KdArti.WaschPreis <> AltPreis.WaschPreis OR KdArti.SonderPreis <> AltPreis.SonderPreis OR KdArti.PeriodenPreis <> AltPreis.PeriodenPreis);
*/

-- KdArti aktualisieren
/*;
UPDATE KdArti SET KdArti.LeasingPreis = AltPreis.LeasingPreis, KdArti.WaschPreis = AltPreis.WaschPreis, KdArti.SonderPreis = AltPreis.SonderPreis, KdArti.PeriodenPreis = AltPreis.PeriodenPreis, KdArti.VKPreis = AltPreis.VKPreis
FROM KdArti, #TmpPreis AltPreis
WHERE AltPreis.KdArtiID = KdArti.ID
  AND (KdArti.LeasingPreis <> AltPreis.LeasingPreis OR KdArti.WaschPreis <> AltPreis.WaschPreis OR KdArti.SonderPreis <> AltPreis.SonderPreis OR KdArti.PeriodenPreis <> AltPreis.PeriodenPreis);
*/
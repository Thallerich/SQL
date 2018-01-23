-- Unterschiede letzter Eintrag im Preisarchiv zum aktuellen Leasing-/Bearbeitungspreis

SELECT Kunden.KdNr, ViewArtikel.ArtikelNr, ViewArtikel.ArtikelBez, KdArti.LeasingPreis, PrPreis.LeasingPreis AS LeasingArchiv, KdArti.WaschPreis, PrPreis.WaschPreis AS WaschArchiv
FROM Kunden, ViewArtikel, KdArti, (
  SELECT PrArchiv.KdArtiID, PrArchiv.LeasingPreis, PrArchiv.WaschPreis, PrArchiv.Datum
  FROM PrArchiv, (
    SELECT PrArchiv.KdArtiID, MAX(PrArchiv.ID) AS PrID
    FROM PrArchiv
    GROUP BY 1) PrLatest
  WHERE PrArchiv.ID = PrLatest.PrID ) PrPreis
WHERE KdArti.KundenID = Kunden.ID
  AND KdArti.ArtikelID = ViewArtikel.ID
  AND KdArti.ID = PrPreis.KdArtiID
  AND ViewArtikel.LanguageID = $LANGUAGE$
  AND KdArti.LeasingPreis + KdArti.WaschPreis <> PrPreis.LeasingPreis + PrPreis.WaschPreis
  AND Kunden.KdNr IN ();
  
  
-- Korrektur der Leasing-/Bearbeitungspreise auf den letzten Eintrag im Preisarchiv

UPDATE KdArti
SET KdArti.LeasingPreis = PrPreis.LeasingPreis, KdArti.WaschPreis = PrPreis.WaschPreis, KdArti.User_ = 'STHA'
FROM Kunden, KdArti, (
  SELECT PrArchiv.KdArtiID, PrArchiv.LeasingPreis, PrArchiv.WaschPreis, PrArchiv.Datum
  FROM PrArchiv, (
    SELECT PrArchiv.KdArtiID, MAX(PrArchiv.ID) AS PrID
    FROM PrArchiv
    GROUP BY 1) PrLatest
  WHERE PrArchiv.ID = PrLatest.PrID ) PrPreis
WHERE KdArti.ID = PrPreis.KdArtiID
	AND KdArti.KundenID = Kunden.ID
    AND KdArti.LeasingPreis + KdArti.WaschPreis <> PrPreis.LeasingPreis + PrPreis.WaschPreis
	AND Kunden.KdNr IN ();
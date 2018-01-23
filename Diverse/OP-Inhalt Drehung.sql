TRY
  DROP TABLE #TmpFinal;
CATCH ALL END;

SELECT KdGf.KurzBez AS SGF, Kunden.KdNr, Kunden.SuchCode AS Kunde, StatusKunden.StatusBez AS Kundenstatus, Vsa.Bez AS VSA, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, StatusArtikel.StatusBez AS Artikelstatus, Artikel.EKPreis, COUNT(DISTINCT OPTeile.ID) AS TeileKunde, 0 AS LiefermengeSchnitt, 0 AS T7, 0 AS T30, 0 AS T60, 0 AS T180, 0 AS TMax, Vsa.ID AS VsaID, Artikel.ID AS ArtikelID
INTO #TmpFinal
FROM OPTeile, Artikel, Vsa, Kunden, KdGf, (SELECT Status.Status, Status.StatusBez$LAN$ AS StatusBez FROM Status WHERE Status.Tabelle = 'ARTIKEL') AS StatusArtikel, (SELECT Status.Status, Status.StatusBez$LAN$ AS StatusBez FROM Status WHERE Status.Tabelle = 'KUNDEN') AS StatusKunden
WHERE OPTeile.ArtikelID = Artikel.ID
  AND Artikel.Status = StatusArtikel.Status
  AND OPTeile.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.KdGfID = KdGf.ID
  AND Kunden.Status = StatusKunden.Status
  AND Artikel.ID IN (SELECT OPSets.Artikel1ID FROM OPSets)
  AND Artikel.ArtGruID NOT IN (SELECT ID FROM ArtGru WHERE SetImSet = $TRUE$)
  AND Artikel.BereichID = 106
  AND OPTeile.Status = 'R'
GROUP BY SGF, Kunden.KdNr, Kunde, Kundenstatus, VSA, Artikelbezeichnung, Artikelstatus, Artikel.EKPreis, VsaID, ArtikelID;

UPDATE Final SET T7 = x.AnzTeile
FROM #TmpFinal Final, (
  SELECT OPTeile.VsaID, OPTeile.ArtikelID, COUNT(DISTINCT OPTeile.ID) AS AnzTeile
  FROM OPTeile, Artikel
  WHERE OPTeile.ArtikelID = Artikel.ID
    AND Artikel.ID IN (SELECT ArtikelID FROM #TmpFinal)
    AND OPTeile.Status = 'R'
    AND TIMESTAMPDIFF(SQL_TSI_DAY, IFNULL(OPTeile.LastScanToKunde, CONVERT('01.01.1980 00:00:00', SQL_TIMESTAMP)), NOW()) <= 7
  GROUP BY OPTeile.VsaID, OPTeile.ArtikelID
) x
WHERE x.ArtikelID = Final.ArtikelID
  AND x.VsaID = Final.VsaID;
  
UPDATE Final SET T30 = x.AnzTeile
FROM #TmpFinal Final, (
  SELECT OPTeile.VsaID, OPTeile.ArtikelID, COUNT(DISTINCT OPTeile.ID) AS AnzTeile
  FROM OPTeile, Artikel
  WHERE OPTeile.ArtikelID = Artikel.ID
    AND Artikel.ID IN (SELECT ArtikelID FROM #TmpFinal)
    AND OPTeile.Status = 'R'
    AND TIMESTAMPDIFF(SQL_TSI_DAY, IFNULL(OPTeile.LastScanToKunde, CONVERT('01.01.1980 00:00:00', SQL_TIMESTAMP)), NOW()) BETWEEN 8 AND 30
  GROUP BY OPTeile.VsaID, OPTeile.ArtikelID
) x
WHERE x.ArtikelID = Final.ArtikelID
  AND x.VsaID = Final.VsaID;
  
UPDATE Final SET T60 = x.AnzTeile
FROM #TmpFinal Final, (
  SELECT OPTeile.VsaID, OPTeile.ArtikelID, COUNT(DISTINCT OPTeile.ID) AS AnzTeile
  FROM OPTeile, Artikel
  WHERE OPTeile.ArtikelID = Artikel.ID
    AND Artikel.ID IN (SELECT ArtikelID FROM #TmpFinal)
    AND OPTeile.Status = 'R'
    AND TIMESTAMPDIFF(SQL_TSI_DAY, IFNULL(OPTeile.LastScanToKunde, CONVERT('01.01.1980 00:00:00', SQL_TIMESTAMP)), NOW()) BETWEEN 31 AND 60
  GROUP BY OPTeile.VsaID, OPTeile.ArtikelID
) x
WHERE x.ArtikelID = Final.ArtikelID
  AND x.VsaID = Final.VsaID;
  
UPDATE Final SET T180 = x.AnzTeile
FROM #TmpFinal Final, (
  SELECT OPTeile.VsaID, OPTeile.ArtikelID, COUNT(DISTINCT OPTeile.ID) AS AnzTeile
  FROM OPTeile, Artikel
  WHERE OPTeile.ArtikelID = Artikel.ID
    AND Artikel.ID IN (SELECT ArtikelID FROM #TmpFinal)
    AND OPTeile.Status = 'R'
    AND TIMESTAMPDIFF(SQL_TSI_DAY, IFNULL(OPTeile.LastScanToKunde, CONVERT('01.01.1980 00:00:00', SQL_TIMESTAMP)), NOW()) BETWEEN 61 AND 180
  GROUP BY OPTeile.VsaID, OPTeile.ArtikelID
) x
WHERE x.ArtikelID = Final.ArtikelID
  AND x.VsaID = Final.VsaID;
  
UPDATE Final SET TMax = x.AnzTeile
FROM #TmpFinal Final, (
  SELECT OPTeile.VsaID, OPTeile.ArtikelID, COUNT(DISTINCT OPTeile.ID) AS AnzTeile
  FROM OPTeile, Artikel
  WHERE OPTeile.ArtikelID = Artikel.ID
    AND Artikel.ID IN (SELECT ArtikelID FROM #TmpFinal)
    AND OPTeile.Status = 'R'
    AND TIMESTAMPDIFF(SQL_TSI_DAY, IFNULL(OPTeile.LastScanToKunde, CONVERT('01.01.1980 00:00:00', SQL_TIMESTAMP)), NOW()) > 180
  GROUP BY OPTeile.VsaID, OPTeile.ArtikelID
) x
WHERE x.ArtikelID = Final.ArtikelID
  AND x.VsaID = Final.VsaID;
  
UPDATE Final SET LiefermengeSchnitt = x.Durchschnitt
FROM #TmpFinal Final, (
  SELECT VsaAnf.VsaID, OPSets.Artikel1ID AS ArtikelID, SUM(VsaAnf.Durchschnitt * OPSets.Menge) AS Durchschnitt
  FROM VsaAnf, KdArti, OPSets
  WHERE VsaAnf.KdArtiID = KdArti.ID
    AND KdArti.ArtikelID = OPSets.ArtikelID
    AND OPSets.Artikel1ID IN (SELECT ArtikelID FROM #TmpFinal)
  GROUP BY VsaAnf.VsaID, ArtikelID
) x
WHERE x.VsaID = Final.VsaID
  AND x.ArtikelID = Final.ArtikelID;
  
SELECT SGF, KdNr, Kunde, Kundenstatus, VSA, Artikelbezeichnung, Artikelstatus, EKPreis, TeileKunde AS [Teile beim Kunden], LiefermengeSchnitt AS [Durchschnitt Liefermenge], T7 AS [<=7], T30 AS [<= 30], T60 AS [<= 60], T180 AS [<= 180], TMax AS [> 180] FROM #TmpFinal;
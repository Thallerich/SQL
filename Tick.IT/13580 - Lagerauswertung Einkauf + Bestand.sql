TRY
  DROP TABLE #TmpResult;
CATCH ALL END;

SELECT Artikel.ArtikelNr, Status.Artikelstatus, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, 0 AS Einkauf2013, 0 AS Einkauf2014, 0 AS Einkauf2015, Artikel.EKPreis, Lief.Name1 AS Lieferant, 0 AS BestandLEN, 0 AS BestandKLU, 0 AS BestandRAN, Artikel.ID AS ArtikelID
INTO #TmpResult
FROM Bestand, ArtGroe, Artikel, Lief, (SELECT Status.Status, Status.StatusBez$LAN$ AS Artikelstatus FROM Status WHERE Status.Tabelle = 'ARTIKEL') AS Status
WHERE Bestand.ArtGroeID = ArtGroe.ID
  AND ArtGroe.ArtikelID = Artikel.ID
  AND Artikel.LiefID = Lief.ID
  AND Artikel.Status = Status.Status
  AND Bestand.ArtGroeID > 0
GROUP BY Artikel.ArtikelNr, Status.Artikelstatus, Artikelbezeichnung, Artikel.EKPreis, Lieferant, ArtikelID
ORDER BY Artikel.ArtikelNr;

UPDATE R SET Einkauf2013 = x.Einkaufsmenge
FROM #TmpResult AS R, ( 
 SELECT ArtGroe.ArtikelID, SUM(BPo.Menge) AS Einkaufsmenge
  FROM BPo, BKo, ArtGroe
  WHERE BPo.BKoID = BKo.ID
    AND BPo.ArtGroeID = ArtGroe.ID
    AND ArtGroe.ArtikelID IN (SELECT ArtikelID FROM #TmpResult)
    AND BKo.Datum BETWEEN '01.01.2013' AND '31.12.2013'
  GROUP BY ArtGroe.ArtikelID
) AS x
WHERE x.ArtikelID = R.ArtikelID;

UPDATE R SET Einkauf2014 = x.Einkaufsmenge
FROM #TmpResult AS R, ( 
 SELECT ArtGroe.ArtikelID, SUM(BPo.Menge) AS Einkaufsmenge
  FROM BPo, BKo, ArtGroe
  WHERE BPo.BKoID = BKo.ID
    AND BPo.ArtGroeID = ArtGroe.ID
    AND ArtGroe.ArtikelID IN (SELECT ArtikelID FROM #TmpResult)
    AND BKo.Datum BETWEEN '01.01.2014' AND '31.12.2014'
  GROUP BY ArtGroe.ArtikelID
) AS x
WHERE x.ArtikelID = R.ArtikelID;

UPDATE R SET Einkauf2015 = x.Einkaufsmenge
FROM #TmpResult AS R, ( 
 SELECT ArtGroe.ArtikelID, SUM(BPo.Menge) AS Einkaufsmenge
  FROM BPo, BKo, ArtGroe
  WHERE BPo.BKoID = BKo.ID
    AND BPo.ArtGroeID = ArtGroe.ID
    AND ArtGroe.ArtikelID IN (SELECT ArtikelID FROM #TmpResult)
    AND BKo.Datum BETWEEN '01.01.2015' AND '31.12.2015'
  GROUP BY ArtGroe.ArtikelID
) AS x
WHERE x.ArtikelID = R.ArtikelID;

UPDATE R SET BestandLEN = x.Bestand
FROM #TmpResult AS R, (
  SELECT ArtGroe.ArtikelID, SUM(Bestand.Bestand) AS Bestand
  FROM Bestand, ArtGroe, LagerArt
  WHERE Bestand.ArtGroeID = ArtGroe.ID
    AND Bestand.LagerArtID = LagerArt.ID
    AND LagerArt.LagerID = 1 --Lenzing
  GROUP BY ArtGroe.ArtikelID
) AS x
WHERE x.ArtikelID = R.ArtikelID;

UPDATE R SET BestandKLU = x.Bestand
FROM #TmpResult AS R, (
  SELECT ArtGroe.ArtikelID, SUM(Bestand.Bestand) AS Bestand
  FROM Bestand, ArtGroe, LagerArt
  WHERE Bestand.ArtGroeID = ArtGroe.ID
    AND Bestand.LagerArtID = LagerArt.ID
    AND LagerArt.LagerID = 5001 --Klagenfurt
  GROUP BY ArtGroe.ArtikelID
) AS x
WHERE x.ArtikelID = R.ArtikelID;

UPDATE R SET BestandRAN = x.Bestand
FROM #TmpResult AS R, (
  SELECT ArtGroe.ArtikelID, SUM(Bestand.Bestand) AS Bestand
  FROM Bestand, ArtGroe, LagerArt
  WHERE Bestand.ArtGroeID = ArtGroe.ID
    AND Bestand.LagerArtID = LagerArt.ID
    AND LagerArt.LagerID = 5004 --Rankweil
  GROUP BY ArtGroe.ArtikelID
) AS x
WHERE x.ArtikelID = R.ArtikelID;

SELECT ArtikelNr, Artikelstatus, Artikelbezeichnung, Einkauf2013, Einkauf2014, Einkauf2015, EKPreis, Lieferant, BestandLEN, BestandKLU, BestandRAN
FROM #TmpResult
WHERE Einkauf2013 > 0
  OR Einkauf2014 > 0
  OR Einkauf2015 > 0
  OR BestandLEN > 0
  OR BestandKLU > 0
  OR BestandRAN > 0;
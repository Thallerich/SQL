TRY
  DROP TABLE #TmpSetList;
  DROP TABLE #TmpFinal;
CATCH ALL END;

SELECT DISTINCT OPSets.ArtikelID
INTO #TmpSetList
FROM OPSets, Artikel
WHERE OPSets.Artikel1ID = Artikel.ID
  AND LOWER(Artikel.ArtikelBez) LIKE '%mantel%';

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, StatusKunde.StatusBez AS Kundenstatus, Vsa.Bez AS VSA, StatusVsa.StatusBez AS VSAStatus, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, 0 AS SetBetroffen, COUNT(OPEtiKo.EtiNr) AS SetKunde, 0 AS LiefermengeSchnitt, OPEtiKo.ArtikelID, OPEtiKo.VsaID
INTO #TmpFinal
FROM OPEtiKo, Vsa, Kunden, Artikel, #TmpSetList SetList, (SELECT Status.Status, Status.StatusBez$LAN$ AS StatusBez FROM Status WHERE Tabelle = 'KUNDEN') AS StatusKunde, (SELECT Status.Status, Status.StatusBez$LAN$ AS StatusBez FROM Status WHERE Status.Tabelle = 'VSA') AS StatusVsa
WHERE OPEtiKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND OPEtiKo.ArtikelID = Artikel.ID
  AND OPEtiKo.ArtikelID = SetList.ArtikelID
  AND Kunden.Status = StatusKunde.Status
  AND Vsa.Status = StatusVsa.Status
  AND OPEtiKo.Status = 'R'
  AND Artikel.BereichID = 106
GROUP BY Kunden.KdNr, Kunde, Kundenstatus, VSA, VSAStatus, Artikel.ArtikelNr, Artikelbezeichnung, OPEtiKo.ArtikelID, OPEtiKo.VsaID;

UPDATE Final SET Final.SetBetroffen = x.AnzSet
FROM #TmpFinal Final, (
  SELECT OPEtiKo.ArtikelID, OPEtiKo.VsaID, COUNT(OPEtiKo.EtiNr) AS AnzSet
  FROM OPEtiKo, #TmpSetList SetList
  WHERE OPEtiKo.ArtikelID = SetList.ArtikelID
    AND OPEtiKo.VerfallDatum BETWEEN '23.07.2016' AND '28.08.2016'
    AND OPEtiKo.Status = 'R'
  GROUP BY OPEtiKo.ArtikelID, OPEtiKo.VsaID
) x
WHERE x.ArtikelID = Final.ArtikelID
  AND x.VsaID = Final.VsaID;
  
UPDATE Final SET Final.LiefermengeSchnitt = VsaAnf.Durchschnitt
FROM #TmpFinal Final, VsaAnf, KdArti
WHERE Final.VsaID = VsaAnf.VsaID
  AND Final.ArtikelID = KdArti.ArtikelID
  AND VsaAnf.KdArtiID = KdArti.ID;
  
SELECT * FROM #TmpFinal;
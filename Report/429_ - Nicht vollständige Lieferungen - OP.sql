DROP TABLE IF EXISTS #TmpOPEtiKo;
DROP TABLE IF EXISTS #TmpFinal;

SELECT OPEtiKo.VsaID, OPEtiKo.ArtikelID, OPEtiKo.Status, COUNT(DISTINCT OPEtiKo.EtiNr) AS AnzEtiketten
INTO #TmpOPEtiKo
FROM OPEtiKo
WHERE OPEtiKo.Status BETWEEN 'D' AND 'P'
  AND OPEtiKo.VerfallDatum > GETDATE()
  AND OPEtiKo.VsaID > 0
GROUP BY OPEtiKo.VsaID, OPEtiKo.ArtikelID, OPEtiKo.Status;

SELECT AnfKo.Status, Status.StatusBez, AnfKo.LieferDatum, KdGf.KurzBez AS SGF, Kunden.KdNr, Kunden.SuchCode AS Kunde, VSA.SuchCode AS VsaNr, VSA.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, AnfPo.Angefordert, 0 AS Gedruckt, 0 AS [Beim Packen], 0 AS Gepackt, 0 AS Steril, 0 AS Unsteril, AnfPo.Geliefert, ServType.ServTypeBez$LAN$ AS Expedition, Vsa.ID AS VsaID, Artikel.ID AS ArtikelID
INTO #TmpFinal
FROM AnfPo, AnfKo, VSA, Kunden, KdArti, Artikel, ServType, KdGf, (SELECT Status.Status, Status.StatusBez$LAN$ AS StatusBez FROM Status WHERE Status.Tabelle = 'ANFKO') AS Status
WHERE (($4$ = 1 AND AnfPo.Angefordert = AnfPo.Geliefert) OR ($4$ = 0 AND AnfPo.Angefordert <> AnfPo.Geliefert))
  AND (AnfPo.Angefordert > 0 OR AnfPo.Geliefert > 0)
  AND AnfPo.AnfKoID = AnfKo.ID
  AND AnfKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND AnfPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Vsa.ServTypeID = ServType.ID
  AND Kunden.KdGfID = KdGf.ID
  AND AnfKo.Status = Status.Status
  AND ServType.ID IN ($3$)
  AND LieferDatum BETWEEN $1$ AND $2$;

UPDATE Final SET Gedruckt = OPEtiKo.AnzEtiketten
FROM #TmpFinal Final, #TmpOPEtiKo OPEtiKo
WHERE Final.VsaID = OPEtiKo.VsaID
  AND Final.ArtikelID = OPEtiKo.ArtikelID
  AND OPEtiKo.Status = 'D';

UPDATE Final SET [Beim Packen] = OPEtiKo.AnzEtiketten
FROM #TmpFinal Final, #TmpOPEtiKo OPEtiKo
WHERE Final.VsaID = OPEtiKo.VsaID
  AND Final.ArtikelID = OPEtiKo.ArtikelID
  AND OPEtiKo.Status = 'G';

UPDATE Final SET Gepackt = OPEtiKo.AnzEtiketten
FROM #TmpFinal Final, #TmpOPEtiKo OPEtiKo
WHERE Final.VsaID = OPEtiKo.VsaID
  AND Final.ArtikelID = OPEtiKo.ArtikelID
  AND OPEtiKo.Status = 'J';

UPDATE Final SET Steril = OPEtiKo.AnzEtiketten
FROM #TmpFinal Final, #TmpOPEtiKo OPEtiKo
WHERE Final.VsaID = OPEtiKo.VsaID
  AND Final.ArtikelID = OPEtiKo.ArtikelID
  AND OPEtiKo.Status = 'M';

UPDATE Final SET Unsteril = OPEtiKo.AnzEtiketten
FROM #TmpFinal Final, #TmpOPEtiKo OPEtiKo
WHERE Final.VsaID = OPEtiKo.VsaID
  AND Final.ArtikelID = OPEtiKo.ArtikelID
  AND OPEtiKo.Status = 'N';

SELECT Status, StatusBez, LieferDatum, SGF, KdNr, Kunde, VsaNr, Vsa, ArtikelNr, Artikelbezeichnung, Angefordert, Gedruckt, [Beim Packen], Gepackt, Steril, Unsteril, Geliefert, Expedition
FROM #TmpFinal Final
ORDER BY LieferDatum, SGF, KdNr, VsaNr, ArtikelNr;
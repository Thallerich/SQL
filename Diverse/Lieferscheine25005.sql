TRY
  DROP TABLE #TmpLS;
CATCH ALL END;

SELECT LsKo.Datum AS Lieferdatum, Kunden.KdNr, Vsa.VsaNr, Vsa.Bez AS Vsa, Bereich.BereichBez$LAN$ AS Produktbereich, LsKo.LsNr, RechKo.RechNr, LsKo.ID AS LsKoID
INTO #TmpLS
FROM LsPo, LsKo, Vsa, Kunden, KdArti, KdBer, Bereich, RechPo, RechKo
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.KdBerID = KdBer.ID
  AND KdBer.BereichID = Bereich.ID
  AND LsPo.RechPoID = RechPo.ID
  AND RechPo.RechKoID = RechKo.ID
  AND Kunden.KdNr = 25005
  AND LsKo.Datum BETWEEN '01.05.2015' AND '30.04.2016'
GROUP BY Lieferdatum, Kunden.KdNr, Vsa.VsaNr, Vsa, Produktbereich, LsKo.LsNr, RechKo.RechNr, LsKoID;

ALTER TABLE #TmpLS ADD COLUMN PZNr char(20);

UPDATE LS SET PZNr = PZ.AuftragsNr
FROM #TmpLS LS, (
  SELECT AnfKo.LsKoID, AnfKo.AuftragsNr
  FROM AnfKo
  WHERE AnfKo.LsKoID IN (SELECT LsKoID FROM #TmpLS)
) PZ
WHERE PZ.LsKoID = Ls.LsKoID;

UPDATE #TmpLS SET RechNr = NULL WHERE RechNr = 0;

SELECT Lieferdatum, KdNr, VsaNr, Vsa, Produktbereich, LsNr, PZNr, RechNr
FROM #TmpLs
ORDER BY KdNr, Lieferdatum, VsaNr, Produktbereich;
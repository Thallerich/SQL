TRY
  DROP TABLE #TmpLSChange;
CATCH ALL END;

SELECT LsPo.ID AS LsPoID, LsKo.ID AS LsKoID, LsKo.VsaID, LsPo.AbteilID, LsPo.KdArtiID
INTO #TmpLSChange
FROM LsPo, LsKo, Vsa, Kunden
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.KdNr = 1071 -- alter Kunde
  AND Vsa.VsaNr = 33 -- alte VSA
  AND LsKo.Datum >= '01.01.2014';
  
UPDATE LsKo SET VsaID = 4241295  --neue VSA
WHERE ID IN (
  SELECT LsKoID
  FROM #TmpLSChange
);

UPDATE LsPo SET AbteilID = 23308342, KdArtiID = a.KdArtiID --neue Kostenstelle
FROM (
  SELECT LSC.LsPoID, KdArtiNeu.ID AS KdArtiID
  FROM #TmpLSChange AS LSC, KdArti, KdArti AS KdArtiNeu, Kunden
  WHERE LSC.KdArtiID = KdArti.ID
    AND KdArti.ArtikelID = KdArtiNeu.ArtikelID
    AND KdArtiNeu.KundenID = Kunden.ID
    AND Kunden.KdNr = 1073  --neuer Kunde
) a
WHERE LsPo.ID = a.LsPoID;
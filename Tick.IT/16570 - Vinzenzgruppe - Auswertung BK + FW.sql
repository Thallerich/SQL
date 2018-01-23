-- Bekleidung
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Traeger.Traeger, Traeger.Nachname, Traeger.Vorname, Teile.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, CONVERT(Teile.Anlage_, SQL_DATE) AS EingabeDatum, Teile.IndienstDat AS Erstauslieferung, Teile.IndienstDat - CONVERT(Teile.Anlage_, SQL_DATE) AS TageBisLieferung
FROM Teile, Traeger, Vsa, Kunden, Holding, KdArti, Artikel, KdBer, Bereich
WHERE Teile.TraegerID = Traeger.ID
  AND Traeger.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.HoldingID = Holding.ID
  AND Teile.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND KdArti.KdBerID = KdBer.ID
  AND KdBer.BereichID = Bereich.ID
  AND Holding.Holding = 'Vinzenz'
  AND Bereich.Bereich = 'BK'
  AND Teile.Status >= 'Q'
  AND TIMESTAMPDIFF(SQL_TSI_MONTH, Teile.Anlage_, NOW()) <= 24
ORDER BY Kunden.KdNr, EingabeDatum;

-- Flachwäsche
TRY
  DROP TABLE #TmpAnf;
CATCH ALL END;

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, AnfKo.Lieferdatum, AnfKo.AuftragsNr AS PackzettelNr, 0 AS LieferscheinNr, Vsa.VsaNr, Vsa.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, AnfPo.Angefordert, 0 AS Geliefert, KdArti.ID AS KdArtiID, AnfKo.LsKoID
INTO #TmpAnf
FROM AnfPo, AnfKo, Vsa, Kunden, Holding, KdArti, Artikel
WHERE AnfPo.AnfKoID = AnfKo.ID
  AND AnfKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.HoldingID = Holding.ID
  AND AnfPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND AnfKo.Lieferdatum >= CURDATE() - 183 -- 6 Monate = 183 Tage
  AND Holding.Holding = 'Vinzenz'
  AND AnfKo.Status = 'S';

UPDATE Anf SET Anf.Geliefert = x.Liefermenge
FROM #TmpAnf AS Anf, (
  SELECT LsPo.KdArtiID, LsPo.LsKoID, LsPo.Menge AS Liefermenge
  FROM LsPo
  WHERE LsPo.LsKoID IN (SELECT LsKoID FROM #TmpAnf)
) AS x
WHERE x.LsKoID = Anf.LsKoID
  AND x.KdArtiID = Anf.KdArtiID;

UPDATE Anf SET Anf.LieferscheinNr = x.LsNr
FROM #TmpAnf AS Anf, (
  SELECT LsKo.ID, LsKo.LsNr
  FROM LsKo
  WHERE LsKo.ID IN (SELECT LsKoID FROM #TmpAnf)
) AS x
WHERE x.ID = Anf.LsKoID;

SELECT Anf.KdNr, Anf.Kunde, Anf.Lieferdatum, Anf.PackzettelNr, Anf.LieferscheinNr, Anf.VsaNr, Anf.Vsa, Anf.ArtikelNr, Anf.Artikelbezeichnung, Anf.Angefordert, Anf.Geliefert, Anf.Geliefert - Anf.Angefordert AS Differenz
FROM #TmpAnf AS Anf
WHERE (Anf.Angefordert <> 0 OR Anf.Geliefert <> 0)
ORDER BY Anf.KdNr, Anf.Lieferdatum, Anf.VsaNr, Anf.ArtikelNr;
-- ######################## OpSetArtikel ###############################
DROP TABLE IF EXISTS #TmpOpSetBedarf596;

SELECT Artikel.ID, Artikel.ArtikelNr AS SetArtNr, Artikel.ArtikelBez$LAN$ AS SetBez, 0 AS Bedarf0, 0 AS AnzGepackt, Artikel.Packmenge
INTO #TmpOpSetBedarf596
FROM Artikel, Bereich, OpSets
WHERE OpSets.ArtikelID = Artikel.ID
  AND Artikel.Status = 'A'
  AND Artikel.BereichID = Bereich.ID
  AND Bereich.IstOP = 1
  AND Artikel.ArtGruID IN ($3$)
GROUP BY Artikel.ID, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, Artikel.Packmenge;

-- ###################### Angeforderte Mengen je Artikel ##############
DROP TABLE IF EXISTS #TmpAnfArti596;

SELECT Artikel.ID, SUM(CEILING(AnfPo.Angefordert / IIF(Artikel.Packmenge = 0, 1, Artikel.Packmenge))) AS Menge
INTO #TmpAnfArti596
FROM AnfKo, AnfPo, KdArti, Artikel
WHERE AnfKo.ID IN (
  SELECT ID
  FROM AnfKo
  WHERE LieferDatum = $1$
    AND ProduktionID IN ($2$)
)
  AND AnfPo.NachholAnfPoID = -1
  AND AnfKo.ID = AnfPo.AnfKoID
  AND KdArti.ID = AnfPo.KdArtiID
  AND Artikel.ID = KdArti.ArtikelID
GROUP BY Artikel.ID;

-- #################### Anforderungen in OpSetArtikel eintragen ########
UPDATE x SET x.Bedarf0 = t.Menge
FROM #TmpOpSetBedarf596 x, #TmpAnfArti596 t
WHERE t.ID = x.ID;

SELECT SetArtNr AS ArtikelNr, SetBez AS Bezeichnung, Bedarf0 AS Anforderung
FROM #TmpOpSetBedarf596 WHERE Bedarf0 > 0

UNION ALL

SELECT '999999999999' AS ArtikelNr, 'Gesamt:' AS Bezeichnung, SUM(Bedarf0) AS Anforderung
FROM #TmpOpSetBedarf596
ORDER BY ArtikelNr;
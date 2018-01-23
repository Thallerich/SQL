DROP TABLE IF EXISTS #TmpInhaltsartikel;
DROP TABLE IF EXISTS #TmpAnfArti596a;

-- ######################## OpSetArtikel ###############################
SELECT Artikel.ID AS IArtikelID, Artikel.ArtikelNr AS [Inhalts-ArtikelNr], Artikel.ArtikelBez$LAN$ AS [Inhalts-Artikelbezeichnung], 0 AS Bedarf0
INTO #TmpInhaltsartikel
FROM OPSets
JOIN Artikel ON OPSets.Artikel1ID = Artikel.ID
JOIN Artikel AS SetArtikel ON OPSets.ArtikelID = SetArtikel.ID
JOIN Bereich ON SetArtikel.BereichID = Bereich.ID
JOIN ArtGru ON SetArtikel.ArtGruID = ArtGru.ID
WHERE SetArtikel.Status = 'A'
  AND Bereich.IstOP = 1
  AND ArtGru.Steril = 1
GROUP BY Artikel.ID, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, SetArtikel.Packmenge, ArtGru.Steril;

-- ###################### Angeforderte Mengen je Artikel ##############
SELECT Artikel.ID AS ArtikelID, SUM(CEILING(AnfPo.Angefordert / IIF(Artikel.Packmenge = 0, 1, Artikel.Packmenge))) AS Menge
INTO #TmpAnfArti596a
FROM AnfPo
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN KdArti ON AnfPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE AnfKo.LieferDatum = $1$
  AND AnfKo.ProduktionID IN ($2$)
  AND AnfPo.NachholAnfPoID = -1
GROUP BY Artikel.ID;

-- #################### Anforderungen in OpSetArtikel eintragen ########
UPDATE Inhaltsartikel SET Bedarf0 = x.IAnfMenge
FROM #TmpInhaltsartikel AS Inhaltsartikel
JOIN (
  SELECT OPSets.Artikel1ID AS IArtikelID, SUM(Anf.Menge * OPSets.Menge) AS IAnfMenge
  FROM #TmpAnfArti596a AS Anf
  JOIN OPSets ON OPSets.ArtikelID = Anf.ArtikelID
  GROUP BY OPSets.Artikel1ID
) AS x ON x.IArtikelID = Inhaltsartikel.IArtikelID;


SELECT [Inhalts-ArtikelNr], [Inhalts-Artikelbezeichnung], Bedarf0 AS Angefordert
FROM #TmpInhaltsartikel 
WHERE Bedarf0 > 0

UNION

SELECT '999999999999' AS [Inhalts-ArtikelNr], 'Gesamt:' AS [Inhalts-Artikelbezeichnung], SUM(Bedarf0) AS Angefordert
FROM #TmpInhaltsartikel
ORDER BY [Inhalts-ArtikelNr];
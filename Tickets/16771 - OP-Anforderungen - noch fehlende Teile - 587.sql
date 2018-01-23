TRY
	DROP TABLE #TmpOpSetBedarf;
	DROP TABLE #TmpAnfArti;
	DROP TABLE #TmpSetGepackt;
	DROP TABLE #TmpOpTeileBedarf;
	DROP TABLE #TmpOpTeileQKAktuell;
	DROP TABLE #TmpOpTeileQK;
CATCH ALL END;

-- ######################## OpSetArtikel #################################
SELECT Artikel.ID, Artikel.ArtikelNr SetArtNr, Langbez.Bez SetBez, 0 Bedarf0, 0 AnzGepackt, Artikel.Packmenge, ArtGru.Steril
INTO #TmpOpSetBedarf 
FROM Artikel, LangBez, Bereich, ArtGru, OpSets
WHERE OpSets.ArtikelID = Artikel.ID
/*Artikel.ID IN (
	SELECT DISTINCT ArtikelID 
	FROM OpSets
) */
AND Artikel.ID = Langbez.TableID 
AND Langbez.TableName = 'ARTIKEL' 
AND Langbez.LanguageID = -1 
AND artikel.Status = 'A' 
AND Artikel.BereichID = Bereich.ID 
AND Bereich.IstOP = True 
AND ArtGru.ID = Artikel.ArtGruID 
GROUP BY 1, 2, 3, 6, 7
ORDER BY SetArtNr;

-- ###################### Angeforderte Mengen je Artikel ###############################
SELECT Artikel.ID, SUM(CEILING(AnfPo.Angefordert / IIF(Artikel.Packmenge = 0, 1, Artikel.Packmenge)) - CEILING(AnfPo.Geliefert / IIF(Artikel.Packmenge = 0, 1, Artikel.Packmenge))) AS Menge 
INTO #TmpAnfArti
FROM AnfKo, AnfPo, KdArti, Artikel 
WHERE AnfKo.ID IN (
	SELECT ID
	FROM AnfKo
	WHERE LieferDatum = $1$ -- CURDATE()+1
	AND Status < 'S'
) 
AND AnfPo.NachholAnfPoID = -1 
AND AnfKo.ID = AnfPo.AnfKoID 
AND KdArti.ID = AnfPo.KdArtiID 
AND Artikel.ID = KdArti.ArtikelID 
GROUP BY Artikel.ID;

-- #################### Anforderungen in OpSetArtikel eintragen ####################################
UPDATE x SET Bedarf0 = t.Menge 
FROM #TmpOpSetBedarf x, #TmpAnfArti t 
WHERE t.ID = x.ID;

-- ################### Bereits gepackte Sets #######################################################
SELECT ArtikelID, COUNT(ID) AS Menge 
INTO #TmpSetGepackt 
FROM OpEtiKo 
WHERE Status BETWEEN 'J' AND 'N'
AND VerfallDatum > CURDATE()
GROUP BY ArtikelID;

-- ################### Gepackte Sets in OpSetArtikel eintragen #####################################
UPDATE x SET AnzGepackt = t.Menge
FROM #TmpOpSetBedarf x, #TmpSetGepackt t
WHERE t.ArtikelID = x.ID;

-- ################### Anzahl OpTeile qualitätskontrolliert bereit zum Packen #######################
SELECT OpTeile.ID, OpTeile.ArtikelID, MAX(OpScans.Zeitpunkt) AS LastScan
INTO #TmpOpTeileQKAktuell
FROM OpTeile, OpScans
WHERE OpScans.OpTeileID = OpTeile.ID 
  AND OpTeile.Status = 'D'
  AND OpTeile.ZielNrID = 10000009
GROUP BY 1, 2;

SELECT x.ArtikelID, COUNT(x.ID) AS Menge
INTO #TmpOpTeileQK
FROM #TmpOpTeileQKAktuell x
WHERE TIMESTAMPDIFF(SQL_TSI_DAY, x.LastScan, CURDATE()) < 2
GROUP BY x.ArtikelID;

-- ################### OpSetArtikel auf Inhaltsartikel aufbrechen ###################################
SELECT Artikel.ID, Artikel.ArtikelNr, Langbez.Bez, SUM(x.Bedarf0 * OpSets.Menge) AS Bedarf, 0 AS QK, SUM(x.AnzGepackt * OpSets.Menge) AS gepackt, x.Steril
INTO #TmpOpTeileBedarf
FROM Artikel, Langbez, OpSets, #TmpOpSetBedarf x
WHERE OpSets.ArtikelID = x.ID
	AND OpSets.Artikel1ID = Artikel.ID
	AND Langbez.TableID = Artikel.ID
	AND Langbez.TableName = 'ARTIKEL'
	AND Langbez.LanguageID = $LANGUAGE$
	AND OpSets.Modus = 2
GROUP BY Artikel.ID, Artikel.ArtikelNr, Langbez.Bez, x.Steril;

-- ################### OpSetArtikel - QK einfügen ##################################################

UPDATE x SET x.QK = y.Menge
FROM #TmpOpTeileBedarf x, #TmpOpTeileQK y
WHERE x.ID = y.ArtikelID
	AND x.Steril = TRUE;

-- ################### OpTeile noch zu waschen / noch zu packen berechnen ##########################

SELECT x.ArtikelNr, x.Bez AS ArtikelBez, x.Steril, x.Bedarf, x.QK, x.gepackt, IIF(x.Bedarf - x.gepackt > 0, x.Bedarf - x.gepackt, 0) AS Packen, IIF(x.Bedarf - x.QK - x.gepackt > 0, x.Bedarf - x.QK - x.gepackt, 0) AS Waschen
FROM #TmpOpTeileBedarf x
WHERE x.Bedarf > 0
ORDER BY Waschen DESC;
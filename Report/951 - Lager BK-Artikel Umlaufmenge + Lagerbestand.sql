DROP TABLE IF EXISTS #TmpResult951951;

SELECT Artikel.ArtikelNr, Status.Bez AS Artikelstatus, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ProdGru.ProdGruBez$LAN$ AS Sortiment, ArtGroe.Groesse, GroePo.Folge, 0 AS Umlaufmenge, 0 AS [Bestand Neuware], 0 AS [Bestand Gebraucht], ArtGroe.ID AS ArtGroeID
INTO #TmpResult951
FROM ArtGroe, Artikel, Bereich, ProdGru, GroePo, GroeKo, (SELECT Status.Status, Status.StatusBez$LAN$ AS Bez FROM Status WHERE Status.Tabelle = 'ARTIKEL') AS Status
WHERE ArtGroe.ArtikelID = Artikel.ID
  AND Artikel.BereichID = Bereich.ID
  AND Artikel.Status = Status.Status
  AND Artikel.ProdGruID = ProdGru.ID
  AND ArtGroe.Groesse = GroePo.Groesse
  AND GroePo.GroeKoID = GroeKo.ID
  AND Artikel.GroeKoID = GroeKo.ID
  AND ArtGroe.ArtikelID > 0;

UPDATE R SET Umlaufmenge = x.Umlaufmenge
FROM #TmpResult951 AS R, (
  SELECT Bestand.ArtGroeID, SUM(Bestand.Umlauf) AS Umlaufmenge
  FROM Bestand, LagerArt
  WHERE Bestand.LagerArtID = LagerArt.ID
    AND LagerArt.LagerID IN ($1$)
  GROUP BY Bestand.ArtGroeID
) AS x
WHERE x.ArtGroeID = R.ArtGroeID;

UPDATE R SET [Bestand Neuware] = x.Bestand
FROM #TmpResult951 AS R, (
  SELECT Bestand.ArtGroeID, SUM(Bestand.Bestand) AS Bestand
  FROM Bestand, LagerArt
  WHERE Bestand.LagerArtID = LagerArt.ID
    AND LagerArt.LagerID IN ($1$)
    AND LagerArt.Neuwertig = 1
  GROUP BY Bestand.ArtGroeID
) AS x
WHERE x.ArtGroeID = R.ArtGroeID;

UPDATE R SET [Bestand Gebraucht] = x.Bestand
FROM #TmpResult951 AS R, (
  SELECT Bestand.ArtGroeID, SUM(Bestand.Bestand) AS Bestand
  FROM Bestand, LagerArt
  WHERE Bestand.LagerArtID = LagerArt.ID
    AND LagerArt.LagerID IN ($1$)
    AND LagerArt.Neuwertig = 0
  GROUP BY Bestand.ArtGroeID
) AS x
WHERE x.ArtGroeID = R.ArtGroeID;

SELECT ArtikelNr, Artikelstatus, Artikelbezeichnung, Sortiment, Groesse, Umlaufmenge, [Bestand Neuware], [Bestand Gebraucht]
FROM #TmpResult951
WHERE (($2$ = 0) OR ($2$ = 1 AND ([Bestand Neuware] != 0 OR [Bestand Gebraucht] != 0 OR Umlaufmenge != 0)))
ORDER BY ArtikelNr, Folge;
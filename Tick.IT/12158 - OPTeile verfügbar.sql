TRY
  DROP TABLE #OpBedarf;
  DROP TABLE #AnfArti;
CATCH ALL END;

SELECT Artikel.ID AS ArtikelIDInhalt, OPSets.ArtikelID AS ArtikelIDSet, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, OPSets.Menge AS MengeInhaltjeSet, 0 AS Bedarf, 0 AS InhaltBenoetigt, 0 AS InhaltVerfuegbar
INTO #OpBedarf 
FROM Artikel, Bereich, ArtGru, OPSets
WHERE OpSets.Artikel1ID = Artikel.ID
  AND ArtGru.ID = Artikel.ArtGruID 
  AND OPSets.ArtikelID IN (
    SELECT Artikel.ID 
    FROM Artikel, ArtGru, Bereich 
    WHERE Artikel.ArtGruID = ArtGru.ID 
      AND Artikel.BereichID = Bereich.ID
      AND ArtGru.Steril = $TRUE$
      AND Bereich.IstOP = $TRUE$
  )
  AND NOT EXISTS (
    SELECT OPSets.*
    FROM OPSets
    WHERE OPSets.ArtikelID = Artikel.ID
  )
  AND OPSets.Modus = 2
  AND ArtGru.Barcodiert = $TRUE$
GROUP BY ArtikelIDInhalt, ArtikelIDSet, Artikel.ArtikelNr, Artikelbezeichnung, OPSets.Menge;

SELECT Artikel.ID AS ArtikelID, SUM(CEILING(AnfPo.Angefordert / Artikel.Packmenge)) AS Menge
INTO #AnfArti
FROM AnfKo, AnfPo, KdArti, Artikel 
WHERE AnfKo.ID = AnfPo.AnfKoID 
  AND KdArti.ID = AnfPo.KdArtiID 
  AND Artikel.ID = KdArti.ArtikelID 
  AND AnfKo.LieferDatum = CURDATE() -- $1$
  AND AnfKo.ProduktionID IN (2) --($2$)
  AND AnfPo.NachholAnfPoID < 0
GROUP BY Artikel.ID;

UPDATE x SET x.Bedarf = t.Menge, x.InhaltBenoetigt = t.Menge * x.MengeInhaltjeSet
FROM #OpBedarf x, #AnfArti t 
WHERE t.ArtikelID = x.ArtikelIDSet;

UPDATE OPBedarf SET InhaltVerfuegbar = x.Verfuegbar
FROM #OPBedarf OPBedarf, (
  SELECT OPTeile.ArtikelID, COUNT(DISTINCT OPTeile.Code) AS Verfuegbar
  FROM OPTeile
  WHERE OPTeile.ArtikelID IN (SELECT ArtikelIDInhalt FROM #OPBedarf)
    AND OPTeile.Status < 'J'
  GROUP BY OPTeile.ArtikelID
) x
WHERE OPBedarf.ArtikelIDInhalt = x.ArtikelID;

SELECT OPBedarf.ArtikelNr, OPBedarf.Artikelbezeichnung, SUM(OPBedarf.InhaltBenoetigt) AS Benötigt, OPBedarf.InhaltVerfuegbar AS Verfügbar
FROM #OPBedarf OPBedarf
WHERE OPBedarf.InhaltBenoetigt > 0
GROUP BY OPBedarf.ArtikelNr, OPBedarf.Artikelbezeichnung, Verfügbar
ORDER BY OPBedarf.ArtikelNr;
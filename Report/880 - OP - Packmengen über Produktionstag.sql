WITH OPPos AS (
  SELECT DISTINCT OPEtiPo.OPEtiKoID, OPEtiPo.OPSetsID
  FROM OPEtiPo
)
SELECT CAST(OPEtiKo.PackZeitpunkt AS date) AS Produktionsdatum, SetArtikel.ArtikelNr AS [Set-ArtikelNr], SetArtikel.ArtikelBez$LAN$ AS [Set-Artikelbezeichnung], COUNT(DISTINCT OPEtiKo.ID) AS [Set-Anzahl], SetArtikel.StueckGewicht AS [Gewicht je Set], InhaltArtikel.ArtikelNr AS [Inhalt-ArtikelNr], InhaltArtikel.ArtikelBez$LAN$ AS [Inhalt-Artikelbezeichnung], SUM(OPSets.Menge) AS [Inhalt-Anzahl], InhaltArtikel.StueckGewicht AS [Gewicht je Stück]
FROM OPPos
JOIN OPEtiKo ON OPPos.OPEtiKoID = OPEtiKo.ID
JOIN Artikel AS SetArtikel ON OPEtiKo.ArtikelID = SetArtikel.ID
JOIN OPSets ON OPPos.OPSetsID = OPSets.ID
JOIN Artikel AS InhaltArtikel ON OPSets.Artikel1ID = InhaltArtikel.ID
WHERE OPEtiKo.PackZeitpunkt BETWEEN $STARTDATE$ AND $ENDDATE$
  AND OPEtiKo.ProduktionID IN ($1$)
GROUP BY CAST(OPEtiKo.PackZeitpunkt AS date), SetArtikel.ArtikelNr, SetArtikel.ArtikelBez$LAN$, SetArtikel.StueckGewicht, InhaltArtikel.ArtikelNr, InhaltArtikel.ArtikelBez$LAN$, InhaltArtikel.StueckGewicht
ORDER BY Produktionsdatum, [Set-ArtikelNr], [Inhalt-ArtikelNr];
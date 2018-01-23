TRY
  DROP TABLE #Ergebnis;
CATCH ALL END;

SELECT KdGf.KurzBez AS SGF, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGru.Steril, SUM(IIF(TIMESTAMPDIFF(SQL_TSI_DAY, IFNULL(OPEtiKo.AusleseZeitpunkt, CONVERT('01.01.1980 00:00:00', SQL_TIMESTAMP)), NOW()) <= 180, 1, 0)) AS [Ist <= 180 Tage], SUM(IIF(TIMESTAMPDIFF(SQL_TSI_DAY, IFNULL(OPEtiKo.AusleseZeitpunkt, CONVERT('01.01.1980 00:00:00', SQL_TIMESTAMP)), NOW()) > 180, 1, 0)) AS [Ist > 180 Tage], 0 AS Durchschnitt, 0 AS Liefertage, Vsa.ID AS VsaID, Artikel.ID AS ArtikelID
INTO #Ergebnis
FROM OPEtiKo, Vsa, Kunden, Artikel, Bereich, ArtGru, KdGf
WHERE OPEtiKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND OPEtiKo.ArtikelID = Artikel.ID
  AND Artikel.BereichID = Bereich.ID
  AND Artikel.ArtGruID = ArtGru.ID
  AND Kunden.KdGfID = KdGf.ID
  AND Bereich.Bereich = 'OP'
  AND OPEtiKo.Status = 'R'
  AND Kunden.ID > 0
  AND NOT EXISTS (
    SELECT OPTeile.*
    FROM OPTeile
    WHERE OPTeile.Code = OPEtiKo.EtiNr
  )
GROUP BY SGF, Kunden.KdNr, Kunde, VsaNr, Vsa, Artikel.ArtikelNr, Artikelbezeichnung, ArtGru.Steril, VsaID, ArtikelID;

UPDATE Ergebnis SET Ergebnis.Durchschnitt = VsaAnf.Durchschnitt
FROM #Ergebnis AS Ergebnis, VsaAnf, KdArti
WHERE Ergebnis.VsaID = VsaAnf.VsaID
  AND VsaAnf.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Ergebnis.ArtikelID;
  
UPDATE Ergebnis SET Ergebnis.Liefertage = x.Liefertage
FROM #Ergebnis AS Ergebnis, (
  SELECT VsaTour.VsaID, COUNT(DISTINCT Touren.Wochentag) AS Liefertage
  FROM VsaTour, KdBer, Bereich, Touren
  WHERE VsaTour.KdBerID = KdBer.ID
    AND KdBer.BereichID = Bereich.ID
    AND VsaTour.TourenID = Touren.ID
    AND Bereich.Bereich = 'OP'
  GROUP BY VsaTour.VsaID
) AS x
WHERE x.VsaID = Ergebnis.VsaID;

SELECT Ergebnis.SGF, Ergebnis.KdNr, Ergebnis.Kunde, Ergebnis.VsaNr, Ergebnis.Vsa, Ergebnis.ArtikelNr, Ergebnis.Artikelbezeichnung, Ergebnis.Steril, Ergebnis.[Ist <= 180 Tage], Ergebnis.[Ist > 180 Tage], Ergebnis.Durchschnitt, Ergebnis.Liefertage
FROM #Ergebnis AS Ergebnis
ORDER BY Ergebnis.KdNr, Ergebnis.VsaNr, Ergebnis.ArtikelNr;

SELECT Ergebnis.SGF, Ergebnis.KdNr, Ergebnis.Kunde, Ergebnis.VsaNr, Ergebnis.Vsa, Ergebnis.ArtikelNr, Ergebnis.Artikelbezeichnung, Ergebnis.Steril, Ergebnis.[Ist <= 180 Tage], Ergebnis.[Ist > 180 Tage], Ergebnis.Durchschnitt, Ergebnis.Liefertage, ROUND(CONVERT(Ergebnis.[Ist <= 180 Tage], SQL_FLOAT) / CONVERT(IIF(Ergebnis.Durchschnitt = 0, 1, Ergebnis.Durchschnitt), SQL_FLOAT), 2) AS Verhältnis, OPSets.Position AS [Set-Packfolge], Artikel.ArtikelNr AS InhaltArtikelNr, Artikel.ArtikelBez$LAN$ AS InhaltArtikelbezeichnung, OPSets.Menge AS MengeJeSet, OPSets.Menge * Ergebnis.[Ist <= 180 Tage] AS MengeGesamt
FROM #Ergebnis AS Ergebnis, OPSets, Artikel
WHERE OPSets.ArtikelID = Ergebnis.ArtikelID
  AND OPSets.Artikel1ID = Artikel.ID
  AND CONVERT(Ergebnis.[Ist <= 180 Tage], SQL_FLOAT) / CONVERT(IIF(Ergebnis.Durchschnitt = 0, 1, Ergebnis.Durchschnitt), SQL_FLOAT) > 5
  AND Artikel.ArtikelNr <> '129899999999'
ORDER BY Ergebnis.KdNr, Ergebnis.VsaNr, Ergebnis.ArtikelNr, [Set-Packfolge];
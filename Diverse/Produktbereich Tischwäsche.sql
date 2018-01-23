-- Tischwäsche ID = 2698
UPDATE Artikel SET Artikel.BereichID = 2698
FROM Artikel, ProdHier
WHERE Artikel.ProdHierID = ProdHier.ID
	AND ProdHier.Hierarchie LIKE ('TIWÄ %');
  
-- Eigenwäsche Tischwäsche ID = 2699
UPDATE Artikel SET Artikel.BereichID = 2699
FROM Artikel, ProdHier
WHERE Artikel.ProdHierID = ProdHier.ID
	AND ProdHier.Hierarchie = 'EWZI ewtw';

-- Kundenartikel Kundenbereich Tischwäsche
UPDATE KdArti SET KdArti.KdBerID = KdBer.ID
FROM Kunden, KdArti, KdBer, (
	SELECT KdArti.ID, KdArti.ArtikelID, KdArti.KdBerID AS OldKdBer, Bereich.Bereich
	FROM KdArti, Artikel, KdBer, Bereich
	WHERE KdArti.ArtikelID = Artikel.ID
		AND KdArti.KdBerID = KdBer.ID
		AND KdBer.BereichID = Bereich.ID
		AND Artikel.BereichID = 2698
) KdArtiChange
WHERE KdArti.ID = KdArtiChange.ID
	AND KdArti.KundenID = Kunden.ID
	AND KdBer.KundenID = Kunden.ID
	AND KdBer.BereichID = 2698
	AND KdArti.KdBerID <> KdBer.ID;

-- Kundenartikel Kundenbereich Eigenwäsche Tischwäsche
UPDATE KdArti SET KdArti.KdBerID = KdBer.ID
FROM Kunden, KdArti, KdBer, (
	SELECT KdArti.ID, KdArti.ArtikelID, KdArti.KdBerID AS OldKdBer, Bereich.Bereich
	FROM KdArti, Artikel, KdBer, Bereich
	WHERE KdArti.ArtikelID = Artikel.ID
		AND KdArti.KdBerID = KdBer.ID
		AND KdBer.BereichID = Bereich.ID
		AND Artikel.BereichID = 2699
) KdArtiChange
WHERE KdArti.ID = KdArtiChange.ID
	AND KdArti.KundenID = Kunden.ID
	AND KdBer.KundenID = Kunden.ID
	AND KdBer.BereichID = 2699
	AND KdArti.KdBerID <> KdBer.ID;




-- Kunden ohne Produktbereich Tischwäsche
SELECT IIF(ProdHier.Hierarchie LIKE 'TIWÄ %', 'Tischwäsche', 'Eigenwäsche Tischwäsche') AS Produktbereich, Kunden.KdNr, Kunden.SuchCode, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Firma.Bez
FROM Kunden, Vsa, VsaAnf, KdArti, Artikel, ProdHier, Firma
WHERE VsaAnf.KdArtiID = KdArti.ID
	AND KdArti.ArtikelID = Artikel.ID
	AND Artikel.ProdHierID = ProdHier.ID
	AND VsaAnf.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND Kunden.FirmaID = Firma.ID
	AND ProdHier.Hierarchie LIKE 'TIWÄ %'
	AND Kunden.ID NOT IN (
		SELECT Kunden.ID
		FROM Kunden, KdBer
		WHERE KdBer.KundenID = Kunden.ID
			AND KdBer.BereichID = 2698) 
	AND Kunden.Status = 'A'
	AND Vsa.Status = 'A'
GROUP BY 1,2,3,4,5,6
ORDER BY Produktbereich, Firma.Bez, Kunden.KdNr, Vsa.SuchCode;

-- Kunden ohne Produktbereich Eigenwäsche Tischwäsche
SELECT IIF(ProdHier.Hierarchie = 'TIWÄ %', 'Tischwäsche', 'Eigenwäsche Tischwäsche') AS Produktbereich, Kunden.KdNr, Kunden.SuchCode, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Firma.Bez
FROM Kunden, Vsa, VsaAnf, KdArti, Artikel, ProdHier, Firma
WHERE VsaAnf.KdArtiID = KdArti.ID
	AND KdArti.ArtikelID = Artikel.ID
	AND Artikel.ProdHierID = ProdHier.ID
	AND VsaAnf.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND Kunden.FirmaID = Firma.ID
	AND ProdHier.Hierarchie = 'EWZI ewtw'
	AND Kunden.ID NOT IN (
		SELECT Kunden.ID
		FROM Kunden, KdBer
		WHERE KdBer.KundenID = Kunden.ID
			AND KdBer.BereichID = 2699) 
	AND Kunden.Status = 'A'
	AND Vsa.Status = 'A'
GROUP BY 1,2,3,4,5,6
ORDER BY Produktbereich, Firma.Bez, Kunden.KdNr, Vsa.SuchCode;
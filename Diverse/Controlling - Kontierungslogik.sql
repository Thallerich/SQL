SELECT DISTINCT Bereich.BereichBez AS Produktbereich, ArtGru.ArtGruBez AS Artikelgruppe, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Firma.Bez AS Firma, Konten.Konto, RPoKonto.AbwKostenstelle AS Kostenträger, KdGf.KurzBez AS Geschäftsbereich, MwSt.Bez AS Mehrwertsteuersatz
FROM Artikel
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
LEFT OUTER JOIN RPoKonto ON RPoKonto.BereichID = Bereich.ID AND (RPoKonto.ArtGruID = ArtGru.ID OR (RPoKonto.ArtGruID = -1 AND RPoKonto.BrancheID = -1))
JOIN Firma ON RPoKonto.FirmaID = Firma.ID
JOIN Konten ON RPoKonto.KontenID = Konten.ID
JOIN KdGf ON RPoKonto.KdGfID = KdGf.ID
JOIN MwSt ON RPoKonto.MWStID = MwSt.ID
WHERE Artikel.ID > 0
  AND Artikel.ArtiTypeID = 1
  AND Firma.SuchCode = N'WOMI';
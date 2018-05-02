USE Wozabal;
GO

SELECT Standort.SuchCode AS Produktionsstandort, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Bereich.BereichBez AS Produktbereich, FaltProg.Programm AS Faltprogramm, FaltProg.Bez AS [Faltprogramm-Bezeichnung]
FROM ArtiStan
JOIN FaltProg ON ArtiStan.FaltProgID = FaltProg.ID
JOIN Artikel ON ArtiStan.ArtikelID = Artikel.ID
JOIN Standort ON ArtiStan.StandortID = Standort.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
WHERE ArtiStan.ID > 0
  AND ArtiStan.ArtikelID > 0
  AND ArtiStan.StandortID IN (2, 4535)
  AND Bereich.Bereich IN (N'BK', N'BW')
  AND Artikel.ArtiTypeID = 1
ORDER BY Produktionsstandort, Produktbereich, ArtikelNr;

GO
SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, SortDest.SortDestBez AS Sortierziel, Prozess.ProzessBez$LAN$ AS Bearbeitungsprozess
FROM Prozess, ArtiStan, Artikel, SortSchP, SortDest
WHERE SortSchP.ArtikelID = Artikel.ID 
AND SortSchP.SortSchKID = 8 -- nur allgemeine Schablone
AND SortSchP.SortDestID = SortDest.ID
AND ArtiStan.ArtikelID = Artikel.ID
AND ArtiStan.BearbProzessID = Prozess.ID
AND ArtiStan.StandortID = 5005; -- Produktion GP Enns 
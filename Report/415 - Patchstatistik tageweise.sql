-- AusBestellung:
SELECT Teile.Patchdatum, COUNT(Teile.Barcode) AS ausBestellung
FROM Teile, Artikel, LagerArt
WHERE Teile.Patchdatum BETWEEN $1$ AND $2$
  AND Artikel.BereichID IN (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich IN (N'BK', N'FW'))
  AND Teile.ArtikelID = Artikel.ID
  AND Teile.LagerartID = Lagerart.ID
  AND LagerArt.LagerArt = N'Z'
GROUP BY Teile.Patchdatum;

--gebraucht:
SELECT Teile.Patchdatum, COUNT(Teile.Barcode) AS gebraucht
FROM Teile, Artikel, LagerArt
WHERE Teile.Patchdatum BETWEEN $1$ AND $2$
  AND Artikel.BereichID IN (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich IN (N'BK', N'FW'))
  AND Teile.ArtikelID = Artikel.ID
  AND Teile.LagerartID = Lagerart.ID
  AND Lagerart.LagerArt IN (N'A', N'R')
GROUP by Teile.Patchdatum;

--neu:
SELECT Teile.Patchdatum, COUNT(Teile.Barcode) AS neu
FROM Teile, Artikel, LagerArt
WHERE Teile.Patchdatum BETWEEN $1$ AND $2$
  AND Artikel.BereichID IN (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich IN (N'BK', N'FW'))
  AND Teile.ArtikelID = Artikel.ID
  AND Teile.LagerartID = Lagerart.ID
  AND Lagerart.LagerArt IN (N'N', N'Z')
GROUP by Teile.Patchdatum;
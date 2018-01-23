-- AusBestellung:
SELECT Teile.Patchdatum, COUNT(Teile.Barcode) AS ausBestellung
FROM Teile, Artikel, LagerArt
WHERE Teile.Patchdatum BETWEEN $1$ AND $2$
  AND Artikel.BereichID IN (100, 102)
  AND Teile.ArtikelID = Artikel.ID
  AND Teile.LagerartID = Lagerart.ID
  AND LagerArt.ID = 1006
GROUP BY Teile.Patchdatum;

--gebraucht:
SELECT Teile.Patchdatum, COUNT(Teile.Barcode) AS gebraucht
FROM Teile, Artikel, LagerArt
WHERE Teile.Patchdatum BETWEEN $1$ AND $2$
  AND Artikel.BereichID IN (100, 102)
  AND Teile.ArtikelID = Artikel.ID
  AND Teile.LagerartID = Lagerart.ID
  AND Lagerart.ID IN (2, 1008)
  AND LagerArt.ID <> -1
GROUP by Teile.Patchdatum;

--neu:
SELECT Teile.Patchdatum, COUNT(Teile.Barcode) AS neu
FROM Teile, Artikel, LagerArt
WHERE Teile.Patchdatum BETWEEN $1$ AND $2$
  AND Artikel.BereichID IN (100, 102)
  AND Teile.ArtikelID = Artikel.ID
  AND Teile.LagerartID = Lagerart.ID
  AND Lagerart.ID IN (1, 1006)
GROUP by Teile.Patchdatum;
SELECT OPTeile.ID, OPTeile.Status, OPTeile.Code, Teile.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, OPTeile.ArtGroeID, Teile.ArtGroeID AS TArtGroeID, OPTeile.LastScanTime, OPTeile.LastScanToKunde, ZielNr.ZielNrBez AS [letzter Ort]
FROM OPTeile
JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
JOIN ZielNr ON OPTeile.ZielNrID = ZielNr.ID
LEFT OUTER JOIN Teile ON OPTeile.Code = Teile.Barcode
LEFT OUTER JOIN ArtGroe ON Teile.ArtGroeID = ArtGroe.ID
WHERE Artikel.ArtikelNr = N'203030104004'
  AND Teile.ID IS NOT NULL
ORDER BY OPTeile.LastScanTime DESC;

UPDATE OPTeile SET OPTeile.ArtGroeID = x.TArtGroeID
FROM OPTeile
JOIN (
  SELECT OPTeile.ID, OPTeile.Status, OPTeile.Code, Teile.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, OPTeile.ArtGroeID, Teile.ArtGroeID AS TArtGroeID, OPTeile.LastScanTime, OPTeile.LastScanToKunde, ZielNr.ZielNrBez AS [letzter Ort]
  FROM OPTeile
  JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
  JOIN ZielNr ON OPTeile.ZielNrID = ZielNr.ID
  LEFT OUTER JOIN Teile ON OPTeile.Code = Teile.Barcode
  LEFT OUTER JOIN ArtGroe ON Teile.ArtGroeID = ArtGroe.ID
  WHERE Artikel.ArtikelNr = N'203030104004'
    AND Teile.ID IS NOT NULL
) AS x ON x.ID = OPTeile.ID;

UPDATE OPTeile SET OPTeile.ArtGroeID = 10297327
WHERE OPTeile.ArtikelID = (SELECT Artikel.ID FROM Artikel WHERE Artikel.ArtikelNr = N'203030104004')
  AND OPTeile.ArtGroeID = -1;

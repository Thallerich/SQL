SELECT OPTeile.ID, OPTeile.Status, OPTeile.Code, Teile.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, OPTeile.ArtGroeID, Teile.ArtGroeID AS TArtGroeID, OPTeile.LastScanTime, OPTeile.LastScanToKunde, ZielNr.ZielNrBez AS [letzter Ort], OPTeile.Anlage_
FROM OPTeile
JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
JOIN ZielNr ON OPTeile.ZielNrID = ZielNr.ID
LEFT OUTER JOIN Teile ON OPTeile.Code = Teile.Barcode AND Teile.ArtikelID = OPTeile.ArtikelID
LEFT OUTER JOIN ArtGroe ON Teile.ArtGroeID = ArtGroe.ID
WHERE Artikel.ArtikelNr = N'203258100201'
  AND OPTeile.ArtGroeID < 0
ORDER BY OPTeile.LastScanTime DESC;

UPDATE OPTeile SET OPTeile.ArtGroeID = x.TArtGroeID
FROM OPTeile
JOIN (
  SELECT OPTeile.ID, OPTeile.Status, OPTeile.Code, Teile.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, OPTeile.ArtGroeID, Teile.ArtGroeID AS TArtGroeID, OPTeile.LastScanTime, OPTeile.LastScanToKunde, ZielNr.ZielNrBez AS [letzter Ort], OPTeile.Anlage_
  FROM OPTeile
  JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
  JOIN ZielNr ON OPTeile.ZielNrID = ZielNr.ID
  LEFT OUTER JOIN Teile ON OPTeile.Code = Teile.Barcode AND Teile.ArtikelID = OPTeile.ArtikelID
  LEFT OUTER JOIN ArtGroe ON Teile.ArtGroeID = ArtGroe.ID
  WHERE Artikel.ArtikelNr = N'203258100201'
    AND OPTeile.ArtGroeID < 0
    AND Teile.ID IS NOT NULL
) AS x ON x.ID = OPTeile.ID;

UPDATE OPTeile SET OPTeile.ArtGroeID = 10297420
WHERE OPTeile.ArtikelID = (SELECT Artikel.ID FROM Artikel WHERE Artikel.ArtikelNr = N'203258100201')
  AND OPTeile.ArtGroeID = -1;

SELECT OPTeile.ID, OPTeile.Code, Teile.Barcode, OPTeile.ArtGroeID, Teile.ArtGroeID, OPTeile.ArtikelID, Teile.ArtikelID
FROM OPTeile
LEFT OUTER JOIN Teile ON Teile.OPTeileID = OPTeile.ID
WHERE OPTeile.ArtikelID = (SELECT Artikel.ID FROM Artikel WHERE Artikel.ArtikelNr = N'203258100201')
  AND (Teile.ArtGroeID <> OPTeile.ArtGroeID OR OPTeile.ArtGroeID < 0)
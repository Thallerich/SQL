SELECT ArtikelNr, Artikelbezeichnung, SUM(Menge) AS Menge, SUM(AnzDirekt) AS [Menge direkt eingesetzt]
FROM (
  SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, BPo.Menge, AnzDirekt = (
      SELECT COUNT(Teile.ID)
      FROM Teile
      WHERE Teile.BPoID = Bpo.ID
    )
  FROM BPo, ArtGroe, Artikel
  WHERE BPo.BKoID IN (
      SELECT BKo.ID
      FROM BKo
      WHERE BKo.LagerartID IN (
            SELECT ID
            FROM Lagerart
            WHERE LagerID IN ($2$)
          )
        AND BKo.Datum BETWEEN $STARTDATE$ AND $ENDDATE$
        AND BKo.LiefID = $3$
      )
    AND BPo.ArtGroeID = ArtGroe.ID
    AND Artikel.ID = ArtGroe.ArtikelID
  ) Daten
GROUP BY ArtikelNr, Artikelbezeichnung;
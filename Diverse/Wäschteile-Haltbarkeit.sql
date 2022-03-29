SELECT ArtGru.Gruppe,
  ArtGru.ArtGruBez AS Artikelgruppe,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez AS Artikelbezeichnung,
  COUNT(Teile.ID) AS Total,
  [bis 12 Monate] = SUM(IIF(DATEDIFF(month, Teile.ErstDatum, GETDATE()) <= 12, 1, 0)),
  [13-24 Monate] = SUM(IIF(DATEDIFF(month, Teile.ErstDatum, GETDATE()) BETWEEN 13 AND 24, 1, 0)),
  [25-36 Monate] = SUM(IIF(DATEDIFF(month, Teile.ErstDatum, GETDATE()) BETWEEN 25 AND 36, 1, 0)),
  [37-48 Monate] = SUM(IIF(DATEDIFF(month, Teile.ErstDatum, GETDATE()) BETWEEN 37 AND 48, 1, 0)),
  [über 49 Monate] = SUM(IIF(DATEDIFF(month, Teile.ErstDatum, GETDATE()) >= 49, 1, 0))
FROM Teile
JOIN Artikel ON Teile.ArtikelID = Artikel.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
WHERE Teile.ArtikelID IN (
    SELECT Teile.ArtikelID
    FROM Teile
    WHERE Teile.Status = N'Q'
      --AND LEN(Teile.Barcode) = 24
      AND Teile.AltenheimModus = 0
      AND Teile.OPTeileID < 0
    GROUP BY Teile.ArtikelID
    HAVING COUNT(Teile.ID) > 10000
    )
  AND Teile.Status = N'Q'
  AND Teile.OPTeileID < 0
  --AND LEN(Teile.Barcode) = 24
  AND Teile.AltenheimModus = 0
GROUP BY ArtGru.Gruppe, ArtGru.ArtGruBez, Artikel.ArtikelNr, Artikel.ArtikelBez
ORDER BY Total DESC;
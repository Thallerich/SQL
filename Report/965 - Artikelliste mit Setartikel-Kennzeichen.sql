SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Status.StatusBez$LAN$ AS Artikelstatus, Bereich.BereichBez$LAN$ AS Produktbereich, ArtGru.ArtGruBez$LAN$ AS Artikelgruppe, CAST(IIF(OPSets.ID IS NULL, 0, 1) AS bit) AS IstSetartikel
FROM Artikel
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN Status ON Artikel.Status = Status.Status AND Status.Tabelle = N'ARTIKEL'
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
LEFT OUTER JOIN OPSets ON OPSets.ArtikelID = Artikel.ID
WHERE Bereich.ID IN ($1$)
  AND Status.ID IN ($2$)
  AND (($3$ = 1 AND OPSets.ID IS NULL) OR ($3$ = 0))
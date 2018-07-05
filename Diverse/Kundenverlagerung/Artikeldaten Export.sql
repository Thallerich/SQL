SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Bereich.BereichBez AS Produktbereich, ISNULL(ArtGroe.Groesse, N'') AS Groesse, KdArti.WaschPreis AS [Waschpreis Kunde 30578], KdArti.LeasingPreis AS [Leasingpreis Kunde 30578]
FROM KdArti
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
LEFT OUTER JOIN ArtGroe ON ArtGroe.ArtikelID = Artikel.ID
LEFT OUTER JOIN (
  SELECT GroePo.Groesse, GroePo.Folge, GroeKo.ID AS GroeKoID
  FROM GroePo
  JOIN GroeKo ON GroePo.GroeKoID = GroeKo.ID
) AS GroeSys ON GroeSys.GroeKoID = Artikel.GroeKoID AND GroeSys.Groesse = ArtGroe.Groesse
WHERE Kunden.KdNr = 30578
  AND (KdArti.Status = N'A' OR KdArti.Umlauf > 0)
ORDER BY Artikel.ArtikelNr, GroeSys.Folge ASC;
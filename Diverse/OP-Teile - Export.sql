SELECT Code, Code2, ArtikelNr, Artikelbezeichnung, [Status], [Letzte Aktion], Erstwoche, Wäschen, Sterilisationen, [Letzter Scan], [Letzter Scan zum Kunden]
FROM (
  SELECT OPTeile.Code, ISNULL(OPTeile.Code2, '') AS Code2, Artikel.ArtikelNr, Artikel.Artikelbez AS Artikelbezeichnung, [Status].StatusBez AS [Status], Actions.ActionsBez AS [Letzte Aktion], OPTeile.Erstwoche, OPTeile.AnzWasch AS [Wäschen], OPTeile.AnzSteril AS [Sterilisationen], FORMAT(OPTeile.[LastScanTime], 'G', 'de-AT') AS [Letzter Scan], FORMAT(OPTeile.LastScanToKunde, 'G', 'de-AT') AS [Letzter Scan zum Kunden], NTILE(3) OVER (ORDER BY OPTeile.Erstwoche ASC) AS PartNr
  FROM OPTeile
  JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
  JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
  JOIN Bereich ON Artikel.BereichID = Bereich.ID
  JOIN [Status] ON OPTeile.[Status] = [Status].[Status] AND [Status].Tabelle = N'OPTEILE'
  JOIN Actions ON OPTeile.LastActionsID = Actions.ID
  WHERE ArtGru.Barcodiert = 1
    AND ArtGru.SetImSet = 0
    AND Bereich.Bereich = N'OP'
) AS OPData
WHERE PartNr = 1;

SELECT Code, Code2, ArtikelNr, Artikelbezeichnung, [Status], [Letzte Aktion], Erstwoche, Wäschen, Sterilisationen, [Letzter Scan], [Letzter Scan zum Kunden]
FROM (
  SELECT OPTeile.Code, ISNULL(OPTeile.Code2, '') AS Code2, Artikel.ArtikelNr, Artikel.Artikelbez AS Artikelbezeichnung, [Status].StatusBez AS [Status], Actions.ActionsBez AS [Letzte Aktion], OPTeile.Erstwoche, OPTeile.AnzWasch AS [Wäschen], OPTeile.AnzSteril AS [Sterilisationen], FORMAT(OPTeile.[LastScanTime], 'G', 'de-AT') AS [Letzter Scan], FORMAT(OPTeile.LastScanToKunde, 'G', 'de-AT') AS [Letzter Scan zum Kunden], NTILE(3) OVER (ORDER BY OPTeile.Erstwoche ASC) AS PartNr
  FROM OPTeile
  JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
  JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
  JOIN Bereich ON Artikel.BereichID = Bereich.ID
  JOIN [Status] ON OPTeile.[Status] = [Status].[Status] AND [Status].Tabelle = N'OPTEILE'
  JOIN Actions ON OPTeile.LastActionsID = Actions.ID
  WHERE ArtGru.Barcodiert = 1
    AND ArtGru.SetImSet = 0
    AND Bereich.Bereich = N'OP'
) AS OPData
WHERE PartNr = 2;

SELECT Code, Code2, ArtikelNr, Artikelbezeichnung, [Status], [Letzte Aktion], Erstwoche, Wäschen, Sterilisationen, [Letzter Scan], [Letzter Scan zum Kunden]
FROM (
  SELECT OPTeile.Code, ISNULL(OPTeile.Code2, '') AS Code2, Artikel.ArtikelNr, Artikel.Artikelbez AS Artikelbezeichnung, [Status].StatusBez AS [Status], Actions.ActionsBez AS [Letzte Aktion], OPTeile.Erstwoche, OPTeile.AnzWasch AS [Wäschen], OPTeile.AnzSteril AS [Sterilisationen], FORMAT(OPTeile.[LastScanTime], 'G', 'de-AT') AS [Letzter Scan], FORMAT(OPTeile.LastScanToKunde, 'G', 'de-AT') AS [Letzter Scan zum Kunden], NTILE(3) OVER (ORDER BY OPTeile.Erstwoche ASC) AS PartNr
  FROM OPTeile
  JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
  JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
  JOIN Bereich ON Artikel.BereichID = Bereich.ID
  JOIN [Status] ON OPTeile.[Status] = [Status].[Status] AND [Status].Tabelle = N'OPTEILE'
  JOIN Actions ON OPTeile.LastActionsID = Actions.ID
  WHERE ArtGru.Barcodiert = 1
    AND ArtGru.SetImSet = 0
    AND Bereich.Bereich = N'OP'
) AS OPData
WHERE PartNr = 3;
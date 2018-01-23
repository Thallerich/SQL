SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, OpTeile.Status, Status.StatusBez AS Statusbezeichnung, REPLACE(Actions.ActionsBez$LAN$, N'OP ', N'') AS [LetzteAktion], COUNT(OPTeile.Code) AS [AnzahlTeile]
FROM OPTeile
JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
JOIN Status ON OPTeile.Status = Status.Status AND Status.Tabelle = N'OPTEILE'
JOIN Actions ON OPTeile.LastActionsID = Actions.ID
JOIN Mitarbei ON OPTeile.AnlageUserID_ = Mitarbei.ID
WHERE Mitarbei.UserName LIKE 'CZ%'
  AND LEN(RTRIM(OPTeile.Code)) = 24
GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, OpTeile.Status, Status.StatusBez, Actions.ActionsBez$LAN$
  
UNION ALL

SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, '-' AS Status, 'Teile gesamt' AS Statusbezeichnung, N'' AS [LetzteAktion], COUNT(OPTeile.Code) AS [AnzahlTeile]
FROM OPTeile
JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
JOIN Status ON OPTeile.Status = Status.Status AND Status.Tabelle = N'OPTEILE'
JOIN Actions ON OPTeile.LastActionsID = Actions.ID
JOIN Mitarbei ON OPTeile.AnlageUserID_ = Mitarbei.ID
WHERE Mitarbei.UserName LIKE 'CZ%'
  AND LEN(RTRIM(OPTeile.Code)) = 24
GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$
ORDER BY ArtikelNr, Status, [LetzteAktion];
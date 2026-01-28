SELECT EinzTeil.Code, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, EinzTeil.WegDatum AS [Schrott-Datum], EinzTeil.LastActionsID, Actions.ActionsBez AS [letzte Aktion], EinzTeil.ZielNrID, ZielNr.ZielNrBez AS [letzter Produktionsort], WegGrund.WeggrundBez AS [Schrott-Grund]
FROM EinzTeil
JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
JOIN Actions ON EinzTeil.LastActionsID = Actions.ID
JOIN ZielNr ON EinzTeil.ZielNrID = ZielNr.ID
JOIN WegGrund ON EinzTeil.WegGrundID = WegGrund.ID
WHERE EinzTeil.[Status] = 'Z'
  AND EinzTeil.WegDatum >= DATEADD(day, -30, GETDATE())
  AND EinzTeil.ZielNrID = 100070220;

GO
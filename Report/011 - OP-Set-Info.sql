SELECT IIF(OPEtiPo.OPEinwegID > 0, OPEinweg.Chargennr, OPTeile.Code) AS [Code / Einweg-Charge], 
  [Status].StatusBez$LAN$ AS [Status], 
  Actions.ActionsBez$LAN$ AS [Letzte Aktion], 
  COUNT(OPEtiPo.ID) AS Menge,
  IIF(OPEtiPo.OPEinwegID > 0, EWArtikel.ArtikelNr, OPArtikel.ArtikelNr) AS Artikelnummer, 
  IIF(OPEtiPo.OPEinwegID > 0, EWArtikel.ArtikelBez$LAN$, OPArtikel.ArtikelBez$LAN$) AS Artikelbezeichnung
FROM OPEtiPo
JOIN OPEtiKo ON OPEtiPo.OPEtiKoID = OPEtiKo.ID
LEFT OUTER JOIN OPTeile ON OPEtiPo.OPTeileID = OPTeile.ID AND OPEtiPo.OPTeileID > 0
LEFT OUTER JOIN [Status] ON OPTeile.Status = [Status].[Status] AND [Status].Tabelle = N'OPTEILE'
LEFT OUTER JOIN Actions ON OPTeile.LastActionsID = Actions.ID
LEFT OUTER JOIN Artikel AS OPArtikel ON OPTeile.ArtikelID = OPArtikel.ID
LEFT OUTER JOIN OPEinweg ON OPEtiPo.OPEinwegID = OPEinweg.ID AND OPEtiPo.OPEinwegID > 0
LEFT OUTER JOIN Artikel AS EWArtikel ON OPEinweg.ArtikelID = EWArtikel.ID
WHERE OPEtiKo.EtiNr = $1$
GROUP BY IIF(OPEtiPo.OPEinwegID > 0, OPEinweg.Chargennr, OPTeile.Code),
  [Status].StatusBez$LAN$,
  Actions.ActionsBez$LAN$,
  IIF(OPEtiPo.OPEinwegID > 0, EWArtikel.ArtikelNr, OPArtikel.ArtikelNr),
  IIF(OPEtiPo.OPEinwegID > 0, EWArtikel.ArtikelBez$LAN$, OPArtikel.ArtikelBez$LAN$)
;
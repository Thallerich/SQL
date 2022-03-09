SELECT Expedition.SuchCode AS Betrieb, Produktion.SuchCode AS Wäscher, Holding.Holding, Kunden.KdNr, Kunden.Name1 AS [Name], Hauptstandort.SuchCode AS [D-BT], RechKo.RechNr, RechKo.RechDat, RechKo.Memo AS Bemerkung, RechKo.Art AS RechArt, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, KdArti.Variante, RechPo.Menge, RechPo.EPreis AS Preis, RechPo.GPreis AS Betrag, RechPo.RabattProz AS RabattProzent, RechPo.Rabatt AS Rabatt
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN KdArti ON RechPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Vsa ON RechPo.VsaID = Vsa.ID
JOIN StandBer ON StandBer.StandKonID = Vsa.StandKonID AND StandBer.BereichID = RechPo.BereichID
JOIN Standort AS Expedition ON StandBer.ExpeditionID = Expedition.ID
JOIN Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID
JOIN Standort AS Hauptstandort ON Kunden.StandortID = Hauptstandort.ID
WHERE RechKo.RechDat BETWEEN $STARTDATE$ AND $ENDDATE$
  AND RechKo.FirmaID IN ($1$)
  AND Holding.ID IN ($2$)
  AND RechPo.Rabatt <> 0;
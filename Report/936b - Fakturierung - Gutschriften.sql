SELECT Holding.Holding AS Kette, Kunden.Debitor, Kunden.KdNr, Kunden.Name1 AS [Name], Hauptstandort.SuchCode AS [Standard BT], Expedition.SuchCode AS [prod. BT], Produktion.SuchCode AS [intern prod. BT], RechKo.RechNr, RechKo.RechDat, RechKo.Memo AS Bemerkung, IIF(RechKo.BasisRechKoID < 0, NULL, BasisRechKo.RechNr) AS [GU für], RechKo.Art AS RechArt, Artikel.ArtikelNr, IIF(Artikel.ID < 0, RechPo.Bez, Artikel.ArtikelBez$LAN$) AS Bezeichnung, IIF(KdArti.ID < 0, NULL, KdArti.Variante) AS Variante, RechPo.EPreis AS Preis, RechPo.RabattProz AS [RabattProzent], RechPo.GPreis AS Betrag
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN RechKo AS BasisRechKo ON RechKo.BasisRechKoID = BasisRechKo.ID
JOIN KdArti ON RechPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Standort AS Hauptstandort ON Kunden.StandortID = Hauptstandort.ID
JOIN Vsa ON RechPo.VsaID = Vsa.ID
JOIN StandBer ON StandBer.StandKonID = Vsa.StandKonID AND StandBer.BereichID = KdBer.ID
JOIN Standort AS Expedition ON StandBer.ExpeditionID = Expedition.ID
JOIN Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID
WHERE RechKo.RechDat BETWEEN $2$ AND $3$
  AND RechKo.FirmaID IN ($1$)
  AND RechKo.Art = N'G';
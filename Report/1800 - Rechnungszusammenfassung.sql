SELECT RechKo.RechNr, RechKo.RechDat AS Rechnungsdatum, RechPo.Menge, RechPo.Bez AS Positionsbezeichnung, Artikel.ArtikelNr, KdArti.Variante, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, RechPo.EPreis, RechKo.RechWaeID AS EPreis_WaeID, RechPo.GPreis, RechKo.RechWaeID AS GPreis_WaeID, Abteil.Bez AS Kostenstelle, RechPo.Rabatt, RechPo.RabattProz AS Rabattsatz, RechPo.VonDatum AS von, RechPo.BisDatum AS bis
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN KdArti ON RechPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Abteil ON RechPo.AbteilID = Abteil.ID
WHERE RechKo.RechDat >= $STARTDATE$
  AND RechKo.RechDat <= $ENDDATE$
  AND RechKo.KundenID = $2$
  AND RechKo.[Status] >= 'N'
  AND RechKo.[Status] < 'X';
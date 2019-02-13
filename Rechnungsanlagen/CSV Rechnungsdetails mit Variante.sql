SELECT RechKo.RechNr AS BelegNr, RechKo.RechDat AS Belegdatum, Kunden.KdNr, Kunden.Name1, Kunden.Name2, Abteil.Abteilung AS KsSt, Abteil.Bez AS Kostenstelle, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, KdArti.Variante, KdArti.VariantBez AS Variantenbezeichnung, KdArti.Referenz AS Warengruppe, RPoType.RPoTypeBez$LAN$ AS Typ, SUM(RechPo.Menge) AS Menge, RechPo.EPreis AS [Einzelpreis], SUM(RechPo.GPreis) AS Positionssumme
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN RPoType ON RechPo.RPoTypeID = RPoType.ID
JOIN KdArti ON RechPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Abteil ON RechPo.AbteilID = Abteil.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
WHERE RechKo.ID = $RECHKOID$
GROUP BY RechKo.RechNr, RechKo.RechDat, Kunden.KdNr, Kunden.Name1, Kunden.Name2, Abteil.Abteilung, Abteil.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, KdArti.Variante, KdArti.VariantBez, KdArti.Referenz, RPoType.RPoTypeBez$LAN$, RechPo.EPreis;
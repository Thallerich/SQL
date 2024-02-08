SELECT Firma.SuchCode AS Firma, KdGf.KurzBez AS Geschäftsbereich, [Zone].ZonenCode AS Vetriebszone, Holding.Holding, Standort.Bez AS Hauptstandort, Kunden.KdNr, Kunden.SuchCode AS Kunde, LsKo.LsNr, LsKo.Datum, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,KDARTI.WaschPreis ,LsPo.Menge, LsKoGruBez$LAN$ AS Reklamationsgrund
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN LsKoGru ON LsKo.LsKoGruID = LsKoGru.ID
WHERE Kunden.FirmaID IN ($1$)
  AND Kunden.KdGfID IN ($2$)
  AND Kunden.HoldingID IN ($3$)
  AND Kunden.StandortID IN ($4$)
  AND LsKo.Datum BETWEEN $STARTDATE$ AND $ENDDATE$
  AND LsPo.Menge < 0
  AND (($5$ = 1 AND LsPo.RechPoID > 0) OR ($5$ = 0))
  AND Kunden.SichtbarID IN ($SICHTBARIDS$);
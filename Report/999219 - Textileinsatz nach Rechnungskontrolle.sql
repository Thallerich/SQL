SELECT LiefRKo.BuchungsNr,
  LiefRKo.RechNr,
  LiefRKo.Datum,
  Lief.LiefNr,
  Lief.Name1 AS Lieferant,
  LiefRKo.NettoSumme,
  Lief.WaeID AS NettoSumme_WaeID,
  LiefRKo.Frachtkosten,
  Lief.WaeID AS Frachtkosten_WaeID,
  LiefRKo.Nebenkosten,
  Lief.WaeID AS Nebenkosten_WaeID,
  Lagerart.Lagerart,
  Lagerart.LagerartBez$LAN$ AS [Bezeichnung Lagerart],
  BKo.BestNr AS [Bestell-Nr.],
  LiefLsKo.LsNr AS [Lieferschein-Nr.],
  LiefLsKo.WeDatum AS [Datum Wareneingang],
  BPo.Pos AS [Bestell-Position],
  ArtGru.Gruppe AS Artikelgruppe,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  ArtGroe.Groesse AS Größe,
  SUM(BPo.Menge) AS Bestellmenge,
  SUM(LiefLsPo.Menge) AS [Liefermenge lt. Lieferschein],
  SUM(BPo.Liefmenge) AS [Liefermenge gesamt],
  BPo.EPreisVorZusch AS [Einzelpreis ohne Zuschlag],
  Lief.WaeID AS [Einzelpreis ohne Zuschlag_WaeID],
  BPo.Einzelpreis AS [Einzelpreis mit Zuschlag],
  Lief.WaeID AS [Einzelpreis mit Zuschlag_WaeID],
  SUM(LiefLsPo.Menge * BPo.Einzelpreis) AS [Summe Lieferpositionen],
  Lief.WaeID AS [Summe Lieferpositionen_WaeID],
  SUM(LiefRPo.Frachtkosten) AS [Frachtkosten der Position],
  Lief.WaeID AS [Frachtkosten der Position_WaeID],
  SUM(LiefRPo.Nebenkosten) AS [Nebenkosten der Position],
  Lief.WaeID AS [Nebenkosten der Position_WaeID],
  SUM(LiefLsPo.Menge * BPo.Einzelpreis) + SUM(LiefRPo.Frachtkosten) + SUM(LiefRPo.Nebenkosten) AS Bewegungspreis,
  Lief.WaeID AS Bewegungspreis_WaeID,
  BKo.MemoIntern
FROM LiefRKo
JOIN LiefRPo ON LiefRPo.LiefRKoID = LiefRKo.ID
JOIN LiefLsPo ON LiefRPo.LiefLsPoID = LiefLsPo.ID
JOIN LiefLsKo ON LiefLsPo.LiefLsKoID = LiefLsKo.ID
JOIN Firma ON LiefRKo.FirmaID = Firma.ID
JOIN Lief ON LiefRKo.LiefID = Lief.ID
JOIN BPo ON LiefLsPo.BPoID = BPo.ID
JOIN BKo ON BPo.BKoID = BKo.ID
JOIN Lagerart ON BKo.LagerartID = Lagerart.ID
JOIN ArtGroe ON BPo.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
WHERE Lagerart.FirmaID = $1$
  AND LiefLsKo.WeDatum BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Lagerart.SichtbarID IN ($SICHTBARIDS$)
  AND LiefRKo.Status > N'M'
GROUP BY LiefRKo.buchungsNr,
  LiefRKo.RechNr,
  LiefRKo.Datum,
  Lief.LiefNr,
  Lief.Name1,
  LiefRKo.NettoSumme,
  LiefRKo.Frachtkosten,
  LiefRKo.Nebenkosten,
  Lief.WaeID,
  Lagerart.Lagerart,
  Lagerart.LagerartBez$LAN$,
  BKo.BestNr,
  LiefLsKo.LsNr,
  LiefLsKo.WeDatum,
  BPo.Pos,
  ArtGru.Gruppe,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$,
  ArtGroe.Groesse,
  BPo.EPreisVorZusch,
  BPo.Einzelpreis,
  BKo.MemoIntern
ORDER BY Datum, RechNr, [Bestell-Nr.], [Lieferschein-Nr.], [Bestell-Position];
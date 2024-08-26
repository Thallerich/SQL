SELECT Kunden.SuchCode AS Kunde, EinzHist.Barcode, Traeger.Traeger, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, (SELECT TOP 1 Scans.DateTime FROM Scans WHERE Scans.EinzHistID = EinzHist.ID ORDER BY Scans.DateTime DESC) AS [Letzter Scan], (SELECT TOP 1 ZielNr.ZielNrBez$LAN$ FROM Scans, ZielNr WHERE Scans.ZielNrID = ZielNr.ID AND Scans.EinzHistID = EinzHist.ID ORDER BY Scans.DateTime DESC) AS [Letztes Ziel]
FROM EinzHist, Traeger, Vsa, Kunden, Artikel, standber
WHERE EinzHist.TraegerID = Traeger.ID
  AND Traeger.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND EinzHist.ArtikelID = Artikel.ID
  AND Kunden.ID = $ID$
  and Standber.StandKonID = vsa.StandKonID
  and standber.ExpeditionID in ($3$)
  and Kunden.SichtbarID IN ($SICHTBARIDS$)
  and vsa.SichtbarID in ($SICHTBARIDS$)
  AND EinzHist.Eingang1 BETWEEN $1$ AND $2$
  AND EinzHist.Eingang1 > ISNULL(EinzHist.Ausgang1, '1980-01-01')
  AND EinzHist.Status = 'Q';
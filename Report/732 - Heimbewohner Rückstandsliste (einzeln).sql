SELECT MAX(Scans.DateTime) AS "Letzter Scan", (
  SELECT TOP 1 ZielNr.ZielNrBez$LAN$ AS ZielNrBez
    FROM ZielNr, Scans
    WHERE Scans.ZielNrID = ZielNr.ID
      AND Scans.EinzHistID = a.ID
    ORDER BY Scans.[DateTime] DESC
  ) AS "Letztes Ziel", a.*
FROM (
  SELECT EinzHist.ID AS ID, Kunden.KdNr, Kunden.Name2, Kunden.Name3, Kunden.Name1 AS Kunde, EinzHist.Barcode AS Seriennummer, Artikel.ArtikelBez AS Artikel, EinzHist.Status, EinzHist.Eingang1, EinzHist.Ausgang1, ISNULL(Traeger.Nachname + N' ', N'') + ISNULL(Traeger.Vorname, N'') AS Träger, Traeger.PersNr AS ZimmerNr, VSA.SuchCode, VSA.Bez AS Bez, VSA.Name1 AS Vsa, VSA.Name2 AS VSA2, VSA.Name3 AS VSA3
  FROM EinzHist, EinzTeil, Traeger, VSA, Kunden, Artikel
  WHERE EinzTeil.CurrEinzHistID = EinzHist.ID
    AND EinzHist.TraegerID = Traeger.ID
    AND Traeger.VSAID = VSA.ID
    AND VSA.KundenID = Kunden.ID
    AND Traeger.ID = $ID$
    AND (EinzHist.Eingang1 > EinzHist.Ausgang1 OR EinzHist.Ausgang1 IS NULL)
    AND EinzHist.Status IN ('Q', 'M')
    AND EinzHist.EinzHistTyp = 1
    AND EinzHist.PoolFkt = 0
    AND EinzHist.ArtikelID = Artikel.ID
    AND Artikel.BereichID = 107
  ) a, Scans
WHERE a.ID = Scans.EinzHistID
GROUP BY a.ID, a.KdNr, a.name2, a.Name3, a.Kunde, a.Seriennummer, a.Artikel, a.Status, a.Eingang1, a.Ausgang1, a.Träger, a.ZimmerNr, a.SuchCode, a.Bez, a.Vsa, a.Vsa2, a.Vsa3
HAVING CONVERT(date, MAX(Scans.[DateTime])) <= $2$
ORDER BY Seriennummer;
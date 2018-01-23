SELECT MAX(Scans.DateTime) AS "Letzter Scan", (
  SELECT TOP 1 ZielNr.ZielNrBez$LAN$ AS ZielNrBez
    FROM ZielNr, Scans
    WHERE Scans.ZielNrID = ZielNr.ID
      AND Scans.TeileID = a.ID
    ORDER BY Scans.DateTime DESC
  ) AS "Letztes Ziel", a.*
FROM (
  SELECT Teile.ID AS ID, Kunden.KdNr, Kunden.Name2, Kunden.Name3, Kunden.Name1 AS Kunde, Teile.Barcode AS Seriennummer, Artikel.ArtikelBez AS Artikel, Teile.Status, Teile.Eingang1, Teile.Ausgang1, ISNULL(TRIM(Traeger.Nachname), '') + ' ' + ISNULL(TRIM(Traeger.Vorname), '') AS Träger, Traeger.PersNr AS ZimmerNr, VSA.SuchCode, VSA.Bez AS Bez, VSA.Name1 AS Vsa, VSA.Name2 AS VSA2, VSA.Name3 AS VSA3
  FROM Teile, Traeger, VSA, Kunden, Artikel
  WHERE Teile.TraegerID = Traeger.ID
    AND Traeger.VSAID = VSA.ID
    AND VSA.KundenID = Kunden.ID
    AND Traeger.ID = $ID$
    AND Teile.Eingang1 >= '2008-09-15'
    AND (Teile.Eingang1 > Teile.Ausgang1 OR Teile.Ausgang1 IS NULL)
    AND Teile.Status IN ('Q', 'M')
    AND Teile.ArtikelID = Artikel.ID
    AND Artikel.BereichID = 107
  ) a, Scans
WHERE a.ID = Scans.TeileID
GROUP BY a.ID, a.KdNr, a.name2, a.Name3, a.Kunde, a.Seriennummer, a.Artikel, a.Status, a.Eingang1, a.Ausgang1, a.Träger, a.ZimmerNr, a.SuchCode, a.Bez, a.Vsa, a.Vsa2, a.Vsa3
HAVING CONVERT(date, MAX(DateTime)) <= $2$
ORDER BY Seriennummer;
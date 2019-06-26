SELECT MAX(Scans.DateTime) AS "Letzter Scan", (
  SELECT TOP 1 ZielNr.ZielNrBez$LAN$
    FROM ZielNr, Scans
    WHERE Scans.ZielNrID = ZielNr.ID
      AND Scans.TeileID = a.ID
    ORDER BY Scans.DateTime DESC
  ) AS "Letztes Ziel", a.*
FROM (
  SELECT Teile.ID AS ID, Kunden.KdNr, Kunden.Name2, Kunden.Name3, Kunden.Name1 AS Kunde, Teile.Barcode AS Seriennummer, Artikel.ArtikelBez$LAN$ AS Artikel, Teile.Status, Teile.Eingang1, Teile.Ausgang1, ISNULL(RTRIM(Traeger.Nachname), '') + ' ' + ISNULL(RTRIM(Traeger.Vorname), '') AS Träger, Traeger.PersNr AS ZimmerNr, VSA.SuchCode, VSA.Bez AS Bez, VSA.Name1 AS Vsa, VSA.Name2 AS VSA2, VSA.Name3 AS VSA3, (SELECT TOP 1 Fach FROM ScanFach WHERE ScanFach.VsaID = Vsa.ID AND ScanFach.TraegerID = Traeger.ID) AS Fach
  FROM Teile, Traeger, VSA, Kunden, Artikel
  WHERE Teile.TraegerID = Traeger.ID
    AND Traeger.VSAID = VSA.ID
    AND VSA.KundenID = Kunden.ID
    AND Kunden.ID = $1$
    AND (Teile.Eingang1 > Teile.Ausgang1 OR Teile.Ausgang1 IS NULL)
    AND Teile.Status IN ('Q', 'M', 'N')
    AND Teile.ArtikelID = Artikel.ID
    AND Artikel.BereichID <> 2696
    AND Teile.AltenheimModus = 1
  ) a, Scans
WHERE a.ID = Scans.TeileID
GROUP BY a.ID, KdNr, Name2, Name3, Kunde, Seriennummer, Artikel, Status, Eingang1, Ausgang1, Träger, ZimmerNr, SuchCode, Bez, Vsa, Vsa2, Vsa3, Fach
HAVING MAX(CONVERT(date, DateTime)) <= $2$
ORDER BY SuchCode, Träger;
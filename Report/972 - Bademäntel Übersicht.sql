SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Status.StatusBez AS Status, NULL AS BestellNr, COUNT(DISTINCT Teile.ID) AS Anzahl
FROM Teile, Artikel, Status, Vsa, Kunden
WHERE Teile.ArtikelID = Artikel.ID
  AND Teile.Status = Status.Status
  AND Status.Tabelle = N'TEILE'
  AND UPPER(Artikel.ArtikelBez) LIKE N'%BADEMA%'
  AND Teile.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Teile.Status IN ('S', 'T', 'U', 'V', 'W', 'Y')
  AND Teile.AusdienstDat BETWEEN $1$ AND $2$
  AND Kunden.KdGfID IN ($3$)
  AND Kunden.Status = 'A'
GROUP BY Kunden.KdNr, Kunden.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez, Status.StatusBez

UNION ALL

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, N'bestellt' AS Status, BKo.BestNr AS BestellNr, COUNT(DISTINCT Teile.ID) AS Anzahl
FROM Teile, Artikel, Status, Vsa, Kunden, KdGf, BPo, BKo
WHERE Teile.ArtikelID = Artikel.ID
  AND Teile.Status = Status.Status
  AND Status.Tabelle = N'TEILE'
  AND UPPER(Artikel.ArtikelBez) LIKE N'%BADEMA%'
  AND Teile.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Teile.BPoID = BPo.ID
  AND BPo.BKoID = BKo.ID
  AND Teile.Status IN ('E', 'G', 'I')
  AND Kunden.KdGfID IN ($3$)
  AND Kunden.Status = 'A'
GROUP BY Kunden.KdNr, Kunden.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez, BKo.BestNr

UNION ALL

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, N'offen' AS Status, NULL AS BestellNr, COUNT(DISTINCT Teile.ID) AS Anzahl
FROM Teile, Artikel, Status, Vsa, Kunden, KdGf
WHERE Teile.ArtikelID = Artikel.ID
  AND Teile.Status = Status.Status
  AND Status.Tabelle = N'TEILE'
  AND UPPER(Artikel.ArtikelBez) LIKE N'%BADEMA%'
  AND Teile.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Teile.Status IN ('A', 'C', 'K', 'L', 'LM', 'M')
  AND Kunden.KdGfID IN ($3$)
  AND Kunden.Status = 'A'
GROUP BY Kunden.KdNr, Kunden.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez
ORDER BY Kunden.KdNr, Artikel.ArtikelNr, Status;
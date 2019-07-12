SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS VSA, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Contain.Barcode, Artikel.ArtikelBez AS Container, ContHist.Zeitpunkt AS [Abgeladen bei VSA], CAST(IIF(CAST(ContHist.Zeitpunkt AS DATE) < CAST('2019-06-16' AS DATE), 1, 0) AS bit) AS [berechnen]
FROM (
  SELECT ID, KundenID, Ausgang
  FROM CONTAIN
  WHERE CAST(contain.Ausgang AS DATE) < CAST('2019-06-16' AS DATE)
    AND KundenID IN (
      SELECT ID FROM Kunden WHERE KdNr IN (25007, 3113, 19100, 30354, 30512)
    )
  ) CT
JOIN ContHist ON CT.KundenID = ContHist.KundenID AND CT.ID = ContHist.ContainID
JOIN Contain ON CT.ID = Contain.ID
JOIN Artikel ON Contain.ArtikelID = Artikel.ID
LEFT JOIN Vsa ON Vsa.ID = ContHist.VsaID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Abteil ON Vsa.AbteilID = Abteil.ID
WHERE ContHist.Zeitpunkt > CT.Ausgang
  --AND CAST(ContHist.Zeitpunkt AS DATE) < CAST('2019-06-16' AS DATE)
  AND ContHist.STATUS = 'e'
ORDER BY KdNr, VsaNr, Kostenstelle, Container, [Abgeladen bei VSA];
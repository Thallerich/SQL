SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS VSA, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Contain.Barcode, Artikel.ArtikelBez AS Container, ContHist.Zeitpunkt AS [Abgeladen bei VSA], CAST(IIF(CAST(ContHist.Zeitpunkt AS DATE) < DATEADD(dd, -28, GETDATE()), 1, 0) AS bit) AS [berechnen]
FROM (
  SELECT ID, KundenID, Ausgang
  FROM CONTAIN
  WHERE KundenID IN (
      SELECT DISTINCT KundenID FROM KdArti WHERE KdArti.ArtikelID = (SELECT ID FROM Artikel WHERE ArtikelNr = N'CONTMIET')
    )
  ) CT
JOIN ContHist ON CT.KundenID = ContHist.KundenID AND CT.ID = ContHist.ContainID
JOIN Contain ON CT.ID = Contain.ID
JOIN Artikel ON Contain.ArtikelID = Artikel.ID
LEFT JOIN Vsa ON Vsa.ID = ContHist.VsaID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Abteil ON Vsa.AbteilID = Abteil.ID
WHERE ContHist.Zeitpunkt > CT.Ausgang
  --AND CAST(ContHist.Zeitpunkt AS DATE) < CAST('2019-04-01' AS DATE)
  AND ContHist.STATUS = 'e'
ORDER BY KdNr, VsaNr, Kostenstelle, Container, [Abgeladen bei VSA];

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS VSA, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Wochen.Woche AS Kalenderwoche, Artikel.ArtikelBez AS Artikelbezeichnung, AbtKdArW.EPreis AS Einzelpreis, AbtKdArW.Menge
FROM AbtKdArW
JOIN Kdarti ON AbtKdArW.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Abteil ON AbtKdArW.AbteilID = Abteil.ID
JOIN Kunden oN Abteil.KundenID = Kunden.ID
JOIN Vsa ON AbtKdArW.VsaID = Vsa.ID
JOIN Wochen ON AbtKdArW.WochenID = Wochen.ID
WHERE Artikel.ArtikelNr = N'CONTMIET'
ORDER BY KdNr, VsaNr, Kostenstelle, Kalenderwoche;
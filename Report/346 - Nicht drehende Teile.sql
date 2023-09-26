DECLARE @currentweek nchar(7) = (SELECT Week.Woche FROM Week WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat);

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS [VSA-Nr.], Vsa.SuchCode AS [VSA-Stichwort], Vsa.Bez AS VSA, Traeger.Traeger, Traeger.Titel, Traeger.Vorname, Traeger.Nachname, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, EinzHist.Barcode, EinzHist.Eingang1 AS [letzter Eingang], EinzHist.Ausgang1 AS [letzter Ausgang], EinzHist.RestwertInfo AS [aktueller Restwert], Lagerart.LagerartBez$LAN$ AS Lagerart
FROM EinzHist
JOIN EinzTeil ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Lagerart ON EinzHist.LagerartID = Lagerart.ID
WHERE Vsa.KundenID = $ID$
  AND EinzHist.Eingang1 < $1$
  AND EinzHist.Status = N'Q'
  AND EinzHist.EinzHistTyp = 1
  AND EinzTeil.AltenheimModus = 0
  AND Lagerart.LagerID IN ($3$) 
ORDER BY [VSA-Nr.], Traeger.Traeger, Artikel.ArtikelNr;
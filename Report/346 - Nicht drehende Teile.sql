DECLARE @currentweek nchar(7) = (SELECT Week.Woche FROM Week WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat);

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS [VSA-Nr.], Vsa.SuchCode AS [VSA-Stichwort], Vsa.Bez AS VSA, Traeger.Traeger, Traeger.Titel, Traeger.Vorname, Traeger.Nachname, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Teile.Barcode, Teile.Eingang1 AS [letzter Eingang], Teile.Ausgang1 AS [letzter Ausgang], TeileRW.RestwertInfo AS [aktueller Restwert]
FROM Teile
CROSS APPLY funcGetRestwert(Teile.ID, @currentweek, 1) AS TeileRW
JOIN TraeArti ON Teile.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE Kunden.ID = $ID$
  AND Teile.Eingang1 < $1$
  AND Teile.Status = 'Q'
ORDER BY [VSA-Nr.], Traeger.Traeger, Artikel.ArtikelNr;
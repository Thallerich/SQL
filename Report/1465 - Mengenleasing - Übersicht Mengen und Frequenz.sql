DECLARE @curweek nchar(7) = (SELECT [Week].Woche FROM [Week] WHERE CAST(GETDATE() AS date) BETWEEN [Week].VonDat AND [Week].BisDat);

SELECT VsaLeas.ID AS VsaLeasID, Holding.Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, VsaOrt.Bez AS Unterort, COALESCE(VsaLOrt.Menge, VsaLeas.Menge) AS Menge, ISNULL(Freq.FreqBez$LAN$, N'<manuell definiert>') AS Frequenz
FROM VsaLeas
LEFT JOIN VsaLOrt ON VsaLOrt.VsaLeasID = VsaLeas.ID
LEFT JOIN VsaOrt ON VsaLOrt.VsaOrtID = VsaOrt.ID
JOIN Vsa ON VsaLeas.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN KdArti ON VsaLeas.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN JahrLief ON JahrLief.TableID = VsaLeas.ID AND JahrLief.TableName = N'VSALEAS' AND JahrLief.Jahr = DATEPART(year, GETDATE())
LEFT JOIN Kalender ON JahrLief.Lieferwochen = Kalender.LieferWochen
LEFT JOIN Freq ON Kalender.FreqID = Freq.ID
WHERE Kunden.ID IN ($2$)
  AND KdBer.BereichID IN ($3$)
  AND @curweek BETWEEN VsaLeas.InDienst AND ISNULL(VsaLeas.AusDienst, N'2099/52');
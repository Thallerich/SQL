WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'TEILE'
)
SELECT KdGf.KurzBez AS SGF, Holding.Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS Vsa, Traeger.Traeger AS [Trägernummer], COALESCE(RTRIM(Traeger.Nachname), N'') + IIF(RTRIM(Traeger.Nachname) + RTRIM(Traeger.Vorname) IS NOT NULL, N', ', N'') + COALESCE(RTRIM(Traeger.Vorname), N'') AS [Trägername], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS [Größe], Teilestatus.StatusBez AS Teilestatus, COUNT(DISTINCT Teile.ID) AS Menge, BKo.BestNr AS Bestellnummer, BKo.Datum AS Bestelldatum, MAX(LiefAbPo.Termin) AS [Liefertermin Lieferant]
FROM Teile
JOIN TraeArti ON Teile.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON Teile.ArtGroeID = ArtGroe.ID
JOIN Teilestatus ON Teile.Status = Teilestatus.Status
JOIN TeileBPo ON TeileBPo.TeileID = Teile.ID AND TeileBPo.Latest = 1
JOIN BPo ON TeileBPo.BPoID = BPo.ID
JOIN BKo ON BPo.BKoID = BKo.ID
LEFT OUTER JOIN LiefAbPo ON LiefAbPo.BPoID = BPo.ID
WHERE Teile.Status IN (N'E', N'G', N'I') -- nur Teile die bestellt wurden oder bestätigt (Auftragsbestätigung vom Lieferanten) wurden
  AND Kunden.ID = $1$
GROUP BY KdGf.KurzBez, Holding.Holding, Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.Bez, Traeger.Traeger, COALESCE(RTRIM(Traeger.Nachname), N'') + IIF(RTRIM(Traeger.Nachname) + RTRIM(Traeger.Vorname) IS NOT NULL, N', ', N'') + COALESCE(RTRIM(Traeger.Vorname), N''), Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, Teilestatus.StatusBez, BKo.BestNr, BKo.Datum
ORDER BY SGF, KdNr, [Trägername], ArtikelNr, Teilestatus;
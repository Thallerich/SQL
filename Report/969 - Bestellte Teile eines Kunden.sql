SELECT KdGf.KurzBez AS SGF, Holding.Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, Mitarbei.Name AS Kundenservice, Vsa.VsaNr, Vsa.Bez AS Vsa, Traeger.Traeger AS [Trägernummer], COALESCE(RTRIM(Traeger.Nachname), N'') + IIF(RTRIM(Traeger.Nachname) + RTRIM(Traeger.Vorname) IS NOT NULL, N', ', N'') + COALESCE(RTRIM(Traeger.Vorname), N'') AS [Trägername], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS [Größe], [Status].StatusBez$LAN$ AS Teilestatus, COUNT(DISTINCT EinzHist.ID) AS Menge, BKo.BestNr AS Bestellnummer, BKo.Datum AS Bestelldatum, DATEADD(day, 14, MAX(LiefAbPo.Termin)) AS [Liefertermin Kunde], CAST(DATEPART(year, DATEADD(day, 14, MAX(LiefAbPo.Termin))) AS nchar(4)) + N'/' + FORMAT(DATEPART(week, DATEADD(day, 14, MAX(LiefAbPo.Termin))), N'00', N'de-AT') AS [Lieferwoche Kunde], Lagerbestand.BestandNeu AS [Lagerbestand Neuware], Lagerbestand.BestandGebraucht AS [Lagerbestand Gebrauchtware], Lagerbestand.Lager AS [Lagerstandort]
FROM EinzHist
JOIN TraeArti ON EinzHist.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Mitarbei ON KdBer.ServiceID = Mitarbei.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN [Status] ON EinzHist.[Status] = [Status].[Status] AND [Status].Tabelle = N'EINZHIST'
JOIN StandKon ON Vsa.StandKonID = StandKon.ID
JOIN StandBer ON StandBer.StandKonID = StandKon.ID AND StandBer.BereichID = Artikel.BereichID
JOIN TeileBPo ON TeileBPo.EinzHistID = EinzHist.ID AND TeileBPo.Latest = 1
JOIN BPo ON TeileBPo.BPoID = BPo.ID
JOIN BKo ON BPo.BKoID = BKo.ID
LEFT OUTER JOIN LiefAbPo ON LiefAbPo.BPoID = BPo.ID
LEFT OUTER JOIN (
  SELECT Standort.Bez AS Lager, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, SUM(IIF(LagerArt.Neuwertig = 1, Bestand.Bestand, 0)) AS BestandNeu, SUM(IIF(LagerArt.Neuwertig = 0, Bestand.Bestand, 0)) AS BestandGebraucht, Standort.ID AS LagerID, Artikel.ID AS ArtikelID, ArtGroe.ID AS ArtGroeID
  FROM Bestand
  JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
  JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
  JOIN LagerArt ON Bestand.LagerArtID = LagerArt.ID
  JOIN Standort ON LagerArt.LagerID = Standort.ID
  GROUP BY Standort.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, Standort.ID, Artikel.ID, ArtGroe.ID
) Lagerbestand ON ArtGroe.ID = Lagerbestand.ArtGroeID AND StandBer.LagerID = Lagerbestand.LagerID
WHERE EinzHist.Status IN (N'E', N'G', N'I') -- nur Teile die bestellt wurden oder bestätigt (Auftragsbestätigung vom Lieferanten) wurden
  AND Kunden.ID = $ID$
GROUP BY KdGf.KurzBez, Holding.Holding, Kunden.KdNr, Kunden.SuchCode, Mitarbei.Name, Vsa.VsaNr, Vsa.Bez, Traeger.Traeger, COALESCE(RTRIM(Traeger.Nachname), N'') + IIF(RTRIM(Traeger.Nachname) + RTRIM(Traeger.Vorname) IS NOT NULL, N', ', N'') + COALESCE(RTRIM(Traeger.Vorname), N''), Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, ArtGroe.Groesse, [Status].StatusBez$LAN$, BKo.BestNr, BKo.Datum, Lagerbestand.BestandNeu, Lagerbestand.BestandGebraucht, Lagerbestand.Lager
ORDER BY SGF, KdNr, [Trägername], ArtikelNr, Teilestatus;
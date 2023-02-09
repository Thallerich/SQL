SELECT BKo.BestNr AS Bestellnummer, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], Traeger.Traeger AS Trägernummer, Traeger.Vorname, Traeger.Nachname, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, COUNT(EinzHist.ID) AS [Anzahl Teile], Auftrag.AuftragsNr
FROM TeileBPo
JOIN EinzHist ON TeileBPo.EinzHistID = EinzHist.ID
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN BPo ON TeileBPo.BPoID = BPo.ID
JOIN BKo ON BPo.BKoID = BKo.ID
JOIN Auftrag ON EinzHist.StartAuftragID = Auftrag.ID
WHERE BKo.BestNr IN (412016698, 412017785)
GROUP BY BKo.BestNr, Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.Bez, Traeger.Traeger, Traeger.Vorname, Traeger.Nachname, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, Auftrag.AuftragsNr;
TRY
  DROP TABLE #TmpBestellTeile;
CATCH ALL END;

SELECT KdGf.KurzBez AS SGF, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS Vsa, Traeger.Traeger, Traeger.Titel, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, Teile.Barcode, CONVERT(Teile.Anlage_, SQL_DATE) AS TeilAnlagedatum, BKo.BestNr, BPo.SollTermin, CONVERT(NULL, SQL_DATE) AS ABTermin, BPo.ID AS BPoID, BPo.LatestLiefAbKoID
INTO #TmpBestellTeile
FROM Teile, BPo, BKo, Traeger, Vsa, Kunden, KdGf, Artikel, ArtGroe
WHERE Teile.BPoID = BPo.ID
  AND BPo.BKoID = BKo.ID
  AND Teile.TraegerID = Traeger.ID
  AND Traeger.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.KdGfID = KdGf.ID
  AND Teile.ArtikelID = Artikel.ID
  AND Teile.ArtGroeID = ArtGroe.ID
  AND Teile.Status IN ('E', 'G', 'I')
  AND BPo.SollTermin > CURDATE() + 14
  AND Traeger.Status = 'A'
  AND Vsa.Status = 'A'
  AND Kunden.Status = 'A'
  AND KdGf.ID IN ($1$);

UPDATE BestellTeile SET ABTermin = x.Termin
FROM #TmpBestellTeile AS BestellTeile, (
  SELECT DISTINCT LiefAbPo.BPoID, LiefAbPo.Termin
  FROM LiefAbPo, LiefAbKo, #TmpBestellTeile AS BT
  WHERE BT.LatestLiefAbKoID = LiefAbKo.ID
    AND LiefAbPo.LiefAbKoID = LiefAbKo.ID
    AND LiefAbPo.BPoID = BT.BPoID
) AS x
WHERE x.BPoID = BestellTeile.BPoID;

SELECT SGF, KdNr, Kunde, VsaStichwort, Vsa, Traeger, Titel, Nachname, Vorname, ArtikelNr, Artikelbezeichnung, Groesse, Barcode, TeilAnlagedatum AS [Anlagedatum Teil], BestNr AS [Bestellung Nr], SollTermin, ABTermin AS [Bestätigter Termin lt. Lieferant]
FROM #TmpBestellTeile
ORDER BY [Anlagedatum Teil] DESC;
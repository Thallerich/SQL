DROP TABLE IF EXISTS #TmpAnfData;

SELECT AnfKo.Auftragsdatum AS Bestelldatum, AnfKo.Lieferdatum, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS [Größe], AnfPo.Angefordert AS Bestellt,Anfpo.UrAngefordert AS UrMengeBestellt, 0 AS Geliefert, 0 AS Verrechnet, CONVERT(money, 0) AS Einzelpreis, AnfKo.LsKoID, AnfPo.KdArtiID, AnfPo.VpsKoID, AnfPo.ArtGroeID, AnfPo.LsKoGruID
INTO #TmpAnfData
FROM AnfPo, AnfKo, Vsa, Kunden, KdArti, Artikel, ArtGroe
WHERE AnfPo.AnfKoID = AnfKo.ID
  AND AnfKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND AnfPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND AnfPo.ArtGroeID = ArtGroe.ID
  AND LieferDatum BETWEEN $1$ AND $2$
  AND Kunden.ID = $ID$
  AND (AnfPo.Angefordert > 0 OR AnfPo.Geliefert > 0);

UPDATE AnfData SET Verrechnet = IIF(x.RechPoID < 0, 0, x.Menge), Einzelpreis = x.EPreis, Geliefert = x.Menge
FROM #TmpAnfData AnfData, (
  SELECT LsKo.ID AS LsKoID, LsPo.KdArtiID, LsPo.ArtGroeID, LsPo.VpsKoID, LsPo.LsKoGruID, LsPo.Menge, LsPo.EPreis, LsPo.RechPoID
  FROM LsPo, LsKo
  WHERE LsPo.LsKoID = LsKo.ID
    AND LsKo.ID IN (SELECT LsKoID FROM #TmpAnfData)
) x
WHERE x.LsKoID = AnfData.LsKoID
  AND x.KdArtiID = AnfData.KdArtiID
  AND x.ArtGroeID = AnfData.ArtGroeID
  AND x.VpsKoID = AnfData.VpsKoID
  AND x.LsKoGruID = AnfData.LsKoGruID;

SELECT Bestelldatum, Lieferdatum, KdNr, Kunde, VsaNr, Vsa, ArtikelNr, Artikelbezeichnung, [Größe], SUM(Bestellt) AS Bestellt, SUM(URMengeBestellt) AS UrBestell, SUM(Geliefert) AS Geliefert, SUM(Verrechnet) AS Verrechnet, Einzelpreis
FROM #TmpAnfData AnfData
GROUP BY Bestelldatum, Lieferdatum, KdNr, Kunde, VsaNr, Vsa, ArtikelNr, Artikelbezeichnung, [Größe], Einzelpreis
ORDER BY KdNr, VsaNr, Bestelldatum, ArtikelNr;
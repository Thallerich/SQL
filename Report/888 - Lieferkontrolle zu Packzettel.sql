DROP TABLE IF EXISTS #TmpLsKontrolle888;

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS VsaBezeichnung, LsKo.LsNr, LsKo.Datum, AnfKo.AuftragsNr AS Packzettelnummer, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, ArtGroe.Groesse AS Größe, IIF((VsaBer.AnfAusEpo > 1 OR KdBer.AnfAusEPo > 1 OR Kunden.CheckPackmenge = 1) AND AnfPo.Angefordert % COALESCE(NULLIF(ArtiStan.PackMenge, -1), Artikel.PackMenge) != 0 AND AnfPo.Angefordert = 1, 0, AnfPo.Angefordert) AS Angefordert, 0 AS Liefermenge, 0 AS AnzahlChips, 0 AS Abweichung, CONVERT(float, 0) AS AbweichungProzent, CAST(IIF(KdArti.[Status] = N'F', 1, 0) AS bit) AS NichtKdArti, CAST(0 AS bit) AS LsIsOK, AnfPo.KdArtiID, AnfKo.LsKoID, AnfPo.ID AS AnfPoID, Artikel.EAN, AnfPo.ArtGroeID, AnfKo.Druckzeitpunkt AS PZGedrucktStamp, LsKo.Druckzeitpunkt AS LsGedrucktStamp
INTO #TmpLsKontrolle888
FROM AnfPo
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN LsKo ON AnfKo.LsKoID = LsKo.ID
JOIN Vsa ON AnfKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON AnfPo.KdArtiID = KdArti.ID
JOIN ArtGroe ON AnfPo.ArtGroeID = ArtGroe.ID
JOIN VsaBer ON AnfKo.VsaID = VsaBer.VsaID AND KdArti.KdBerID = VsaBer.KdBerID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
LEFT JOIN ArtiStan ON ArtiStan.ArtikelID = Artikel.ID AND AnfKo.ProduktionID = ArtiStan.StandortID
WHERE AnfKo.AuftragsNr = $1$
  AND (IIF((VsaBer.AnfAusEpo > 1 OR KdBer.AnfAusEPo > 1 OR Kunden.CheckPackmenge = 1) AND AnfPo.Angefordert % COALESCE(NULLIF(ArtiStan.PackMenge, -1), Artikel.PackMenge) != 0 AND AnfPo.Angefordert = 1, 0, AnfPo.Angefordert) > 0 OR AnfPo.Geliefert > 0);
  
UPDATE LsKontrolle SET LsKontrolle.Liefermenge = LsPo.Menge
FROM #TmpLsKontrolle888 LsKontrolle, LsPo, LsKo
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKontrolle.LsKoID = LsKo.ID
  AND LsKontrolle.KdArtiID = LsPo.KdArtiID
  AND LsKontrolle.ArtGroeID = LsPo.ArtGroeID;

UPDATE LsKontrolle SET LsKontrolle.AnzahlChips = x.AnzahlChips
FROM #TmpLsKontrolle888 LsKontrolle, (
  SELECT COUNT(DISTINCT Scans.EinzTeilID) AS AnzahlChips, Scans.AnfPoID
  FROM Scans, #TmpLsKontrolle888 LSK
  WHERE Scans.AnfPoID = LSK.AnfPoID
  GROUP BY Scans.AnfPoID
) x
WHERE x.AnfPoID = LsKontrolle.AnfPoID;

UPDATE #TmpLsKontrolle888 SET Abweichung = Liefermenge - Angefordert, AbweichungProzent = ROUND(100 / CONVERT(float, IIF(Angefordert = 0, 1, Angefordert)) * CONVERT(float, Liefermenge - Angefordert), 2);

SELECT KdNr, Kunde, VsaStichwort, VsaBezeichnung, LsNr, Datum, Packzettelnummer, ArtikelNr, ArtikelBez, Größe, Angefordert, Liefermenge, AnzahlChips, Abweichung, FORMAT(IIF(AbweichungProzent > 100, 100, AbweichungProzent) / 100, 'P', 'de-AT') AS AbweichungProzent, NichtKdArti, LsIsOK, KdArtiID, LsKoID, AnfPoID, EAN, PZGedrucktStamp, LsGedrucktStamp
FROM #TmpLsKontrolle888
ORDER BY KdNr, VsaStichwort, LsNr, NichtKdArti DESC;
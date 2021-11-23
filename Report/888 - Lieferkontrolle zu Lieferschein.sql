DROP TABLE IF EXISTS #TmpLsKontrolle888;

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS VsaBezeichnung, LsKo.LsNr, LsKo.Datum, AnfKo.AuftragsNr AS Packzettelnummer, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, ArtGroe.Groesse AS Größe, IIF(DATEDIFF(minute, AnfPo.Anlage_, AnfPo.BestaetZeitpunkt) = 0, 0, AnfPo.Angefordert) AS Angefordert, 0 AS Liefermenge, 0 AS AnzahlChips, 0 AS Abweichung, CONVERT(float, 0) AS AbweichungProzent, CAST(IIF(KdArti.Vorlaeufig = 1 AND KdArti.AnlageUserID_ IN (SELECT Mitarbei.ID FROM Mitarbei WHERE UserName IN ('TAGJOB', 'CITJOB')), 1, 0) AS bit) AS NichtKdArti, CAST(0 AS bit) AS LsIsOK, AnfPo.KdArtiID, AnfKo.LsKoID, AnfPo.ID AS AnfPoID, Artikel.EAN, AnfPo.ArtGroeID
INTO #TmpLsKontrolle888
FROM AnfPo, AnfKo, Vsa, Kunden, KdArti, Artikel, LsKo, ArtGroe
WHERE AnfPo.AnfKoID = AnfKo.ID
  AND AnfKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND AnfPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND AnfKo.LsKoID = LsKo.ID
  AND AnfPo.ArtGroeID = ArtGroe.ID
  AND LsKo.LsNr = $1$
  AND (AnfPo.Angefordert > 0 OR AnfPo.Geliefert > 0);
  
UPDATE LsKontrolle SET LsKontrolle.Liefermenge = LsPo.Menge
FROM #TmpLsKontrolle888 LsKontrolle, LsPo, LsKo
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKontrolle.LsKoID = LsKo.ID
  AND LsKontrolle.KdArtiID = LsPo.KdArtiID
  AND LsKontrolle.ArtGroeID = LsPo.ArtGroeID;

UPDATE LsKontrolle SET LsKontrolle.AnzahlChips = x.AnzahlChips
FROM #TmpLsKontrolle888 LsKontrolle, (
  SELECT COUNT(DISTINCT OPScans.OPTeileID) AS AnzahlChips, OPScans.AnfPoID
  FROM OPScans, #TmpLsKontrolle888 LSK
  WHERE OPScans.AnfPoID = LSK.AnfPoID
  GROUP BY OPScans.AnfPoID
) x
WHERE x.AnfPoID = LsKontrolle.AnfPoID;

UPDATE #TmpLsKontrolle888 SET Abweichung = Liefermenge - Angefordert, AbweichungProzent = ROUND(100 / CONVERT(float, IIF(Angefordert = 0, 1, Angefordert)) * CONVERT(float, Liefermenge - Angefordert), 2);
  
DELETE FROM #TmpLsKontrolle888
WHERE Abweichung = 0
  AND ((EAN IS NOT NULL AND Liefermenge = AnzahlChips) OR EAN IS NULL);

INSERT INTO #TmpLsKontrolle888
SELECT Kunden.KdNr, Kunden.SuchCode, Vsa.SuchCode, Vsa.Bez, LsKo.LsNr, LsKo.Datum, AnfKo.AuftragsNr, NULL, NULL, N'-', 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, NULL, -1
FROM LsKo, Vsa, Kunden, AnfKo
WHERE LsKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND AnfKo.LsKoID = LsKo.ID
  AND LsKo.LsNr = $1$;

DELETE FROM #TmpLsKontrolle888
WHERE LsIsOK = 1
  AND (SELECT COUNT(*) FROM #TmpLsKontrolle888) > 1;

SELECT KdNr, Kunde, VsaStichwort, VsaBezeichnung, LsNr, Datum, Packzettelnummer, ArtikelNr, ArtikelBez, Größe, Angefordert, Liefermenge, AnzahlChips, Abweichung, FORMAT(IIF(AbweichungProzent > 100, 100, AbweichungProzent) / 100, 'P', 'de-AT') AS AbweichungProzent, NichtKdArti, LsIsOK, KdArtiID, LsKoID, AnfPoID, EAN
FROM #TmpLsKontrolle888
ORDER BY KdNr, VsaStichwort, LsNr, NichtKdArti DESC;
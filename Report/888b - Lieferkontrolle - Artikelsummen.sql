DROP TABLE IF EXISTS #TmpLsKontrolle888b;
DROP TABLE IF EXISTS #TmpFinal;

SELECT StandKon.StandKonBez$LAN$ AS Standortkonfiguration, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS VsaBezeichnung, CONVERT(char(10), NULL) AS LsNr, CONVERT(date, NULL) AS Datum, AnfKo.AuftragsNr AS Packzettelnummer, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, ArtGroe.Groesse AS Größe, IIF(DATEDIFF(minute, AnfPo.Anlage_, AnfPo.BestaetZeitpunkt) = 0, 0, AnfPo.Angefordert) AS Angefordert, AnfKo.Sonderfahrt, 0 AS Liefermenge, 0 AS AnzahlChips, AnfPo.KdArtiID, AnfKo.LsKoID, AnfPo.ID AS AnfPoID, AnfPo.ArtGroeID
INTO #TmpLsKontrolle888b
FROM AnfPo, AnfKo, Vsa, Kunden, KdArti, Artikel, StandKon, ArtGroe
WHERE AnfPo.AnfKoID = AnfKo.ID
  AND AnfKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Vsa.StandKonID = StandKon.ID
  AND AnfPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND AnfPo.ArtGroeID = ArtGroe.ID
  AND AnfKo.Lieferdatum BETWEEN $1$ AND $2$
  AND AnfKo.Status >= 'I'
  AND Vsa.StandKonID IN ($4$)
  AND (($3$ = 1 AND Artikel.EAN IS NOT NULL) OR ($3$ = 0));

UPDATE LsKontrolle SET LsNr = CONVERT(char(10), LsKo.LsNr), Datum = LsKo.Datum
FROM #TmpLsKontrolle888b LsKontrolle, LsKo
WHERE LsKontrolle.LsKoID = LsKo.ID
  AND LsKontrolle.LsKoID > 0;

UPDATE LsKontrolle SET LsKontrolle.Liefermenge = LsPo.Menge
FROM #TmpLsKontrolle888b LsKontrolle, LsPo, LsKo
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKontrolle.LsKoID = LsKo.ID
  AND LsKontrolle.KdArtiID = LsPo.KdArtiID
  AND LsKontrolle.ArtGroeID = LsPo.ArtGroeID
  AND LsKontrolle.LsKoID > 0;

UPDATE LsKontrolle SET LsKontrolle.AnzahlChips = x.AnzahlChips
FROM #TmpLsKontrolle888b LsKontrolle, (
  SELECT COUNT(DISTINCT Scans.EinzTeilID) AS AnzahlChips, Scans.AnfPoID
  FROM Scans, #TmpLsKontrolle888b LSK
  WHERE Scans.AnfPoID = LSK.AnfPoID
  GROUP BY Scans.AnfPoID
) x
WHERE x.AnfPoID = LsKontrolle.AnfPoID;

SELECT LSK.Standortkonfiguration, IIF($5$ = 0, 0, LSK.KdNr) AS KdNr, IIF($5$ = 0, '', LSK.Kunde) AS Kunde, LSK.Datum, LSK.ArtikelNr, LSK.ArtikelBez, LSK.Größe, SUM(IIF(LSK.Sonderfahrt = 0, LSK.Angefordert, 0)) AS Angefordert, SUM(IIF(LSK.Sonderfahrt = 1, LSK.Angefordert, 0)) AS [Angefordert Sonderlieferung], SUM(LSK.Liefermenge) AS Liefermenge, SUM(LSK.AnzahlChips) AS [Anzahl Chips], 0 AS Abweichung, CONVERT(float, 0) AS AbweichungProzent
INTO #TmpFinal
FROM #TmpLsKontrolle888b LSK
GROUP BY KdNr, Kunde, LSK.Standortkonfiguration, LSK.Datum, LSK.ArtikelNr, LSK.ArtikelBez, LSK.Größe;

UPDATE #TmpFinal SET Abweichung = Liefermenge - Angefordert - [Angefordert Sonderlieferung], AbweichungProzent = ROUND(100 / CONVERT(float, IIF(Angefordert + [Angefordert Sonderlieferung] = 0, 1, Angefordert + [Angefordert Sonderlieferung])) * CONVERT(float, Liefermenge - Angefordert - [Angefordert Sonderlieferung]), 2);

SELECT * FROM #TmpFinal WHERE Angefordert > 0 OR [Angefordert Sonderlieferung] > 0 OR Liefermenge > 0;
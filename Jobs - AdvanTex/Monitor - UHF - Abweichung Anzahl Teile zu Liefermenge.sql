DROP TABLE IF EXISTS #AnfCheck;

SELECT AnfPo.ID AS AnfPoID,
  AnfPo.KdArtiID,
  AnfPo.ArtGroeID,
  AnfKo.VsaID,
  AnfKo.LsKoID,
  AnfKo.AuftragsNr,
  AnfKo.Lieferdatum,
  AnfPo.Angefordert,
  AnfPo.Geliefert,
  AnfPo.UserID_,
  AnfPo.Update_,
  Vsa.StandKonID,
  Standort.Bez AS Produktion,
  CAST(0 AS int) AS TeileAnzahl
INTO #AnfCheck
FROM AnfPo
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN Vsa ON AnfKo.VsaID = Vsa.ID
JOIN KdArti ON AnfPo.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
JOIN Standort ON StandBer.ProduktionID = Standort.ID
WHERE AnfKo.LieferDatum > CAST(GETDATE() AS date)
  AND AnfKo.[Status] = N'S'
  AND AnfPo.Geliefert != 0
  AND Standort.SuchCode LIKE N'WOE_';

UPDATE #AnfCheck SET TeileAnzahl = ScanSum.Anzahl
FROM (
  SELECT Scans.AnfPoID, COUNT(DISTINCT Scans.EinzTeilID) AS Anzahl
  FROM Scans
  WHERE Scans.AnfPoID IN (
    SELECT #AnfCheck.AnfPoID
    FROM #AnfCheck
  )
  GROUP BY Scans.AnfPoID
) AS ScanSum
WHERE ScanSum.AnfPoID = #AnfCheck.AnfPoID;

SELECT #AnfCheck.Produktion,
  StandKon.StandKonBez AS [Standort-Konfiguration],
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.VsaNr,
  Vsa.Bez AS [Vsa-Bezeichnung],
  #AnfCheck.Lieferdatum,
  #AnfCheck.AuftragsNr AS Packzettel,
  LsKo.LsNr AS Lieferschein,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez AS Artikelbezeichnung,
  ArtGroe.Groesse AS Größe,
  CAST(#AnfCheck.Angefordert AS int) AS Angefordert,
  CAST(#AnfCheck.Geliefert AS int) AS Geliefert,
  #AnfCheck.TeileAnzahl AS [Anzahl Teile],
  CAST(#AnfCheck.Geliefert - #AnfCheck.TeileAnzahl AS int) AS Abweichung,
  FORMAT(ROUND((#AnfCheck.Geliefert - #AnfCheck.TeileAnzahl) / (#AnfCheck.Geliefert / 100), 0) / 100, N'# %') AS [Abweichung in Prozent],
  Mitarbei.Name AS [Letzte Änderung von],
  #AnfCheck.Update_ AS Änderungszeitpunkt
FROM #AnfCheck
JOIN Vsa ON #AnfCheck.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN LsKo ON #AnfCheck.LsKoID = LsKo.ID
JOIN KdArti ON #AnfCheck.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON #AnfCheck.ArtGroeID = ArtGroe.ID
JOIN Mitarbei ON #AnfCheck.UserID_ = Mitarbei.ID
JOIN StandKon ON #AnfCheck.StandKonID = StandKon.ID
WHERE ROUND((#AnfCheck.Geliefert - #AnfCheck.TeileAnzahl) / (#AnfCheck.Geliefert / 100), 0) >= 10
  AND CAST(#AnfCheck.Geliefert - #AnfCheck.TeileAnzahl AS int) > Artikel.Packmenge
  AND #AnfCheck.TeileAnzahl > 0;
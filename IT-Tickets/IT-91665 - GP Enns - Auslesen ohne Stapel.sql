SELECT *
FROM (
  SELECT AnfPo.ID AS AnfPoID, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], AnfKo.Lieferdatum, AnfKo.AuftragsNr, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, KdArti.Variante, COALESCE(IIF(ArtiStan.Packmenge = -1, NULL, ArtiStan.Packmenge), Artikel.Packmenge) AS VPE, AnfPo.Angefordert, AnfPo.Geliefert, COUNT(Scans.ID) AS Ausgelesen, SUM(IIF(Scans.VPSPoID < 0, 1, 0)) AS [davon ohne Stapelbildung], Mitarbei.MitarbeiUser AS [Bestätigt von]
  FROM AnfPo
  JOIN Scans ON Scans.AnfPoID = AnfPo.ID
  JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
  JOIN Vsa ON AnfKo.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN KdArti ON AnfPo.KdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN Mitarbei ON AnfPo.BestaetUserID = Mitarbei.ID
  LEFT JOIN ArtiStan ON ArtiStan.ArtikelID = Artikel.ID AND ArtiStan.StandortID = (SELECT ID FROM Standort WHERE Bez = N'Produktion GP Enns')
  /* WHERE AnfKo.ProduktionID = (SELECT ID FROM Standort WHERE Bez = N'Produktion GP Enns')
    AND AnfKo.LieferDatum = CAST(GETDATE() AS date) */
  WHERE AnfPo.ID = 194919260
  GROUP BY AnfPo.ID, Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.Bez, AnfKo.Lieferdatum, AnfKo.AuftragsNr, Artikel.ArtikelNr, Artikel.ArtikelBez, KdArti.Variante, COALESCE(IIF(ArtiStan.Packmenge = -1, NULL, ArtiStan.Packmenge), Artikel.Packmenge), AnfPo.Angefordert, AnfPo.Geliefert, Mitarbei.MitarbeiUser
) x
WHERE Ausgelesen % VPE != 0;

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Prüfung einzelner Packzettel-Positionen                                                                                   ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
DROP TABLE IF EXISTS #Vps;
GO

SELECT VpsKo.ID AS VpsKoID, VpsPo.ID AS VpsPoID, Scans.ID AS ScansID, VpsKo.VpsNr, VpsPo.Menge
INTO #Vps
FROM VpsPo
JOIN VpsKo ON VpsPo.VPSKoID = VpsKo.ID
JOIN Scans ON Scans.VpsPoID = VpsPo.ID
WHERE Scans.AnfPoID = 194919260;

GO

SELECT #Vps.VpsKoID, #Vps.VPSNr, #Vps.Menge, COUNT(DISTINCT Scans.EinzTeilID) AS [Anzahl Teile], COUNT(DISTINCT #Vps.ScansID) AS Auslesescans
FROM #Vps
JOIN Scans ON Scans.VPSPoID = #Vps.VpsPoID AND Scans.ActionsID = 126
JOIN EinzTeil ON Scans.EinzTeilID = EinzTeil.ID
GROUP BY #Vps.VpsKoID, #Vps.VpsNr, #Vps.Menge
HAVING (COUNT(DISTINCT Scans.EinzTeilID) != #Vps.Menge OR COUNT(DISTINCT #Vps.ScansID) != #Vps.Menge);

GO
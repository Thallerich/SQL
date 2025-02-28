SELECT *
FROM (
  SELECT AnfPo.ID AS AnfPoID, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], AnfKo.Lieferdatum, AnfKo.AuftragsNr, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, KdArti.Variante, COALESCE(IIF(ArtiStan.Packmenge = -1, NULL, ArtiStan.Packmenge), Artikel.Packmenge) AS VPE, AnfPo.Angefordert, AnfPo.Geliefert, COUNT(Scans.ID) AS Ausgelesen, SUM(IIF(Scans.VPSPoID < 0, 1, 0)) AS [davon ohne Stapelbildung]
  FROM AnfPo
  JOIN Scans ON Scans.AnfPoID = AnfPo.ID
  JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
  JOIN Vsa ON AnfKo.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN KdArti ON AnfPo.KdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  LEFT JOIN ArtiStan ON ArtiStan.ArtikelID = Artikel.ID AND ArtiStan.StandortID = (SELECT ID FROM Standort WHERE Bez = N'Produktion GP Enns')
  WHERE AnfKo.ProduktionID = (SELECT ID FROM Standort WHERE Bez = N'Produktion GP Enns')
    AND AnfKo.LieferDatum = CAST(GETDATE() AS date)
  GROUP BY AnfPo.ID, Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.Bez, AnfKo.Lieferdatum, AnfKo.AuftragsNr, Artikel.ArtikelNr, Artikel.ArtikelBez, KdArti.Variante, COALESCE(IIF(ArtiStan.Packmenge = -1, NULL, ArtiStan.Packmenge), Artikel.Packmenge), AnfPo.Angefordert, AnfPo.Geliefert
) x
WHERE Ausgelesen % VPE != 0;
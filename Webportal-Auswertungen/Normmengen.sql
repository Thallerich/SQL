SELECT VsaID AS BlockID, N'VSA' AS BlockIDName, Produktbereich, ArtikelNr, Artikelbezeichnung, Groesse, [VSA-Nummer], [VSA-Bezeichnung], CAST([1] * NormFaktor1 AS numeric(3,0)) AS Montag, CAST([2] * NormFaktor2 AS numeric(3,0)) AS Dienstag, CAST([3] * NormFaktor3 AS numeric(3,0)) AS Mittwoch, CAST([4] * NormFaktor4 AS numeric(3,0)) AS Donnerstag, CAST([5] * NormFaktor5 AS numeric(3,0)) AS Freitag, CAST([6] * NormFaktor6 AS numeric(3,0)) AS Samstag, CAST([7] * NormFaktor7 AS numeric(3,0)) AS Sonntag, Sollpuffer, [durchschnittliche Liefermenge], [letzte Inventur], KdNr, Name1, Name2, Name3
FROM (
  SELECT Bereich.BereichBez AS Produktbereich, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse, Vsa.VsaNr AS [VSA-Nummer], Vsa.Bez AS [VSA-Bezeichnung], VsaAnf.Normmenge, VsaAnf.Sollpuffer, VsaAnf.Durchschnitt AS [durchschnittliche Liefermenge], VsaAnf.IstDatum AS [letzte Inventur], Kunden.KdNr, Kunden.Name1, Kunden.Name2, Kunden.Name3, Touren.Wochentag, Vsa.NormFaktor1, Vsa.NormFaktor2, Vsa.NormFaktor3, Vsa.NormFaktor4, Vsa.NormFaktor5, Vsa.NormFaktor6, Vsa.NormFaktor7, Vsa.ID AS VsaID
  FROM VsaAnf
  JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN ArtGroe ON VsaAnf.ArtGroeID = ArtGroe.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN Bereich ON KdBer.BereichID = Bereich.ID
  JOIN VsaTour ON VsaTour.VsaID = Vsa.ID AND VsaTour.KdBerID = KdBer.ID
  JOIN Touren ON VsaTour.TourenID = Touren.ID
  WHERE Kunden.ID = " . $kundenID . "
    AND Vsa.AbteilID IN (
      SELECT WebUAbt.AbteilID
      FROM WebUAbt
      WHERE WebUAbt.WebUserID = " . $webuserID . "
    )
    AND Vsa.ID IN ($vsaids)
    AND VsaAnf.Status = N'A'
    AND VsaAnf.Art = N'N' -- Art: Norm-Lieferung
    AND CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum
) AS Normlieferdaten
PIVOT (
  MAX(Normmenge) FOR Wochentag IN ([1], [2], [3], [4], [5], [6], [7])
) AS NormlieferPivot
ORDER BY [VSA-Nummer], ArtikelNr;
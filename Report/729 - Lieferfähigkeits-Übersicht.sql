WITH AnfDaten AS (
  SELECT AnfKo.Lieferdatum, AnfPo.Angefordert, AnfPo.Geliefert, AnfPo.KdArtiID, AnfKo.VsaID
  FROM AnfPo, AnfKo
  WHERE AnfPo.AnfKoID = AnfKo.ID
    AND AnfKo.Lieferdatum BETWEEN $1$ AND $2$
    AND (AnfPo.Angefordert > 0 OR AnfPo.Geliefert > 0)
)
SELECT AnfDaten.LieferDatum, Kunden.KdNr, Kunden.SuchCode, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, SUM(AnfDaten.Angefordert) AS Angefordert, SUM(AnfDaten.Geliefert) AS Geliefert, SUM(AnfDaten.Angefordert - AnfDaten.Geliefert) AS Differenz, ROUND(SUM(AnfDaten.Geliefert) / SUM(IIF(AnfDaten.Angefordert = 0, 1, AnfDaten.Angefordert)) * 100, 2) AS Prozent
FROM AnfDaten, VSA, Kunden, KdArti, Artikel, Bereich
WHERE AnfDaten.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND AnfDaten.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Artikel.BereichID = Bereich.ID
  AND Bereich.ID IN ($3$)
  AND (($4$ = 1 AND AnfDaten.Angefordert - AnfDaten.Geliefert <> 0) OR ($4$ = 0))
  AND Kunden.FirmaID IN ($5$)
  AND Kunden.StandortID IN ($6$)
GROUP BY AnfDaten.LieferDatum, Kunden.KdNr, Kunden.SuchCode, Vsa.SuchCode, Vsa.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$
ORDER BY Artikel.ArtikelNr, AnfDaten.LieferDatum;
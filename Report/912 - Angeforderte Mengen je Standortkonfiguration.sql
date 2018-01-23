SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, StandKon.Bez AS Standortkonfiguration, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, SUM(AnfPo.Angefordert) AS Menge
FROM AnfPo, AnfKo, Vsa, Kunden, KdArti, Artikel, StandKon
WHERE AnfPo.AnfKoID = AnfKo.ID
  AND AnfKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND AnfPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Vsa.StandKonID = StandKon.ID
  AND AnfKo.Lieferdatum = $1$
  AND StandKon.ID IN ($2$)
GROUP BY Kunden.KdNr, Kunden.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, StandKon.Bez
HAVING SUM(AnfPo.Angefordert) > 0;
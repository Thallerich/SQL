WITH OPSetKunde AS (
  SELECT OPEtiKo.ArtikelID, OPEtiKo.VsaID, COUNT(OPEtiKo.ID) AS Anzahl
  FROM OPEtiKo
  WHERE OPEtiKo.[Status] = N'R'
    AND DATEDIFF(day, OPEtiKo.AusleseZeitpunkt, GETDATE()) < 180
  GROUP BY OPEtiKo.ArtikelID, OPEtiKo.VsaID
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS [Vsa-Stichwort], Vsa.Bez AS [Vsa-Bezeichnung], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, SUM(AnfPo.Angefordert) AS Angefordert, SUM(AnfPo.Geliefert) AS Geliefert, VsaAnf.Durchschnitt, ISNULL(OPSetKunde.Anzahl, 0) AS [Sets beim Kunden < 180 Tage]
FROM AnfPo
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN Vsa ON AnfKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON AnfPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN VsaAnf ON VsaAnf.KdArtiID = AnfPo.KdArtiID AND VsaAnf.VsaID = AnfKo.VsaID AND VsaAnf.ArtGroeID = AnfPo.ArtGroeID
LEFT OUTER JOIN OPSetKunde ON OPSetKunde.ArtikelID = Artikel.ID AND OPSetKunde.VsaID = Vsa.ID
WHERE Vsa.StandKonID IN ($1$)
  AND AnfKo.LieferDatum = $2$
  AND (($3$ = 1 AND AnfPo.Angefordert != 0) OR ($3$ = 0))
  AND KdBer.BereichID = (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich = N'ST')
GROUP BY Kunden.Kdnr, Kunden.SuchCode, Vsa.VsaNr, Vsa.SuchCode, Vsa.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, VsaAnf.Durchschnitt, ISNULL(OPSetKunde.Anzahl, 0)
ORDER BY Kunden.KdNr, Vsa.VsaNr, Artikel.ArtikelNr;
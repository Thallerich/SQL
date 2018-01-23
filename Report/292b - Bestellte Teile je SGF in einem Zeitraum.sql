SELECT KdGf.KurzBez AS SGF, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, COUNT(Teile.ID) AS Menge
FROM BPo
JOIN BKo ON BPo.BKoID = BKo.ID
JOIN Lief ON BKo.LiefID = Lief.ID
JOIN ArtGroe ON BPo.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Teile ON Teile.BPoID = BPo.ID
JOIN Vsa ON Teile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
WHERE Lief.ID = $ID$
  AND BKo.Datum BETWEEN $1$ AND $2$
  AND KdGf.ID IN ($3$)
GROUP BY KdGf.KurzBez, Artikel.ArtikelNr, Artikel.ArtikelBez
ORDER BY SGF, Artikel.ArtikelNr, Artikelbezeichnung;
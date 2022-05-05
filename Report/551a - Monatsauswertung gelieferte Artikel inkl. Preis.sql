SELECT Kunden.SuchCode, Vsa.Bez AS VsaBezeichnung, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, SUM(LsPo.Menge) AS Menge, LsPo.EPreis AS Einzelpreis, CAST(SUM(LsPo.Menge * LsPo.EPreis) AS money) AS Preis
FROM LsPo, LsKo, Vsa, Kunden, KdArti, Artikel
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Kunden.ID IN ($3$)
  AND LsKo.Datum BETWEEN $1$ AND $2$
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
GROUP BY Kunden.SuchCode, Vsa.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, LsPo.EPreis
HAVING SUM(LsPo.Menge) != 0
ORDER BY VsaBezeichnung ASC, ArtikelNr ASC
WITH Lagerbestand AS (
  SELECT OPEtiko.ArtikelID, COUNT(OPEtiKo.ID) AS Menge
  FROM OPEtiKo
  WHERE OPEtiKo.Status = N'J'
    AND OPEtiKo.ProduktionID = $2$
  GROUP BY OPEtiKo.ArtikelID
)
SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, SUM(AnfPo.Angefordert * OPSets.Menge) AS [benötigte Menge], Lagerbestand.Menge AS [bereits gepackt]
FROM AnfPo
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN KdArti ON AnfPo.KdArtiID = KdArti.ID
JOIN OPSets ON KdArti.ArtikelID = OPSets.ArtikelID
JOIN Artikel ON OPSets.Artikel1ID = Artikel.ID
LEFT JOIN Lagerbestand ON Artikel.ID = Lagerbestand.ArtikelID
WHERE AnfKo.LieferDatum BETWEEN $STARTDATE$ AND $ENDDATE$
  AND EXISTS (
    SELECT o.*
    FROM OPSets o
    WHERE o.ArtikelID = Artikel.ID
  )
  AND AnfPo.Angefordert > 0
  AND AnfKo.ProduktionID = $2$
GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez, Lagerbestand.Menge
ORDER BY ArtikelNr ASC;
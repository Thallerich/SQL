WITH LastLief AS (
  SELECT ISNULL(OPSets.Artikel1ID, KdArti.ArtikelID) AS ArtikelID, LsKo.VsaID, MAX(LsKo.Datum) AS LetztesLieferdatum
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
  LEFT OUTER JOIN OPSets ON OPSets.ArtikelID = KdArti.ArtikelID
  GROUP BY ISNULL(OPSets.Artikel1ID, KdArti.ArtikelID), LsKo.VsaID
),
AnfArtikel AS (
  SELECT ISNULL(OPSets.Artikel1ID, KdArti.ArtikelID) AS ArtikelID, VsaAnf.VsaID, VsaAnf.Durchschnitt
  FROM VsaAnf
  JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
  LEFT OUTER JOIN OPSets ON KdArti.ArtikelID = OPSets.ArtikelID
)
SELECT Bereich.Bereich AS Produktbereich, Bereich.BereichBez AS Produktbereichsbezeichnung, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Artikel.EkPreis AS Einkaufspreis, Kunden.KdNr, Kunden.SuchCode AS Kunde, Standort.SuchCode AS StandortKurz, Standort.Bez AS Standort, MAX(LastLief.LetztesLieferdatum) AS [Letztes Auslieferdatum], SUM(AnfArtikel.Durchschnitt) AS [Durchschnittliche Liefermenge]
FROM Artikel
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN AnfArtikel ON AnfArtikel.ArtikelID = Artikel.ID
JOIN Vsa ON AnfArtikel.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN StandBer ON StandBer.StandKonID = Vsa.StandKonID AND StandBer.BereichID = Bereich.ID
JOIN Standort oN StandBer.ProduktionID = Standort.ID
LEFT OUTER JOIN LastLief ON LastLief.ArtikelID = Artikel.ID AND LastLief.VsaID = Vsa.ID
WHERE Bereich.Bereich = N'OP'
  AND ArtGru.Steril = 0
  AND NOT EXISTS (
    SELECT OPSets.*
    FROM OPSets
    WHERE OPSets.ArtikelID = Artikel.ID
  )
  AND Artikel.ID > 0
GROUP BY Bereich.Bereich, Bereich.BereichBez, Artikel.ArtikelNr, Artikel.ArtikelBez, Artikel.EkPreis, Kunden.KdNr, Kunden.SuchCode, Standort.SuchCode, Standort.Bez;
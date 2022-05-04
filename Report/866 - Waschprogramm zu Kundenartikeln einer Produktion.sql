WITH SelectedStandort AS (
  SELECT Standort.ID, Standort.SuchCode
  FROM Standort
  WHERE Standort.ID IN ($1$)
)
SELECT SelectedStandort.SuchCode AS Produktion, Kunden.KdNr, Kunden.SuchCode AS Kunde, Bereich.BereichBez$LAN$ AS Produktbereich, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, KdArti.Variante, WaschPrg.WaschPrgBez$LAN$ AS Waschprogramm
FROM KdArti
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN WaschPrg ON KdArti.WaschPrgID = WaschPrg.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
CROSS JOIN SelectedStandort
WHERE KdArti.Status != N'I'
  AND Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1
  AND EXISTS (
    SELECT Vsa.ID
    FROM Vsa
    JOIN StandBer ON StandBer.StandKonID = Vsa.StandKonID
    WHERE StandBer.BereichID = KdBer.BereichID
      AND Vsa.KundenID = Kunden.ID
      AND StandBer.ProduktionID IN (SELECT ID FROM SelectedStandort)
      AND Vsa.Status = N'A'
  )
ORDER BY Produktion, KdNr, ArtikelNr, Variante;
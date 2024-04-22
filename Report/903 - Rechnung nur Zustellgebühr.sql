SELECT Firma.SuchCode AS Firma, RechKo.RechNr, RechKo.RechDat, Kunden.KdNr, Kunden.SuchCode AS Kunde, RechKo.NettoWert, RechKo.BruttoWert
FROM RechKo
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN Firma ON RechKo.FirmaID = Firma.ID
WHERE RechKo.Status < N'L'
  AND RechKo.ID > 0
  AND RechKo.FirmaID IN ($1$)
  AND EXISTS (
    SELECT RechPo.*
    FROM RechPo
    JOIN KdArti ON RechPo.KdArtiID = KdArti.ID
    JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
    WHERE RechPo.RechKoID = RechKo.ID
      AND Artikel.ArtikelNr = N'ZUS'
  )
  AND NOT EXISTS (
    SELECT RechPo.*
    FROM RechPo
    JOIN KdArti ON RechPo.KdArtiID = KdArti.ID
    JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
    WHERE RechPo.RechKoID = RechKo.ID
      AND Artikel.ArtikelNr != N'ZUS'
  )
ORDER BY RechKo.RechNr DESC;
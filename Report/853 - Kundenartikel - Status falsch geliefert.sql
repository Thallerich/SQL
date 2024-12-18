SELECT Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez AS Artikelbezeichnung,
  KdArti.Variante,
  KdArti.WaschPreis AS Bearbeitungspreis,
  KdArti.LeasPreis AS Leasingpreis,
  LiefKdArti.Menge AS Liefermenge,
  LiefKdArti.ErsteLieferung AS [Datum erste Lieferung],
  LiefKdArti.LetzteLieferung AS [Datum letzte Lieferung],
  KdArti.ID AS KdArtiID
FROM KdArti
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
LEFT JOIN (
  SELECT LsPo.KdArtiID, SUM(LsPo.Menge) AS Menge, MIN(LsKo.Datum) AS ErsteLieferung, MAX(LsKo.Datum) AS LetzteLieferung
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  GROUP BY LsPo.KdArtiID
) AS LiefKdArti ON LiefKdArti.KdArtiID = KdArti.ID
WHERE Kunden.ID IN ($10$)
  AND KdBer.ServiceID IN ($11$)
  AND (($12$ = 1 AND KdArti.WaschPreis = 0 AND KdArti.LeasPreis = 0) OR ($12$ = 0))
  AND KdArti.Status = N'F';
SELECT Firma.SuchCode AS Firma, [Zone].ZonenCode AS Vertriebszone, KdGf.KurzBez AS Geschäftsbereich, Standort.Bez AS Hauptstandort, Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez AS Reparatur, KdArti.WaschPreis AS Bearbeitungspreis, KdArti.LeasPreis
FROM KdArti
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
WHERE Kunden.AdrArtID = 1
  AND Kunden.[Status] = N'A'
  AND Firma.SuchCode = N'FA14'
  AND KdArti.LeasPreis != 0
  AND NOT EXISTS (
    SELECT EinzHist.*
    FROM EinzHist
    WHERE EinzHist.ArtikelID = KdArti.ArtikelID
      AND EinzHist.EinzHistTyp = 1
      AND EinzHist.PoolFkt = 0
      AND CAST(GETDATE() AS date) BETWEEN EinzHist.EinzHistVon AND EinzHist.EinzHistBis
  )
  AND NOT EXISTS (
    SELECT VsaAnf.*
    FROM VsaAnf
    WHERE VsaAnf.KdArtiID = KdArti.ID
      AND VsaAnf.Bestand != 0
  )
  AND NOT EXISTS (
    SELECT VsaLeas.*
    FROM VsaLeas
    WHERE VsaLeas.KdArtiID = KdArti.ID
      AND VsaLeas.Menge > 0
  )
  AND EXISTS (
    SELECT LsPo.*
    FROM LsPo
    JOIN LsKo ON LsPo.LsKoID = LsKo.ID
    WHERE LsPo.KdArtiID = KdArti.ID
      AND LsKo.Datum >= DATEFROMPARTS(DATEPART(year, DATEADD(month, -1, GETDATE())), DATEPART(month, DATEADD(month, -1, GETDATE())), 1)
      AND LsPo.Menge != 0
  );
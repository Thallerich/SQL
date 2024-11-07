SELECT Firma.SuchCode AS Firma, Kunden.KdNr, Kunden.SuchCode, Wae.IsoCode AS Vertragswährung, LsKo.LsNr, LsKo.Datum, Artikel.ArtikelNr, Artikel.ArtikelBez, KdArti.Variante, LsPo.Menge, LsPo.EPreis AS Einzelpreis, LsPo.Menge * LsPo.EPreis AS Positionssumme
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Wae ON Kunden.VertragWaeID = Wae.ID
JOIN BrLauf ON Kunden.BrLaufID = BrLauf.ID
WHERE LsKo.[Status] = N'Q'
  AND LsKo.Datum >= N'2024-10-01'
  AND LsKo.Datum <= N'2024-10-31'
  AND LsPo.RechPoID = -1
  AND LsPo.EPreis != 0
  AND (BrLauf.ID = -1 OR BrLauf.AuchMonatsabschl = 1);
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, LsKo.LsNr, LsKo.Datum AS Lieferdatum, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Produktion.SuchCode AS Produktion, Expedition.SuchCode AS Expedition, Bereich.Bereich AS Produktbereich, KdArti.WaschPreis, KdArti.LeasPreis, LsPo.EPreis, SUM(LsPo.Menge) AS Menge, LsPo.InternKalkPreis
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Standort AS Produktion ON LsPo.ProduktionID = Produktion.ID
JOIN Fahrt ON LsKo.FahrtID = Fahrt.ID
JOIN Standort AS Expedition ON Fahrt.ExpeditionID = Expedition.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
WHERE LsKo.Datum BETWEEN N'2025-06-01' AND N'2025-06-30'
  AND LsKo.[Status] >= N'Q'
  AND LsKo.SentToSAP = 1
  AND LsKo.InternKalkFix = 1
  AND (LEFT(LsKo.Referenz, 7) != N'INTERN_' OR LsKo.Referenz IS NULL)
  AND KdGf.KurzBez IN (N'MED', N'GAST', N'JOB', N'SAEU', N'BM', N'RT', N'MIC')
  AND Firma.SuchCode = N'FA14'
  AND Produktion.SuchCode != N'BUDA'
  AND LsPo.InternKalkPreis != 0
GROUP BY Kunden.KdNr, Kunden.SuchCode, LsKo.LsNr, LsKo.Datum, Artikel.ArtikelNr, Artikel.ArtikelBez, Produktion.SuchCode, Expedition.SuchCode, Bereich.Bereich, KdArti.WaschPreis, KdArti.LeasPreis, LsPo.EPreis, LsPo.InternKalkPreis;

GO
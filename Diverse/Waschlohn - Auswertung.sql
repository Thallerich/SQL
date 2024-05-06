SELECT Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Produktion.SuchCode AS Wäscher,
  Produktion.Bez AS [Wäscher Bezeichnung],
  Artikel.ArtikelNr,
  Artikel.ArtikelBez,
  Artikelkategorie = 
    CASE
      WHEN UPPER(Artikel.ArtikelBez) LIKE N'%T-SHIRT%' THEN N'T-Shirt'
      WHEN UPPER(Artikel.ArtikelBez) LIKE N'%BUNDHOSE%' OR UPPER(Artikel.ArtikelBez) LIKE N'% BH %' THEN N'Bundhose'
    END,
  KdArti.WaschPreis AS Bearbeitungspreis,
  KdArti.LeasPreis AS Mietpreis,
  CAST(SUM(LsPo.Menge) AS numeric(15,4)) AS Liefermenge,
  LsPo.InternKalkPreis AS Waschlohnpreis,
  CAST(SUM(LsPo.Menge * LsPo.InternKalkPreis) AS money) AS Waschlohn
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Standort AS Produktion ON LsPo.ProduktionID = Produktion.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
WHERE Firma.SuchCode = N'FA14'
  AND KdGf.KurzBez IN (N'MED', N'GAST', N'JOB', N'SAEU', N'BM', N'RT', N'MIC')
  AND LsKo.Datum BETWEEN N'2024-04-01' AND N'2024-04-30'
  AND LsKo.Status >= N'Q'
  AND LsKo.SentToSAP = 1
  AND (LEFT(LsKo.Referenz, 7) != N'INTERN_' OR LsKo.Referenz IS NULL)
GROUP BY Kunden.KdNr, Kunden.SuchCode, Produktion.SuchCode, Produktion.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez, KdArti.WaschPreis, KdArti.LeasPreis, LsPo.InternKalkPreis;
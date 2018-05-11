DROP TABLE IF EXISTS #Waschlohn;

SELECT Kunden.KdNr, Kunden.Debitor, KdGf.KurzBez AS SGF, RechKo.RechNr, RechKo.RechDat, Bereich.BereichBez AS Produktbereich, IIF(Artikel.ID < 0, N'', Artikel.ArtikelNr) AS ArtikelNr, ISNULL(Artikel.ArtikelBez, N'') AS Artikelbezeichnung, SUM(FibuDet.Menge) AS VerrechMenge, FibuDet.EPreis, SUM(FibuDet.GPreis) AS UmsatzNetto, Konten.Konto AS Erlöskonto, CAST(KdGf.FibuNr AS nchar(3)) + RechPo.KsSt AS Kostenträger, RechPo.KsSt, FibuDet.Differenz, FibuDet.VsaID, FibuDet.KdArtiID, FibuDet.BereichID
INTO #Waschlohn
FROM FibuDet WITH (NOLOCK)
JOIN Bereich WITH (NOLOCK) ON FibuDet.BereichID = Bereich.ID
JOIN KdArti WITH (NOLOCK) ON FibuDet.KdArtiID = KdArti.ID
JOIN Artikel WITH (NOLOCK) ON KdArti.ArtikelID = Artikel.ID
JOIN RechPo WITH (NOLOCK) ON FibuDet.RechPoID = RechPo.ID
JOIN RechKo WITH (NOLOCK) ON FibuDet.RechKoID = RechKo.ID
JOIN Konten WITH (NOLOCK) ON RechPo.KontenID = Konten.ID
JOIN Kunden WITH (NOLOCK) ON RechKo.KundenID = Kunden.ID
JOIN KdGf WITH (NOLOCK) ON Kunden.KdGfID = KdGf.ID
WHERE FibuDet.FibuExpID IN (
  SELECT DISTINCT RechKo.FibuExpID
  FROM RechKo
  WHERE RechKo.RechDat BETWEEN N'2018-04-01' AND N'2018-04-30'
    AND RechKo.FirmaID = (
      SELECT Firma.ID
      FROM Firma
      WHERE Firma.SuchCode = N'WM'
    )
  AND KdGf.KurzBez <> N'ÖS'
)
GROUP BY Kunden.KdNr, Kunden.Debitor, KdGf.KurzBez, RechKo.RechNr, RechKo.RechDat, Bereich.BereichBez, IIF(Artikel.ID < 0, N'', Artikel.ArtikelNr), Artikel.ArtikelBez, FibuDet.EPreis, Konten.Konto, CAST(KdGf.FibuNr AS nchar(3)) + RechPo.KsSt, RechPo.KsSt, FibuDet.Differenz, FibuDet.VsaID, FibuDet.KdArtiID, FibuDet.BereichID;

DROP TABLE IF EXISTS #LMenge;

SELECT LsKo.VsaID, LsPo.KdArtiID, KdBer.BereichID, Kunden.KdNr, Kunden.Debitor, KdGf.KurzBez AS SGF, Artikel.ArtikelNr, Artikel.ArtikelBez, LsPo.EPreis, SUM(LsPo.Menge) AS Liefermenge, Standort.SuchCode AS Produzent, Standort.FibuNr
INTO #LMenge
FROM LsPo WITH (NOLOCK)
JOIN LsKo WITH (NOLOCK) ON LsPo.LsKoID = LsKo.ID
JOIN Standort WITH (NOLOCK) ON LsPo.ProduktionID = Standort.ID
JOIN KdArti WITH (NOLOCK) ON LsPo.KdArtiID = KdArti.ID
JOIN Artikel WITH (NOLOCK) ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer WITH (NOLOCK) ON KdArti.KdBerID = KdBer.ID
JOIN Kunden WITH (NOLOCK) ON KdArti.KundenID = Kunden.ID
JOIN KdGf WITH (NOLOCK) ON Kunden.KdGfID = KdGf.ID
WHERE LsKo.Datum BETWEEN N'2018-04-01' AND N'2018-04-30'
  AND Kunden.FirmaID = (SELECT Firma.ID FROM Firma WHERE Firma.SuchCode = N'WM')
  AND Artikel.ID > 0
  AND KdGf.KurzBez <> N'ÖS'
GROUP BY LsKo.VsaID, LsPo.KdArtiID, KdBer.BereichID, Kunden.KdNr, Kunden.Debitor, KdGf.KurzBez, Artikel.ArtikelNr, Artikel.ArtikelBez, LsPo.EPreis, Standort.SuchCode, Standort.FibuNr;

SELECT KdNr, Debitor, SGF, RechNr AS Rechnungsnummer, RechDat AS Rechnungsdatum, Produktbereich, ArtikelNr, Artikelbezeichnung, SUM(VerrechMenge) AS [verrechnete Menge], EPreis AS Einzelpreis, SUM(UmsatzNetto) AS UmsatzNetto, Erlöskonto, [Kostenträger FIBU-Übergabe], SUM(Liefermenge) AS Liefermenge, Produzent, [Kostenträger Produzent], Differenz
FROM (
  SELECT ISNULL(Waschlohn.KdNr, LMenge.KdNr) AS KdNr, ISNULL(Waschlohn.Debitor, LMenge.Debitor) AS Debitor, ISNULL(Waschlohn.SGF, LMenge.SGF) AS SGF, Waschlohn.RechNr, Waschlohn.RechDat, Waschlohn.Produktbereich, ISNULL(Waschlohn.ArtikelNr, LMenge.ArtikelNr) AS ArtikelNr, ISNULL(Waschlohn.Artikelbezeichnung, LMenge.ArtikelBez) AS Artikelbezeichnung, ISNULL(Waschlohn.VerrechMenge, 0) AS VerrechMenge, ISNULL(Waschlohn.EPreis, LMenge.EPreis) AS EPreis, ISNULL(Waschlohn.UmsatzNetto, 0) AS UmsatzNetto, Waschlohn.Erlöskonto, Waschlohn.Kostenträger AS [Kostenträger FIBU-Übergabe], ISNULL(LMenge.Liefermenge, 0) AS Liefermenge, ISNULL(LMenge.Produzent, Standort.SuchCode) AS Produzent, CAST(ISNULL(LMenge.FibuNr, Standort.FibuNr) AS nchar(3)) + RTRIM(Waschlohn.KsSt) AS [Kostenträger Produzent], Waschlohn.Differenz
  FROM #Waschlohn AS Waschlohn
  FULL OUTER JOIN #LMenge AS LMenge ON LMenge.VsaID = Waschlohn.VsaID AND LMenge.KdArtiID = Waschlohn.KdArtiID AND LMenge.BereichID = Waschlohn.BereichID AND LMenge.EPreis = Waschlohn.EPreis AND Waschlohn.Differenz = 0
  LEFT OUTER JOIN Vsa WITH (NOLOCK) ON Waschlohn.VsaID = Vsa.ID
  LEFT OUTER JOIN StandBer WITH (NOLOCK) ON Vsa.StandKonID = StandBer.StandKonID AND StandBer.BereichID = Waschlohn.BereichID
  LEFT OUTER JOIN Standort WITH (NOLOCK) ON StandBer.ProduktionID = Standort.ID
) AS WaschlohnDaten
GROUP BY KdNr, Debitor, SGF, RechNr, RechDat, Produktbereich, ArtikelNr, Artikelbezeichnung, EPreis, Erlöskonto, [Kostenträger FIBU-Übergabe], Produzent, [Kostenträger Produzent], Differenz;
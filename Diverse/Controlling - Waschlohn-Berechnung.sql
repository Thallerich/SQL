DECLARE @FirmaID int = (SELECT Firma.ID FROM Firma WHERE Firma.SuchCode = N'51');
DECLARE @DatumVon date = CAST(N'2018-04-01' AS date);
DECLARE @DatumBis date = CAST(N'2018-04-30' AS date);

DROP TABLE IF EXISTS #Waschlohn;

SELECT Kunden.KdNr, Kunden.Debitor, KdGf.KurzBez AS SGF, RechKo.RechNr, RechKo.RechDat, Bereich.BereichBez AS Produktbereich, IIF(Artikel.ID < 0, N'', Artikel.ArtikelNr) AS ArtikelNr, ISNULL(Artikel.ArtikelBez, N'') AS Artikelbezeichnung, SUM(FibuDet.Menge) AS VerrechMenge, FibuDet.EPreis, SUM(FibuDet.GPreis) AS UmsatzNetto, Konten.Konto AS Erlöskonto, CAST(IIF(@FirmaID = 5001, 93, KdGf.FibuNr) AS nchar(3)) + RechPo.KsSt AS Kostenträger, RechPo.KsSt, FibuDet.Differenz, FibuDet.VsaID, FibuDet.KdArtiID, FibuDet.BereichID, KdGf.ID AS KdGfID, Kunden.MWstID, Artikel.ArtGruID
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
  WHERE RechKo.RechDat BETWEEN @DatumVon AND @DatumBis
    AND RechKo.FirmaID = @FirmaID
  AND KdGf.KurzBez <> N'ÖS'
)
GROUP BY Kunden.KdNr, Kunden.Debitor, KdGf.KurzBez, RechKo.RechNr, RechKo.RechDat, Bereich.BereichBez, IIF(Artikel.ID < 0, N'', Artikel.ArtikelNr), Artikel.ArtikelBez, FibuDet.EPreis, Konten.Konto, CAST(IIF(@FirmaID = 5001, 93, KdGf.FibuNr) AS nchar(3)) + RechPo.KsSt, RechPo.KsSt, FibuDet.Differenz, FibuDet.VsaID, FibuDet.KdArtiID, FibuDet.BereichID, KdGf.ID, Kunden.MwStID, Artikel.ArtGruID;

DROP TABLE IF EXISTS #LMenge;

SELECT LsKo.VsaID, LsPo.KdArtiID, KdBer.BereichID, KdGf.ID AS KdGfID, Kunden.MwStID, Artikel.ArtGruID, Bereich.BereichBez AS Produktbereich, Kunden.KdNr, Kunden.Debitor, KdGf.KurzBez AS SGF, Artikel.ArtikelNr, Artikel.ArtikelBez, SUM(LsPo.Menge) AS Liefermenge, Standort.SuchCode AS Produzent, Standort.FibuNr
INTO #LMenge
FROM LsPo WITH (NOLOCK)
JOIN LsKo WITH (NOLOCK) ON LsPo.LsKoID = LsKo.ID
JOIN Standort WITH (NOLOCK) ON LsPo.ProduktionID = Standort.ID
JOIN KdArti WITH (NOLOCK) ON LsPo.KdArtiID = KdArti.ID
JOIN Artikel WITH (NOLOCK) ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer WITH (NOLOCK) ON KdArti.KdBerID = KdBer.ID
JOIN Bereich WITH (NOLOCK) ON KdBer.BereichID = Bereich.ID
JOIN Kunden WITH (NOLOCK) ON KdArti.KundenID = Kunden.ID
JOIN KdGf WITH (NOLOCK) ON Kunden.KdGfID = KdGf.ID
WHERE LsKo.Datum BETWEEN @DatumVon AND @DatumBis
  AND Kunden.FirmaID = @FirmaID
  AND Artikel.ID > 0
  AND KdGf.KurzBez <> N'ÖS'
GROUP BY LsKo.VsaID, LsPo.KdArtiID, KdBer.BereichID, KdGf.ID, Kunden.MwStID, Artikel.ArtGruID, Bereich.BereichBez, Kunden.KdNr, Kunden.Debitor, KdGf.KurzBez, Artikel.ArtikelNr, Artikel.ArtikelBez, Standort.SuchCode, Standort.FibuNr;

DROP TABLE IF EXISTS #ResultWLohn;

SELECT ISNULL(Waschlohn.KdNr, LMenge.KdNr) AS KdNr, ISNULL(Waschlohn.Debitor, LMenge.Debitor) AS Debitor, ISNULL(Waschlohn.SGF, LMenge.SGF) AS SGF, Waschlohn.RechNr, Waschlohn.RechDat, ISNULL(Waschlohn.Produktbereich, LMenge.Produktbereich) AS Produktbereich, ISNULL(Waschlohn.ArtikelNr, LMenge.ArtikelNr) AS ArtikelNr, ISNULL(Waschlohn.Artikelbezeichnung, LMenge.ArtikelBez) AS Artikelbezeichnung, ISNULL(Waschlohn.VerrechMenge, 0) AS VerrechMenge, Waschlohn.EPreis, ISNULL(Waschlohn.UmsatzNetto, 0) AS UmsatzNetto, Waschlohn.Erlöskonto, Waschlohn.Kostenträger AS [Kostenträger FIBU-Übergabe], ISNULL(LMenge.Liefermenge, 0) AS Liefermenge, ISNULL(LMenge.Produzent, Standort.SuchCode) AS Produzent, CAST(ISNULL(LMenge.FibuNr, Standort.FibuNr) AS nchar(3)) COLLATE Latin1_General_CS_AS AS FibuNr, RTRIM(Waschlohn.KsSt) AS Kostenträger, Waschlohn.Differenz, ISNULL(Waschlohn.BereichID, LMenge.BereichID) AS BereichID, ISNULL(Waschlohn.KdGfID, LMenge.KdGfID) AS KdGfID, ISNULL(Waschlohn.MwStID, LMenge.MwStID) AS MwStID, ISNULL(Waschlohn.ArtGruID, LMenge.ArtGruID) AS ArtGruID
INTO #ResultWLohn
FROM #Waschlohn AS Waschlohn
FULL OUTER JOIN #LMenge AS LMenge ON LMenge.VsaID = Waschlohn.VsaID AND LMenge.KdArtiID = Waschlohn.KdArtiID AND LMenge.BereichID = Waschlohn.BereichID AND Waschlohn.Differenz = 0
LEFT OUTER JOIN Vsa WITH (NOLOCK) ON Waschlohn.VsaID = Vsa.ID
LEFT OUTER JOIN StandBer WITH (NOLOCK) ON Vsa.StandKonID = StandBer.StandKonID AND StandBer.BereichID = Waschlohn.BereichID
LEFT OUTER JOIN Standort WITH (NOLOCK) ON StandBer.ProduktionID = Standort.ID;

UPDATE ResultWLohn SET Kostenträger = KontoLogik.AbwKostenstelle
FROM #ResultWLohn AS ResultWLohn
JOIN (
  SELECT BereichID, KdGfID, MWStID, ArtGruID, AbwKostenstelle
  FROM RPoKonto
  WHERE RPoTypeID = 2
    AND BrancheID = -1
    AND Art = N'B'
    AND FirmaID = @FirmaID
  GROUP BY BereichID, KdGfID, MwStID, ArtGruID, AbwKostenstelle
) AS KontoLogik ON KontoLogik.BereichID = ResultWLohn.BereichID AND KontoLogik.KdGfID = ResultWLohn.KdGfID AND KontoLogik.MWStID = ResultWLohn.MwStID AND KontoLogik.ArtGruID = ResultWLohn.ArtGruID
WHERE ResultWLohn.Kostenträger IS NULL;

SELECT KdNr, Debitor, SGF, RechNr AS Rechnungsnummer, RechDat AS Rechnungsdatum, Produktbereich, ArtikelNr, Artikelbezeichnung, SUM(VerrechMenge) AS [verrechnete Menge], EPreis AS Einzelpreis, SUM(UmsatzNetto) AS UmsatzNetto, Erlöskonto, [Kostenträger FIBU-Übergabe], SUM(Liefermenge) AS Liefermenge, Produzent, RTRIM(FibuNr) + Kostenträger AS [Kostenträger Produzent], Differenz
FROM #ResultWLohn AS WaschlohnDaten
GROUP BY KdNr, Debitor, SGF, RechNr, RechDat, Produktbereich, ArtikelNr, Artikelbezeichnung, EPreis, Erlöskonto, [Kostenträger FIBU-Übergabe], Produzent, RTRIM(FibuNr) + Kostenträger, Differenz;
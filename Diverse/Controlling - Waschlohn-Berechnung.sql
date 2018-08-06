DROP TABLE IF EXISTS #Waschlohn;
DROP TABLE IF EXISTS #LieferMenge;
DROP TABLE IF EXISTS #ResultWLohnUmsatz;
DROP TABLE IF EXISTS #ResultWLohnStueck;
GO

DECLARE @FirmaID int = (SELECT Firma.ID FROM Firma WHERE Firma.SuchCode = N'SAL');  --WOMI: Wozabal Miettex; UKLU: Umlauft; SAL: Salesianer
DECLARE @DatumVon date = CAST(N'2018-07-01' AS date);
DECLARE @DatumBis date = CAST(N'2018-07-31' AS date);
DECLARE @BerufsgruppeID int = (SELECT CAST(Settings.ValueMemo AS int) FROM Settings WHERE Settings.Parameter = N'ID_ARTIKEL_BERUFSGRUPPE');

--* Debug: Netto-Summe der Rechnungen
--SELECT FORMAT(SUM(NettoWert), N'C', N'de-AT') FROM RechKo WHERE RechKo.RechDat BETWEEN @DatumVon AND @DatumBis AND FirmaID = @FirmaID AND RechKo.FibuExpID > 0;

SELECT FibuDet.ID AS FibuDetID, Kunden.KdNr, Kunden.Debitor, KdGf.KurzBez AS SGF, RechKo.RechNr, RechKo.RechDat, Bereich.BereichBez AS Produktbereich, IIF(Artikel.ID < 0, N'', Artikel.ArtikelNr) AS ArtikelNr, ISNULL(Artikel.ArtikelBez, N'') AS Artikelbezeichnung, SUM(FibuDet.Menge) AS VerrechMenge, FibuDet.EPreis, SUM(FibuDet.GPreis) AS UmsatzNetto, Konten.Konto AS Erlöskonto, CAST(IIF(@FirmaID = 5001, 93, IIF(@FirmaID = 5260, 90, KdGf.FibuNr)) AS nchar(3)) COLLATE Latin1_General_CS_AS AS FibuNrVertrieb, RechPo.KsSt AS KostenträgerVertrieb, RechPo.KsSt, FibuDet.Differenz, FibuDet.VsaID, FibuDet.KdArtiID, FibuDet.BereichID, KdGf.ID AS KdGfID, Kunden.MWstID, Artikel.ArtGruID, CAST(0 AS bit) AS IsLeasing, CAST(0 AS bit) AS IsStueck, CAST(IIF(Artikel.ID = @BerufsgruppeID, 1, 0) AS bit) AS IsBerufsgruppe
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
  )
  AND KdGf.KurzBez IN (N'MED', N'GAST', N'JOB')
GROUP BY FibuDet.ID, Kunden.KdNr, Kunden.Debitor, KdGf.KurzBez, RechKo.RechNr, RechKo.RechDat, Bereich.BereichBez, IIF(Artikel.ID < 0, N'', Artikel.ArtikelNr), Artikel.ArtikelBez, FibuDet.EPreis, Konten.Konto, CAST(IIF(@FirmaID = 5001, 93, IIF(@FirmaID = 5260, 90, KdGf.FibuNr)) AS nchar(3)) COLLATE Latin1_General_CS_AS, RechPo.KsSt, RechPo.KsSt, FibuDet.Differenz, FibuDet.VsaID, FibuDet.KdArtiID, FibuDet.BereichID, KdGf.ID, Kunden.MwStID, Artikel.ArtGruID, CAST(IIF(Artikel.ID = @BerufsgruppeID, 1, 0) AS bit);

UPDATE WL SET IsLeasing = 1
FROM #Waschlohn AS WL
JOIN (
  SELECT FibuDet.Differenz, FibuDet.VsaID, FibuDet.KdArtiID, FibuDet.BereichID, FibuDet.EPreis
  FROM FibuDet WITH (NOLOCK)
  JOIN RechPo WITH (NOLOCK) ON FibuDet.RechPoID = RechPo.ID
  JOIN RPoType WITH (NOLOCK) ON RechPo.RPoTypeID = RPoType.ID
  WHERE FibuDet.FibuExpID IN (
      SELECT DISTINCT RechKo.FibuExpID
      FROM RechKo
      WHERE RechKo.RechDat BETWEEN @DatumVon AND @DatumBis
        AND RechKo.FirmaID = @FirmaID
      )
    AND RPoType.StatistikGruppe = N'Leasing'
) AS x ON WL.Differenz = x.Differenz AND WL.VsaID = x.VsaID AND WL.KdArtiID = x.KdArtiID AND WL.BereichID = x.BereichID AND WL.EPreis = x.EPreis;

UPDATE WL SET IsStueck = 1
FROM #Waschlohn AS WL
JOIN (
  SELECT FibuDet.Differenz, FibuDet.VsaID, FibuDet.KdArtiID, FibuDet.BereichID, FibuDet.EPreis
  FROM FibuDet WITH (NOLOCK)
  JOIN RechPo WITH (NOLOCK) ON FibuDet.RechPoID = RechPo.ID
  JOIN RPoType WITH (NOLOCK) ON RechPo.RPoTypeID = RPoType.ID
  WHERE FibuDet.FibuExpID IN (
      SELECT DISTINCT RechKo.FibuExpID
      FROM RechKo
      WHERE RechKo.RechDat BETWEEN @DatumVon AND @DatumBis
        AND RechKo.FirmaID = @FirmaID
      )
    AND RPoType.StatistikGruppe <> N'Leasing'
) AS x ON WL.Differenz = x.Differenz AND WL.VsaID = x.VsaID AND WL.KdArtiID = x.KdArtiID AND WL.BereichID = x.BereichID AND WL.EPreis = x.EPreis;

SELECT LsKo.VsaID, LsPo.KdArtiID, KdBer.BereichID, KdGf.ID AS KdGfID, Kunden.MwStID, Artikel.ArtGruID, Bereich.BereichBez AS Produktbereich, Kunden.KdNr, Kunden.Debitor, KdGf.KurzBez AS SGF, Artikel.ArtikelNr, Artikel.ArtikelBez, SUM(LsPo.Menge) AS Liefermenge, Standort.SuchCode AS Produzent, Standort.FibuNr, CAST(IIF(@FirmaID = 5001, 93, IIF(@FirmaID = 5260, 90, KdGf.FibuNr)) AS nchar(3)) COLLATE Latin1_General_CS_AS AS FibuNrVertrieb
INTO #LieferMenge
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
  AND KdGf.KurzBez IN (N'MED', N'GAST', N'JOB')
GROUP BY LsKo.VsaID, LsPo.KdArtiID, KdBer.BereichID, KdGf.ID, Kunden.MwStID, Artikel.ArtGruID, Bereich.BereichBez, Kunden.KdNr, Kunden.Debitor, KdGf.KurzBez, Artikel.ArtikelNr, Artikel.ArtikelBez, Standort.SuchCode, Standort.FibuNr, CAST(IIF(@FirmaID = 5001, 93, IIF(@FirmaID = 5260, 90, KdGf.FibuNr)) AS nchar(3)) COLLATE Latin1_General_CS_AS;

SELECT ISNULL(Waschlohn.KdNr, LieferMenge.KdNr) AS KdNr, ISNULL(Waschlohn.Debitor, LieferMenge.Debitor) AS Debitor, ISNULL(Waschlohn.SGF, LieferMenge.SGF) AS SGF, Waschlohn.RechNr, Waschlohn.RechDat, ISNULL(Waschlohn.Produktbereich, LieferMenge.Produktbereich) AS Produktbereich, ISNULL(Waschlohn.ArtikelNr, LieferMenge.ArtikelNr) AS ArtikelNr, ISNULL(Waschlohn.Artikelbezeichnung, LieferMenge.ArtikelBez) AS Artikelbezeichnung, SUM(ISNULL(Waschlohn.VerrechMenge, 0)) AS VerrechMenge, SUM(ISNULL(Waschlohn.UmsatzNetto, 0)) AS UmsatzNetto, Waschlohn.Erlöskonto, ISNULL(Waschlohn.FibuNrVertrieb, LieferMenge.FibuNrVertrieb) AS FibuNrVertrieb, Waschlohn.KostenträgerVertrieb, SUM(ISNULL(LieferMenge.Liefermenge, 0)) AS Liefermenge, ISNULL(LieferMenge.Produzent, Standort.SuchCode) AS Produzent, CAST(ISNULL(LieferMenge.FibuNr, Standort.FibuNr) AS nchar(3)) COLLATE Latin1_General_CS_AS AS FibuNr, RTRIM(Waschlohn.KsSt) AS Kostenträger, Waschlohn.Differenz, ISNULL(Waschlohn.BereichID, LieferMenge.BereichID) AS BereichID, ISNULL(Waschlohn.KdGfID, LieferMenge.KdGfID) AS KdGfID, ISNULL(Waschlohn.MwStID, LieferMenge.MwStID) AS MwStID, ISNULL(Waschlohn.ArtGruID, LieferMenge.ArtGruID) AS ArtGruID, MAX(CAST(ISNULL(Waschlohn.IsLeasing, 0) AS tinyint)) AS IsLeasing, MAX(CAST(ISNULL(Waschlohn.IsStueck, 0) AS tinyint)) AS IsStueck, MAX(CAST(ISNULL(Waschlohn.IsBerufsgruppe, 0) AS tinyint)) AS IsBerufsgruppe
INTO #ResultWLohnStueck
FROM #Waschlohn AS Waschlohn
FULL OUTER JOIN #LieferMenge AS LieferMenge ON LieferMenge.VsaID = Waschlohn.VsaID AND LieferMenge.KdArtiID = Waschlohn.KdArtiID AND LieferMenge.BereichID = Waschlohn.BereichID AND Waschlohn.Differenz = 0
LEFT OUTER JOIN Vsa WITH (NOLOCK) ON Waschlohn.VsaID = Vsa.ID
LEFT OUTER JOIN StandBer WITH (NOLOCK) ON Vsa.StandKonID = StandBer.StandKonID AND StandBer.BereichID = Waschlohn.BereichID
LEFT OUTER JOIN Standort WITH (NOLOCK) ON StandBer.ProduktionID = Standort.ID
GROUP BY ISNULL(Waschlohn.KdNr, LieferMenge.KdNr), ISNULL(Waschlohn.Debitor, LieferMenge.Debitor), ISNULL(Waschlohn.SGF, LieferMenge.SGF), Waschlohn.RechNr, Waschlohn.RechDat, ISNULL(Waschlohn.Produktbereich, LieferMenge.Produktbereich), ISNULL(Waschlohn.ArtikelNr, LieferMenge.ArtikelNr), ISNULL(Waschlohn.Artikelbezeichnung, LieferMenge.ArtikelBez), Waschlohn.Erlöskonto, ISNULL(Waschlohn.FibuNrVertrieb, LieferMenge.FibuNrVertrieb), Waschlohn.KostenträgerVertrieb, ISNULL(LieferMenge.Produzent, Standort.SuchCode), CAST(ISNULL(LieferMenge.FibuNr, Standort.FibuNr) AS nchar(3)) COLLATE Latin1_General_CS_AS, RTRIM(Waschlohn.KsSt), Waschlohn.Differenz, ISNULL(Waschlohn.BereichID, LieferMenge.BereichID), ISNULL(Waschlohn.KdGfID, LieferMenge.KdGfID), ISNULL(Waschlohn.MwStID, LieferMenge.MwStID), ISNULL(Waschlohn.ArtGruID, LieferMenge.ArtGruID);

SELECT Waschlohn.KdNr, Waschlohn.Debitor, Waschlohn.SGF, Waschlohn.RechNr, Waschlohn.RechDat, Waschlohn.Produktbereich, Waschlohn.ArtikelNr, Waschlohn.Artikelbezeichnung, SUM(ISNULL(Waschlohn.VerrechMenge, 0)) AS VerrechMenge, SUM(ISNULL(Waschlohn.UmsatzNetto, 0)) AS UmsatzNetto, Waschlohn.Erlöskonto, Waschlohn.FibuNrVertrieb, Waschlohn.KostenträgerVertrieb, Standort.SuchCode AS Produzent, CAST(Standort.FibuNr AS nchar(3)) COLLATE Latin1_General_CS_AS AS FibuNr, RTRIM(Waschlohn.KsSt) AS Kostenträger, Waschlohn.Differenz, Waschlohn.BereichID, Waschlohn.KdGfID, Waschlohn.MwStID, Waschlohn.ArtGruID, MAX(CAST(Waschlohn.IsLeasing AS tinyint)) AS IsLeasing, MAX(CAST(Waschlohn.IsStueck AS tinyint)) AS IsStueck, MAX(CAST(Waschlohn.IsBerufsgruppe AS tinyint)) AS IsBerufsgruppe
INTO #ResultWLohnUmsatz
FROM #Waschlohn AS Waschlohn
LEFT OUTER JOIN Vsa WITH (NOLOCK) ON Waschlohn.VsaID = Vsa.ID
LEFT OUTER JOIN StandBer WITH (NOLOCK) ON Vsa.StandKonID = StandBer.StandKonID AND StandBer.BereichID = Waschlohn.BereichID
LEFT OUTER JOIN Standort WITH (NOLOCK) ON StandBer.ProduktionID = Standort.ID
GROUP BY Waschlohn.KdNr, Waschlohn.Debitor, Waschlohn.SGF, Waschlohn.RechNr, Waschlohn.RechDat, Waschlohn.Produktbereich, Waschlohn.ArtikelNr, Waschlohn.Artikelbezeichnung, Waschlohn.Erlöskonto, Waschlohn.FibuNrVertrieb, Waschlohn.KostenträgerVertrieb, Standort.SuchCode, CAST(Standort.FibuNr AS nchar(3)) COLLATE Latin1_General_CS_AS, RTRIM(Waschlohn.KsSt), Waschlohn.Differenz, Waschlohn.BereichID, Waschlohn.KdGfID, Waschlohn.MwStID, Waschlohn.ArtGruID;

UPDATE ResultWLohnUmsatz SET Kostenträger = KontoLogik.AbwKostenstelle
FROM #ResultWLohnUmsatz AS ResultWLohnUmsatz
JOIN (
  SELECT BereichID, KdGfID, MWStID, ArtGruID, AbwKostenstelle
  FROM RPoKonto
  WHERE RPoTypeID = 2
    AND BrancheID = -1
    AND Art = N'B'
    AND FirmaID = @FirmaID
  GROUP BY BereichID, KdGfID, MwStID, ArtGruID, AbwKostenstelle
) AS KontoLogik ON KontoLogik.BereichID = ResultWLohnUmsatz.BereichID AND KontoLogik.KdGfID = ResultWLohnUmsatz.KdGfID AND KontoLogik.MWStID = ResultWLohnUmsatz.MwStID AND KontoLogik.ArtGruID = ResultWLohnUmsatz.ArtGruID
WHERE ResultWLohnUmsatz.Kostenträger IS NULL;

UPDATE #ResultWLohnUmsatz SET KostenträgerVertrieb = Kostenträger
WHERE KostenträgerVertrieb IS NULL;

UPDATE ResultWLohnStueck SET Kostenträger = KontoLogik.AbwKostenstelle
FROM #ResultWLohnStueck AS ResultWLohnStueck
JOIN (
  SELECT BereichID, KdGfID, MWStID, ArtGruID, AbwKostenstelle
  FROM RPoKonto
  WHERE RPoTypeID = 2
    AND BrancheID = -1
    AND Art = N'B'
    AND FirmaID = @FirmaID
  GROUP BY BereichID, KdGfID, MwStID, ArtGruID, AbwKostenstelle
) AS KontoLogik ON KontoLogik.BereichID = ResultWLohnStueck.BereichID AND KontoLogik.KdGfID = ResultWLohnStueck.KdGfID AND KontoLogik.MWStID = ResultWLohnStueck.MwStID AND KontoLogik.ArtGruID = ResultWLohnStueck.ArtGruID
WHERE ResultWLohnStueck.Kostenträger IS NULL;

UPDATE #ResultWLohnStueck SET KostenträgerVertrieb = Kostenträger
WHERE KostenträgerVertrieb IS NULL;

SELECT KdNr, Debitor, SGF AS Vertrieb, RechNr AS Rechnungsnummer, RechDat AS Rechnungsdatum, Produktbereich, ArtikelNr, Artikelbezeichnung, SUM(VerrechMenge) AS [verrechnete Menge], SUM(UmsatzNetto) AS UmsatzNetto, Erlöskonto, RTRIM(FibuNrVertrieb) + KostenträgerVertrieb [Kostenträger Vertrieb], Produzent, RTRIM(FibuNr) + Kostenträger AS [Kostenträger Produzent], Verrechnungsart = 
  CASE
    WHEN IsLeasing = 1 AND IsStueck = 0 THEN N'Pauschal'
    WHEN IsStueck = 1  AND IsLeasing = 0 THEN N'Stück'
    WHEN IsLeasing = 1 AND IsStueck = 1 THEN N'Splitting'
    WHEN IsBerufsgruppe = 1 THEN N'Berufsgruppen'
    ELSE N'(unbekannt)'
  END
FROM #ResultWLohnUmsatz AS WaschlohnDaten
GROUP BY KdNr, Debitor, SGF, RechNr, RechDat, Produktbereich, ArtikelNr, Artikelbezeichnung, Erlöskonto, RTRIM(FibuNrVertrieb) + KostenträgerVertrieb, Produzent, RTRIM(FibuNr) + Kostenträger,
  CASE
    WHEN IsLeasing = 1 AND IsStueck = 0 THEN N'Pauschal'
    WHEN IsStueck = 1  AND IsLeasing = 0 THEN N'Stück'
    WHEN IsLeasing = 1 AND IsStueck = 1 THEN N'Splitting'
    WHEN IsBerufsgruppe = 1 THEN N'Berufsgruppen'
    ELSE N'(unbekannt)'
  END;

SELECT KdNr, Debitor, SGF AS Vertrieb, Produktbereich, ArtikelNr, Artikelbezeichnung, SUM(Liefermenge) AS [Liefermenge], RTRIM(FibuNrVertrieb) + KostenträgerVertrieb [Kostenträger Vertrieb], Produzent, RTRIM(FibuNr) + Kostenträger AS [Kostenträger Produzent], Verrechnungsart = 
  CASE
    WHEN IsLeasing = 1 AND IsStueck = 0 THEN N'Pauschal'
    WHEN IsStueck = 1  AND IsLeasing = 0 THEN N'Stück'
    WHEN IsLeasing = 1 AND IsStueck = 1 THEN N'Splitting'
    WHEN IsBerufsgruppe = 1 THEN N'Berufsgruppen'
    ELSE N'(unbekannt)'
  END
FROM #ResultWLohnStueck AS WaschlohnDaten
GROUP BY KdNr, Debitor, SGF, RechNr, RechDat, Produktbereich, ArtikelNr, Artikelbezeichnung, Erlöskonto, RTRIM(FibuNrVertrieb) + KostenträgerVertrieb, Produzent, RTRIM(FibuNr) + Kostenträger,
  CASE
    WHEN IsLeasing = 1 AND IsStueck = 0 THEN N'Pauschal'
    WHEN IsStueck = 1  AND IsLeasing = 0 THEN N'Stück'
    WHEN IsLeasing = 1 AND IsStueck = 1 THEN N'Splitting'
    WHEN IsBerufsgruppe = 1 THEN N'Berufsgruppen'
    ELSE N'(unbekannt)'
  END;

--* Debug: Netto-Summe Waschlohn - muss mit Netto-Summe Rechnungen übereinstimmen!
--SELECT FORMAT(SUM(UmsatzNetto), N'C', N'de-AT') FROM #ResultWLohnUmsatz;

--* Auswertung für Ascendum- und AUVA-Weiterverrechnung KLU:
/*
SELECT WLU.Erlöskonto, RTRIM(WLU.FibuNrVertrieb) + WLU.KostenträgerVertrieb AS [KTr WM], N'93' + WLU.Kostenträger AS [KTr USMK], FORMAT(SUM(WLU.UmsatzNetto), N'C', N'de-AT') AS Umsatz
FROM #ResultWLohnUmsatz AS WLU
JOIN Kunden ON WLU.KdNr = Kunden.KdNr
JOIN Holding ON Kunden.HoldingID = Holding.ID
WHERE Holding.Holding = N'AUVA'
  AND WLU.Produzent = N'UKLU'
GROUP BY WLU.Erlöskonto, RTRIM(WLU.FibuNrVertrieb) + WLU.KostenträgerVertrieb, N'93' + WLU.Kostenträger;

SELECT WLU.Erlöskonto, RTRIM(WLU.FibuNrVertrieb) + WLU.KostenträgerVertrieb AS [KTr WM], N'93' + WLU.Kostenträger AS [KTr USMK], FORMAT(SUM(WLU.UmsatzNetto), N'C', N'de-AT') AS Umsatz
FROM #ResultWLohnUmsatz AS WLU
JOIN Kunden ON WLU.KdNr = Kunden.KdNr
WHERE Kunden.KdNr = 30970
  AND WLU.Produzent = N'UKLU'
GROUP BY WLU.Erlöskonto, RTRIM(WLU.FibuNrVertrieb) + WLU.KostenträgerVertrieb, N'93' + WLU.Kostenträger;

*/
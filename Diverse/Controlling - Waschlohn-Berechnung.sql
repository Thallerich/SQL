DROP TABLE IF EXISTS #Waschlohn;
DROP TABLE IF EXISTS #LieferMenge;
DROP TABLE IF EXISTS #ResultWLohnUmsatz;
DROP TABLE IF EXISTS #ResultWLohnStueck;

DECLARE @FirmaID int = (SELECT Firma.ID FROM Firma WHERE Firma.SuchCode = N'FA14');  --WOMI: Wozabal Miettex; UKLU: Umlauft; FA14: Salesianer; SMP: Budweis
DECLARE @DatumVon date = CAST(N'2019-09-01' AS date);
DECLARE @DatumBis date = CAST(N'2019-09-30' AS date);
DECLARE @FibuPeriode nchar(7) = (SELECT CAST(DATEPART(year, @DatumBis) AS nchar(4)) + N'-' + IIF(DATEPART(month, @DatumBis) < 10, N'0', N'') + CAST(DATEPART(month, @DatumBis) AS nchar(2)));
DECLARE @BerufsgruppeID int = (SELECT CAST(Settings.ValueMemo AS int) FROM Settings WHERE Settings.Parameter = N'ID_ARTIKEL_BERUFSGRUPPE');
DECLARE @MonatAbgeschlossen bit = (SELECT IIF(FiBuPeriode > @FibuPeriode, 1, 0) FROM Firma WHERE Firma.ID = @FirmaID);
DECLARE @ErrorMsg nvarchar(100);

IF @FirmaID < 0 BEGIN
  SET @ErrorMsg = N'Bite eine Firma auswählen!';
  THROW 51500, @ErrorMsg, 1;
END;

IF @MonatAbgeschlossen = 0 BEGIN
  SET @ErrorMsg = N'Der Monat ' + @FibuPeriode + N' wurde für die gewählte Firma noch nicht abgeschlossen!';
  THROW 51000, @ErrorMsg, 1;
END;

SELECT Kunden.KdNr, Kunden.Debitor, KdGf.KurzBez AS SGF, Bereich.BereichBez AS Produktbereich, IIF(Artikel.ID < 0, N'', Artikel.ArtikelNr) AS ArtikelNr, ISNULL(Artikel.ArtikelBez, N'') AS Artikelbezeichnung, SUM(FibuDet.Menge) AS VerrechMenge, FibuDet.EPreis, SUM(FibuDet.GPreis) AS UmsatzNetto, Konten.Konto AS Erlöskonto,
  FibuNrVertrieb = 
    CASE @FirmaID
      WHEN 5001 THEN N'93 '
      WHEN 5260 THEN N'90 '
      WHEN 5256 THEN N'895'
      ELSE KdGf.FibuNr
    END,
  RechPo.KsSt AS KostenträgerVertrieb, RechPo.KsSt, FibuDet.Differenz, FibuDet.VsaID, FibuDet.KdArtiID, FibuDet.BereichID, KdGf.ID AS KdGfID, Kunden.MWstID, Artikel.ArtGruID, CAST(0 AS bit) AS IsLeasing, CAST(0 AS bit) AS IsStueck, CAST(IIF(Artikel.ID = @BerufsgruppeID, 1, 0) AS bit) AS IsBerufsgruppe, Wae.IsoCode AS Waehrung
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
JOIN Wae WITH (NOLOCK) ON RechKo.WaeID = Wae.ID
WHERE FibuDet.FibuExpID IN (
    SELECT DISTINCT RechKo.FibuExpID
    FROM RechKo
    WHERE RechKo.RechDat BETWEEN @DatumVon AND @DatumBis
      AND RechKo.FirmaID = @FirmaID
  )
  AND KdGf.KurzBez IN (N'MED', N'GAST', N'JOB')
  AND RechKo.FirmaID = @FirmaID
  AND RechKo.RechDat BETWEEN @DatumVon AND @DatumBis
GROUP BY Kunden.KdNr, Kunden.Debitor, KdGf.KurzBez, Bereich.BereichBez, IIF(Artikel.ID < 0, N'', Artikel.ArtikelNr), Artikel.ArtikelBez, FibuDet.EPreis, Konten.Konto, 
  CASE @FirmaID
    WHEN 5001 THEN N'93 '
    WHEN 5260 THEN N'90 '
    WHEN 5256 THEN N'895'
    ELSE KdGf.FibuNr
  END,
  RechPo.KsSt, RechPo.KsSt, FibuDet.Differenz, FibuDet.VsaID, FibuDet.KdArtiID, FibuDet.BereichID, KdGf.ID, Kunden.MwStID, Artikel.ArtGruID, CAST(IIF(Artikel.ID = @BerufsgruppeID, 1, 0) AS bit), Wae.IsoCode;

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
    AND RechPo.EPreis <> 0
) AS x ON WL.Differenz = x.Differenz AND WL.VsaID = x.VsaID AND WL.KdArtiID = x.KdArtiID AND WL.BereichID = x.BereichID;

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
) AS x ON WL.Differenz = x.Differenz AND WL.VsaID = x.VsaID AND WL.KdArtiID = x.KdArtiID AND WL.BereichID = x.BereichID;

SELECT LsKo.VsaID, LsPo.KdArtiID, KdBer.BereichID, KdGf.ID AS KdGfID, Kunden.MwStID, Artikel.ArtGruID, Bereich.BereichBez AS Produktbereich, Kunden.KdNr, Kunden.Debitor, KdGf.KurzBez AS SGF, Artikel.ArtikelNr, Artikel.ArtikelBez, SUM(LsPo.Menge) AS Liefermenge, Standort.SuchCode AS Produzent,
  FibuNr = 
  CASE
    WHEN Standort.FibuNr = N'663' AND @DatumBis < N'2019-08-01' THEN N'673'
    WHEN Standort.FibuNr = N'666' AND @DatumBis < N'2019-08-01' THEN N'676'
    ELSE Standort.FibuNr
  END,
  FibuNrVertrieb = 
  CASE @FirmaID
    WHEN 5001 THEN N'93 '
    WHEN 5260 THEN N'90 '
    WHEN 5256 THEN N'895'
    ELSE KdGf.FibuNr
  END
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
GROUP BY LsKo.VsaID, LsPo.KdArtiID, KdBer.BereichID, KdGf.ID, Kunden.MwStID, Artikel.ArtGruID, Bereich.BereichBez, Kunden.KdNr, Kunden.Debitor, KdGf.KurzBez, Artikel.ArtikelNr, Artikel.ArtikelBez, Standort.SuchCode,
 CASE
    WHEN Standort.FibuNr = N'663' AND @DatumBis < N'2019-08-01' THEN N'673'
    WHEN Standort.FibuNr = N'666' AND @DatumBis < N'2019-08-01' THEN N'676'
    ELSE Standort.FibuNr
  END,
  CASE @FirmaID
    WHEN 5001 THEN N'93 '
    WHEN 5260 THEN N'90 '
    WHEN 5256 THEN N'895'
    ELSE KdGf.FibuNr
  END;

SELECT ISNULL(Waschlohn.KdNr, LieferMenge.KdNr) AS KdNr, ISNULL(Waschlohn.Debitor, LieferMenge.Debitor) AS Debitor, ISNULL(Waschlohn.SGF, LieferMenge.SGF) AS SGF, ISNULL(Waschlohn.Produktbereich, LieferMenge.Produktbereich) AS Produktbereich, ISNULL(Waschlohn.ArtikelNr, LieferMenge.ArtikelNr) AS ArtikelNr, ISNULL(Waschlohn.Artikelbezeichnung, LieferMenge.ArtikelBez) AS Artikelbezeichnung, SUM(ISNULL(Waschlohn.VerrechMenge, 0)) AS VerrechMenge, SUM(ISNULL(Waschlohn.UmsatzNetto, 0)) AS UmsatzNetto, Waschlohn.Erlöskonto, ISNULL(Waschlohn.FibuNrVertrieb, LieferMenge.FibuNrVertrieb) AS FibuNrVertrieb, Waschlohn.KostenträgerVertrieb, SUM(ISNULL(LieferMenge.Liefermenge, 0)) AS Liefermenge, ISNULL(LieferMenge.Produzent, Standort.SuchCode) AS Produzent, CAST(ISNULL(LieferMenge.FibuNr, CASE WHEN Standort.FibuNr = N'663' AND @DatumBis < N'2019-08-01' THEN N'673' WHEN Standort.FibuNr = N'666' AND @DatumBis < N'2019-08-01' THEN N'676' ELSE Standort.FibuNr END) AS nchar(3)) COLLATE Latin1_General_CS_AS AS FibuNr, RTRIM(Waschlohn.KsSt) AS Kostenträger, Waschlohn.Differenz, ISNULL(Waschlohn.BereichID, LieferMenge.BereichID) AS BereichID, ISNULL(Waschlohn.KdGfID, LieferMenge.KdGfID) AS KdGfID, ISNULL(Waschlohn.MwStID, LieferMenge.MwStID) AS MwStID, ISNULL(Waschlohn.ArtGruID, LieferMenge.ArtGruID) AS ArtGruID, MAX(CAST(ISNULL(Waschlohn.IsLeasing, 0) AS tinyint)) AS IsLeasing, MAX(CAST(ISNULL(Waschlohn.IsStueck, 0) AS tinyint)) AS IsStueck, MAX(CAST(ISNULL(Waschlohn.IsBerufsgruppe, 0) AS tinyint)) AS IsBerufsgruppe, Waschlohn.Waehrung
INTO #ResultWLohnStueck
FROM (
  SELECT KdNr, Debitor, SGF, Produktbereich, ArtikelNr, Artikelbezeichnung, KostenträgerVertrieb, FibuNrVertrieb, SUM(VerrechMenge) AS VerrechMenge, SUM(UmsatzNetto) AS UmsatzNetto, Erlöskonto, KsSt, Differenz, BereichID, KdGfID, MWStID, ArtGruID, IsBerufsgruppe, IsLeasing, IsStueck, VsaID, KdArtiID, Waehrung
  FROM #Waschlohn
  WHERE Differenz = 0
  GROUP BY  KdNr, Debitor, SGF, Produktbereich, ArtikelNr, Artikelbezeichnung, KostenträgerVertrieb, FibuNrVertrieb, Erlöskonto, KsSt, Differenz, BereichID, KdGfID, MWStID, ArtGruID, IsBerufsgruppe, IsLeasing, IsStueck, VsaID, KdArtiID, Waehrung
) AS Waschlohn
FULL OUTER JOIN #LieferMenge AS LieferMenge ON LieferMenge.VsaID = Waschlohn.VsaID AND LieferMenge.KdArtiID = Waschlohn.KdArtiID AND LieferMenge.BereichID = Waschlohn.BereichID
LEFT OUTER JOIN Vsa WITH (NOLOCK) ON Waschlohn.VsaID = Vsa.ID
LEFT OUTER JOIN StandBer WITH (NOLOCK) ON Vsa.StandKonID = StandBer.StandKonID AND StandBer.BereichID = Waschlohn.BereichID
LEFT OUTER JOIN Standort WITH (NOLOCK) ON StandBer.ProduktionID = Standort.ID
GROUP BY ISNULL(Waschlohn.KdNr, LieferMenge.KdNr), ISNULL(Waschlohn.Debitor, LieferMenge.Debitor), ISNULL(Waschlohn.SGF, LieferMenge.SGF), ISNULL(Waschlohn.Produktbereich, LieferMenge.Produktbereich), ISNULL(Waschlohn.ArtikelNr, LieferMenge.ArtikelNr), ISNULL(Waschlohn.Artikelbezeichnung, LieferMenge.ArtikelBez), Waschlohn.Erlöskonto, ISNULL(Waschlohn.FibuNrVertrieb, LieferMenge.FibuNrVertrieb), Waschlohn.KostenträgerVertrieb, ISNULL(LieferMenge.Produzent, Standort.SuchCode),  CAST(ISNULL(LieferMenge.FibuNr, CASE WHEN Standort.FibuNr = N'663' AND @DatumBis < N'2019-08-01' THEN N'673' WHEN Standort.FibuNr = N'666' AND @DatumBis < N'2019-08-01' THEN N'676' ELSE Standort.FibuNr END) AS nchar(3)) COLLATE Latin1_General_CS_AS , RTRIM(Waschlohn.KsSt), Waschlohn.Differenz, ISNULL(Waschlohn.BereichID, LieferMenge.BereichID), ISNULL(Waschlohn.KdGfID, LieferMenge.KdGfID), ISNULL(Waschlohn.MwStID, LieferMenge.MwStID), ISNULL(Waschlohn.ArtGruID, LieferMenge.ArtGruID), Waschlohn.Waehrung;

SELECT Waschlohn.KdNr, Waschlohn.Debitor, Waschlohn.SGF, Waschlohn.Produktbereich, Waschlohn.ArtikelNr, Waschlohn.Artikelbezeichnung, SUM(ISNULL(Waschlohn.VerrechMenge, 0)) AS VerrechMenge, SUM(ISNULL(Waschlohn.UmsatzNetto, 0)) AS UmsatzNetto, Waschlohn.Erlöskonto, Waschlohn.FibuNrVertrieb, Waschlohn.KostenträgerVertrieb, Standort.SuchCode AS Produzent, CAST(CASE WHEN Standort.FibuNr = N'663' AND @DatumBis < N'2019-08-01' THEN N'673' WHEN Standort.FibuNr = N'666' AND @DatumBis < N'2019-08-01' THEN N'676' ELSE Standort.FibuNr END AS nchar(3)) COLLATE Latin1_General_CS_AS AS FibuNr, RTRIM(Waschlohn.KsSt) AS Kostenträger, Waschlohn.Differenz, Waschlohn.BereichID, Waschlohn.KdGfID, Waschlohn.MwStID, Waschlohn.ArtGruID, MAX(CAST(Waschlohn.IsLeasing AS tinyint)) AS IsLeasing, MAX(CAST(Waschlohn.IsStueck AS tinyint)) AS IsStueck, MAX(CAST(Waschlohn.IsBerufsgruppe AS tinyint)) AS IsBerufsgruppe, Waschlohn.Waehrung
INTO #ResultWLohnUmsatz
FROM #Waschlohn AS Waschlohn
LEFT OUTER JOIN Vsa WITH (NOLOCK) ON Waschlohn.VsaID = Vsa.ID
LEFT OUTER JOIN StandBer WITH (NOLOCK) ON Vsa.StandKonID = StandBer.StandKonID AND StandBer.BereichID = Waschlohn.BereichID
LEFT OUTER JOIN Standort WITH (NOLOCK) ON StandBer.ProduktionID = Standort.ID
GROUP BY Waschlohn.KdNr, Waschlohn.Debitor, Waschlohn.SGF, Waschlohn.Produktbereich, Waschlohn.ArtikelNr, Waschlohn.Artikelbezeichnung, Waschlohn.Erlöskonto, Waschlohn.FibuNrVertrieb, Waschlohn.KostenträgerVertrieb, Standort.SuchCode, CAST(CASE WHEN Standort.FibuNr = N'663' AND @DatumBis < N'2019-08-01' THEN N'673' WHEN Standort.FibuNr = N'666' AND @DatumBis < N'2019-08-01' THEN N'676' ELSE Standort.FibuNr END AS nchar(3)) COLLATE Latin1_General_CS_AS, RTRIM(Waschlohn.KsSt), Waschlohn.Differenz, Waschlohn.BereichID, Waschlohn.KdGfID, Waschlohn.MwStID, Waschlohn.ArtGruID, Waschlohn.Waehrung;

UPDATE ResultWLohnUmsatz SET Produzent = N'BUDW', FibuNr = N'894'
FROM #ResultWLohnUmsatz AS ResultWLohnUmsatz
WHERE Produzent = N'WOLE'
  AND ArtikelNr IN (N'103605105001', N'103635109001', N'103661141401', N'103661141801', N'103607003004', N'103635209004', N'103663141404', N'103663142104', N'103605105010', N'103605205065', N'103605505003', N'103635209065', N'103667141403', N'113635209001', N'113661141406', N'113661141806', N'113665141401', N'113665141801', N'113605105010', N'113605205001', N'113635109006', N'113665142401', N'103661142001', N'113661141410', N'113661141810', N'103663142404', N'103661142401', N'113635109010', N'103661141410', N'103666121001', N'103635109006', N'103661141406', N'103661141806', N'103635109010', N'103663141465', N'103663141865', N'103663142165', N'103663141804', N'103605105006', N'103661141810', N'103605205004', N'103605304090', N'103605305090', N'103607003090', N'103635310090', N'103653181890', N'103666125001', N'103661142201', N'113635209065', N'113605105006', N'113635209004', N'113605205065', N'103661142406', N'103661142410', N'103635109031', N'103661142110', N'113605205004', N'G30121', N'113661141401', N'103661142206', N'103661143001', N'103661161601', N'103605007020', N'103605007035', N'103605007060', N'103605009060', N'103605010099', N'103605405006', N'103666141405', N'103666212105', N'103680141406', N'103680142206', N'103605105035', N'103680141806', N'103661202001', N'103635210504', N'103680141480', N'103680141481', N'103680141482', N'103680141483', N'103635410006', N'G30124', N'G10200', N'G20200', N'G30214', N'G30218', N'G30224', N'103635309095', N'103680181806');

UPDATE ResultWLohnStueck SET Produzent = N'BUDW', FibuNr = N'894'
FROM #ResultWLohnStueck AS ResultWLohnStueck
WHERE Produzent = N'WOLE'
  AND ArtikelNr IN (N'103605105001', N'103635109001', N'103661141401', N'103661141801', N'103607003004', N'103635209004', N'103663141404', N'103663142104', N'103605105010', N'103605205065', N'103605505003', N'103635209065', N'103667141403', N'113635209001', N'113661141406', N'113661141806', N'113665141401', N'113665141801', N'113605105010', N'113605205001', N'113635109006', N'113665142401', N'103661142001', N'113661141410', N'113661141810', N'103663142404', N'103661142401', N'113635109010', N'103661141410', N'103666121001', N'103635109006', N'103661141406', N'103661141806', N'103635109010', N'103663141465', N'103663141865', N'103663142165', N'103663141804', N'103605105006', N'103661141810', N'103605205004', N'103605304090', N'103605305090', N'103607003090', N'103635310090', N'103653181890', N'103666125001', N'103661142201', N'113635209065', N'113605105006', N'113635209004', N'113605205065', N'103661142406', N'103661142410', N'103635109031', N'103661142110', N'113605205004', N'G30121', N'113661141401', N'103661142206', N'103661143001', N'103661161601', N'103605007020', N'103605007035', N'103605007060', N'103605009060', N'103605010099', N'103605405006', N'103666141405', N'103666212105', N'103680141406', N'103680142206', N'103605105035', N'103680141806', N'103661202001', N'103635210504', N'103680141480', N'103680141481', N'103680141482', N'103680141483', N'103635410006', N'G30124', N'G10200', N'G20200', N'G30214', N'G30218', N'G30224', N'103635309095', N'103680181806');

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

SELECT KdNr, Debitor, SGF AS Vertrieb, Produktbereich, ArtikelNr, Artikelbezeichnung, SUM(VerrechMenge) AS [verrechnete Menge], SUM(UmsatzNetto) AS UmsatzNetto, Erlöskonto, RTRIM(FibuNrVertrieb) + KostenträgerVertrieb [Kostenträger Vertrieb], Produzent, RTRIM(FibuNr) + Kostenträger AS [Kostenträger Produzent], Verrechnungsart = 
  CASE
    WHEN IsLeasing = 1 AND IsStueck = 0 THEN N'Pauschal'
    WHEN IsStueck = 1  AND IsLeasing = 0 THEN N'Stück'
    WHEN IsLeasing = 1 AND IsStueck = 1 THEN N'Splitting'
    WHEN IsBerufsgruppe = 1 THEN N'Berufsgruppen'
    ELSE N'(unbekannt)'
  END, Waehrung
FROM #ResultWLohnUmsatz AS WaschlohnDaten
GROUP BY KdNr, Debitor, SGF, Produktbereich, ArtikelNr, Artikelbezeichnung, Erlöskonto, RTRIM(FibuNrVertrieb) + KostenträgerVertrieb, Produzent, RTRIM(FibuNr) + Kostenträger,
  CASE
    WHEN IsLeasing = 1 AND IsStueck = 0 THEN N'Pauschal'
    WHEN IsStueck = 1  AND IsLeasing = 0 THEN N'Stück'
    WHEN IsLeasing = 1 AND IsStueck = 1 THEN N'Splitting'
    WHEN IsBerufsgruppe = 1 THEN N'Berufsgruppen'
    ELSE N'(unbekannt)'
  END, Waehrung;

SELECT KdNr, Debitor, SGF AS Vertrieb, Produktbereich, ArtikelNr, Artikelbezeichnung, SUM(Liefermenge) AS [Liefermenge], RTRIM(FibuNrVertrieb) + KostenträgerVertrieb [Kostenträger Vertrieb], Produzent, RTRIM(FibuNr) + Kostenträger AS [Kostenträger Produzent], Verrechnungsart = 
  CASE
    WHEN IsLeasing = 1 AND IsStueck = 0 THEN N'Pauschal'
    WHEN IsStueck = 1  AND IsLeasing = 0 THEN N'Stück'
    WHEN IsLeasing = 1 AND IsStueck = 1 THEN N'Splitting'
    WHEN IsBerufsgruppe = 1 THEN N'Berufsgruppen'
    ELSE N'(unbekannt)'
  END, Waehrung
FROM #ResultWLohnStueck AS WaschlohnDaten
GROUP BY KdNr, Debitor, SGF, Produktbereich, ArtikelNr, Artikelbezeichnung, Erlöskonto, RTRIM(FibuNrVertrieb) + KostenträgerVertrieb, Produzent, RTRIM(FibuNr) + Kostenträger,
  CASE
    WHEN IsLeasing = 1 AND IsStueck = 0 THEN N'Pauschal'
    WHEN IsStueck = 1  AND IsLeasing = 0 THEN N'Stück'
    WHEN IsLeasing = 1 AND IsStueck = 1 THEN N'Splitting'
    WHEN IsBerufsgruppe = 1 THEN N'Berufsgruppen'
    ELSE N'(unbekannt)'
  END, Waehrung;

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

-- Neu für AUVA / Ascendum nach SAP-Schnittstelle für Rechnungen
SELECT Konten.Konto AS Erlöskonto, [KTr WOMI] = 
    CASE RechKo.FirmaID
      WHEN 5001 THEN N'93 ' + RechPo.KsSt
      WHEN 5260 THEN N'90 ' + RechPo.KsSt
      WHEN 5256 THEN N'895' + RechPo.KsSt
      ELSE CAST(KdGf.FibuNr AS nchar(3)) + RechPo.KsSt
    END,
  N'93 ' + RechPo.KsSt AS [KTr USMK], FORMAT(SUM(RechPo.GPreis), N'C', N'de-AT') AS Umsatz
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Konten ON RechPo.KontenID = Konten.ID
JOIN Vsa ON RechPo.VsaID = Vsa.ID
JOIN StandBer ON StandBer.StandKonID = Vsa.StandKonID AND StandBer.BereichID = RechPo.BereichID
JOIN Standort ON StandBer.ProduktionID = Standort.ID
WHERE Holding.Holding = N'AUVA'
  AND RechKo.RechDat BETWEEN N'2019-11-01' AND N'2019-11-30'
  AND Standort.SuchCode = N'UKLU'
GROUP BY Konten.Konto,
  CASE RechKo.FirmaID
    WHEN 5001 THEN N'93 ' + RechPo.KsSt
    WHEN 5260 THEN N'90 ' + RechPo.KsSt
    WHEN 5256 THEN N'895' + RechPo.KsSt
    ELSE CAST(KdGf.FibuNr AS nchar(3)) + RechPo.KsSt
  END,
  N'93 ' + RechPo.KsSt;

SELECT Konten.Konto AS Erlöskonto, [KTr WOMI] = 
    CASE RechKo.FirmaID
      WHEN 5001 THEN N'93 ' + RechPo.KsSt
      WHEN 5260 THEN N'90 ' + RechPo.KsSt
      WHEN 5256 THEN N'895' + RechPo.KsSt
      ELSE CAST(KdGf.FibuNr AS nchar(3)) + RechPo.KsSt
    END,
  N'93 ' + RechPo.KsSt AS [KTr UMSK], FORMAT(SUM(RechPo.GPreis), N'C', N'de-AT') AS Umsatz, KdGf.FibuNr, RechPo.KsSt
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Konten ON RechPo.KontenID = Konten.ID
JOIN Vsa ON RechPo.VsaID = Vsa.ID
JOIN StandBer ON StandBer.StandKonID = Vsa.StandKonID AND StandBer.BereichID = RechPo.BereichID
JOIN Standort ON StandBer.ProduktionID = Standort.ID
WHERE Kunden.KdNr = 30970
  AND RechKo.RechDat BETWEEN N'2019-11-01' AND N'2019-11-30'
  AND Standort.SuchCode = N'UKLU'
GROUP BY Konten.Konto,
  CASE RechKo.FirmaID
    WHEN 5001 THEN N'93 ' + RechPo.KsSt
    WHEN 5260 THEN N'90 ' + RechPo.KsSt
    WHEN 5256 THEN N'895' + RechPo.KsSt
    ELSE CAST(KdGf.FibuNr AS nchar(3)) + RechPo.KsSt
  END,
  N'93 ' + RechPo.KsSt, KdGf.FibuNr, RechPo.KsSt;
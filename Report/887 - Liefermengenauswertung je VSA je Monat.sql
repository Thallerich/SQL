DECLARE @CalendarMonths TABLE (
  [Month] nchar(7)
);

DECLARE
  @basedate date,
  @maxdate date,
  @lastdate date,
  @offset int,
  @maxmonths int,
  @pivotcolumns nvarchar(max),
  @pivotsql nvarchar(max);

SET @basedate = $STARTDATE$;
SET @maxdate = $ENDDATE$;
SET @lastdate = @basedate;
SET @offset = 1;
SET @maxmonths = DATEDIFF(month, @basedate, @maxdate);

INSERT INTO @CalendarMonths ([Month]) VALUES (FORMAT(@basedate, N'yyyy-MM', N'de-AT'));

WHILE (@offset <= @maxmonths)
BEGIN
  SET @lastdate = DATEADD(month, 1, @lastdate);

  INSERT INTO @CalendarMonths ([Month])
  VALUES (FORMAT(@lastdate, N'yyyy-MM', N'de-AT'));

  SET @offset = @offset + 1;
END;

SELECT @pivotcolumns = COALESCE(@pivotcolumns + ', ','') + QUOTENAME(CalMon.[Month])
FROM (
  SELECT [Month]
  FROM @CalendarMonths
) AS CalMon
ORDER BY CalMon.[Month] ASC;

DROP TABLE IF EXISTS #LiefermengeVSA;

WITH LiefermengeMonatlich AS (
  SELECT FORMAT(LsKo.Datum, N'yyyy-MM', N'de-AT') AS Monat, LsKo.VsaID, LsPo.KdArtiID, LsPo.AbteilID, LsPo.ArtGroeID, SUM(LsPo.Menge) AS Liefermenge
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  JOIN Vsa ON LsKo.VsaID = Vsa.ID
  JOIN Rentomat ON Vsa.RentomatID = Rentomat.ID
  WHERE LsKo.Datum BETWEEN @basedate AND @maxdate
    AND LsKo.Status >= N'Q'
    AND Vsa.KundenID IN ($3$)
    AND LsPo.Menge != 0
    AND ((Vsa.RentomatID > 0 AND Rentomat.LsKoArtScanOutID > 0 AND LsKo.LsKoArtID != Rentomat.LsKoArtScanOutID) OR (Vsa.RentomatID < 0) OR (Rentomat.LsKoArtScanOutID < 0))
    AND (($6$ = 0) OR ($6$ = 1 AND LsPo.Menge > 0 AND LsPo.LsKoGruID NOT IN (SELECT ID FROM LsKoGru WHERE Reklamation = 1) AND LsKo.LsKoGruID NOT IN (SELECT ID FROM LsKoGru WHERE Reklamation = 1)))
    AND NOT EXISTS (
      SELECT Scans.*
      FROM Scans
      JOIN EinzHist ON Scans.EinzHistID = EinzHist.ID
      WHERE Scans.LsPoID = LsPo.ID
        AND EinzHist.TraeArtiID > 0
    )
  GROUP BY FORMAT(LsKo.Datum, N'yyyy-MM', N'de-AT'), LsKo.VsaID, LsPo.KdArtiID, LsPo.AbteilID, LsPo.ArtGroeID

  UNION ALL

  SELECT FORMAT(LsKo.Datum, N'yyyy-MM', N'de-AT') AS Monat, LsKo.VsaID, LsPo.KdArtiID, LsPo.AbteilID, EinzHist.ArtGroeID, COUNT(Scans.ID) AS Liefermenge
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  JOIN Vsa ON LsKo.VsaID = Vsa.ID
  JOIN Scans ON Scans.LsPoID = LsPo.ID
  JOIN EinzHist ON Scans.EinzHistID = EinzHist.ID
  JOIN Rentomat ON Vsa.RentomatID = Rentomat.ID
  WHERE LsKo.Datum BETWEEN @basedate AND @maxdate
    AND LsKo.Status >= N'Q'
    AND Vsa.KundenID IN ($3$)
    AND LsPo.Menge != 0
    AND EinzHist.TraeArtiID > 0
    AND ((Vsa.RentomatID > 0 AND Rentomat.LsKoArtScanOutID > 0 AND LsKo.LsKoArtID != Rentomat.LsKoArtScanOutID) OR (Vsa.RentomatID < 0) OR (Rentomat.LsKoArtScanOutID < 0))
    AND (($6$ = 0) OR ($6$ = 1 AND LsPo.Menge > 0 AND LsPo.LsKoGruID NOT IN (SELECT ID FROM LsKoGru WHERE Reklamation = 1) AND LsKo.LsKoGruID NOT IN (SELECT ID FROM LsKoGru WHERE Reklamation = 1)))
  GROUP BY FORMAT(LsKo.Datum, N'yyyy-MM', N'de-AT'), LsKo.VsaID, LsPo.KdArtiID, LsPo.AbteilID, EinzHist.ArtGroeID
)
SELECT ProdBetrieb.SuchCode AS [produzierender Betrieb], IntProdBetrieb.SuchCode AS [intern produzierender Betrieb], Holding.Holding AS Kette, Kunden.KdNr AS Kundennummer, Kunden.SuchCode AS Kundenname, Vsa.VsaNr AS [VSA-Nummer], Vsa.Bez AS [VSA-Bezeichnung], Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Bereich.Bereich AS Produktbereich, ArtGru.Gruppe AS Artikelgruppe, Artikel.ArtikelNr AS Artikelnummer, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Artikel.StueckGewicht AS Stückgewicht, LiefArt.LiefArtBez$LAN$ AS Auslieferart, LiefermengeMonatlich.Monat, LiefermengeMonatlich.Liefermenge
INTO #LiefermengeVSA
FROM (
  SELECT Monat, VsaID, KdArtiID, AbteilID, ArtGroeID, SUM(Liefermenge) AS Liefermenge
  FROM LiefermengeMonatlich
  GROUP BY Monat, VsaID, KdArtiID, AbteilID, ArtGroeID
) AS LiefermengeMonatlich
JOIN Vsa ON LiefermengeMonatlich.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN KdArti ON LiefermengeMonatlich.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN LiefArt ON KdArti.LiefArtID = LiefArt.ID
JOIN ArtGroe ON LiefermengeMonatlich.ArtGroeID = ArtGroe.ID
JOIN Abteil ON LiefermengeMonatlich.AbteilID = Abteil.ID
JOIN StandBer ON StandBer.StandKonID = Vsa.StandKonID AND StandBer.BereichID = Bereich.ID
JOIN Standort AS ProdBetrieb ON StandBer.ExpeditionID = ProdBetrieb.ID
JOIN Standort AS IntProdBetrieb ON StandBer.ProduktionID = IntProdBetrieb.ID
WHERE Kunden.ID IN ($3$)
  AND Bereich.ID IN ($4$)
  AND LiefArt.ID IN ($5$);

SET @pivotsql = N'SELECT [produzierender Betrieb], [intern produzierender Betrieb], Kette, Kundennummer, Kundenname, [VSA-Nummer], [VSA-Bezeichnung], Kostenstelle, Kostenstellenbezeichnung, Produktbereich, Artikelgruppe, Artikelnummer, Artikelbezeichnung, Größe, Stückgewicht, Auslieferart, ' + @pivotcolumns + ' FROM #LiefermengeVSA AS LiefermengeVSA PIVOT ( SUM(LiefermengeVSA.Liefermenge) FOR LiefermengeVSA.Monat IN (' + @pivotcolumns + ')) AS PivotResult ORDER BY Kundennummer, [VSA-Nummer],Artikelnummer';

EXEC (@pivotsql);
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
  @sqltext nvarchar(max),
  @customerid int,
  @webuserid int,
  @startyear int,
  @endyear int;

SET @startyear = $startyear;
SET @endyear = $endyear;

/* Zukünftige Jahre automatisch auf das aktuelle Jahr setzen */
/* Keine Jahre mehr als 5 Jahre in der Vergangenheit erlauben */
IF @startyear > YEAR(GETDATE())
  SET @startyear = YEAR(GETDATE());
IF @startyear < YEAR(GETDATE()) - 5
  SET @startyear = YEAR(GETDATE()) - 5;

IF @endyear > YEAR(GETDATE())
  SET @endyear = YEAR(GETDATE());
IF @endyear < YEAR(GETDATE()) - 5
  SET @endyear = YEAR(GETDATE()) - 5;

SET @basedate = DATEFROMPARTS(@startyear, 1, 1);
SET @maxdate = CAST(DATEADD(year, @endyear - YEAR(GETDATE()), GETDATE()) AS date);
SET @lastdate = @basedate;
SET @offset = 1;
SET @maxmonths = DATEDIFF(month, @basedate, @maxdate);
SET @customerid = $kundenID;
SET @webuserid = $webuserID;

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

CREATE TABLE #LiefermengeVSA (
  [produzierender Betrieb] nvarchar(15) COLLATE Latin1_General_CS_AS,
  [intern produzierender Betrieb] nvarchar(15) COLLATE Latin1_General_CS_AS,
  Kette nvarchar(10) COLLATE Latin1_General_CS_AS,
  Kundennummer int,
  Kundenname nvarchar(20) COLLATE Latin1_General_CS_AS,
  [VSA-Nummer] int,
  [VSA-Bezeichnung] nvarchar(40) COLLATE Latin1_General_CS_AS,
  Kostenstelle nvarchar(20) COLLATE Latin1_General_CS_AS,
  Kostenstellenbezeichnung nvarchar(80) COLLATE Latin1_General_CS_AS,
  Produktbereich nchar(3) COLLATE Latin1_General_CS_AS,
  Artikelgruppe nchar(8) COLLATE Latin1_General_CS_AS,
  Artikelnummer nvarchar(15) COLLATE Latin1_General_CS_AS,
  Artikelbezeichnung nvarchar(60) COLLATE Latin1_General_CS_AS,
  Größe nvarchar(12) COLLATE Latin1_General_CS_AS,
  Stückgewicht numeric(18, 4),
  Auslieferart nchar(2) COLLATE Latin1_General_CS_AS,
  Monat nchar(7) COLLATE Latin1_General_CS_AS,
  Liefermenge numeric(18, 4)
);

SET @sqltext = N'
WITH LiefermengeMonatlich AS (
  SELECT FORMAT(LsKo.Datum, N''yyyy-MM'', N''de-AT'') AS Monat, LsKo.VsaID, LsPo.KdArtiID, LsPo.AbteilID, LsPo.ArtGroeID, SUM(LsPo.Menge) AS Liefermenge
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  JOIN Vsa ON LsKo.VsaID = Vsa.ID
  JOIN Rentomat ON Vsa.RentomatID = Rentomat.ID
  WHERE LsKo.Datum BETWEEN @basedate AND @maxdate
    AND LsKo.Status >= N''Q''
    AND Vsa.KundenID = @customerid
    AND Vsa.AbteilID IN (
      SELECT WebUAbt.AbteilID
      FROM WebUAbt
      WHERE WebUAbt.WebUserID = @webuserid
    )
    AND Vsa.ID IN (  
      SELECT Vsa.ID
      FROM Vsa
      JOIN WebUser ON WebUser.KundenID = Vsa.KundenID
      LEFT JOIN WebUVsa ON WebUVsa.WebUserID = WebUser.ID
      WHERE WebUser.ID = @webuserid
        AND (WebUVsa.ID IS NULL OR WebUVsa.VsaID = Vsa.ID)
    
    )
    AND LsPo.Menge != 0
    AND ((Vsa.RentomatID > 0 AND Rentomat.LsKoArtScanOutID > 0 AND LsKo.LsKoArtID != Rentomat.LsKoArtScanOutID) OR (Vsa.RentomatID < 0) OR (Rentomat.LsKoArtScanOutID < 0))
    AND NOT EXISTS (
      SELECT Scans.*
      FROM Scans
      JOIN EinzHist ON Scans.EinzHistID = EinzHist.ID
      WHERE Scans.LsPoID = LsPo.ID
        AND EinzHist.TraeArtiID > 0
    )
  GROUP BY FORMAT(LsKo.Datum, N''yyyy-MM'', N''de-AT''), LsKo.VsaID, LsPo.KdArtiID, LsPo.AbteilID, LsPo.ArtGroeID

  UNION ALL

  SELECT FORMAT(LsKo.Datum, N''yyyy-MM'', N''de-AT'') AS Monat, LsKo.VsaID, LsPo.KdArtiID, LsPo.AbteilID, EinzHist.ArtGroeID, COUNT(Scans.ID) AS Liefermenge
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  JOIN Vsa ON LsKo.VsaID = Vsa.ID
  JOIN Scans ON Scans.LsPoID = LsPo.ID
  JOIN EinzHist ON Scans.EinzHistID = EinzHist.ID
  JOIN Rentomat ON Vsa.RentomatID = Rentomat.ID
  WHERE LsKo.Datum BETWEEN @basedate AND @maxdate
    AND LsKo.Status >= N''Q''
    AND Vsa.KundenID = @customerid
    AND Vsa.AbteilID IN (
      SELECT WebUAbt.AbteilID
      FROM WebUAbt
      WHERE WebUAbt.WebUserID = @webuserid
    )
    AND Vsa.ID IN (  
      SELECT Vsa.ID
      FROM Vsa
      JOIN WebUser ON WebUser.KundenID = Vsa.KundenID
      LEFT JOIN WebUVsa ON WebUVsa.WebUserID = WebUser.ID
      WHERE WebUser.ID = @webuserid
        AND (WebUVsa.ID IS NULL OR WebUVsa.VsaID = Vsa.ID)
    
    )
    AND LsPo.Menge != 0
    AND EinzHist.TraeArtiID > 0
    AND ((Vsa.RentomatID > 0 AND Rentomat.LsKoArtScanOutID > 0 AND LsKo.LsKoArtID != Rentomat.LsKoArtScanOutID) OR (Vsa.RentomatID < 0) OR (Rentomat.LsKoArtScanOutID < 0))
  GROUP BY FORMAT(LsKo.Datum, N''yyyy-MM'', N''de-AT''), LsKo.VsaID, LsPo.KdArtiID, LsPo.AbteilID, EinzHist.ArtGroeID
)
INSERT INTO #LiefermengeVSA ([produzierender Betrieb], [intern produzierender Betrieb], Kette, Kundennummer, Kundenname, [VSA-Nummer], [VSA-Bezeichnung], Kostenstelle, Kostenstellenbezeichnung, Produktbereich, Artikelgruppe, Artikelnummer, Artikelbezeichnung, Größe, Stückgewicht, Auslieferart, Monat, Liefermenge)
SELECT ProdBetrieb.SuchCode AS [produzierender Betrieb], IntProdBetrieb.SuchCode AS [intern produzierender Betrieb], Holding.Holding AS Kette, Kunden.KdNr AS Kundennummer, Kunden.SuchCode AS Kundenname, Vsa.VsaNr AS [VSA-Nummer], Vsa.Bez AS [VSA-Bezeichnung], Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Bereich.Bereich AS Produktbereich, ArtGru.Gruppe AS Artikelgruppe, Artikel.ArtikelNr AS Artikelnummer, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Artikel.StueckGewicht AS Stückgewicht, LiefArt.LiefArt AS Auslieferart, LiefermengeMonatlich.Monat, LiefermengeMonatlich.Liefermenge
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
WHERE Kunden.ID = @customerid
  AND Vsa.AbteilID IN (
    SELECT WebUAbt.AbteilID
    FROM WebUAbt
    WHERE WebUAbt.WebUserID = @webuserid
  )
  AND Vsa.ID IN (  
    SELECT Vsa.ID
    FROM Vsa
    JOIN WebUser ON WebUser.KundenID = Vsa.KundenID
    LEFT JOIN WebUVsa ON WebUVsa.WebUserID = WebUser.ID
    WHERE WebUser.ID = @webuserid
      AND (WebUVsa.ID IS NULL OR WebUVsa.VsaID = Vsa.ID)
  );
';

EXEC sp_executesql @sqltext, N'@customerid int, @webuserid int, @basedate date, @maxdate date', @customerid, @webuserid, @basedate, @maxdate;

SET @sqltext = N'SELECT [produzierender Betrieb], [intern produzierender Betrieb], Kette, Kundennummer, Kundenname, [VSA-Nummer], [VSA-Bezeichnung], Kostenstelle, Kostenstellenbezeichnung, Produktbereich, Artikelgruppe, Artikelnummer, Artikelbezeichnung, Größe, Stückgewicht, Auslieferart, ' + @pivotcolumns + ' FROM #LiefermengeVSA AS LiefermengeVSA PIVOT ( SUM(LiefermengeVSA.Liefermenge) FOR LiefermengeVSA.Monat IN (' + @pivotcolumns + ')) AS PivotResult ORDER BY Kundennummer, [VSA-Nummer], Artikelnummer';

EXEC sp_executesql @sqltext;
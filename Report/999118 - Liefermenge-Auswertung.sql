/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: collectData                                                                                                     ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #Customers999118;
DROP TABLE IF EXISTS #ProductArea999118;
DROP TABLE IF EXISTS #Result999118;

CREATE TABLE #Result999118 (
  KdNr int,
  Kunde nchar(20) COLLATE Latin1_General_CS_AS,
  [VSA-Nr] int,
  [VSA-Stichwort] nvarchar(40) COLLATE Latin1_General_CS_AS,
  [VSA-Bezeichnung] nvarchar(40) COLLATE Latin1_General_CS_AS,
  Bereich nchar(3) COLLATE Latin1_General_CS_AS,
  Gruppe nchar(8) COLLATE Latin1_General_CS_AS,
  ArtikelNr nchar(15) COLLATE Latin1_General_CS_AS,
  Variante nchar(2) COLLATE Latin1_General_CS_AS,
  Artikelbezeichnung nvarchar(60) COLLATE Latin1_General_CS_AS,
  [Gewicht (kg/Stück)] numeric(18,4),
  Leasingpreis money,
  Lieferdatum date,
  LsKoID int,
  LsNr int,
  Art nchar(1) COLLATE Latin1_General_CS_AS,
  [Lieferschein-Art] nvarchar(40) COLLATE Latin1_General_CS_AS,
  Menge float,
  Einzelpreis money,
  [Rabatt in Prozent] float,
  Rabatt money,
  Gesamtpreis money,
  Kostenstelle nchar(20) COLLATE Latin1_General_CS_AS,
  Kostenstellenbezeichnung nvarchar(80) COLLATE Latin1_General_CS_AS,
  RechNr int
);

SELECT Kunden.ID
INTO #Customers999118
FROM Kunden
WHERE Kunden.ID IN ($6$);

SELECT Bereich.ID
INTO #ProductArea999118
FROM Bereich
WHERE Bereich.iD IN ($7$);

DECLARE @startdate date = $STARTDATE$;
DECLARE @enddate date = $ENDDATE$;
DECLARE @onlyUHF bit = $2$;
DECLARE @useliefdat bit = $3$;

DECLARE @sqltext nvarchar(max);
DECLARE @filtercond nvarchar(max);

IF @useliefdat = 0
  SET @filtercond = N' AND RechKo.RechDat BETWEEN @startdate AND @enddate AND RechKo.ID > 0';
ELSE
  SET @filtercond = N' AND LsKo.Datum BETWEEN @startdate AND @enddate';

IF @onlyUHF = 0
  SET @sqltext = N'
  SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS [VSA-Nr], Vsa.SuchCode AS [VSA-Stichwort], Vsa.Bez AS [VSA-Bezeichnung], Bereich.Bereich, ArtGru.Gruppe, Artikel.ArtikelNr, KdArti.Variante, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Artikel.StueckGewicht AS [Gewicht (kg/Stück)], KdArti.LeasPreis AS Leasingpreis, LsKo.Datum AS Lieferdatum, LsKo.ID AS LsKoID, LsKo.LsNr, LsKoArt.Art, LsKoArt.LsKoArtBez$LAN$ AS [Lieferschein-Art], LsPo.Menge, LsPo.EPreis AS Einzelpreis, RechPo.RabattProz AS [Rabatt in Prozent], IIF(RechPo.RabattProz = 0, 0, (LsPo.EPreis * LsPo.Menge) * (RechPo.RabattProz / 100)) AS Rabatt, LsPo.EPreis * LsPo.Menge AS Gesamtpreis, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, RechKo.RechNr
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  JOIN LsKoArt ON LsKo.LsKoArtID = LsKoArt.ID
  JOIN Vsa ON LsKo.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN Bereich ON KdBer.BereichID = Bereich.ID
  JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
  JOIN RechPo ON LsPo.RechPoID = RechPo.ID
  JOIN Abteil ON RechPo.AbteilID = Abteil.ID
  JOIN RechKo ON RechPo.RechKoID = RechKo.ID
  WHERE Kunden.ID IN (SELECT ID FROM #Customers999118)
    AND Bereich.ID IN (SELECT ID FROM #ProductArea999118) '
  + @filtercond + ';
  ';
ELSE
  SET @sqltext = N'
  SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS [VSA-Nr], Vsa.SuchCode AS [VSA-Stichwort], Vsa.Bez AS [VSA-Bezeichnung], Bereich.Bereich, ArtGru.Gruppe, Artikel.ArtikelNr, KdArti.Variante, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Artikel.StueckGewicht AS [Gewicht (kg/Stück)], KdArti.LeasPreis AS Leasingpreis, LsKo.Datum AS Lieferdatum, LsKo.ID AS LsKoID, LsKo.LsNr, LsKoArt.Art, LsKoArt.LsKoArtBez$LAN$ AS [Lieferschein-Art], LsPo.Menge, LsPo.EPreis AS Einzelpreis, RechPo.RabattProz AS [Rabatt in Prozent], IIF(RechPo.RabattProz = 0, 0, (LsPo.EPreis * LsPo.Menge) * (RechPo.RabattProz / 100)) AS Rabatt, LsPo.EPreis * LsPo.Menge AS Gesamtpreis, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, RechKo.RechNr
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  JOIN LsKoArt ON LsKo.LsKoArtID = LsKoArt.ID
  JOIN Vsa ON LsKo.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN Bereich ON KdBer.BereichID = Bereich.ID
  JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
  JOIN RechPo ON LsPo.RechPoID = RechPo.ID
  JOIN Abteil ON RechPo.AbteilID = Abteil.ID
  JOIN RechKo ON RechPo.RechKoID = RechKo.ID
  WHERE Kunden.ID IN (SELECT ID FROM #Customers999118)
    AND Bereich.ID IN (SELECT ID FROM #ProductArea999118) '
  + @filtercond + '
    AND EXISTS (
      SELECT Scans.*
      FROM Scans
      WHERE Scans.LsPoID = LsPo.ID
        AND Scans.ActionsID = 102
    );
  ';

INSERT INTO #Result999118 (KdNr, Kunde, [VSA-Nr], [VSA-Stichwort], [VSA-Bezeichnung], Bereich, Gruppe, ArtikelNr, Variante, Artikelbezeichnung, [Gewicht (kg/Stück)], Leasingpreis, Lieferdatum, LsKoID, LsNr, Art, [Lieferschein-Art], Menge, Einzelpreis, [Rabatt in Prozent], Rabatt, Gesamtpreis, Kostenstelle, Kostenstellenbezeichnung, RechNr)
EXEC sp_executesql @sqltext, N'@startdate date, @enddate date', @startdate, @enddate;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: Reportdaten                                                                                                     ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT KdNr, Kunde, [VSA-Nr], [VSA-Stichwort], [VSA-Bezeichnung], Bereich, Gruppe, ArtikelNr, Variante, Artikelbezeichnung, [Gewicht (kg/Stück)], Lieferdatum, LsKoID, LsNr, Menge, Einzelpreis, Leasingpreis, Gesamtpreis, [Rabatt in Prozent], Rabatt, Gesamtpreis - Rabatt AS [Gesamtpreis rabattiert], Kostenstelle, Kostenstellenbezeichnung, RechNr
FROM #Result999118;
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Export-Script to transfer the wearers of a customer from AdvanTex to ABS                                                  ++ */
/* ++ Save the three SELECTs as seperate .csv-files named (in order):                                                           ++ */
/* ++   wearer.csv                                                                                                              ++ */
/* ++   wearinv.csv                                                                                                             ++ */
/* ++   uniqueitem.csv                                                                                                          ++ */
/* ++ ATTENTION: No headers!                                                                                                    ++ */
/* ++                                                                                                                           ++ */
/* ++ Author: Stefan Thaller - 2018-06-21                                                                                       ++ */
/* ++ Version 3.0 - 2018-08-24                                                                                                  ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @KdNr int = 6052;
DECLARE @KdNrABS int =  10003881;

DECLARE @Betrieb nchar(4) = N'SA22';  --Betriebscode des zukünftig für den Kunden zuständigen Betriebs
DECLARE @QualKlass nchar(1) = N'G'; -- Qualitätsklasse; Standardwert, da in AdvanTex so nicht vorhanden

DECLARE @ImportFile nvarchar(200) = N'\\atenadvantex01.wozabal.int\AdvanTex\Temp\6052_FischerBrot.xlsx'; 
DECLARE @XLSXImportSQL nvarchar(max);
DECLARE @ImportFile2 nvarchar(200) = N'\\atenadvantex01.wozabal.int\AdvanTex\Temp\6052_FischerBrot_Artikelliste.xlsx';
DECLARE @XLSXImportSQL2 nvarchar(max);
DECLARE @ImportFile3 nvarchar(200) = N'\\atenadvantex01.wozabal.int\AdvanTex\Temp\6052_FischerBrot_Groessen.xlsx';
DECLARE @XLSXImportSQL3 nvarchar(max);

DECLARE @Traeger TABLE (
  ID int,
  VsaID int,
  Traeger int,
  TNAdv nchar(8),
  Vorname nvarchar(20) COLLATE Latin1_General_CS_AS,
  Nachname nvarchar(25) COLLATE Latin1_General_CS_AS,
  PersNr nvarchar(10) COLLATE Latin1_General_CS_AS,
  Geschlecht nchar(1) COLLATE Latin1_General_CS_AS,
  Indienst nchar(7) COLLATE Latin1_General_CS_AS,
  IndienstDat date,
  Ausdienst nchar(7) COLLATE Latin1_General_CS_AS,
  AusdienstDat date,
  RentoArtID int,
  RentoCodID int,
  RentomatKredit int,
  Namenschild1 nvarchar(40) COLLATE Latin1_General_CS_AS,
  Namenschild2 nvarchar(40) COLLATE Latin1_General_CS_AS,
  Namenschild3 nvarchar(40) COLLATE Latin1_General_CS_AS,
  Emblem bit
);

DECLARE @ImportTable TABLE (
  [Status] nchar(1) COLLATE Latin1_General_CS_AS,
  Träger int,
  PersNr nchar(10) COLLATE Latin1_General_CS_AS,
  Nachname nvarchar(25) COLLATE Latin1_General_CS_AS,
  Vorname nvarchar(20) COLLATE Latin1_General_CS_AS,
  Schrank nchar(3) COLLATE Latin1_General_CS_AS,
  Fach int,
  SchrankFachBemerkung nvarchar(100) COLLATE Latin1_General_CS_AS,
  Emb bit,
  Abt int,
  AbtBez nvarchar(100) COLLATE Latin1_General_CS_AS,
  Anlieferstelle int,
  AnlieferstelleBez nvarchar(30) COLLATE Latin1_General_CS_AS,
  Verteilstelle int,
  VerteilstelleBez nvarchar(100) COLLATE Latin1_General_CS_AS,
  Kostenstelle nvarchar(100) COLLATE Latin1_General_CS_AS
);

DECLARE @ImportTable2 TABLE (
  ArtikelNr nchar(15) COLLATE Latin1_General_CS_AS,
  ABSArtikelNr nchar(15) COLLATE Latin1_General_CS_AS
);

DECLARE @ImportTable3 TABLE (
  ABSArtikelNr nchar(15) COLLATE Latin1_General_CS_AS,
  GroeFalsch nchar(20) COLLATE Latin1_General_CS_AS,
  GroeKorrekt nchar(20) COLLATE Latin1_General_CS_AS
)

SET @XLSXImportSQL = N'SELECT CAST(Status as nchar(1)) AS [Status], ' +
  N'CAST(Träger AS int) AS Träger, ' +
  N'CAST(PersNr AS nchar(10)) AS PersNr, ' +
  N'CAST(Nachname AS nvarchar(25)) AS Nachname, ' +
  N'CAST(Vorname AS nvarchar(20)) AS Vorname, ' +
  N'CAST(Schrank AS nchar(3)) AS Schrank, ' +
  N'CAST(Fach AS int) AS Fach, ' +
  N'CAST(SchrankFachBemerkung AS nvarchar(100)) AS SChrankFachBemerkung, ' +
  N'CAST(Emb AS bit) AS Emb, ' +
  N'CAST(Abt AS int) AS Abt, ' +
  N'CAST(AbtBez AS nvarchar(100)) AS AbtBez, ' +
  N'CAST(Anlieferstelle AS int) AS Anlieferstelle, ' +
  N'CAST(AnlieferstelleBez AS nvarchar(30)) AS AnlieferstelleBez, ' +
  N'CAST(Verteilstelle AS int) AS Verteilstelle, ' +
  N'CAST(VerteilstelleBez AS nvarchar(100)) AS VerteilstelleBez, ' +
  N'CAST(Kostenstelle AS nvarchar(100)) AS Kostenstelle ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [ABS$]);';

SET @XLSXImportSQL2 = N'SELECT DISTINCT CAST(ArtNr AS nchar(15)) AS ArtikelNr, ' +
  N'CAST(ABSArtNr AS nchar(15)) AS ABSArtikelNr ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile2+''', [Preisliste$]);';

SET @XLSXImportSQL3 = N'SELECT DISTINCT CAST(Produkt AS nchar(15)) AS ABSArtikelNr, ' +
  N'CAST(GroeFalsch AS nchar(20)) AS GroeFalsch, ' +
  N'CAST(GroeKorrekt AS nchar(20)) AS GroeKorrekt ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile3+''', [ABSGroe$]);';

INSERT INTO @ImportTable
EXEC sp_executesql @XLSXImportSQL;

INSERT INTO @ImportTable2
EXEC sp_executesql @XLSXImportSQL2;

INSERT INTO @ImportTable3
EXEC sp_executesql @XLSXImportSQL3;

INSERT INTO @Traeger
SELECT Traeger.ID, Traeger.VsaID, ROW_NUMBER() OVER (ORDER BY Traeger.ID) AS Traeger, Traeger.Traeger AS TNAdv, Traeger.Vorname, Traeger.Nachname, Traeger.PersNr, Traeger.Geschlecht, Traeger.Indienst, Traeger.IndienstDat, Traeger.Ausdienst, Traeger.AusdienstDat, Traeger.RentoArtID, Traeger.RentoCodID, Traeger.RentomatKredit, Traeger.Namenschild1, Traeger.Namenschild2, Traeger.Namenschild3, Traeger.Emblem
FROM Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.KdNr = @KdNr
  AND Traeger.Altenheim = 0
  AND Traeger.Status IN (N'A', N'P', N'K')
  AND Vsa.VsaNr IN (16, 14, 10, 11, 18, 19);

/* ++ wearer.csv ++ */
SELECT
  @KdNrABS AS CUSTOMERNUMBER,
  ISNULL(Traeger.Traeger, N'') AS WEARERNUMBER,
  N'' AS WEAREREMPLOYMENTNUMBER,
  RTRIM(IIF(Traeger.Vorname IS NULL, N'', RTRIM(REPLACE(Traeger.Vorname, N',', N' ')) + N' ') + ISNULL(RTRIM(REPLACE(Traeger.Nachname, N',', N' ')), N'')) AS FULLNAME,
  ISNULL(RTRIM(REPLACE(Traeger.Nachname, N',', N' ')), N'') AS SEARCHNAME,
  EMBLEMNAME =
    CASE WHEN Traeger.Emblem = 1
    THEN (
      SELECT TOP 1 ISNULL(RTRIM(Artikel.ArtikelBez), N'')
      FROM TraeArti
      JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
      JOIN KdArti AS EmbKdArti ON KdArti.EmbKdArtiID = EmbKdArti.ID
      JOIN Artikel ON EmbKdArti.ArtikelID = Artikel.ID
      WHERE TraeArti.TraegerID = Traeger.ID
    )
    ELSE N''
    END,
  ISNULL(RTRIM(Traeger.PersNr), N'') AS CUSTOMEREMPLOYEENUMBER,
  IIF(Traeger.Geschlecht = N'M', N'M', N'F') AS SEX,
  IIF(RentoArt.Code = N'P', N'Y', N'N') AS DUMMYFORPOOL,
  ISNULL(FORMAT(Traeger.IndienstDat, N'dd/MM/yyyy', N'en-US'), N'') AS DATEACTIVE,
  FORMAT(ISNULL(Traeger.AusdienstDat, N'2099-12-31'), N'dd/MM/yyyy', N'en-US') AS DATEINACTIVE,
  N'' AS REMARK,
  ISNULL(RentoCod.Funktionscode, N'') AS WEARERFUNCTIONCODE,
  IIF(RentoCod.ID < 0, N'', ISNULL(RentoCod.Bez, N'')) AS WEARERFUNCTIONDESCRIPTION,
  N'' AS FLAGCODE,
  N'' AS FLAGDESCRIPTION,
  RTRIM(ISNULL(CAST(ABSData.Fach AS nchar(6)), N'')) AS LOCKERBANK,
  RTRIM(ISNULL(ABSData.Schrank, N'')) AS LOCKER,
  N'' AS GARMENTDISPENSERCODE,
  N'' AS GARMENTDISPENSERDESC,
  Traeger.RentomatKredit AS DISPENSECREDIT,
  N'N' AS WEARERPRICE,
  N'' AS PRICESTARTDATE,
  N'' AS PRICE,
  ABSData.Abt AS DEPARTMENTNUMBER,
  N'' AS LOCKERSORTADDRESS,
  ISNULL(RTRIM(REPLACE(Traeger.Vorname, N',', N' ')), N'') AS FIRSTNAME,
  N'' AS EMPLOYMENTFLAGCODE,
  N'' AS EMPLOYMENTFLAGDESCRIPTION,
  ABSData.Anlieferstelle AS DELIVERYPOINTNUMBER,
  ABSData.AnlieferstelleBez AS DELIVERYPOINTDESCRIPTION,
  ISNULL(RTRIM(REPLACE(Traeger.Namenschild1, N',', N' ')), N'') AS EMBROIDERYLETTERINGLINE1,
  ISNULL(RTRIM(REPLACE(Traeger.Namenschild2, N',', N' ')), N'') AS EMBROIDERYLETTERINGLINE2,
  ISNULL(RTRIM(REPLACE(Traeger.Namenschild3, N',', N' ')), N'') AS EMBROIDERYLETTERINGLINE3,
  N'' AS LOCKERSORTGROUPNUMBER,
  N'' AS LOCKERSORTGROUPDESCR,
  N'' AS EXTERNALLOCKERBANK,
  N'' AS EXTERNALLOCKER,
  ABSData.Verteilstelle AS CONSUMPTIONPOINTNUMBER,
  N'' AS KEYCOMBINATION,
  N'' AS EOL
FROM @Traeger AS Traeger
JOIN @ImportTable AS ABSData ON ABSData.Träger = CAST(Traeger.TNAdv AS int) AND ABSData.Vorname = Traeger.Vorname AND ABSData.Nachname = Traeger.Nachname
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN RentoArt ON Traeger.RentoArtID = RentoArt.ID
JOIN RentoCod ON Traeger.RentoCodID = RentoCod.ID
ORDER BY WEARERNUMBER ASC;

/* ++ wearinv.csv ++ */
SELECT
  @KdNrABS AS CUSTOMERNUMBER,
  ISNULL(Traeger.Traeger, N'') AS WEARERNUMBER,
  1 AS WEAREREMPLOYMENTNUMBER,
  ISNULL(RTRIM(ABSArtikel.ABSArtikelNr), N'') AS PRODUCTCODE,
  IIF(ABSGroe.GroeKorrekt IS NOT NULL, RTRIM(ABSGroe.GroeKorrekt), ISNULL(RTRIM(ArtGroe.Groesse) + ISNULL(N'/' + RIGHT(RTRIM(REPLICATE(N'0', 3) + CAST(TraeMass.Mass AS nchar(3))), 3), IIF(ArtGroe.Beinlaenge > 0, N'/' + RIGHT(RTRIM(REPLICATE(N'0', 3) + CAST(ArtGroe.Beinlaenge AS nchar(3))), 3), N'')), N'')) AS SIZECODE,
  IIF(ABSGroe.GroeKorrekt IS NOT NULL, RTRIM(ABSGroe.GroeKorrekt), ISNULL(RTRIM(ArtGroe.Groesse) + ISNULL(N'/' + RIGHT(RTRIM(REPLICATE(N'0', 3) + CAST(TraeMass.Mass AS nchar(3))), 3), IIF(ArtGroe.Beinlaenge > 0, N'/' + RIGHT(RTRIM(REPLICATE(N'0', 3) + CAST(ArtGroe.Beinlaenge AS nchar(3))), 3), N'')), N'')) AS SIZEDESCRIPTION,
  N'GEF-A' AS FINISHINGMETHODCODE,
  N'' AS FINISHINGMETHODDESCRIPTION,
  N'' AS MODIFICATIONCODE1,
  N'' AS MODIFICATIONDESCRIPTION1,
  N'' AS MODIFICATIONCODE2,
  N'' AS MODIFICATIONDESCRIPTION2,
  N'' AS MODIFICATIONCODE3,
  N'' AS MODIFICATIONDESCRIPTION3,
  SUM(TraeArti.Menge) AS MAXINVENTORY,
  0 AS FREEOFCHARGEQTY,
  SUM(TraeArti.Menge) AS CIRCINVENTORY,
  ROUND(SUM(TraeArti.Menge) / 2, 0, 1) AS CHANGESPERWEEK,
  N'' AS SPECIALQUALITYGRADE,
  ISNULL(FORMAT(Traeger.IndienstDat, N'dd/MM/yyyy', N'en-US'), N'') AS STARTDATE,
  FORMAT(ISNULL(Traeger.AusdienstDat, N'2099-12-31'), N'dd/MM/yyyy', N'en-US') AS ENDDATE,
  N'' AS SWINGSUITSTATUS,
  N'' AS MAXFREEOFCHARGE,
  N'' AS WEARERINVENTORYPRICE,
  N'' AS PRICESTARTDATE,
  N'' AS PRICE,
  N'' AS QUANTITYRETURNED,
  N'' AS WEARERINVREMARK,
  N'' AS EMBLEMTEMPLATE,
  N'' AS QTYTOBERETURNEDDECREASEMAX,
  N'' AS QTYTOBERETURNEDREPLACMENT,
  N'' AS WEARERINVOICECATEGORYCODE,
  N'' AS WEARERINVOICEDATEGORYDESC,
  N'' AS WIC_EMPLOYERPERCENTAGE,
  N'' AS WIC_MAXEMPLOYERAMOUNT,
  N'' AS PHASEIN_PRODUCTCODE,
  N'' AS PHASEIN_SIZECODE,
  N'' AS PHASEIN_DATEACTIVE_WIL,
  N'' AS EOL
FROM @Traeger AS Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN RentoArt ON Traeger.RentoArtID = RentoArt.ID
JOIN RentoCod ON Traeger.RentoCodID = RentoCod.ID
JOIN TraeArti ON TraeArti.TraegerID = Traeger.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN @ImportTable2 AS ABSArtikel ON ABSArtikel.ArtikelNr = Artikel.ArtikelNr
LEFT OUTER JOIN TraeMass ON TraeMass.TraeArtiID = TraeArti.ID AND TraeMass.MassOrtID = 1
LEFT OUTER JOIN @ImportTable3 AS ABSGroe ON ABSGroe.ABSArtikelNr = ABSArtikel.ABSArtikelNr AND ABSGroe.GroeFalsch = ISNULL(RTRIM(ArtGroe.Groesse) + ISNULL(N'/' + RIGHT(RTRIM(REPLICATE(N'0', 3) + CAST(TraeMass.Mass AS nchar(3))), 3), IIF(ArtGroe.Beinlaenge > 0, N'/' + RIGHT(RTRIM(REPLICATE(N'0', 3) + CAST(ArtGroe.Beinlaenge AS nchar(3))), 3), N'')), N'')
WHERE TraeArti.Menge > 0
GROUP BY ISNULL(Traeger.Traeger, N''), ISNULL(RTRIM(ABSArtikel.ABSArtikelNr), N''), IIF(ABSGroe.GroeKorrekt IS NOT NULL, RTRIM(ABSGroe.GroeKorrekt), ISNULL(RTRIM(ArtGroe.Groesse) + ISNULL(N'/' + RIGHT(RTRIM(REPLICATE(N'0', 3) + CAST(TraeMass.Mass AS nchar(3))), 3), IIF(ArtGroe.Beinlaenge > 0, N'/' + RIGHT(RTRIM(REPLICATE(N'0', 3) + CAST(ArtGroe.Beinlaenge AS nchar(3))), 3), N'')), N'')), IIF(ABSGroe.GroeKorrekt IS NOT NULL, RTRIM(ABSGroe.GroeKorrekt), ISNULL(RTRIM(ArtGroe.Groesse) + ISNULL(N'/' + RIGHT(RTRIM(REPLICATE(N'0', 3) + CAST(TraeMass.Mass AS nchar(3))), 3), IIF(ArtGroe.Beinlaenge > 0, N'/' + RIGHT(RTRIM(REPLICATE(N'0', 3) + CAST(ArtGroe.Beinlaenge AS nchar(3))), 3), N'')), N'')), ISNULL(FORMAT(Traeger.IndienstDat, N'dd/MM/yyyy', N'en-US'), N''), FORMAT(ISNULL(Traeger.AusdienstDat, N'2099-12-31'), N'dd/MM/yyyy', N'en-US')  
ORDER BY WEARERNUMBER, PRODUCTCODE;

/* ++ uniqueitem.csv ++ */
SELECT
  @Betrieb AS BUSINESSUNIT,
  RTRIM(Teile.Barcode) AS PRIMARYID,
  1 AS IDCODESEQUENCENUMBER,
  ISNULL(RTRIM(Teile.RentomatChip), N'') AS SECONDARYID,
  20 AS [STATUS],
  20 AS STAY,
  @KdNrABS AS CUSTOMERNUMBER,
  ISNULL(Traeger.Traeger, N'') AS WEARERNUMBER,
  1 AS WEAREREMPLOYMENTNUMBER,
  ISNULL(RTRIM(ABSArtikel.ABSArtikelNr), N'') AS PRODUCTCODE,
  IIF(ABSGroe.GroeKorrekt IS NOT NULL, RTRIM(ABSGroe.GroeKorrekt), ISNULL(RTRIM(ArtGroe.Groesse) + ISNULL(N'/' + RIGHT(RTRIM(REPLICATE(N'0', 3) + CAST(TraeMass.Mass AS nchar(3))), 3), IIF(ArtGroe.Beinlaenge > 0, N'/' + RIGHT(RTRIM(REPLICATE(N'0', 3) + CAST(ArtGroe.Beinlaenge AS nchar(3))), 3), N'')), N'')) AS SIZECODE,
  N'GEF-A' AS FINISHINGMETHODCODE,
  N'' AS GARMENTSEQUENCENUMBER,
  Teile.RuecklaufG AS WASHESTOTAL,
  Teile.AnzRepairG AS REPAIRTOTAL,
  0 AS REWASHESTOTAL,
  Teile.RuecklaufK AS WASHESTHISISSUE,
  Teile.AnzRepair AS REPAIRSTHISISSUE,
  0 AS REWASHESTHISISSUE,
  N'N' AS CUSTOMEROWNED,
  N'' AS RELATEDCUSTOMERNUMBER,
  N'' AS DELIVERYFROMSTOCK,
  0 AS STARTRENTFROM,
  ISNULL(FORMAT(CAST(Teile.Eingang1 AS datetime), N'dd/MM/yyyy hh:mm:ss', N'en-US'), N'') AS LASTINSCANDATE,
  ISNULL(FORMAT(CAST(Teile.Ausgang1 AS datetime), N'dd/MM/yyyy hh:mm:ss', N'en-US'), N'') AS LASTOUTSCANDATE,
  (SELECT ISNULL(FORMAT(MAX(Scans.DateTime), N'dd/MM/yyyy hh:mm:ss', N'en-US'), N'') FROM Scans WHERE Scans.TeileID = Teile.ID) AS LASTSCANDATE,
  N'' AS STATUSCHANGEDATE,
  N'' AS STAYCHANGEDATE,
  ISNULL(FORMAT(Teile.ErstDatum, N'dd/MM/yyyy', N'en-US'), N'') AS PURCHASEDATE,
  IIF(Teile.IndienstDat = Teile.ErstDatum, 1, 2) AS NUMBEROFISSUES,
  ISNULL(FORMAT(Teile.ErstDatum, N'dd/MM/yyyy', N'en-US'), N'') AS FIRSTISSUEDATE,
  ISNULL(FORMAT(Teile.IndienstDat, N'dd/MM/yyyy', N'en-US'), N'') AS LASTISSUEDATE,
  N'' AS ENDDATEFULLRENT,
  N'' AS DAYSINCIRCPREVISSUE,
  N'' AS DAYSINSTOCKPREVIOUS,
  N'' AS SUPPLIERNUMBER,
  N'' AS PURCHASEPRICE,
  ISNULL(RTRIM(Wae.IsoCode), N'') AS CURRENCYCODE,
  @QualKlass AS QUALITYGRADECODE,
  N'' AS FREEEXTRAGARMENTS,
  N'31/12/2099' AS ENDDATEFREEEXTRA,
  N'' AS MODIFICATIONCODE1,
  N'' AS MODIFICATIONDESCRIPTION1,
  N'' AS MODIFICATIONCODE2,
  N'' AS MODIFICATIONDESCRIPTION2,
  N'' AS MODIFICATIONCODE3,
  N'' AS MODIFICATIONDESCRIPTION3,
  N'' AS REASONCODE,
  N'' AS FLAGCODE,
  N'' AS FLAGDESCRIPTION,
  N'' AS FLAGSTARTDATE,
  N'' AS FLAGFREETEXT,
  N'' AS REMARK,
  N'' AS LEASEWEEKS,
  N'' AS RESIDUALVALUEAMOUNT,
  N'' AS REPLACEMENTPRICE,
  N'' AS EOL
FROM @Traeger AS Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN RentoArt ON Traeger.RentoArtID = RentoArt.ID
JOIN RentoCod ON Traeger.RentoCodID = RentoCod.ID
JOIN TraeArti ON TraeArti.TraegerID = Traeger.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Teile ON Teile.TraeArtiID = TraeArti.ID
JOIN Wae ON Kunden.WaeID = Wae.ID
JOIN @ImportTable2 AS ABSArtikel ON ABSArtikel.ArtikelNr = Artikel.ArtikelNr
LEFT OUTER JOIN TraeMass ON TraeMass.TraeArtiID = TraeArti.ID AND TraeMass.MassOrtID = 1
LEFT OUTER JOIN @ImportTable3 AS ABSGroe ON ABSGroe.ABSArtikelNr = ABSArtikel.ABSArtikelNr AND ABSGroe.GroeFalsch = ISNULL(RTRIM(ArtGroe.Groesse) + ISNULL(N'/' + RIGHT(RTRIM(REPLICATE(N'0', 3) + CAST(TraeMass.Mass AS nchar(3))), 3), IIF(ArtGroe.Beinlaenge > 0, N'/' + RIGHT(RTRIM(REPLICATE(N'0', 3) + CAST(ArtGroe.Beinlaenge AS nchar(3))), 3), N'')), N'')
WHERE TraeArti.Menge > 0
  AND Teile.Status BETWEEN N'M' AND N'Q'
ORDER BY WEARERNUMBER, PRODUCTCODE;
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

DECLARE @KdNr int = 30363;
DECLARE @KdNrABS int =  90000000;

DECLARE @Betrieb nchar(4) = N'SA00';  --Betriebscode des zukünftig für den Kunden zuständigen Betriebs
DECLARE @QualKlass nchar(1) = N'G'; -- Qualitätsklasse; Standardwert, da in AdvanTex so nicht vorhanden

DECLARE @Traeger TABLE (
  ID int,
  VsaID int,
  Traeger int,
  Vorname nvarchar(20),
  Nachname nvarchar(25),
  PersNr nvarchar(10),
  Geschlecht nchar(1),
  Indienst nchar(7),
  IndienstDat date,
  Ausdienst nchar(7),
  AusdienstDat date,
  RentoArtID int,
  RentoCodID int,
  RentomatKredit int,
  Namenschild1 nvarchar(40),
  Namenschild2 nvarchar(40),
  Namenschild3 nvarchar(40),
  Emblem bit
);

INSERT INTO @Traeger
SELECT Traeger.ID, Traeger.VsaID, ROW_NUMBER() OVER (ORDER BY Traeger.ID) AS Traeger, Traeger.Vorname, Traeger.Nachname, Traeger.PersNr, Traeger.Geschlecht, Traeger.Indienst, Traeger.IndienstDat, Traeger.Ausdienst, Traeger.AusdienstDat, Traeger.RentoArtID, Traeger.RentoCodID, Traeger.RentomatKredit, Traeger.Namenschild1, Traeger.Namenschild2, Traeger.Namenschild3, Traeger.Emblem
FROM Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.KdNr = @KdNr
  AND Traeger.Altenheim = 0
  AND Traeger.Status IN (N'A', N'P', N'K');

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
  N'' AS LOCKERBANK,
  N'' AS LOCKER,
  N'' AS GARMENTDISPENSERCODE,
  N'' AS GARMENTDISPENSERDESC,
  Traeger.RentomatKredit AS DISPENSECREDIT,
  N'N' AS WEARERPRICE,
  N'' AS PRICESTARTDATE,
  N'' AS PRICE,
  Vsa.VsaNr AS DEPARTMENTNUMBER,
  N'' AS LOCKERSORTADDRESS,
  ISNULL(RTRIM(REPLACE(Traeger.Vorname, N',', N' ')), N'') AS FIRSTNAME,
  N'' AS EMPLOYMENTFLAGCODE,
  N'' AS EMPLOYMENTFLAGDESCRIPTION,
  N'' AS DELIVERYPOINTNUMBER,
  N'' AS DELIVERYPOINTDESCRIPTION,
  ISNULL(RTRIM(REPLACE(Traeger.Namenschild1, N',', N' ')), N'') AS EMBROIDERYLETTERINGLINE1,
  ISNULL(RTRIM(REPLACE(Traeger.Namenschild2, N',', N' ')), N'') AS EMBROIDERYLETTERINGLINE2,
  ISNULL(RTRIM(REPLACE(Traeger.Namenschild3, N',', N' ')), N'') AS EMBROIDERYLETTERINGLINE3,
  N'' AS LOCKERSORTGROUPNUMBER,
  N'' AS LOCKERSORTGROUPDESCR,
  N'' AS EXTERNALLOCKERBANK,
  N'' AS EXTERNALLOCKER,
  N'' AS CONSUMPTIONPOINTNUMBER,
  N'' AS KEYCOMBINATION,
  N'' AS EOL
FROM @Traeger AS Traeger
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
  ISNULL(RTRIM(Artikel.ArtikelNr2), N'') AS PRODUCTCODE,
  ISNULL(RTRIM(ArtGroe.Groesse), N'') AS SIZECODE,
  ISNULL(RTRIM(ArtGroe.Groesse), N'') AS SIZEDESCRIPTION,
  N'GEF-A' AS FINISHINGMETHODCODE,
  N'' AS FINISHINGMETHODDESCRIPTION,
  N'' AS MODIFICATIONCODE1,
  N'' AS MODIFICATIONDESCRIPTION1,
  N'' AS MODIFICATIONCODE2,
  N'' AS MODIFICATIONDESCRIPTION2,
  N'' AS MODIFICATIONCODE3,
  N'' AS MODIFICATIONDESCRIPTION3,
  TraeArti.Menge AS MAXINVENTORY,
  0 AS FREEOFCHARGEQTY,
  TraeArti.Menge AS CIRCINVENTORY,
  ROUND(TraeArti.Menge / 2, 0, 1) AS CHANGESPERWEEK,
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
WHERE TraeArti.Menge > 0
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
  ISNULL(RTRIM(Artikel.ArtikelNr2), N'') AS PRODUCTCODE,
  ISNULL(RTRIM(ArtGroe.Groesse), N'') AS SIZECODE,
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
WHERE TraeArti.Menge > 0
  AND Teile.Status = N'Q'
ORDER BY WEARERNUMBER, PRODUCTCODE;
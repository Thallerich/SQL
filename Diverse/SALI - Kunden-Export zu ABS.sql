DECLARE @KdNr int = 30972;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Export-Script to transfer the wearers of a customer from AdvanTex to ABS                                                  ++ */
/* ++ Save the three SELECTs as seperate .csv-files named (in order):                                                           ++ */
/* ++   wearer.csv                                                                                                              ++ */
/* ++   wearinv.csv                                                                                                             ++ */
/* ++   uniqueitem.csv                                                                                                          ++ */
/* ++ ATTENTION: csv-file has to end with ;\r\n - needs to be done manually after export!                                       ++ */
/* ++                                                                                                                           ++ */
/* ++ Author: Stefan Thaller - 2018-06-21                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

/* ++ wearer.csv ++ */
SELECT
  Kunden.KdNr AS CUSTOMERNUMBER,
  RTRIM(Traeger.Traeger) AS WEARERNUMBER,
  N'' AS WEAREREMPLOYMENTNUMBER,
  IIF(Traeger.Vorname IS NULL, N'', RTRIM(Traeger.Vorname) + N' ') + ISNULL(RTRIM(Traeger.Nachname), N'') AS FULLNAME,
  ISNULL(RTRIM(Traeger.Nachname), N'') AS SEARCHNAME,
  N'' AS EMBLEMNAME,
  ISNULL(RTRIM(Traeger.PersNr), N'') AS CUSTOMEREMPLOYEENUMBER,
  IIF(Traeger.Geschlecht = N'M', N'M', N'F') AS SEX,
  IIF(RentoArt.Code = N'P', N'Y', N'N') AS DUMMYFORPOOL,
  Traeger.IndienstDat AS DATEACTIVE,
  ISNULL(Traeger.AusdienstDat, N'2099-12-31') AS DATEINACTIVE,
  N'' AS REMARK,
  ISNULL(RentoCod.Funktionscode, N'') AS WEARERFUNCTIONCODE,
  IIF(RentoCod.ID < 0, N'', RentoCod.Bez) AS WEARERFUNCTIONDESCRIPTION,
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
  ISNULL(RTRIM(Traeger.Vorname), N'') AS FIRSTNAME,
  N'' AS EMPLOYMENTFLAGCODE,
  N'' AS EMPLOYMENTFLAGDESCRIPTION,
  N'' AS DELIVERYPOINTNUMBER,
  N'' AS DELIVERYPOINTDESCRIPTION,
  ISNULL(RTRIM(Traeger.Namenschild1), N'') AS EMBROIDERYLETTERINGLINE1,
  ISNULL(RTRIM(Traeger.Namenschild2), N'') AS EMBROIDERYLETTERINGLINE2,
  ISNULL(RTRIM(Traeger.Namenschild3), N'') AS EMBROIDERYLETTERINGLINE3,
  N'' AS LOCKERSORTGROUPNUMBER,
  N'' AS LOCKERSORTGROUPDESCR,
  N'' AS EXTERNALLOCKERBANK,
  N'' AS EXTERNALLOCKER,
  N'' AS CONSUMPTIONPOINTNUMBER,
  N'' AS KEYCOMBINATION
FROM Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN RentoArt ON Traeger.RentoArtID = RentoArt.ID
JOIN RentoCod ON Traeger.RentoCodID = RentoCod.ID
WHERE Kunden.KdNr = @KdNr
  AND Traeger.Altenheim = 0
  AND Traeger.Status IN (N'A', N'P', N'K');

/* ++ wearinv.csv ++ */
SELECT
  Kunden.KdNr AS CUSTOMERNUMBER,
  ISNULL(RTRIM(Traeger.Traeger), N'') AS WEARERNUMBER,
  1 AS WEAREREMPLOYMENTNUMBER,
  RTRIM(Artikel.ArtikelNr) AS PRODUCTCODE,
  RTRIM(ArtGroe.Groesse) AS SIZECODE,
  RTRIM(ArtGroe.Groesse) AS SIZEDESCRIPTION,
  N'' AS FINISHINGMETHODCODE,
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
  Traeger.IndienstDat AS STARTDATE,
  ISNULL(Traeger.AusdienstDat, N'2099-12-31') AS ENDDATE,
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
  N'' AS PHASEIN_DATEACTIVE_WIL
FROM Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN RentoArt ON Traeger.RentoArtID = RentoArt.ID
JOIN RentoCod ON Traeger.RentoCodID = RentoCod.ID
JOIN TraeArti ON TraeArti.TraegerID = Traeger.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
WHERE Kunden.KdNr = @KdNr
  AND Traeger.Altenheim = 0
  AND Traeger.Status IN (N'A', N'P', N'K')
  AND TraeArti.Menge > 0;

/* ++ uniqueitem.csv ++ */
SELECT
  N'' AS BUSINESSUNIT,
  RTRIM(Teile.Barcode) AS PRIMARYID,
  1 AS IDCODESEQUENCENUMBER,
  ISNULL(RTRIM(Teile.RentomatChip), N'') AS SECONDARYID,
  20 AS [STATUS],
  20 AS STAY,
  Kunden.KdNr AS CUSTOMERNUMBER,
  ISNULL(RTRIM(Traeger.Traeger), N'') AS WEARERNUMBER,
  1 AS WEAREREMPLOYMENTNUMBER,
  RTRIM(Artikel.ArtikelNr) AS PRODUCTCODE,
  RTRIM(ArtGroe.Groesse) AS SIZECODE,
  N'' AS FINISHINGMETHODCODE,
  N'' AS GARMENTSEQUENCENUMBER,
  Teile.RuecklaufG AS WASHESTOTAL,
  Teile.AnzRepairG AS REPAIRTOTAL,
  0 AS REWASHESTOTAL,
  Teile.RuecklaufK AS WASHESTHISISSUE,
  Teile.AnzRepair AS REPAIRSTHISISSUE,
  0 AS REWASHESTHISISSUE,
  N'' AS RELATEDCUSTOMERNUMBER,
  N'' AS DELIVERYFROMSTOCK,
  0 AS STARTRENTFROM,
  CAST(Teile.Eingang1 AS datetime) AS LASTINSCANDATE,
  CAST(Teile.Ausgang1 AS datetime) AS LASTOUTSCANDATE,
  (SELECT MAX(Scans.DateTime) FROM Scans WHERE Scans.TeileID = Teile.ID) AS LASTSCANDATE,
  N'' AS STATUSCHANGEDATE,
  N'' AS STAYCHANGEDATE,
  N'' AS PURCHASEDATE,
  IIF(Teile.IndienstDat = Teile.ErstDatum, 1, 2) AS NUMBEROFISSUES,
  Teile.ErstDatum AS FIRSTISSUEDATE,
  Teile.IndienstDat AS LASTISSUEDATE,
  N'' AS ENDDATEFULLRENT,
  N'' AS DAYSINCIRCPREVISSUE,
  N'' AS DAYSINSTOCKPREVIOUS,
  N'' AS SUPPLIERNUMBER,
  N'' AS PURCHASEPRICE,
  RTRIM(Wae.IsoCode) AS CURRENCYCODE,
  N'' AS QUALITYGRADECODE,
  N'' AS FREEEXTRAGARMENTS,
  N'' AS ENDDATEFREEEXTRA,
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
  N'' AS REPLACEMENTPRICE
FROM Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN RentoArt ON Traeger.RentoArtID = RentoArt.ID
JOIN RentoCod ON Traeger.RentoCodID = RentoCod.ID
JOIN TraeArti ON TraeArti.TraegerID = Traeger.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Teile ON Teile.TraeArtiID = TraeArti.ID
JOIN Wae ON Kunden.WaeID = Wae.ID
WHERE Kunden.KdNr = @KdNr
  AND Traeger.Altenheim = 0
  AND Traeger.Status IN (N'A', N'P', N'K')
  AND TraeArti.Menge > 0
  AND Teile.Status = N'Q';
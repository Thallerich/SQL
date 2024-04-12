/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Rechnungsanlage Bewohner / Heimanteile netto                                                                              ++ */
/* ++ Version 2.1                                                                                                               ++ */
/* ++                                                                                                                           ++ */
/* ++ Author: Stefan Thaller - 2018-10-01                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @LsPoSumme TABLE (
  Kostenstelle nchar(15),
  KostenstelleBez nvarchar(80),
  KostenstelleID int,
  Nachname nchar(25),
  Vorname nchar(20),
  TraegerNr nchar(8),
  ZimmerNr nchar(10),
  ServiceProzent numeric(7,4),
  RabattBearbeitung numeric(7,4),
  ProzentTraeger numeric(7,4),
  LsPoID int,
  LsPoSumme smallmoney,
  AnteilTraeger smallmoney,
  AnteilHeim smallmoney,
  Jahr nchar(4),
  Monat nchar(2),
  RechNr int,
  KundenIDNr int
);

INSERT INTO @LsPoSumme
SELECT Abteil.Abteilung AS Kostenstelle,
  Abteil.Bez AS KostenstelleBez,
  Abteil.ID AS KostenstelleID,
  Traeger.Nachname,
  Traeger.Vorname,
  Traeger.Traeger AS TraegerNr,
  Traeger.PersNr AS ZimmerNr,
  BewAbr.ServiceProz AS ServiceProzent,
  KdBer.RabattWasch AS RabattBearbeitung,
  BewKdAr.ProzTraeger AS ProzentTraeger,
  LsPo.ID AS LsPoID,
  LsPo.Menge * LsPo.EPreis * (1 - (KdBer.RabattWasch/100)) AS LsPoSumme,
  LsPo.Menge * LsPo.EPreis * (1 - (KdBer.RabattWasch/100)) * ProzTraeger/100 AS AnteilTraeger,
  LsPo.Menge * LsPo.EPreis * (1 - (KdBer.RabattWasch/100)) * (1 - (ProzTraeger/100)) AS AnteilHeim,
  FORMAT(RechKo.RechDat, N'yyyy') AS Jahr,
  FORMAT(RechKo.RechDat, N'MM') AS Monat,
  RechKo.RechNr,
  KundenIDNr =
    CASE Kunden.KdNr
      WHEN 7425 THEN 689926
      WHEN 30061 THEN 621346
      WHEN 2529403 THEN 402524
      WHEN 25033 THEN 159771
      WHEN 19016 THEN 716221
      WHEN 2024 THEN 499302
      WHEN 23010 THEN 518885
      WHEN 10006790 THEN 1654580
      ELSE NULL
    END
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN RechPo ON LsPo.RechPoID = RechPo.ID
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Abteil ON LsPo.AbteilID = Abteil.ID
JOIN Traeger ON LsKo.TraegerID = Traeger.ID
JOIN BewAbr ON Traeger.BewAbrID = BewAbr.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
LEFT OUTER JOIN BewKdAr ON BewKdAr.BewAbrID = BewAbr.ID AND BewKdAr.KdArtiID = KdArti.ID
WHERE RechKo.ID = $RECHKOID$
  AND Bereich.Bereich = N'PWS';

SELECT LPS.Jahr,
  LPS.Monat,
  LPS.RechNr,
  LPS.Kostenstelle,
  LPS.KostenstelleBez,
  LPS.Nachname,
  LPS.Vorname,
  LPS.ZimmerNr,
  LPS.TraegerNr,
  SUM(LPS.LsPoSumme) AS NettoPreis,
  SUM(LPS.LsPoSumme) * 1.2 AS BruttoPreis,
  SUM(LPS.AnteilTraeger) AS NettoTraeger,
  SUM(LPS.AnteilTraeger) * 1.2 AS BruttoTraeger,
  SUM(LPS.AnteilHeim) AS NettoHeim,
  SUM(LPS.AnteilHeim) * 1.2 AS BruttoHeim,
  LPS.KundenIDNr
FROM @LsPoSumme AS LPS
GROUP BY LPS.Jahr, LPS.Monat, LPS.RechNr, LPS.Kostenstelle, LPS.KostenstelleBez, LPS.KostenstelleID, LPS.Nachname, LPS.Vorname, LPS.ZimmerNr, LPS.TraegerNr, LPS.RabattBearbeitung, LPS.ServiceProzent, LPS.KundenIDNr
ORDER BY Nachname, Vorname;
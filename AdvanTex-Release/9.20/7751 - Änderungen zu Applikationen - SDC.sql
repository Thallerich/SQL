/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ ARTIMOD                                                                                                                   ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
INSERT INTO RepQueue (Typ, TableName, TableID, ApplicationID, SdcDevID, Priority)
SELECT 'UPDATE' AS Typ, 'ARTIMOD' AS TableName, ArtiMod.ID, N'AdvanTex' AS ApplicationID, SDC.ID AS SdcDevID, 13 AS Priority
FROM ArtiMod
CROSS JOIN (
  SELECT ID
  FROM SdcDev
  WHERE ID > -1
    AND IsTriggerDestGr1=1
) AS SDC;

GO
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ TEILAPPL                                                                                                                  ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

INSERT INTO RepQueue (Typ, TableName, TableID, ApplicationID, SdcDevID, Priority)
SELECT 'UPDATE' AS Typ, 'TEILAPPL' AS TableName, ID, N'AdvanTex' AS ApplicationID, Daten.SdcDevID, IIF(TeilAppl.Bearbeitung = N'-', 9999999, 24) AS Priority
FROM TeilAppl 
JOIN (
  SELECT DISTINCT StBerSdc.SdcDevID, Teile.ID TeileID
  FROM Vsa, StandBer, StBerSdc, Teile, KdArti, KdBer
  WHERE Vsa.StandKonID = StandBer.StandKonID
    AND Teile.VsaID = Vsa.ID
    AND Teile.KdArtiID = KdArti.ID
    AND KdArti.KdBerID = KdBer.ID
    AND KdBer.BereichID = StandBer.BereichID
    AND Standber.ID = StBerSdc.StandberID
    AND StBerSdc.SdcDevID IN (SELECT ID FROM SdcDev WHERE ID > -1 AND IsTriggerDest = 1)
    AND ((StBerSdc.Modus = 0) OR (Teile.Status < 'Q'))
    AND Teile.AltenheimModus = 0
) Daten ON Daten.TeileID = TeilAppl.TeileID;

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ KDARAPPL                                                                                                                  ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

INSERT INTO RepQueue (Typ, TableName, TableID, ApplicationID, SdcDevID, Priority)
SELECT 'UPDATE' AS Typ, 'KDARAPPL' AS TableName, KdArAppl.ID, N'AdvanTex' AS ApplicationID, SDC.ID AS SdcDevID, 16 AS Priority
FROM KdArAppl
CROSS JOIN (
  SELECT ID 
  FROM SdcDev
  WHERE ID > -1
    AND IsTriggerDest=1
) AS SDC
WHERE KdArAppl.ArtiTypeID = 8;

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ KDARTI                                                                                                                    ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

INSERT INTO RepQueue (Typ, TableName, TableID, ApplicationID, SdcDevID, Priority)
SELECT 'UPDATE' AS Typ, 'KDARTI' AS TableName, KdArti.ID, N'AdvanTex' AS ApplicationID, SDC.ID AS SdcDevID, 15 AS Priority
FROM KdArti
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
CROSS JOIN (
  SELECT ID 
  FROM SdcDev
  WHERE ID > -1
    AND IsTriggerDest=1
) AS SDC
WHERE Kunden.AdrArtID = 1
  AND Artikel.ArtiTypeID = 8;

GO
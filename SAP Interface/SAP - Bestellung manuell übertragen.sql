IF OBJECT_ID(N'dbo._SAPPurchaseOrder') IS NULL
  CREATE TABLE _SAPPurchaseOrder (
    ID int PRIMARY KEY CLUSTERED NOT NULL
  );
ELSE
  TRUNCATE TABLE _SAPPurchaseOrder;

GO

INSERT INTO _SAPPurchaseOrder (ID)
SELECT BKo.ID
FROM BKo
WHERE BKo.BestNr IN (412048350, 412048353)
  AND BKo.SentToSAP = 0;

GO

SELECT Lief.ID, Lief.LiefNr, Lief.Name1, LiefType.LiefTypeBez, LiefType.InternerLief
FROM Lief
JOIN LiefType ON Lief.LiefTypeID = LiefType.ID
WHERE Lief.ID IN (
  SELECT BKo.LiefID
  FROM BKo
  WHERE BKo.ID IN (SELECT _SAPPurchaseOrder.ID FROM _SAPPurchaseOrder)
);

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Modulaufruf:                                                                                                              ++ */
/* ++   SAPPURCHASEORDERSEND;19800101;0;-1;_SAPPurchaseOrder                                                                    ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

/* 
UPDATE BKo SET SentToSAP = 1
WHERE BKo.ID IN (SELECT _SAPPurchaseOrder.ID FROM _SAPPurchaseOrder)
  AND BKo.LiefID IN (SELECT Lief.ID FROM Lief WHERE Lief.LiefTypeID IN (SELECT LiefType.ID FROM LiefType WHERE LiefType.InternerLief = 1));
*/
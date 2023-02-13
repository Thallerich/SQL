CREATE TABLE _SAPPurchaseOrder (
  ID int PRIMARY KEY CLUSTERED NOT NULL
);

GO

INSERT INTO _SAPPurchaseOrder (ID)
SELECT BKo.ID
FROM BKo
WHERE BKo.BestNr = 412017538
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
DROP TABLE _SAPPurchaseOrder;
GO
*/
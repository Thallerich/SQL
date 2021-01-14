DECLARE @Output TABLE (
  WebUserID int,
  KundenID int
);

DECLARE @WebUChanged TABLE (
  WebUserID int,
  FuncDeactivateW bit,
  FuncDecAmount bit 
);

DECLARE @KdNr int = 272295;

INSERT INTO @WebUChanged (WebUserID, FuncDeactivateW)
SELECT __WebUserFuncDeactivateW.ID AS WebUserID, __WebUserFuncDeactivateW.FuncDeactivateW
FROM __WebUserFuncDeactivateW
JOIN WebUser ON WebUser.ID = __WebUserFuncDeactivateW.ID
JOIN Kunden ON WebUser.KundenID = Kunden.ID
WHERE Kunden.KdNr = @KdNr;

MERGE @WebUChanged AS WebUChanged
USING (
  SELECT __WebUserFuncDecAmount.ID AS WebUserID, __WebUserFuncDecAmount.FuncDecAmount
  FROM __WebUserFuncDecAmount
  JOIN WebUser ON WebUser.ID = __WebUserFuncDecAmount.ID
  JOIN Kunden ON WebUser.KundenID = Kunden.ID
  WHERE Kunden.KdNr = @KdNr
) AS source (WebUserID, FuncDecAmount) ON source.WebUserID = WebUChanged.WebUserID
WHEN MATCHED THEN
  UPDATE SET FuncDecAmount = 1
WHEN NOT MATCHED THEN
  INSERT (WebUserID, FuncDecAmount) VALUES (source.WebUserID, source.FuncDecAmount);

MERGE @WebUChanged AS WebUChanged
USING (
  SELECT __WebUserGraz.ID AS WebUserID, __WebUserGraz.FuncDecAmount
  FROM __WebUserGraz
  JOIN WebUser ON WebUser.ID = __WebUserGraz.ID
  JOIN Kunden ON WebUser.KundenID = Kunden.ID
  WHERE Kunden.KdNr = @KdNr
) AS source (WebUserID, FuncDecAmount) ON source.WebUserID = WebUChanged.WebUserID
WHEN MATCHED THEN
  UPDATE SET FuncDecAmount = 1
WHEN NOT MATCHED THEN
  INSERT (WebUserID, FuncDecAmount) VALUES (source.WebUserID, source.FuncDecAmount);

BEGIN TRANSACTION;

--SELECT Webuser.ID, WebUser.UserName, WebUser.FuncDeactivateW, WebUChanged.FuncDeactivateW, WebUser.FuncDecAmount, WebUChanged.FuncDecAmount
UPDATE WebUser SET FuncDeactivateW = WebUChanged.FuncDeactivateW, FuncDecAmount = WebUChanged.FuncDecAmount
OUTPUT inserted.ID, inserted.KundenID
INTO @Output
FROM WebUser
JOIN Kunden ON WebUser.KundenID = Kunden.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN @WebUChanged AS WebUChanged ON WebUser.ID = WebUChanged.WebUserID
WHERE (Webuser.FuncDecAmount != WebUChanged.FuncDecAmount OR WebUser.FuncDeactivateW != WebUChanged.FuncDeactivateW);

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, WebUser.UserName
FROM @Output AS changed
JOIN Kunden ON changed.KundenID = Kunden.ID
JOIN WebUser ON changed.WebUserID = WebUser.ID;

-- COMMIT;
-- ROLLBACK;
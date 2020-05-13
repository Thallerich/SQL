DECLARE @Output TABLE (
  WebUserID int,
  KundenID int
);

DECLARE @WebUChanged TABLE (
  WebUserID int,
  FuncDeactivateW bit,
  FuncDecAmount bit 
);

INSERT INTO @WebUChanged (WebUserID, FuncDeactivateW)
SELECT __WebUserFuncDeactivateW.ID AS WebUserID, __WebUserFuncDeactivateW.FuncDeactivateW
FROM __WebUserFuncDeactivateW;

MERGE @WebUChanged AS WebUChanged
USING (
  SELECT ID AS WebUserID, FuncDecAmount
  FROM __WebUserFuncDecAmount
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
WHERE Standort.SuchCode = N'UKLU'
  AND (Webuser.FuncDecAmount != WebUChanged.FuncDecAmount OR WebUser.FuncDeactivateW != WebUChanged.FuncDeactivateW);

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, WebUser.UserName
FROM @Output AS changed
JOIN Kunden ON changed.KundenID = Kunden.ID
JOIN WebUser ON changed.WebUserID = WebUser.ID;

-- COMMIT;
-- ROLLBACK;
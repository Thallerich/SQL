CREATE TABLE __WebUserFuncDeactivateW (
  ID int,
  UserName nvarchar(20) COLLATE Latin1_General_CS_AS,
  FuncDeactivateW bit
);

--SELECT WebUser.ID, WebUser.UserName, WebUser.FuncDecAmount
UPDATE WebUser SET /*FuncDecAmount = 0,*/ FuncDeactivateW = 0
OUTPUT inserted.ID, inserted.UserName, deleted.FuncDecAmount
INTO __WebUserFuncDeactivateW
FROM WebUser
JOIN Kunden ON WebUser.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
WHERE Firma.Land = N'AT'
  AND KdGf.KurzBez = N'JOB'
  AND WebUser.Status = N'A'
  AND WebUser.FuncDeactivateW = 1;
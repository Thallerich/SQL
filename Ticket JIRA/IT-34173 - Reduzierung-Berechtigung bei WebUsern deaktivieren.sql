CREATE TABLE __WebUserFuncDecAmount (
  ID int,
  UserName nvarchar(20) COLLATE Latin1_General_CS_AS,
  FuncDecAmount bit
);

--SELECT WebUser.ID, WebUser.UserName, WebUser.FuncDecAmount
UPDATE WebUser SET FuncDecAmount = 0
OUTPUT inserted.ID, inserted.UserName, deleted.FuncDecAmount
INTO __WebUserFuncDecAmount
FROM WebUser
JOIN Kunden ON WebUser.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
WHERE Firma.Land = N'AT'
  AND KdGf.KurzBez = N'JOB'
  AND WebUser.FuncDecAmount = 1;
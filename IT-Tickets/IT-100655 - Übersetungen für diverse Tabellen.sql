SELECT N'FORMULAR' AS TableName, Formular.ID AS TableID, Formular.FormularBez AS [Bezeichnung DE], Formular.FormularBez3 AS [Bezeichnung RO]
FROM Formular
WHERE Formular.Typ = N'RECHKO'

UNION ALL

SELECT N'BRLAUF' AS TableName, BrLauf.ID AS TableID, BrLauf.BrLaufBez AS [Bezeichnung DE], BrLauf.BrLaufBez3 AS [Bezeichnung RO]
FROM BrLauf

UNION ALL

SELECT N'RECHCK' AS TableName, RechChk.ID AS TableID, RechChk.RechChkBez AS [Bezeichnung DE], RechChk.RechChkBez3 AS [Bezeichnung RO]
FROM RechChk

UNION ALL

SELECT N'RKOANLAG' AS TableName, RKoAnlag.ID AS TableID, RKoAnlag.RkoAnlagBez AS [Bezeichnung DE], RKoAnlag.RkoAnlagBez3 AS [Bezeichnung RO]
FROM RKoAnlag

UNION ALL

SELECT N'RKOOUT' AS TableName, RKoOut.ID AS TableID, RKoOut.RkoOutBez AS [Bezeichnung DE], RKoOut.RkoOutBez3 AS [Bezeichnung RO]
FROM RKoOut

UNION ALL

SELECT N'FRACHT' AS TableName, Fracht.ID AS TableID, Fracht.FrachtBez AS [Bezeichnung DE], Fracht.FrachtBez3 AS [Bezeichnung RO]
FROM Fracht

UNION ALL

SELECT N'CO2CFG' AS TableName, CO2Cfg.ID AS TableID, CO2Cfg.CO2CfgBez AS [Bezeichnung DE], CO2Cfg.CO2CfgBez3 AS [Bezeichnung RO]
FROM CO2Cfg;
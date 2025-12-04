SELECT N'FORMULAR' AS TableName, Formular.ID AS TableID, Formular.FormularBez AS [Bezeichnung DE], Formular.FormularBez3 AS [Bezeichnung RO]
FROM Formular
WHERE Formular.Typ = N'RECHKO'

UNION ALL

SELECT N'BRLAUF' AS TableName, BrLauf.ID AS TableID, BrLauf.BrLaufBez AS [Bezeichnung DE], BrLauf.BrLaufBez3 AS [Bezeichnung RO]
FROM BrLauf

UNION ALL

SELECT N'RECHCHK' AS TableName, RechChk.ID AS TableID, RechChk.RechChkBez AS [Bezeichnung DE], RechChk.RechChkBez3 AS [Bezeichnung RO]
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

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT N'VERWEND' AS TableName, Verwend.ID AS TableID, Verwend.VerwendBez AS [Bezeichnung DE], Verwend.VerwendBez3 AS [Bezeichnung RO]
FROM Verwend

UNION ALL

SELECT N'RWCONFIG' AS TableName, RwConfig.ID AS TableID, RwConfig.RwConfigBez AS [Bezeichnung DE], RwConfig.RwConfigBez3 AS [Bezeichnung RO]
FROM RwConfig

UNION ALL

SELECT N'RWLAUF' AS TableName, RwLauf.ID AS TableID, RwLauf.RwLaufBez AS [Bezeichnung DE], RwLauf.RwLaufBez3 AS [Bezeichnung RO]
FROM RwLauf

UNION ALL

SELECT N'FORMULAR' AS TableName, Formular.ID AS TableID, Formular.FormularBez AS [Bezeichnung DE], Formular.FormularBez3 AS [Bezeichnung RO]
FROM Formular
WHERE Formular.Typ = 'LSKO'

UNION ALL

SELECT N'LSBCDET' AS TableName, LsBcDet.ID AS TableID, LsBcDet.LsBcDetBez AS [Bezeichnung DE], LsBcDet.LsBcDetBez3 AS [Bezeichnung RO]
FROM LsBcDet

UNION ALL

SELECT N'EAUSLART' AS TableName, EAuslArt.ID AS TableID, EAuslArt.EAuslArtBez AS [Bezeichnung DE], EAuslArt.EAuslArtBez3 AS [Bezeichnung RO]
FROM EAuslArt

UNION ALL

SELECT N'ORDERBY' AS TableName, OrderBy.ID AS TableID, OrderBy.OrderByBez AS [Bezeichnung DE], OrderBy.OrderByBez3 AS [Bezeichnung RO]
FROM OrderBy
WHERE OrderBy.TableName IN ('LIEFERSCHEIN', 'PACKZETTEL')

UNION ALL

SELECT N'BCLAYOUT' AS TableName, BcLayout.ID AS TableID, BcLayout.BcLayoutBez AS [Bezeichnung DE], BcLayout.BcLayoutBez3 AS [Bezeichnung RO]
FROM BcLayout;
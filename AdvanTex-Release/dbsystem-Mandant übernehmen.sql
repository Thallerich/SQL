INSERT INTO dbSystem.dbo.Mandant (ID, Bez, ConnectPath, TestMandant, Verfuegbar, Anlage_, FertigEingespielt, DataPath, SQLConvertDateFormat, SQLConvertTimeFormat, AnlageUser_, User_)
SELECT ID, Bez, ConnectPath, TestMandant, Verfuegbar, Anlage_, FertigEingespielt, DataPath, SQLConvertDateFormat, SQLConvertTimeFormat, N'THALST' AS AnlageUser_, N'THALST' AS User_
FROM dbsystem_orig.dbo.Mandant;
GO
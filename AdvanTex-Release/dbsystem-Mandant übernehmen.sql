INSERT INTO dbSystem.dbo.Mandant (ID, Bez, ConnectPath, TestMandant, Verfuegbar, Anlage_, FertigEingespielt, DataPath, SQLConvertDateFormat, SQLConvertTimeFormat, AnlageUser_, User_)
SELECT ID, Bez, ConnectPath, TestMandant, Verfuegbar, Anlage_, FertigEingespielt, DataPath, SQLConvertDateFormat, SQLConvertTimeFormat, AnlageUser_, User_
FROM dbSystem_old.dbo.Mandant;

GO
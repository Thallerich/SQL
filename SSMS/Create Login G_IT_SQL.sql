CREATE LOGIN [SAL\G_IT_SQL] FROM WINDOWS;
GO

sp_addsrvrolemember @loginame = [SAL\G_IT_SQL], @rolename = N'sysadmin';
GO
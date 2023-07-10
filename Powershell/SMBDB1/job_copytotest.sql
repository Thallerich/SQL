BACKUP DATABASE salesianer_u4ber
  TO DISK = N'E:\sql_backup\salesianer_u4ber.bak'
  WITH COPY_ONLY, INIT, SKIP, FORMAT, MEDIANAME = N'salesianer_u4ber', NAME = N'salesianer_u4ber for Test';

BACKUP DATABASE salesianer_u4ber_22
  TO DISK = N'E:\sql_backup\salesianer_u4ber_22.bak'
  WITH COPY_ONLY, INIT, SKIP, FORMAT, MEDIANAME = N'salesianer_u4ber', NAME = N'salesianer_u4ber for Test';

RESTORE DATABASE salesianer_u4ber
FROM DISK = N'E:\sql_backup\salesianer_u4ber.bak'
WITH RECOVERY, REPLACE,
  MOVE N'abacus_u4ber' TO N'E:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\_TESZT_salesianer_u4ber.mdf',
  MOVE N'abacus_u4ber_log' TO N'E:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\_TESZT_salesianer_u4ber_log.ldf';

RESTORE DATABASE salesianer_u4ber_22
FROM DISK = N'E:\sql_backup\salesianer_u4ber_22.bak'
WITH RECOVERY, REPLACE,
  MOVE N'abacus_u4ber' TO N'E:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\_TESZT_salesianer_u4ber_22.mdf',
  MOVE N'abacus_u4ber_log' TO N'E:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\_TESZT_salesianer_u4ber_22_log.ldf';
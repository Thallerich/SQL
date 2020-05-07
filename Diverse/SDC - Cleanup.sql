SET NOCOUNT ON;

DECLARE @rows int = 1;
DECLARE @tcpclean int;
DECLARE @prodclean int;

SET @prodclean = (SELECT CAST(Settings.ValueMemo AS int) FROM Settings WHERE Settings.Parameter = N'PRODAFTERDAYS');
SET @tcpclean = (SELECT CAST(Settings.ValueMemo AS int) FROM Settings WHERE Settings.Parameter = N'CLEANUPTCPLOGAFTERDAYS');

WHILE @rows > 0
BEGIN
	BEGIN TRANSACTION;
		DELETE TOP (10000)
		FROM SdcStack
		WHERE ProdID IN (
			SELECT ID
			FROM SdcProd
			WHERE Ready = 1
				AND Update_ < DATEADD(day, @prodclean * -1, GETDATE())
		);

		SET @rows = @@ROWCOUNT;
	COMMIT TRANSACTION;
END;

SET @rows = 1;

WHILE @rows > 0
BEGIN
	BEGIN TRANSACTION;
		DELETE TOP (10000)
		FROM SDCScans
		WHERE ProdID IN (
			SELECT ID
			FROM SdcProd
			WHERE Ready = 1
				AND Update_ < DATEADD(day, @prodclean * -1, GETDATE())
		);

		SET @rows = @@ROWCOUNT;
	COMMIT TRANSACTION;
END;

SET @rows = 1;

WHILE @rows > 0
BEGIN
	BEGIN TRANSACTION;
		DELETE TOP (10000)
		FROM SdcPsPo
		WHERE SdcProdID IN (
			SELECT ID
			FROM SdcProd
			WHERE Ready = 1
				AND Update_ < DATEADD(day, @prodclean * -1, GETDATE())
		);

		SET @rows = @@ROWCOUNT;
	COMMIT TRANSACTION;
END;

SET @rows = 1;

WHILE @rows > 0
BEGIN
	BEGIN TRANSACTION;
		DELETE TOP (10000)
		FROM SdcTausc
		WHERE SdcProdID IN (
			SELECT ID
			FROM SdcProd
			WHERE Ready = 1
				AND Update_ < DATEADD(day, @prodclean * -1, GETDATE())
		);

		SET @rows = @@ROWCOUNT;
	COMMIT TRANSACTION;
END;

SET @rows = 1;

WHILE @rows > 0
BEGIN
	BEGIN TRANSACTION;
		DELETE TOP (10000)
		FROM SdcPsKo
		WHERE Completed = 1
			AND Printed = 1
			AND Update_ < DATEADD(day, @prodclean * -1, GETDATE())
			AND NOT EXISTS (
				SELECT *
				FROM SdcPsPo
				WHERE SdcPsPo.SdcPsKoID = SdcPsKo.ID
			);

		SET @rows = @@ROWCOUNT;
	COMMIT TRANSACTION;
END;

SET @rows = 1;

WHILE @rows > 0
BEGIN
	BEGIN TRANSACTION;
		DELETE TOP (10000)
		FROM SdcProd
		WHERE ID IN (
			SELECT ID
			FROM SdcProd
			WHERE Ready = 1
				AND Update_ < DATEADD(day, @prodclean * -1, GETDATE())
		);

		SET @rows = @@ROWCOUNT;
	COMMIT TRANSACTION;
END;

SET @rows = 1;

WHILE @rows > 0
BEGIN
	BEGIN TRANSACTION;
		DELETE TOP (10000)
		FROM SDCTCPL
		WHERE Stamp < DATEADD(day, @tcpclean * -1, GETDATE());

		SET @rows = @@ROWCOUNT;
	COMMIT TRANSACTION;
END;

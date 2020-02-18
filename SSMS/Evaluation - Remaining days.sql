DECLARE @RemainingTime INT
DECLARE @InstanceName SYSNAME
SELECT @InstanceName = CONVERT(SYSNAME, SERVERPROPERTY('InstanceName'))
EXEC @RemainingTime = xp_qv '2715127595', @InstanceName
SELECT @RemainingTime 'Remaining evaluation days:'

GO
SELECT object_name ,counter_name, FORMAT(ROUND(cntr_value / 1024, 2), '# MB') AS 'Memory MB'
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Target Server Memory (KB)'

UNION ALL

SELECT object_name ,counter_name, FORMAT(ROUND(cntr_value / 1024, 2), '# MB') AS 'Memory MB'
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Total Server Memory (KB)';